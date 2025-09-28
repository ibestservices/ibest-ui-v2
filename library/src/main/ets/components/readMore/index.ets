import { IBestIcon } from "../../../../../Index"
import { IBestAwaitable, IBestBaseDataType, IBestStorageKey, IBestStringNumber } from "../../model/Global.type"
import { getDefaultBaseStyle } from "../../theme-chalk/src"
import { CONTAINER_SIZE } from "../../theme-chalk/src/container"
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from "../../theme-chalk/src/index.type"
import { convertDimensionsWidthUnit, getComponentsInfo, getSizeByUnit, handleBeforeFunction } from "../../utils/utils"
import { AppStorageV2 } from "@kit.ArkUI"

@ComponentV2
export struct IBestReadMore{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Local colorMode: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.COLOR_MODE)!
    /**
     * 展开状态
     */
    @Param @Require value: boolean
    /**
     * 展开操作文案
     */
    @Param expandText: ResourceStr = $r("app.string.ibest_text_expand")
    /**
     * 收起操作文案
     */
    @Param collapseText: ResourceStr = $r("app.string.ibest_text_collapse")
    /**
     * 展开时显示的图标
     */
    @Param expandIcon: ResourceStr = 'arrow-down'
    /**
     * 收起时显示的图标
     */
    @Param collapseIcon: ResourceStr = 'arrow-up'
    /**
     * 操作文字颜色
     */
    @Param actionColor: ResourceColor = this.baseStyle.primary
    /**
     * 文字大小
     */
    @Param actionFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 收起高度
     */
    @Param collapseHeight: IBestStringNumber = convertDimensionsWidthUnit(50)
    /**
     * 动画时长, 单位ms
     */
    @Param duration: number = 200
    /**
     * 置灰
     */
    @Param inactive: boolean = false
    /**
     * 是否为一次性展开, 即展开后不再显示收起
     */
    @Param once: boolean = false
    /**
     * 展开前回调
     */
    @Event beforeExpand?: () => IBestAwaitable = undefined
    /**
     * 默认内容
     */
    @BuilderParam defaultBuilder: CustomBuilder
    /**
     * 切换回调
     */
    @Event toggle: (value: boolean) => void = () => {}
    @Event $value: (value: boolean) => void = () => {}

    @Local contentHeight: number = 0
    @Local uniId: number = 0
    @Local isReady: boolean = false
    @Local isShow: boolean = false
    private context: UIContext = this.getUIContext()

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
        setTimeout(() => {
            this.getContentHeight()
        }, 50)
    }
    // 获取高度
    getContentHeight(){
        let info = getComponentsInfo(this.context, `ibest_readmore_${this.uniId}`)
        this.contentHeight = info.height
        if(!this.isShow){
            this.isReady = true
            setTimeout(() => {
                this.isShow = true
            }, 50)
        }
    }
    // 切换
    async changeExpand(){
        let status = await handleBeforeFunction(this.beforeExpand)
        if(!status){
            return
        }
        let value = !this.value
        this.$value(value)
        this.toggle(value)
    }

    build() {
        Column(){
            Column(){
                Column(){
                    if(this.defaultBuilder){
                        this.defaultBuilder()
                    }
                }
                .width(CONTAINER_SIZE.FULL)
                .alignItems(HorizontalAlign.Start)
                Row()
                    .width(CONTAINER_SIZE.FULL)
                    .height(convertDimensionsWidthUnit(50))
                    .position({left: 0, bottom: 0})
                    .opacity(this.value ? 0 : 1)
                    .animation({
                        duration: this.isShow ? this.duration : 0
                    })
                    .linearGradient({
                        direction: GradientDirection.Top,
                        colors: this.colorMode.value == 0 ? [["#000", 0], ["rgba(0,0,0,0)", 1]] : [["#fff", 0], ["rgba(255, 255, 255, 0)", 1]]
                    })
            }
            .width(CONTAINER_SIZE.FULL)
            .height(this.isReady ? this.value ? this.contentHeight : getSizeByUnit(this.collapseHeight) : "auto")
            .id(`ibest_readmore_${this.uniId}`)
            .clip(true)
            .animation({
                duration: this.isShow ? this.duration : 0
            })
            if(!(this.value && this.once)){
                Row({space: this.baseStyle.spaceX}){
                    Text(this.value ? this.collapseText : this.expandText)
                        .fontColor(this.actionColor)
                        .fontSize(this.actionFontSize)
                    IBestIcon({
                        name: this.value ? this.collapseIcon : this.expandIcon,
                        color: this.actionColor,
                        iconSize: this.actionFontSize
                    })
                }
                .width(CONTAINER_SIZE.FULL)
                .justifyContent(FlexAlign.Center)
                .margin({ top: this.baseStyle.spaceXs })
                .opacity(this.inactive ? 0.5 : 1)
                .onClick(() => {
                    this.changeExpand()
                })
            }
        }
    }
}