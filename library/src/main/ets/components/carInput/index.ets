import { CONTAINER_SIZE } from '../../theme-chalk/src/container';
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type';
import { IBestCarKeyboardContent } from '../carKeyboard';
import { IBestCarInputModel, IBestCarKeyboardConfig, IBestInputHighlightType } from './index.type';
import { FocusController } from '@ohos.arkui.UIContext';
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils';
import { IBestCarInputColor } from './color';
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type';
import { AppStorageV2 } from '@kit.ArkUI';

@Extend(TextInput) function ibestCarInputStyle(){
	.width(CONTAINER_SIZE.FULL)
	.height(CONTAINER_SIZE.FULL)
	.copyOption(CopyOptions.None)
	.selectionMenuHidden(true)
	.enableAutoFill(false)
	.opacity(0)
}

@ComponentV2
export struct IBestCarInput {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 值
	 */
	@Param @Require value: string
	/**
	 * 自动聚焦
     */
	@Param autoFocus: boolean = false
	/**
	 * 是否显示闪烁光标
	 */
	@Param showCursor: boolean = true
	/**
	 * 光标位置
     */
	@Param cursorPosition: 'center' | 'bottom' = 'center'
	/**
	 * 光标颜色
     */
	@Param cursorColor: ResourceColor = ''
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
	 * 高亮类型
	 */
	@Param highlightType: IBestInputHighlightType = "border"
	/**
	 * 高亮颜色
	 */
	@Param highlightColor: ResourceColor = ""
	/**
	 * 键盘配置
	 */
	@Param keyboardConfig?: IBestCarKeyboardConfig = undefined
	/**
	 * 是否显示边框线
	 */
	@Param isShowBorder: boolean = true
	/**
	 * 边框线颜色
	 */
	@Param bdColor: ResourceColor = IBestCarInputColor.borderColor
	/**
	 * 背景色
	 */
	@Param bgColor: ResourceColor = IBestCarInputColor.bg
	/**
	 * 文字颜色
	 */
	@Param textColor: ResourceColor = IBestCarInputColor.textColor
	/**
	 * 文字大小
	 */
	@Param fontSize: IBestStringNumber = this.baseStyle.fontSizeXl as string
	/**
	 * 完成
	 */
	onConfirm: (value: string) => void = () => {}
	@Event $value: (value: string) => void = () => {}

	@Local uniId: number = 0
	// 最大长度
	@Provider() maxLength: number = 8
	// 输入框列表
	@Local inputList: IBestCarInputModel[] = []
	// 当前聚焦的输入框下标
	@Local currentFocusIndex: number = 0
	// 输入框是否聚焦
	@Local focused: boolean = false
	private textInputController: TextInputController = new TextInputController()
	private focusController: FocusController = this.getUIContext().getFocusController()
	@Builder carKeyboardBuilder(){
		IBestCarKeyboardContent({
			value: this.value,
			maxLength: this.maxLength,
			title: this.keyboardConfig?.title || '',
			confirmBtnText: this.keyboardConfig?.confirmBtnText || '',
			keyHeight: this.keyboardConfig?.keyHeight || '',
			$value: (value: string): void => this.$value(value),
			onClose: () => {
				this.stopEdit()
			},
			onConfirm: () => {
				this.onConfirm(this.value)
			}
		})
	}

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		this.formatInputList()
	}
	// 格式化inputList
	@Monitor("value")
	formatInputList(){
		let value = this.value
		if(value.length > this.maxLength){
			this.$value(value.slice(0, this.maxLength))
		}else{
			this.inputList = Array(this.maxLength).fill("").map((_: string, index: number) => new IBestCarInputModel(value[index] || ""))
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
				TextInput({ text: $$this.value, controller: this.textInputController })
					.defaultFocus(this.autoFocus)
					.maxLength(this.maxLength)
					.id(`ibest_passwordInput_${this.uniId}`)
					.ibestCarInputStyle()
					.customKeyboard(this.carKeyboardBuilder, { supportAvoidance: true })
					.onFocus(() => {
						this.focused = true
					})
					.onBlur(() => {
						this.focused = false
						this.stopEdit()
					})
				Row({ space: getSizeByUnit(this.space) }){
					ForEach(this.inputList, (item: IBestCarInputModel, index: number) => {
						InputField({
							item: item,
							index: index,
							space: this.space,
							radius: this.radius,
							isHighlightCurrent: this.isHighlightCurrent,
							highlightType: this.highlightType,
							highlightColor: this.highlightColor,
							isShowBorder: this.isShowBorder,
							bdColor: this.bdColor,
							bgColor: this.bgColor,
							textColor: this.textColor,
							fontSize: this.fontSize,
							showCursor: this.showCursor,
							cursorPosition: this.cursorPosition,
							cursorColor: this.cursorColor,
							focused: this.focused,
							currentFocusIndex: this.currentFocusIndex
						})
					}, (item: IBestCarInputModel) => item.id)
				}
				.width(CONTAINER_SIZE.FULL)
				.height(CONTAINER_SIZE.FULL)
				.border({ width: this.isShowBorder && this.space == 0 ? 1 : 0, color: this.bdColor })
				.justifyContent(FlexAlign.SpaceBetween)
				.onClick(() => {
					this.focusController.requestFocus(`ibest_passwordInput_${this.uniId}`)
				})
			}
			.width(CONTAINER_SIZE.FULL)
			.height(getSizeByUnit(this.inputHeight))
		}
		.width(CONTAINER_SIZE.FULL)
		.padding(convertDimensionsWidthUnit(5))
	}
}

