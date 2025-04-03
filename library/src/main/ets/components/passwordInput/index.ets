import { GRAY_COLOR } from '../../theme-chalk/src/color';
import { CONTAINER_SIZE } from '../../theme-chalk/src/container';
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type';
import { NumberKeyboard } from '../numberKeyboard';
import { IBestPasswordInputModel, NumberKeyboardConfig } from './index.type';
import { FocusController } from '@ohos.arkui.UIContext';
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils';
import { IBestPasInputColor } from './color';
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type';
import { AppStorageV2 } from '@kit.ArkUI';
@Extend(TextInput) function ibestPasswordInputStyle(id: number, inputLength: number){
	.width(CONTAINER_SIZE.FULL)
	.height(CONTAINER_SIZE.FULL)
	.maxLength(inputLength)
	.copyOption(CopyOptions.None)
	.selectionMenuHidden(true)
	.enableAutoFill(false)
	.opacity(0)
	.id(`ibestPasswordInput_${id}`)
}

@ComponentV2
export struct IBestPasswordInput {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 值
	 */
	@Param @Require value: string = ""
	/**
	 * 长度
	 */
	@Param inputLength: number = 6
	/**
	 * 输入框高度
	 */
	@Param inputHeight: IBestStringNumber = convertDimensionsWidthUnit(50)
	/**
	 * 格子间距
	 */
	@Param space: IBestStringNumber = 0
	/**
	 * 圆角, 仅有间距时有效
	 */
	@Param radius: IBestStringNumber = convertDimensionsWidthUnit(5)
	/**
	 * 是否高亮当前正在输入的格子
	 */
	@Param isHighlightCurrent: boolean = true
	/**
	 * 高亮颜色
	 */
	@Param highlightColor: ResourceColor = this.baseStyle.primary
	/**
	 * 是否隐藏内容
	 */
	@Param isHidden: boolean = true
	/**
	 * 提示文字
	 */
	@Param tip: string = ""
	/**
	 * 错误提示
	 */
	@Param errorTip: string = ""
	/**
	 * 是否使用系统键盘
	 */
	@Param useSystemKeyboard: boolean = false
	/**
	 * 自定义键盘配置
	 */
	@Param numberKeyboardConfig?: NumberKeyboardConfig = undefined
	/**
	 * 是否显示边框线
     */
	@Param isShowBorder: boolean = true
	/**
	 * 边框线颜色
     */
	@Param bdColor: ResourceColor = IBestPasInputColor.borderColor
	/**
	 * 格子背景色
     */
	@Param cellBgColor: ResourceColor = IBestPasInputColor.bg
	/**
	 * 格子内文字颜色
     */
	@Param cellTextColor: ResourceColor = IBestPasInputColor.textColor
	/**
	 * 黑点大小
     */
	@Param dotFontSize: IBestStringNumber = convertDimensionsWidthUnit(40)
	/**
	 * 明文展示时文字大小
     */
	@Param textFontSize: IBestStringNumber = this.baseStyle.fontSizeXl as string
	/**
	 * 提示文字大小
	 */
	@Param tipFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 区域点击
	 */
	@Event onFieldClick: () => void = () => {}
	/**
	 * 输入完成
	 */
	@Event onFinish: () => void = () => {}
	@Event $value: (value: string) => void = () => {}

	// 唯一id
	@Local uniId: number = 0
	// 输入框列表
	@Local inputList: IBestPasswordInputModel[] = []
	@Local inputVal: string = this.value
	// 当前聚焦的输入框下标
	@Local currentFocusIndex: number = 0
	// 输入框是否聚焦
	@Local focused: boolean = false
	private textInputController: TextInputController = new TextInputController()
	private focusController: FocusController = this.getUIContext().getFocusController()

	@Monitor("inputVal") inputValChange(){
		this.$value(this.inputVal)
		this.formatInputList()
	}

