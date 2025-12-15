import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { GRAY_COLOR } from '../../theme-chalk/src/color'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestProgressColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestProgress{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 进度值
     */
	@Param @Require value: number = 0
	/**
	 * 目标值
     */
	@Param target: number = 100
	/**
	 * 进度条粗细
     */
	@Param lineWidth: IBestStringNumber = convertDimensionsWidthUnit(4)
	/**
	 * 进度条颜色
     */
	@Param color: ResourceColor = ""
	/**
	 * 进度条渐变色
     */
	@Param linearGradientColor?: LinearGradient = undefined
	/**
	 * 进度条背景色
     */
	@Param bgColor: ResourceColor = IBestProgressColor.bgColor
	/**
	 * 是否显示进度条文字
     */
	@Param showText: boolean = true
	/**
	 * 文字显示在进度条内
     */
	@Param textInside: boolean = false
	/**
	 * 文字颜色
     */
	@Param textColor: ResourceColor = IBestProgressColor.textColor
	/**
	 * 文字大小
     */
	@Param textFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 是否置灰
     */
	@Param inactive: boolean = false
	/**
	 * 不确定进度
     */
	@Param indeterminate: boolean = false
	/**
	 * 不确定进度时动画时长 单位s
     */
	@Param duration: number = 3
	/**
	 * 圆角
	 * @since 1.0.6
	 */
	@Param radius: IBestStringNumber = this.baseStyle.borderRadiusMax as number
	/**
	 * 格式化文本函数
     */
	@Event format?: (value: number) => string = undefined
	/**
	 * 到达目标值
	 */
	@Event onReachTarget: () => void = () => {}
	@Event $value: (value: number) => void = () => {}

	@Local positionX: string = `-${this.value}%`

	@Monitor("value")
	valueChange(){
		let value = this.value
		if(value < 0 || value > this.target){
			value = Math.min(this.target, Math.max(value, 0))
			this.$value(value)
		}
		if(value == this.target){
			this.onReachTarget()
		}
	}
	getColor(){
		return this.inactive ? GRAY_COLOR.GRAY_5 : (this.color || this.baseStyle.primary)
	}
	getTextColor(){
		return this.inactive ? GRAY_COLOR.GRAY_5 : this.textColor
	}
	getText(){
		return this.format ? this.format(this.value) : this.value + "%"
	}
	getWidth(){
		return this.value / this.target * 100 + "%"
	}

	build() {
		Row({space: this.baseStyle.spaceXs}){
			Stack({alignContent: Alignment.Start}){
				Row()
					.width(CONTAINER_SIZE.FULL)
					.height(CONTAINER_SIZE.FULL)
					.backgroundColor(this.bgColor)
				Row(){
					if(this.showText && this.textInside && this.value){
						Text(this.getText())
							.fontSize(getSizeByUnit(this.textFontSize, true))
							.fontColor(IBestProgressColor.whiteColor)
							.margin({right: this.baseStyle.spaceXs})
					}
				}
				.width(this.getWidth())
				.height(CONTAINER_SIZE.FULL)
				.borderRadius(getSizeByUnit(this.radius))
				.linearGradient(this.linearGradientColor)
				.justifyContent(FlexAlign.End)
				.position(this.indeterminate ? {x: this.positionX} : undefined)
				.animation({
					duration: this.indeterminate ? this.duration*1000 : 300,
					iterations: this.indeterminate ? -1 : 1,
					curve: Curve.EaseOut
				})
				.backgroundColor(this.getColor())
				.onAppear(() => {
					if(this.indeterminate){
						this.positionX = "100%"
					}
				})
			}
			.layoutWeight(1)
			.height(getSizeByUnit(this.lineWidth))
			.borderRadius(getSizeByUnit(this.radius))
			.clip(true)
			if(this.showText && !this.textInside){
				Text(this.getText())
					.fontSize(getSizeByUnit(this.textFontSize, true))
					.fontColor(this.getTextColor())
					.constraintSize({minWidth: convertDimensionsWidthUnit(40)})
			}
		}
		.width(CONTAINER_SIZE.FULL)
	}
}