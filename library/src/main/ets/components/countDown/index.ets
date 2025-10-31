import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { getSizeByUnit, padZero } from '../../utils/utils'
import { IBestCountDownColor } from './color'
import { CurrentTime, IBestCountDownController } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'

const SECOND = 1000
const MINUTE = 60 * SECOND
const HOUR = 60 * MINUTE
const DAY = 24 * HOUR

function parseTime(time: number): CurrentTime {
	const days = Math.floor(time / DAY)
	const hours = Math.floor((time % DAY) / HOUR)
	const minutes = Math.floor((time % HOUR) / MINUTE)
	const seconds = Math.floor((time % MINUTE) / SECOND)
	const milliseconds = Math.floor(time % SECOND)

	return {
		total: time,
		days,
		hours,
		minutes,
		seconds,
		milliseconds,
	}
}

@ComponentV2
export struct IBestCountDown{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 倒计时时长 单位毫秒
     */
	@Param time: number = 0
	/**
	 * 文字颜色
     */
	@Param color: ResourceColor = IBestCountDownColor.textColor
	/**
	 * 文字大小
     */
	@Param fontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 时间格式
     */
	@Param format: string = 'HH:mm:ss'
	/**
	 * 是否自动开始倒计时
     */
	@Param autoStart: boolean = true
	/**
	 * 控制器
     */
	@Param controller: IBestCountDownController = new IBestCountDownController()
	/**
	 * 结束事件
	 * @since 0.0.8
	 */
	@Event onFinish: () => void = () => {}

	@Local isCounting: boolean = false
	@Local remain: number = 0
	private endTime: number = 0
	private timer: number = 0

	aboutToAppear(): void {
		this.controller.start = (): void => this.startCountDown()
		this.controller.pause = (): void => this.pause()
		this.controller.reset = (totalTime?: number): void => this.reset(totalTime)
		this.remain = this.time
		if(this.autoStart){
			this.startCountDown()
		}
	}
	aboutToDisappear(): void {
		this.clearTimer()
	}
	startCountDown(){
		if(!this.isCounting){
			this.endTime = Date.now() + this.remain
			this.secondCountdown()
			this.isCounting = true
		}
	}
	pause(){
		this.isCounting = false
	}
	reset(totalTime: number = this.time){
		this.pause()
		this.remain = totalTime
	}
	getTimeText(){
		return this.parseFormat(this.format, parseTime(this.remain))
	}
	secondCountdown(){
		this.clearTimer()
		this.timer = setTimeout(() => {
			if(this.isCounting){
				this.remain = this.getRemainSecond()
				if(this.remain > 0){
					this.secondCountdown()
				}else {
					this.onFinish()
				}
			}
		}, 30)
	}
	clearTimer(){
		clearTimeout(this.timer)
		this.timer = 0
	}
	getRemainSecond(){
		return Math.max(this.endTime - Date.now(), 0)
	}
	parseFormat(format: string, currentTime: CurrentTime): string {
		let days = currentTime.days,
			hours = currentTime.hours,
			minutes = currentTime.minutes,
			seconds = currentTime.seconds,
			milliseconds = currentTime.milliseconds
		if (format.includes('DD')) {
			format = format.replace('DD', padZero(currentTime.days))
		} else {
			hours += days * 24
		}

		if (format.includes('HH')) {
			format = format.replace('HH', padZero(hours))
		} else {
			minutes += hours * 60
		}

		if (format.includes('mm')) {
			format = format.replace('mm', padZero(minutes))
		} else {
			seconds += minutes * 60
		}

		if (format.includes('ss')) {
			format = format.replace('ss', padZero(seconds))
		} else {
			milliseconds += seconds * 1000
		}

		if (format.includes('S')) {
			const ms = padZero(milliseconds, 3)

			if (format.includes('SSS')) {
				format = format.replace('SSS', ms)
			} else if (format.includes('SS')) {
				format = format.replace('SS', ms.slice(0, 2))
			} else {
				format = format.replace('S', ms.charAt(0))
			}
		}

		return format
	}

	build() {
		Text(this.getTimeText())
			.fontColor(this.color)
			.fontSize(getSizeByUnit(this.fontSize, true))
	}
}