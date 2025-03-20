import { COLOR_TYPE, ColorType } from '../../theme-chalk/src/color.type'
import { GRAY_COLOR } from '../../theme-chalk/src/color'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { SIZE, SizeType } from '../../theme-chalk/src/size.type'
import { BtnSizeType } from './index.type'
import { IBestLoading } from '../loading/index'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestButtonColor } from './color'
import { IBestIcon } from '../icon'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestButton {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 类型，可选值为 primary success warning danger 默认值为default
	 */
	@Param type: ColorType = COLOR_TYPE.DEFAULT
	/**
	 * 大小，可选值为 large normal small mini
	 */
	@Param buttonSize: SizeType = SIZE.NORMAL
	/**
	 * 是否为朴素按钮
	 */
	@Param plain: boolean = false
	/**
	 * 是否为方形按钮
	 */
	@Param square: boolean = false
	/**
	 * 是否为圆形按钮
	 */
	@Param round: boolean = false
	/**
	 * 是否使用 0.5px 边框
	 */
	@Param hairline: boolean = false
	/**
	 * 是否显示为加载状态
	 */
	@Param loading: boolean = false
	/**
	 * loading加载的文案
	 */
	@Param loadingText: ResourceStr = ""
	/**
	 * 按钮展示的文字
	 */
	@Param text: ResourceStr = ""
	/**
	 * 是否禁用
	 */
	@Param disabled: boolean = false
	/**
	 * 按钮颜色
	 */
	@Param color: ResourceColor = ""
	/**
	 * 加载图标的大小, 如果为-1就是默认值 默认值跟随字体大小
	 */
	@Param loadingSize: IBestStringNumber = -1
	/**
	 * 按钮宽度
	 */
	@Param btnWidth: IBestStringNumber = ""
	/**
	 * 按钮高度
	 */
	@Param btnHeight: IBestStringNumber = ""
	/**
	 * 按钮文字大小
	 */
	@Param btnFontSize: IBestStringNumber = ""
	/**
	 * 按钮图标
	 */
	@Param icon: ResourceStr = ""
	/**
	 * 按钮文字颜色
	 */
	@Param fontColor: ResourceColor = ""
	/**
	 * 按钮边框颜色
	 */
	@Param btnBorderColor: ResourceColor = ""
	/**
	 * 按钮圆角
	 */
	@Param btnBorderRadius: IBestStringNumber = ""
	/**
	 * 图标位置
     */
	@Param iconPosition: 'left' | 'right' | 'top' | 'bottom' = 'left'
	/**
	 * 文字与图标间距
     */
	@Param space: IBestStringNumber = this.baseStyle.spaceBase as string
	/**
	 * 默认插槽
	 */
	@BuilderParam defaultBuilder: CustomBuilder
	/**
	 * 图标的builder
	 */
	@BuilderParam iconBuilder: CustomBuilder
	/**
	 * 加载图标的builder
	 */
	@BuilderParam loadingIconBuilder: CustomBuilder
	/**
	 * 点击按钮，且按钮状态不为加载或禁用时触发
	 */
	@Event onBtnClick: () => void = () => {}

	@Builder iconContent() {
		if (this.loading) {
			// 如果有自定义loading
			if (this.loadingIconBuilder) {
				this.loadingIconBuilder()
			} else {
				// 默认的loading
				IBestLoading({
					loadingSize: this.computedLoadingSize,
					loadingColor: this.computedTextColor
				}).margin({
					left: this.iconPosition == "right" && (this.text || this.loadingText) ? getSizeByUnit(this.space) : 0,
					right: this.iconPosition == "left" && (this.text || this.loadingText) ? getSizeByUnit(this.space) : 0,
					bottom: this.iconPosition == "top" && (this.text || this.loadingText) ? getSizeByUnit(this.space) : 0,
					top: this.iconPosition == "bottom" && (this.text || this.loadingText) ? getSizeByUnit(this.space) : 0
				})
			}
		} else if (this.iconBuilder) {
			this.iconBuilder()
		} else if (this.icon) {
			IBestIcon({
				name: this.icon,
				iconSize: this.computedBtnSize.fontSize,
				color: this.computedTextColor
			}).margin({
				left: this.iconPosition == "right" && (this.text || this.loadingText) ? getSizeByUnit(this.space) : 0,
				right: this.iconPosition == "left" && (this.text || this.loadingText) ? getSizeByUnit(this.space) : 0,
				bottom: this.iconPosition == "top" && (this.text || this.loadingText) ? getSizeByUnit(this.space) : 0,
				top: this.iconPosition == "bottom" && (this.text || this.loadingText) ? getSizeByUnit(this.space) : 0
			})
		}
	}
	/**
	 * 根据buttonSize换对应的按钮尺寸
	 */
	@Computed
	get computedBtnSize(): BtnSizeType {
		if (this.btnWidth || this.btnHeight) {
			return {
				width: this.btnWidth || "auto",
				height: this.btnHeight || convertDimensionsWidthUnit(44),
				padding: convertDimensionsWidthUnit(15),
				fontSize: this.btnFontSize || this.baseStyle.fontSizeMd as string
			}
		}
		const buttonSize = this.buttonSize
		switch (buttonSize) {
			case SIZE.MINI:
				return {
					width: "auto",
					height: convertDimensionsWidthUnit(24),
					padding: this.baseStyle.spaceBase as string,
					fontSize: this.btnFontSize || this.baseStyle.fontSizeXs as string
				}
			case SIZE.SMALL:
				return {
					width: "auto",
					height: convertDimensionsWidthUnit(32),
					padding: this.baseStyle.spaceXs as string,
					fontSize: this.btnFontSize || this.baseStyle.fontSizeSm as string
				}
			case SIZE.LARGE:
				return {
					width: CONTAINER_SIZE.FULL,
					height: convertDimensionsWidthUnit(50),
					padding: this.baseStyle.spaceXs as string,
					fontSize: this.btnFontSize || this.baseStyle.fontSizeLg as string
				}
			default:
				return {
					width: "auto",
					height: convertDimensionsWidthUnit(44),
					padding: convertDimensionsWidthUnit(15),
					fontSize: this.btnFontSize || this.baseStyle.fontSizeMd as string
				}
		}
	}
	/**
	 * 根据颜色type获取背景色
	 */
	@Computed
	get computedBgColor() {
		return this.plain ? "transparent" : this.color ? this.color : this.type == "default" ? IBestButtonColor.defaultBg : this.baseStyle[this.type]
	}
	/**
	 * 获取按钮的borderRadius
	 */
	@Computed
	get computedBorderRadius() {
		return this.btnBorderRadius || (this.square ? 0 : this.round ? this.baseStyle.borderRadiusMax as string : this.baseStyle.borderRadiusMd as string)
	}
	/**
	 * 获取按钮边框的颜色
	 */
	@Computed
	get computedBorderColor() {
		return this.btnBorderColor || (this.color ? this.color : this.type === COLOR_TYPE.DEFAULT ? GRAY_COLOR.GRAY_4 : this.baseStyle[this.type])
	}
	/**
	 * 获取按钮文字的颜色
	 */
	@Computed
	get computedTextColor() {
		if (this.fontColor) {
			return this.fontColor
		}
		if (this.plain) {
			return this.color ? this.color : this.type === COLOR_TYPE.DEFAULT ? IBestButtonColor.textColor : this.baseStyle[this.type]
		}
		return this.type === COLOR_TYPE.DEFAULT ? IBestButtonColor.textColor : IBestButtonColor.whiteColor
	}
	/**
	 * 获取loading的大小
	 */
	@Computed
	get computedLoadingSize() {
		return this.loadingSize != -1 ? getSizeByUnit(this.loadingSize) : this.computedBtnSize.fontSize
	}
	build() {
		Button({ type: ButtonType.Normal }) {
			if (this.defaultBuilder) {
				this.defaultBuilder()
			} else {
				if(['left', 'right'].includes(this.iconPosition)){
					Row() {
						if(this.iconPosition == "left"){
							this.iconContent()
						}
						Text(this.loading ? this.loadingText ?? this.text : this.text)
							.fontSize(getSizeByUnit(this.computedBtnSize.fontSize, true))
							.fontColor(this.computedTextColor)
						if(this.iconPosition == "right"){
							this.iconContent()
						}
					}
				}else{
					Column(){
						if(this.iconPosition == "top"){
							this.iconContent()
						}
						Text(this.loading ? this.loadingText ?? this.text : this.text)
							.fontSize(getSizeByUnit(this.computedBtnSize.fontSize, true))
							.fontColor(this.computedTextColor)
						if(this.iconPosition == "bottom"){
							this.iconContent()
						}
					}
				}
			}
		}
		.width(getSizeByUnit(this.computedBtnSize.width))
		.height(getSizeByUnit(this.computedBtnSize.height))
		.padding({ left: getSizeByUnit(this.computedBtnSize.padding), right: getSizeByUnit(this.computedBtnSize.padding), top: 0, bottom: 0 })
		.borderWidth(convertDimensionsWidthUnit(this.hairline ? 0.5 : 1))
		.borderRadius(getSizeByUnit(this.computedBorderRadius))
		.fontColor(this.computedTextColor)
		.backgroundColor(this.computedBgColor)
		.borderColor(this.computedBorderColor)
		.hitTestBehavior(this.loading ? HitTestMode.None : HitTestMode.Default)
		.enabled(!this.disabled)
		.opacity(this.disabled && this.plain ? 0.5 : 1)
		.onTouch(event => {
			event.type == TouchType.Up && this.onBtnClick()
		})
		.animation({ duration: this.baseStyle.animationDuration as number })
	}
}