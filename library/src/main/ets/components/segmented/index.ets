import { IBestAwaitable, IBestStorageKey, IBestStringNumber } from "../../model/Global.type"
import { CONTAINER_SIZE } from "../../theme-chalk/src/container"
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from "../../theme-chalk/src/index.type"
import { convertDimensionsWidthUnit, getComponentsInfo, getSizeByUnit, handleBeforeFunction } from "../../utils/utils"
import { IBestSegmentedColor } from "./color"
import { IBestSegmentedItem, IBestSegmentedOption } from "./index.type"
import { AppStorageV2 } from "@kit.ArkUI"
import { IBestIcon } from "../icon"

@ComponentV2
export struct IBestSegmented{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 当前选中的值
     */
    @Param @Require value: IBestStringNumber
    /**
     * 选项列表
     */
    @Param @Require options: (IBestStringNumber | IBestSegmentedItem)[]
    /**
     * 宽度类型
     */
    @Param widthType: 'auto' | 'flex' = 'flex'
    /**
     * 高度
     */
    @Param contentHeight: IBestStringNumber = convertDimensionsWidthUnit(34)
    /**
     * 内边距
     */
    @Param contentPadding: Length | Padding | LocalizedPadding = convertDimensionsWidthUnit(4)
    /**
     * 是否为圆形
     */
    @Param round: boolean = false
    /**
     * 圆角, 仅round为false时生效
     */
    @Param radius: Length | BorderRadiuses | LocalizedBorderRadiuses = convertDimensionsWidthUnit(2)
    /**
     * 单个选项内边距
     */
    @Param itemPadding: Length | Padding | LocalizedPadding = { left: this.baseStyle.spaceXsm, right: this.baseStyle.spaceXsm }
    /**
     * 背景色
     */
    @Param bgColor: ResourceColor = IBestSegmentedColor.bgColor
    /**
     * 选中背景颜色
     */
    @Param activeBgColor: ResourceColor = ""
    /**
     * 未选中文字颜色
     */
    @Param inactiveTextColor: ResourceColor = IBestSegmentedColor.inactiveTextColor
    /**
     * 选中文字颜色
     */
    @Param activeTextColor: ResourceColor = IBestSegmentedColor.activeTextColor
    /**
     * 字体大小
     */
    @Param fontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 色块是否显示阴影
     */
    @Param activeShadow: ShadowOptions | ShadowStyle = { radius: 4, color: "#333", offsetY: 2 }
    /**
     * 切换前回调
     */
    @Event beforeChange?: (value: IBestStringNumber) => IBestAwaitable = undefined
    /**
     * 选项点击回调
     */
    @Event onOptionClick: (value: IBestStringNumber) => void = () => {}
    /**
     * 切换回调
     */
    @Event onChange: (value: IBestStringNumber) => void = () => {}
    @Event $value: (value: IBestStringNumber) => void = () => {}

    @Local uniId: number = 0
    @Local isReady: boolean = false
    @Local contentWidth: number = 0
    @Local widthList: number[] = []
    @Local translateXList: number[] = []
    private context: UIContext = this.getUIContext()
    private scroller: Scroller = new Scroller()

