import { IBestStorageKey, IBestStringNumber } from "../../model/Global.type"
import { CONTAINER_SIZE } from "../../theme-chalk/src/container"
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from "../../theme-chalk/src/index.type"
import { convertDimensionsWidthUnit, getSizeByUnit, padZero } from "../../utils/utils"
import { IBestRollingTextColor } from "./color"
import { IBestRollingTextController } from "./index.type"
import { AppStorageV2 } from "@kit.ArkUI"

@ComponentV2
export struct IBestRollingText{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 起始数值
     */
    @Param startNum: number = 0
    /**
     * 目标数值
     */
    @Param targetNum: number = 0
    /**
     * 动画时长，单位ms
     */
    @Param duration: number = 2000
    /**
     * 翻滚方向
     */
    @Param rollingDirection: 'up' | 'down' = 'down'
    /**
     * 是否自动开始翻滚
     */
    @Param autoStart: boolean = true
    /**
     * 自动翻滚延迟时长，单位ms
     */
    @Param delay: number = 500
    /**
     * 停止顺序
     */
    @Param stopOrder: 'ltr' | 'rtl' = 'ltr'
    /**
     * 单个数位宽度
     */
    @Param numWidth: IBestStringNumber = convertDimensionsWidthUnit(15)
    /**
     * 单个数位高度
     */
    @Param numHeight: IBestStringNumber = convertDimensionsWidthUnit(40)
    /**
     * 数字间距
     */
    @Param gap: IBestStringNumber = 0
    /**
     * 文字背景色
     */
    @Param textBgColor: ResourceColor = ''
    /**
     * 文字颜色
     */
    @Param fontColor: ResourceColor = IBestRollingTextColor.textColor
    /**
     * 字体大小
     */
    @Param fontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 单个数位边框圆角
     */
    @Param radius: IBestStringNumber = 0
    /**
     * 控制器
     */
    @Param controller: IBestRollingTextController = new IBestRollingTextController()

    @Local textHeight: number = 0
    @Local isStart: boolean = false
    private circleNum: number = 2

    aboutToAppear() {
        this.controller.start = (): void => this.start()
        this.controller.reset = (): void => this.reset()
    }
    init(){
        if(this.autoStart && !this.isStart){
            setTimeout(() => {
                this.start()
            }, this.delay)
        }
    }
    // 获取数字长度
    getLength(){
        return `${Math.max(this.startNum, this.targetNum!)}`.length
    }
    // 获取目标数字的数组
    getTargetNumArr(){
        return padZero(this.targetNum, this.getLength()).split('')
    }
    // 获取每项数字数组
    getItemArr(index: number)                                                                                                                    {
        const startNumArr = padZero(this.startNum, this.getLength()).split('')
        const targetNumArr = this.getTargetNumArr()
        const result: number[] = []
        for (let i = Number(startNumArr[index]); i <= 9; i++) {
            result.push(i)
        }
        for (let i = 0; i <= this.circleNum; i++) {
            for (let j = 0; j <= 9; j++) {
                result.push(j)
            }
        }
        for (let i = 0; i <= Number(targetNumArr[index]); i++) {
            result.push(i)
        }
        return this.rollingDirection == "down" ? result.reverse() : result
    }
    // 获取延迟
    getDelay(i: number){
        if (this.stopOrder === 'ltr') return 0.2 * i
        return 0.2 * (this.getLength() - 1 - i)
    }
    // 开始
    start(){
        this.isStart = true
    }
    // 重置
    reset(){
        this.isStart = false
        if(this.autoStart){
            setTimeout(() => {
                this.start()
            }, this.delay)
        }
    }
    build() {
        Row({space: getSizeByUnit(this.gap)}){
            ForEach(this.getTargetNumArr(), (_: string, index: number) => {
                IBestRollingTextItem({
                    itemArr: this.getItemArr(index),
                    delay: this.getDelay(index),
                    textHeight: this.textHeight,
                    isStart: this.isStart,
                    numWidth: this.numWidth,
                    numHeight: this.numHeight,
                    rollingDirection: this.rollingDirection,
                    duration: this.duration,
                    textBgColor: this.textBgColor,
                    fontColor: this.fontColor,
                    fontSize: this.fontSize,
                    radius: this.radius
                })
            })
        }
        .height(getSizeByUnit(this.numHeight))
        .onAreaChange((_, newVal) => {
            this.textHeight = newVal.height as number
            this.init()
        })
    }
}

@ComponentV2
struct IBestRollingTextItem{
    @Param @Require itemArr: number[]
    @Param @Require delay: number
    @Param @Require textHeight: number
    @Param @Require isStart: boolean
    @Param @Require numWidth: IBestStringNumber
    @Param @Require numHeight: IBestStringNumber
    @Param @Require rollingDirection: 'up' | 'down'
    @Param @Require duration: number
    @Param @Require textBgColor: ResourceColor
    @Param @Require fontColor: ResourceColor
    @Param @Require fontSize: IBestStringNumber
    @Param @Require radius: IBestStringNumber
    @Local transY: number = 0
    private uiContext = this.getUIContext()

    @Monitor("isStart")
    start(){
        if(this.isStart) {
            this.uiContext.animateTo({
                duration: this.duration,
                delay: this.delay * 1000,
                curve: Curve.EaseInOut
            }, () => {
                this.transY = this.rollingDirection == 'down' ? 0 : -this.getTranslateY()
            })
        }else if(this.rollingDirection == 'down'){
            this.transY = -this.getTranslateY()
        }else {
            this.transY = 0
        }
    }
    @Monitor("textHeight")
    textHeightChange(){
        if(this.rollingDirection == 'down'){
            this.transY = -this.getTranslateY()
        }
    }
    // 获取总偏移量
    getTranslateY(){
        return this.textHeight * (this.itemArr.length - 1)
    }
    build() {
        Row(){
            Column(){
                ForEach(this.itemArr, (item: number) => {
                    Row(){
                        Text(item.toString())
                            .fontColor(this.fontColor)
                            .fontSize(getSizeByUnit(this.fontSize, true))
                    }
                    .width(CONTAINER_SIZE.FULL)
                    .height(getSizeByUnit(this.numHeight))
                    .justifyContent(FlexAlign.Center)
                })
            }
            .translate({y: this.transY})
        }
        .width(getSizeByUnit(this.numWidth))
        .height(CONTAINER_SIZE.FULL)
        .backgroundColor(this.textBgColor)
        .borderRadius(getSizeByUnit(this.radius))
        .clip(true)
    }
}