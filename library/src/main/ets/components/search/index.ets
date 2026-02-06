import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { GRAY_COLOR } from '../../theme-chalk/src/color'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestIcon } from '../icon'
import { IBestSearchColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'
@ComponentV2
export struct IBestSearch {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 输入框绑定值
	 */
	@Param @Require value: string
	/**
	 * 左侧文本
	 */
	@Param label: ResourceStr = ''
	/**
	 * 左侧文本颜色
     */
	@Param labelColor: ResourceColor = IBestSearchColor.labelColor
	/**
	 * 输入框文字颜色
     */
	@Param textColor: ResourceColor = IBestSearchColor.textColor
	/**
	 * 输入框文字大小
     */
	@Param textFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 输入框 placeholder 提示文字
	 */
	@Param placeholder: ResourceStr = ''
	/**
	 * placeholder 提示文字颜色
	 */
	@Param placeholderColor: ResourceColor = GRAY_COLOR.GRAY_5
	/**
	 * 搜索框高度
	 */
	@Param contentHeight: IBestStringNumber = convertDimensionsWidthUnit(34)
	/**
	 * 外侧背景色
	 */
	@Param outBgColor: ResourceColor = IBestSearchColor.outerBg
	/**
	 * 内侧背景色
	 */
	@Param innerBgColor: ResourceColor = IBestSearchColor.innerBg
	/**
	 * 是否为圆形搜索框
	 */
	@Param isRound: boolean = false
	/**
	 * 圆角大小
	 */
	@Param radius: IBestStringNumber = 0
	/**
	 * 左侧图标
	 */
	@Param leftIcon: ResourceStr = "search"
	/**
	 * 左侧图标颜色
	 */
	@Param leftIconColor: ResourceColor = IBestSearchColor.leftIconColor
	/**
	 * 是否可清除
	 */
	@Param clearable: boolean = true
	/**
	 * 清除图片地址
	 */
	@Param clearIcon: ResourceStr = "clear"
	/**
	 * 清除图标显示时机
	 */
	@Param clearTrigger: "always" | "focus" = 'focus'
	/**
	 * 自动获取焦点
	 */
	@Param autoFocus: boolean = false
	/**
	 * 是否显示右侧按钮
	 */
	@Param showRightButton: boolean = false
	/**
	 * 右侧按钮文字
	 */
	@Param rightButtonText: ResourceStr = $r("app.string.ibest_text_cancel")
	/**
	 * 是否禁用
	 */
	@Param disabled: boolean = false
	/**
	 * 是否只读
	 */
	@Param readOnly: boolean = false
	/**
	 * 输入法回车键类型
	 */
	@Param enterKeyType: EnterKeyType = EnterKeyType.Search
	/**
	 * 右侧按钮背景色
     */
	@Param rightBtnBgColor: ResourceColor = IBestSearchColor.outerBg
	/**
	 * 右侧按钮按压背景色
     */
	@Param rightBtnPressBgColor: ResourceColor = IBestSearchColor.activeBg
	/**
	 * 外侧内边距
	 * @since 1.0.3
	 */
	@Param outPadding: Padding | Length | LocalizedPadding = ''
	/**
	 * 光标颜色
	 * @since 1.1.2
	 */
	@Param caretColor: ResourceColor = ""
	/**
	 * 自定义右侧按钮
	 */
	@BuilderParam customRightButton: CustomBuilder
	/**
	 * 输入回调
	 */
	@Event onInput: (value: string) => void = () => {}
	/**
	 * 搜索回调
	 */
	@Event onSearch: () => void = () => {}
	/**
	 * 失焦回调
	 */
	@Event onInputBlur: () => void = () => {}
	/**
	 * 聚焦回调
	 */
	@Event onInputFocus: () => void = () => {}
	/**
	 * 清除回调
	 */
	@Event onClear: () => void = () => {}
	/**
	 * 右侧按钮点击回调
	 */
	@Event onRightButtonClick: () => void = () => {}
	@Event $value: (value: string) => void = () => {}

	@Local isFocus: boolean = false
	@Local clearLock: boolean = false

	clear(){
		this.clearLock = true
		this.$value("")
		this.onClear()
		setTimeout(() => {
			this.clearLock = false
		}, 10)
	}

	build() {
		Row(){
			Row(){
				Row(){
					if(this.label){
						Text(this.label)
							.fontSize(this.baseStyle.fontSizeMd)
							.fontColor(this.labelColor)
							.margin({ right: this.baseStyle.spaceBase })
					}
					IBestIcon({
						name: this.leftIcon,
						iconSize: convertDimensionsWidthUnit(18),
						color: this.leftIconColor
					}).margin({ right: this.baseStyle.spaceBase })
					TextInput({ text: $$this.value, placeholder: this.placeholder })
						.layoutWeight(1)
						.padding(0)
						.borderRadius(0)
						.fontColor(this.textColor)
						.fontSize(this.textFontSize)
						.placeholderFont({
							size: this.textFontSize
						})
						.placeholderColor(this.placeholderColor)
						.caretColor(this.caretColor)
						.backgroundColor("transparent")
						.enableAutoFill(false)
						.defaultFocus(this.autoFocus)
						.enterKeyType(this.enterKeyType)
						.focusable(!(this.disabled || this.readOnly))
						.onChange((value: string) => {
							if(!this.clearLock){
								this.$value(value)
								this.onInput(value)
							}
						})
						.onSubmit(() => {
							this.onSearch()
						})
						.onFocus(() => {
							this.isFocus = true
							this.onInputFocus()
						})
						.onBlur(() => {
							this.isFocus = false
							this.onInputBlur()
						})
					if(this.clearable){
						Row(){
							IBestIcon({
								name: this.clearIcon,
								iconSize: convertDimensionsWidthUnit(18),
								color: GRAY_COLOR.GRAY_5
							}).onClick(() => {
								this.clear()
							})
						}
						.padding({ left: this.baseStyle.spaceXs, right: this.baseStyle.spaceXs })
						.visibility(this.value && (this.clearTrigger == "always" || this.isFocus) ? Visibility.Visible : Visibility.None)
						.onClick(() => {
							this.clear()
						})
					}
				}
				.layoutWeight(1)
				.height(CONTAINER_SIZE.FULL)
				.backgroundColor(this.innerBgColor)
				.borderRadius(this.isRound ? this.baseStyle.borderRadiusMax : getSizeByUnit(this.radius))
				.padding({ left: this.baseStyle.spaceSm })
				.alignItems(VerticalAlign.Center)
				if(this.customRightButton){
					this.customRightButton()
				}else if(this.showRightButton){
					Text(this.rightButtonText)
						.constraintSize({minWidth: convertDimensionsWidthUnit(44)})
						.height(CONTAINER_SIZE.FULL)
						.fontSize(this.baseStyle.fontSizeMd)
						.padding({ left: this.baseStyle.spaceXs, right: this.baseStyle.spaceXs })
						.stateStyles({
							normal: {
								.backgroundColor(this.rightBtnBgColor)
							},
							pressed: {
								.backgroundColor(this.rightBtnPressBgColor)
							}
						})
						.onClick(() => {
							this.onRightButtonClick()
						})
				}
			}
			.height(getSizeByUnit(this.contentHeight))
		}
		.width(CONTAINER_SIZE.FULL)
		.padding(this.outPadding ? getSizeByUnit(this.outPadding) : {
			left: this.baseStyle.spaceSm,
			right: this.customRightButton || this.showRightButton ? 0 : this.baseStyle.spaceSm,
			top: this.baseStyle.spaceXsm,
			bottom: this.baseStyle.spaceXsm
		})
		.backgroundColor(this.outBgColor)
		.enabled(!this.disabled)
	}
}