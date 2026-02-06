import { IBestStorageKey, IBestStringNumber } from "../../model/Global.type"
import { CONTAINER_SIZE } from "../../theme-chalk/src/container"
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from "../../theme-chalk/src/index.type"
import { addNumber, convertDimensionsWidthUnit, getSizeByUnit, measureTextSize } from "../../utils/utils"
import { IBestCaliperColor } from "./color"
import { IBestCaliperScale } from "./index.type"
import { AppStorageV2 } from "@kit.ArkUI"

@ComponentV2
export struct IBestCaliper{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 绑定值
     */
    @Param @Require value: number
    /**
     * 大刻度之间分为几个小刻度
     */
    @Param scales: number = 10
    /**
     * 每个小刻度代表数值
     */
    @Param scaleSize: number = 1
    /**
     * 开始刻度值
     */
    @Param startNum: number = 0
    /**
     * 结束刻度值
     */
    @Param endNum: number = 100
    /**
     * 背景色
     */
    @Param bgColor: ResourceColor = ''
    /**
     * 刻度线颜色
     */
    @Param scaleColor: ResourceColor = IBestCaliperColor.scaleColor
    /**
     * 选中刻度线颜色
     */
    @Param activeScaleColor: ResourceColor = ''
    /**
     * 刻度对齐方式
     */
    @Param scaleAlign: "top" | "center" | "bottom" = "top"
    /**
     * 字体大小
     */
    @Param fontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 字体颜色
     */
    @Param fontColor: ResourceColor = ''
    /**
     * 大刻度宽度
     */
    @Param bigScaleWidth: IBestStringNumber = 1
    /**
     * 大刻度高度
     */
    @Param bigScaleHeight: IBestStringNumber = convertDimensionsWidthUnit(30)
    /**
     * 小刻度宽度
     */
    @Param smallScaleWidth: IBestStringNumber = 1
    /**
     * 小刻度高度
     */
    @Param smallScaleHeight: IBestStringNumber = convertDimensionsWidthUnit(20)
    /**
     * 选中刻度宽度
     */
    @Param activeScaleWidth: IBestStringNumber = 3
    /**
     * 选中刻度文字字重
     */
    @Param activeFontWeight: IBestStringNumber | FontWeight = FontWeight.Normal
    /**
     * 刻度间距
     */
    @Param scaleSpace: IBestStringNumber = convertDimensionsWidthUnit(10)
    /**
     * 刻度变化回调
     */
    @Event onChange: (value: number) => void = () => {}
    @Event $value: (value: number) => void = () => {}

    @Local realActiveWidth: number = 0
    @Local scaleList: IBestCaliperScale[] = []
    private uiContext = this.getUIContext()
    private listScroller: ListScroller = new ListScroller()
    private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right })
    private flag: boolean = false

    aboutToAppear(): void {
        this.initScaleList()
    }
    // 初始化刻度列表
    initScaleList(){
        let list: IBestCaliperScale[] = []
        const scaleSize = this.scales * this.scaleSize
        for (let i = this.startNum; i <= this.endNum; i = addNumber(i, this.scaleSize)) {
            list.push({
                value: i,
                isBig: i % scaleSize === 0
            })
        }
        this.scaleList = list
        if(this.value != this.startNum){
            setTimeout(() => {
                this.updateIndex()
            })
        }
    }
    @Monitor("value")
    valueChange(){
        if(!this.flag){
            this.updateIndex()
        }
    }
    getFontHeight() {
        return measureTextSize(this.uiContext, {
            textContent: "0",
            fontSize: this.fontSize
        }).height
    }
    updateIndex() {
        let index = this.scaleList.findIndex(item => item.value === this.value)
        if(index > -1){
            this.listScroller.scrollToIndex(index, true, ScrollAlign.CENTER)
        }
    }
    onScroll(index: number){
        if(this.flag){
            const i = index < 0 ? 0 : index > this.scaleList.length - 1 ? this.scaleList.length - 1 : index
            this.$value(this.scaleList[i].value)
        }
    }

    build() {
        List({ space: getSizeByUnit(this.scaleSpace), scroller: this.listScroller }) {
            ListItem()
                .width(getSizeByUnit(this.activeScaleWidth))
                .height(1)
                .position({left: 0, top: 0})
                .opacity(0)
                .zIndex(-1)
                .onAreaChange((_, newVal) => {
                    this.realActiveWidth = newVal.width as number
                })
            Repeat<IBestCaliperScale>(this.scaleList).each((obj: RepeatItem<IBestCaliperScale>) => {
                ListItem(){
                    Row(){
                        Row()
                            .width(getSizeByUnit(this.value === obj.item.value ? this.activeScaleWidth : obj.item.isBig ? this.bigScaleWidth : this.smallScaleWidth))
                            .height(getSizeByUnit(obj.item.isBig ? this.bigScaleHeight : this.smallScaleHeight))
                            .backgroundColor(this.value === obj.item.value ? this.activeScaleColor || this.baseStyle.primary : this.scaleColor)
                            .borderRadius(this.value === obj.item.value ? this.baseStyle.borderRadiusMax : 0)
                        if(obj.item.isBig){
                            Text(obj.item.value.toString())
                                .fontColor(this.fontColor || this.baseStyle.primary)
                                .fontSize(getSizeByUnit(this.fontSize, true))
                                .fontWeight(this.value === obj.item.value ? this.activeFontWeight : "")
                                .position({left: this.value === obj.item.value ? this.realActiveWidth / 2 : 0, bottom: -5})
                                .translate({x: "-50%", y: CONTAINER_SIZE.FULL})
                        }
                    }
                    .padding({bottom: this.getFontHeight() + 5})
                }
            })
            .key((item: IBestCaliperScale) => item.value.toString())
            .virtualScroll({
                onTotalCount: () => { return this.scaleList.length }
            })
        }
        .width(CONTAINER_SIZE.FULL)
        .backgroundColor(this.bgColor)
        .scrollBar(BarState.Off)
        .chainAnimation(true)
        .edgeEffect(EdgeEffect.None)
        .listDirection(Axis.Horizontal)
        .scrollSnapAlign(ScrollSnapAlign.CENTER)
        // api22 更新
        // .scrollSnapAnimationSpeed(ScrollSnapAnimationSpeed.SLOW)
        .onScrollIndex((_start: number, _: number, centerIndex: number) => {
            this.onScroll(centerIndex)
        })
        .onScrollStop(() => {
            this.flag = false
        })
        .parallelGesture(
            PanGesture(this.panOption)
                .onActionUpdate(() => {
                    this.flag = true
                })
        )
    }
}