    @Builder iconBuilder(item: IBestSegmentedItem, index: number){
        IBestIcon({
            name: item.icon,
            iconSize: this.fontSize,
            color: this.getColor(index),
            iconAnimation: {
                duration: this.isReady ? 300 : 0,
                curve: "cubic-bezier(0.645,0.045,0.355,1)"
            }
        })
    }
    @Builder contentBuilder(showId: boolean = false){
        Stack({alignContent: Alignment.BottomStart}){
            if(this.activeIndex > -1 && this.activeIndex < this.options.length){
                Row()
                    .height(CONTAINER_SIZE.FULL)
                    .backgroundColor(this.activeBgColor || this.baseStyle.primary)
                    .borderRadius(this.getRadius())
                    .shadow(this.activeShadow)
                    .translate({ x: this.translateXList[this.activeIndex] })
                    .width(this.widthList[this.activeIndex])
                    .animation({
                        duration: this.isReady ? this.baseStyle.animationDuration as number : 0,
                        curve: "cubic-bezier(0.645,0.045,0.355,1)"
                    })
            }
            Row(){
                ForEach(this.options, (item: IBestStringNumber | IBestSegmentedItem, index: number) => {
                    Row({space: this.baseStyle.spaceX}){
                        if(typeof item === "object" && item.icon && (!item.iconPosition || item.iconPosition == "left")){
                            this.iconBuilder(item, index)
                        }
                        if(typeof item === "string" || typeof item === "object" && item.label){
                            Text(typeof item === "object" ? item.label : item.toString())
                                .constraintSize({maxWidth: CONTAINER_SIZE.FULL})
                                .fontSize(getSizeByUnit(this.fontSize, true))
                                .fontColor(this.getColor(index))
                                .maxLines(1)
                                .textOverflow({overflow: TextOverflow.Ellipsis})
                                .animation({
                                    duration: this.isReady ? 300 : 0,
                                    curve: "cubic-bezier(0.645,0.045,0.355,1)"
                                })
                        }
                        if(typeof item === "object" && item.icon && item.iconPosition == "right"){
                            this.iconBuilder(item, index)
                        }
                    }
                    .layoutWeight(this.widthType == "flex" ? 1 : undefined)
                    .height(CONTAINER_SIZE.FULL)
                    .padding(getSizeByUnit(this.itemPadding))
                    .justifyContent(FlexAlign.Center)
                    .borderRadius(this.getRadius())
                    .enabled(typeof item === "object" ? !item.disabled : true)
                    .opacity(typeof item === "object" && item.disabled ? 0.6 : 1)
                    .id(`ibest_segmented_option_${this.uniId}_${index}`)
                    .onClick(() => {
                        this.selectItem(item)
                    })
                })
            }
            .width(this.widthType == "flex" ? CONTAINER_SIZE.FULL : "")
            .borderRadius(this.getRadius())
        }
        .id(showId ? `ibest_segmented_${this.uniId}` : "")
    }

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
    }
    onDidBuild() {
        this.init()
    }
    init() {
        if(this.options.length){
            setTimeout(() => {
                this.getWidth()
                this.scrollCenter()
                setTimeout(() => {
                    this.isReady = true
                }, 50)
            }, 50)
        }
    }
    @Monitor("options", "options.length")
    optionsChange(){
        this.init()
    }
    getWidth(){
        let tabWidthList: number[] = []
        let translateXList: number[] = []
        let contentInfo = getComponentsInfo(this.context, `ibest_segmented_${this.uniId}`)
        this.options.forEach((_: IBestStringNumber | IBestSegmentedOption, index: number) => {
            let boxInfo = getComponentsInfo(this.context, `ibest_segmented_option_${this.uniId}_${index}`)
            tabWidthList.push(boxInfo.width)
            translateXList.push(boxInfo.localLeft)
        })
        this.widthList = tabWidthList
        this.contentWidth = contentInfo.width
        this.translateXList = translateXList
    }
    @Computed
    get activeIndex(){
        return this.options.findIndex((item: IBestStringNumber | IBestSegmentedOption) => {
            if(typeof item === "object"){
                return item.value === this.value
            }else {
                return item === this.value
            }
        })
    }
    getColor(index: number){
        return index == this.activeIndex ? this.activeTextColor : this.inactiveTextColor
    }
    getRadius(){
        return this.round ? this.baseStyle.borderRadiusMax : getSizeByUnit(this.radius)
    }
    async selectItem(item: IBestStringNumber | IBestSegmentedItem){
        let value = typeof item === "object" ? item.value : item
        this.onOptionClick(value)
        if(value === this.value){
            return
        }
        let status = await handleBeforeFunction(this.beforeChange, value)
        if(!status){
            return
        }
        this.$value(value)
        this.onChange(value)
        this.scrollCenter()
    }
    scrollCenter(animate: boolean = true){
        if(this.widthType == "auto"){
            this.scroller.scrollTo({
                xOffset: this.translateXList[this.activeIndex] - this.contentWidth/2 + this.widthList[this.activeIndex]/2,
                yOffset: 0,
                animation: animate ? {
                    duration: animate ? 100 : 0,
                    curve: Curve.FastOutSlowIn
                } : false
            })
        }
    }

    build() {
        Row(){
            if(this.widthType == "auto"){
                Scroll(this.scroller){
                    this.contentBuilder()
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .align(Alignment.Start)
                .clip(false)
                .id(`ibest_segmented_${this.uniId}`)
            }else{
                this.contentBuilder(true)
            }
        }
        .width(this.widthType == "flex" ? CONTAINER_SIZE.FULL : "")
        .height(getSizeByUnit(this.contentHeight))
        .padding(getSizeByUnit(this.contentPadding))
        .borderRadius(this.getRadius())
        .backgroundColor(this.bgColor)
        .opacity(this.options.length ? 1 : 0)
        .animation({duration: this.baseStyle.animationDuration as number})
        .clip(true)
        .onAreaChange(() => {
            this.init()
        })
    }
}