@ComponentV2
struct InputField {
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Param @Require item: IBestCarInputModel
	@Param index: number = 0
	@Param @Require space: IBestStringNumber
	@Param @Require radius: IBestStringNumber
	@Param @Require isHighlightCurrent: boolean
	@Param @Require highlightType: IBestInputHighlightType
	@Param @Require highlightColor: ResourceColor
	@Param @Require isShowBorder: boolean
	@Param @Require bdColor: ResourceColor
	@Param @Require bgColor: ResourceColor
	@Param @Require textColor: ResourceColor
	@Param @Require fontSize: IBestStringNumber
	@Param @Require showCursor: boolean
	@Param @Require cursorPosition: 'center' | 'bottom'
	@Param @Require cursorColor: ResourceColor
	@Param @Require focused: boolean
	@Param @Require currentFocusIndex: number
	// 光标透明度
	@Local cursorOpacity: number = 0
	// 光标闪烁时长
	@Local cursorBlinkDuration: number = 500
	@Consumer() maxLength: number = 8
	private uiContext = this.getUIContext()
	// 当前输入框是否聚焦
	getIsFocus(){
		return this.isHighlightCurrent && this.focused && this.space && this.currentFocusIndex == this.index
	}
	// 光标闪烁
	cursorBlink(){
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
			Text("新能源")
				.fontSize(this.baseStyle.fontSizeXs)
				.fontColor(this.baseStyle.success)
				.visibility(this.index == this.maxLength - 1 && !this.item.value ? Visibility.Visible : Visibility.None)
			Text(this.item.value)
				.fontSize(getSizeByUnit(this.fontSize, true))
				.fontColor(this.textColor)
				.visibility(this.item.value ? Visibility.Visible : Visibility.None)
			if(this.showCursor && this.focused && this.currentFocusIndex == this.index){
				Divider()
					.strokeWidth(2)
					.width(this.cursorPosition == 'bottom' ? '50%' : '')
					.height(this.cursorPosition == 'center' ? '50%' : '')
					.vertical(this.cursorPosition == 'center')
					.position(this.cursorPosition == 'bottom' ? { left: '25%', bottom: 10 } : { x: '50%', y: '25%' })
					.color(this.cursorColor || this.textColor)
					.opacity(this.cursorOpacity)
					.onAppear(() => {
						this.cursorBlink()
					})
			}
		}
		.layoutWeight(1)
		.height(CONTAINER_SIZE.FULL)
		.justifyContent(FlexAlign.Center)
		.backgroundColor(this.bgColor)
		.border(this.space ? {
			width: this.isShowBorder ? 1 : 0,
			color: this.getIsFocus() ? this.highlightType == 'border' ? this.highlightColor || this.baseStyle.primary : '' : this.bdColor
		} : {
			width: { left: this.index > 0 && this.isShowBorder ? 1 : 0 },
			color: this.bdColor
		})
		.borderRadius(this.space ? getSizeByUnit(this.radius) : 0)
		.shadow({
			radius: this.highlightType == 'shadow' && this.getIsFocus() ? 20 : 0,
			color: this.highlightColor || this.baseStyle.primary as string
		})
	}
}