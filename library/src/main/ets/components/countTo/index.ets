import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestCountToColor } from './color'
import { IBestCountToController } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'

@ComponentV2
export struct IBestCountTo{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 开始值
     */
    @Param start: number = 0
    /**
     * 结束值
     */
    @Param end: number = 0
    /**
     * 持续时间，单位毫秒
     */
    @Param duration: number = 2000
    /**
     * 是否自动开始滚动
     */
    @Param autoPlay: boolean = true
    /**
     * 小数位数
     */
    @Param decimals: number = 0
    /**
     * 结尾使用缓动
     */
    @Param useEasing: boolean = true
    /**
     * 千位分隔符
     */
    @Param separator: ResourceStr = ''
    /**
     * 字体大小
     */
    @Param fontSize: IBestStringNumber = convertDimensionsWidthUnit(30, true)
    /**
     * 字体色
     */
    @Param color: ResourceColor = IBestCountToColor.textColor
    /**
     * 字重
     */
    @Param fontWeight: FontWeight = FontWeight.Normal
    /**
     * 实例
     */
    @Param controller: IBestCountToController = new IBestCountToController()
	/**
	 * 结束事件
	 * @since 0.0.8
	 */
	@Event onFinish: () => void = () => {}

    @Local formatVal: string = ''
    current: number = 0
    interval: number = 16
    timer: number = 0
    localStartVal: number = this.start
    localDuration: number = this.duration
    startTime: number = 0
    remaining: number = 0

    aboutToAppear(): void {
        this.controller.start = (): void => this.startCountDown()
        this.controller.pause = (): void => this.clearTimer()
        this.controller.reStart = (): void => this.reStart()
        this.controller.reset = (): void => this.reset()
        this.reset()
        this.autoPlay && this.startCountDown()
    }
    aboutToDisappear(): void {
        this.clearTimer()
    }
    // 开始滚动
    @Monitor("start", "end")
    startCountDown(){
        this.startTime = 0
        this.localDuration = this.duration
        this.localStartVal = this.start
        this.countTo()
    }
    // 暂定状态，重新再开始滚动；或者滚动状态下，暂停
    reStart() {
        this.startTime = 0
        this.localDuration = this.remaining
        this.localStartVal = this.current
        this.countTo()
    }
    // 暂停滚动
    clearTimer(){
        clearTimeout(this.timer)
        this.timer = 0
    }
    // 重置滚动
    reset(){
        this.startTime = 0
        this.clearTimer()
        this.formatVal = this.format(this.start)
    }
    // 滚动
    countTo(){
        this.clearTimer()
        this.timer = setTimeout(() => {
			let timestamp = Date.now() + this.interval
			if (!this.startTime) this.startTime = timestamp
			const progress = timestamp - this.startTime
			this.remaining = this.localDuration - progress
			if (this.useEasing) {
				this.current = this.easingFn(progress, this.localStartVal, this.end - this.localStartVal, this.localDuration)
			} else {
				this.current = this.localStartVal + (this.end - this.localStartVal) * (progress / this.localDuration)
			}
			this.current = Math.min(this.end, this.current)
			this.formatVal = this.format(this.current)
			if (progress < this.localDuration) {
				this.countTo()
			}else {
				this.onFinish()
			}
        }, this.interval)
    }
    // 缓动函数
    easingFn(t: number, b: number, c: number, d: number) {
        return (c * (-Math.pow(2, (-10 * t) / d) + 1) * 1024) / 1023 + b;
    }
    // 格式化
    format(num: number){
        const arr = num.toFixed(this.decimals).split(".")
        let x1 = arr[0]
        const x2 = arr.length > 1 ? "." + arr[1] : ""
        const rgx = /(\d+)(\d{3})/
        if (this.separator) {
            while (rgx.test(x1)) {
                x1 = x1.replace(rgx, "$1" + this.separator + "$2")
            }
        }
        return x1 + x2
    }
    build() {
        Text(this.formatVal)
            .fontColor(this.color)
            .fontSize(getSizeByUnit(this.fontSize, true))
            .fontWeight(this.fontWeight)
    }
}