	@Builder numberKeyboardBuilder(){
		NumberKeyboard({
			value: this.inputVal!!,
			title: this.numberKeyboardConfig?.title || '',
			extraKey: this.numberKeyboardConfig?.extraKey,
			closeButtonText: this.numberKeyboardConfig?.closeBtnText,
			deleteButtonText: this.numberKeyboardConfig?.deleteButtonText,
			styleType: this.numberKeyboardConfig?.styleType,
			isRandomKeyOrder: this.numberKeyboardConfig?.isRandomKeyOrder,
			maxLength: this.inputLength,
			onClose: () => {
				this.stopEdit()
			}
		})
	}

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		this.formatInputList()
	}
	// 格式化inputList
	formatInputList(){
		let value = this.inputVal
		if(/\s/g.test(value)){
			this.inputVal = value.replace(/\s/g, "")
		}else if(value.length > this.inputLength){
			this.inputVal = value.slice(0, this.inputLength)
		}else if(value.length == this.inputLength){
			this.onFinish()
		}else{
			this.inputList = Array(this.inputLength).fill("").map((_: string, index: number) => new IBestPasswordInputModel(value[index] || ""))
			this.currentFocusIndex = value.length
		}
	}
	// 输入框结束编辑
	stopEdit(){
		this.textInputController.stopEditing()
	}
	build() {
		Column({ space: this.baseStyle.spaceMd as string }){
			Stack(){
				if(this.useSystemKeyboard){
					TextInput({ text: $$this.inputVal, controller: this.textInputController })
						.ibestPasswordInputStyle(this.uniId, this.inputLength)
						.onFocus(() => {
							this.focused = true
						})
						.onBlur(() => {
							this.focused = false
						})
				}else{
					TextInput({ text: $$this.inputVal, controller: this.textInputController })
						.ibestPasswordInputStyle(this.uniId, this.inputLength)
						.customKeyboard(this.numberKeyboardBuilder, { supportAvoidance: true })
						.onFocus(() => {
							this.focused = true
						})
						.onBlur(() => {
							this.focused = false
							this.stopEdit()
						})
				}
				Row({ space: getSizeByUnit(this.space) }){
					ForEach(this.inputList, (item: IBestPasswordInputModel, index: number) => {
						InputField({
							item: item,
							index: index,
							isHidden: this.isHidden,
							space: this.space,
							radius: this.radius,
							isHighlightCurrent: this.isHighlightCurrent,
							highlightColor: this.highlightColor,
							isShowBorder: this.isShowBorder,
							bdColor: this.bdColor,
							cellBgColor: this.cellBgColor,
							cellTextColor: this.cellTextColor,
							dotFontSize: this.dotFontSize,
							textFontSize: this.textFontSize,
							focused: this.focused,
							currentFocusIndex: this.currentFocusIndex
						})
					}, (item: IBestPasswordInputModel) => item.id)
				}
				.width(CONTAINER_SIZE.FULL)
				.height(CONTAINER_SIZE.FULL)
				.border({ width: this.isShowBorder && this.space == 0 ? 1 : 0, color: this.bdColor })
				.justifyContent(FlexAlign.SpaceBetween)
				.onClick(() => {
					this.onFieldClick()
					this.focusController.requestFocus(`ibestPasswordInput_${this.uniId}`)
				})
			}
			.width(CONTAINER_SIZE.FULL)
			.height(getSizeByUnit(this.inputHeight))
			// 提示信息
			if(this.tip || this.errorTip){
				Text(this.inputVal.length == this.inputLength && this.errorTip ? this.errorTip : this.tip)
					.width(CONTAINER_SIZE.FULL)
					.textAlign(TextAlign.Center)
					.fontSize(getSizeByUnit(this.tipFontSize, true))
					.fontColor(this.inputVal.length == this.inputLength && this.errorTip ? this.baseStyle.danger : GRAY_COLOR.GRAY_6)
			}
		}
		.width(CONTAINER_SIZE.FULL)
		.padding(convertDimensionsWidthUnit(5))
	}
}

@ComponentV2
struct InputField {
	@Param @Require isHidden: boolean
	@Param @Require space: IBestStringNumber
	@Param @Require radius: IBestStringNumber
	@Param @Require isHighlightCurrent: boolean
	@Param @Require highlightColor: ResourceColor
	@Param @Require isShowBorder: boolean
	@Param @Require bdColor: ResourceColor
	@Param @Require cellBgColor: ResourceColor
	@Param @Require cellTextColor: ResourceColor
	@Param @Require dotFontSize: IBestStringNumber
	@Param @Require textFontSize: IBestStringNumber
	@Param @Require focused: boolean
	@Param @Require currentFocusIndex: number
	@Param @Require index: number
	@Param @Require item: IBestPasswordInputModel
	// 光标透明度
	@Local cursorOpacity: number = 0
	// 光标闪烁时长
	@Local cursorBlinkDuration: number = 500
	private uiContext = this.getUIContext()
	// 光标闪烁
	cursorBlink(): void{
		this.uiContext.keyframeAnimateTo({ iterations: -1 }, [
			{
				duration: this.cursorBlinkDuration,
				event: () => {
					this.cursorOpacity = 1
				}
			},
			{
				duration: this.cursorBlinkDuration,
				event: () => {
					this.cursorOpacity = 0
				}
			}
		])
	}
	build() {
		Row(){
			Text(this.isHidden ? "•" : this.item.value)
				.fontSize(getSizeByUnit(this.isHidden ? this.dotFontSize : this.textFontSize, true))
				.fontColor(this.cellTextColor)
				.visibility(this.item.value ? Visibility.Visible : Visibility.None)
			if(this.focused && this.currentFocusIndex == this.index){
				Divider()
					.strokeWidth(1)
					.height("50%")
					.vertical(true)
					.color(this.cellTextColor)
					.opacity(this.cursorOpacity)
					.onAppear(() => {
						this.cursorBlink()
					})
			}
		}
		.layoutWeight(1)
		.height(CONTAINER_SIZE.FULL)
		.justifyContent(FlexAlign.Center)
		.backgroundColor(this.cellBgColor)
		.border(this.space ? {
			width: this.isShowBorder ? 1 : 0,
			color: this.bdColor
		} : {
			width: { left: this.index > 0 && this.isShowBorder ? 1 : 0 },
			color: this.bdColor
		})
		.borderRadius(this.space ? getSizeByUnit(this.radius) : 0)
		.shadow({
			radius: this.isHighlightCurrent && this.focused && this.space && this.currentFocusIndex == this.index ? 20 : 0,
			color: this.highlightColor,
			type: ShadowType.COLOR
		})
	}
}