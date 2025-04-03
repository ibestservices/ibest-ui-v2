import { IBestDialogColor } from './color'
import { GRAY_COLOR } from '../../theme-chalk/src/color'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getSizeByUnit, sleep } from '../../utils/utils'
import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { AppStorageV2, ImmersiveMode, LengthMetrics, LevelMode } from '@kit.ArkUI'

@Extend(Button) function defaultBtnStyles(theme: 'default' | 'round-button') {
	.layoutWeight(1)
	.height(convertDimensionsWidthUnit(theme == 'round-button' ? 36 : 48))
}
@ComponentV2
export struct IBestDialogView {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local colorMode: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.COLOR_MODE)!
	/**
	 * 弹窗宽度
	 */
	@Param dialogWidth: IBestStringNumber = ""
	/**
	 * 弹窗圆角
	 */
	@Param dialogBorderRadius: IBestStringNumber = ""
	/**
	 * 背景色
     */
	@Param bgColor: ResourceColor = ""
	/**
	 * 背景图片
	 */
	@Param bgImage: ResourceStr = ''
	/**
	 * 标题
	 */
	@Param title: ResourceStr = ''
	/**
	 * 标题颜色
	 */
	@Param titleColor: ResourceColor = ''
	/**
	 * 标题的fontSize
	 */
	@Param titleFontSize: IBestStringNumber = ""
	/**
	 * 标题的padding-top值
	 */
	@Param titlePaddingTop: IBestStringNumber = ""
	/**
	 * 标题的padding-left与padding-right值
	 */
	@Param titlePaddingX: IBestStringNumber = ""
	/**
	 * 标题的padding-top值
	 */
	@Param titleLineHeight: IBestStringNumber = ""
	/**
	 * 标题的对齐方式
	 */
	@Param titleTextAlign: 'left' | 'center' | 'right' = 'center'
	/**
	 * 文本内容，支持通过 \n 换行
	 */
	@Param message: ResourceStr = ""
	/**
	 * 内容区域的fontColor 默认#323233
	 */
	@Param messageFontColor: ResourceColor = ''
	/**
	 * 内容区域的fontSize
	 */
	@Param messageFontSize: IBestStringNumber = ""
	/**
	 * 内容区域的行高 lineHeight
	 */
	@Param messageLineHeight: IBestStringNumber = ""
	/**
	 * 内容区域的padding-top值
	 */
	@Param messagePaddingTop: IBestStringNumber = ""
	/**
	 * 内容区域的padding-left与padding-right值
	 */
	@Param messagePaddingX: IBestStringNumber = ""
	/**
	 * 内容区域的padding-bottom值
	 */
	@Param messagePaddingBottom: IBestStringNumber = ""
	/**
	 * 内容区域的文字对齐方式
	 */
	@Param messageTextAlign: 'left' | 'center' | 'right' = 'center'
	/**
	 * 内容区域最大高度
	 */
	@Param messageMaxHeight: IBestStringNumber = ''
	/**
	 * 样式风格
	 */
	@Param theme: 'default' | 'round-button' = 'default'
	/**
	 * 按钮间距
	 */
	@Param buttonSpace: IBestStringNumber = 0
	/**
	 * 是否展示确认按钮
	 */
	@Param showConfirmButton: boolean = true
	/**
	 * 是否展示取消按钮
	 */
	@Param showCancelButton: boolean = false
	/**
	 * 确认按钮文案
	 */
	@Param confirmButtonText: ResourceStr = $r("app.string.ibest_text_confirm")
	/**
	 * 取消按钮的文案
	 */
	@Param cancelButtonText: ResourceStr = $r("app.string.ibest_text_cancel")
	/**
	 * 按钮的文字大小
	 */
	@Param buttonFontSize: IBestStringNumber = ""
	/**
	 * 确认按钮的字体颜色
	 */
	@Param confirmButtonColor: ResourceColor = ''
	/**
	 * 确认按钮的背景颜色
	 */
	@Param confirmButtonBgColor: ResourceColor = ''
	/**
	 * 取消按钮的字体颜色
	 */
	@Param cancelButtonColor: ResourceColor = ''
	/**
	 * 取消按钮的背景颜色
	 */
	@Param cancelButtonBgColor: ResourceColor = ""
	/**
	 * 是否禁用确认按钮
	 */
	@Param confirmButtonDisabled: boolean = false
	/**
	 * 是否禁用取消按钮
	 */
	@Param cancelButtonDisabled: boolean = false
	/**
	 * 确认按钮的loading
	 */
	@Param confirmButtonLoading: boolean = false
	/**
	 * 取消按钮的loading
	 */
	@Param cancelButtonLoading: boolean = false
	/**
	 * 标题区域的builder
	 */
	@BuilderParam titleBuilder: CustomBuilder
	/**
	 * 内容区域的builder
	 */
	@BuilderParam defaultBuilder: CustomBuilder
	/**
	 * 底部区域的builder
	 */
	@BuilderParam footerBuilder: CustomBuilder
	/**
	 * 点击取消的回调
	 */
	@Event onCancel: () => void = () => {}
	/**
	 * 点击确认的的回调
	 */
	@Event onConfirm: () => void = () => {}
	/**
	 * 点击遮罩
     */
	@Event onClickOverlay: () => void = () => {}

	@Local whiteColor: ResourceColor = IBestDialogColor.white
	@Local contentBg: ResourceColor = this.bgColor || IBestDialogColor.contentBg
	@Local titleDefaultColor: ResourceColor = IBestDialogColor.titleColor
	@Local messageColor: ResourceColor = IBestDialogColor.messageColor
	@Local cancelTextColor: ResourceColor = IBestDialogColor.cancelTextColor
	@Local bdColor: ResourceColor = IBestDialogColor.borderColor

	@Builder placeRow(){
		Blank()
			.onClick(() => {
				this.onClickOverlay()
			})
	}
	// 颜色模式切换
	@Monitor("colorMode.value")
	colorModeChange() {
		this.whiteColor = ""
		this.contentBg = ""
		this.titleDefaultColor = ""
		this.messageColor = ""
		this.cancelTextColor = ""
		this.bdColor = ""
		setTimeout(() => {
			this.whiteColor = IBestDialogColor.white
			this.contentBg = this.bgColor || IBestDialogColor.contentBg
			this.titleDefaultColor = IBestDialogColor.titleColor
			this.messageColor = IBestDialogColor.messageColor
			this.cancelTextColor = IBestDialogColor.cancelTextColor
			this.bdColor = IBestDialogColor.borderColor
		})
	}
	// 标题对齐
	getTitleAlign() {
		switch (this.titleTextAlign) {
			case 'left':
				return FlexAlign.Start
			case 'right':
				return FlexAlign.End
			default:
				return FlexAlign.Center
		}
	}
	// 内容对齐
	getMessageAlign(){
		switch (this.messageTextAlign) {
			case 'left':
				return TextAlign.Start
			case 'right':
				return TextAlign.End
			default:
				return TextAlign.Center
		}
	}
	getTitleColor() {
		return this.titleColor || this.titleDefaultColor
	}
	// 获取内容区域文字颜色
	getMsgColor() {
		return this.messageFontColor || (this.title ? GRAY_COLOR.GRAY_7 : this.messageColor)
	}
	// 确认按钮的文字颜色
	getConfirmBtnFontColor() {
		return this.confirmButtonColor || (this.theme == 'round-button' ? this.whiteColor : this.baseStyle.primary)
	}
	// 确认按钮背景色
	getConfirmBtnBgColor() {
		return this.confirmButtonBgColor || (this.theme == 'round-button' ? this.baseStyle.primary : "transparent")
	}
	// 取消按钮的文字颜色
	getCancelBtnFontColor() {
		return this.cancelButtonColor || this.cancelTextColor
	}
	// 取消按钮背景色
	getCancelBtnBgColor() {
		return this.cancelButtonBgColor || "transparent"
	}
	build() {
		Row(){
			this.placeRow()
			Column() {
				if (this.titleBuilder) {
					this.titleBuilder()
				} else {
					if (this.title) {
						Row(){
							Text(this.title)
								.fontSize(getSizeByUnit(this.titleFontSize ?? this.baseStyle.fontSizeLg as string, true))
								.fontWeight(FontWeight.Medium)
								.lineHeight(getSizeByUnit(this.titleLineHeight ?? convertDimensionsWidthUnit(24)))
								.padding({
									top: getSizeByUnit(this.titlePaddingTop ?? convertDimensionsWidthUnit(26)),
									left: getSizeByUnit(this.titlePaddingX ?? convertDimensionsWidthUnit(24)),
									right: getSizeByUnit(this.titlePaddingX ?? convertDimensionsWidthUnit(24))
								})
								.fontColor(this.getTitleColor())
						}
						.width(CONTAINER_SIZE.FULL)
						.justifyContent(this.getTitleAlign())
					}
				}
				if (this.defaultBuilder) {
					this.defaultBuilder()
				} else {
					Scroll() {
						Text(this.message)
							.width(CONTAINER_SIZE.FULL)
							.padding({
								top: getSizeByUnit(this.messagePaddingTop ?? convertDimensionsWidthUnit(8)),
								left: getSizeByUnit(this.messagePaddingX ?? convertDimensionsWidthUnit(24)),
								right: getSizeByUnit(this.messagePaddingX ?? convertDimensionsWidthUnit(24)),
								bottom: getSizeByUnit(this.messagePaddingBottom ?? convertDimensionsWidthUnit(26))
							})
							.margin({ top: this.title ? 0 : getSizeByUnit(this.messagePaddingBottom ?? convertDimensionsWidthUnit(26)) })
							.textAlign(this.getMessageAlign())
							.lineHeight(getSizeByUnit(this.messageLineHeight ?? this.baseStyle.lineHeightMd as string))
							.fontSize(getSizeByUnit(this.messageFontSize ?? this.baseStyle.fontSizeMd as string, true))
							.fontColor(this.getMsgColor())
					}
					.scrollBarColor(this.baseStyle.scrollBarColor as string)
					.edgeEffect(EdgeEffect.None)
					.constraintSize({
						maxHeight: getSizeByUnit(this.messageMaxHeight ?? "auto")
					})
				}
				if (this.footerBuilder) {
					this.footerBuilder()
				} else {
					Row({ space: getSizeByUnit(this.buttonSpace ?? 0) }) {
						// 取消按钮
						if (this.showCancelButton) {
							Button({ type: ButtonType.Normal }) {
								Row() {
									if (this.cancelButtonLoading) {
										LoadingProgress()
											.width(getSizeByUnit(this.buttonFontSize ?? this.baseStyle.fontSizeLg as string))
											.color(this.getCancelBtnFontColor())
											.margin({
												right: this.baseStyle.spaceMini
											})
											.transition({ type: TransitionType.Insert, opacity: 1 })
											.transition({ type: TransitionType.Delete, opacity: 0 })
									} else {
										Text(this.cancelButtonText ?? $r("app.string.ibest_text_cancel"))
											.fontColor(this.getCancelBtnFontColor())
											.fontSize(getSizeByUnit(this.buttonFontSize ?? this.baseStyle.fontSizeLg as string, true))
											.transition({ type: TransitionType.Insert, opacity: 1 })
											.transition({ type: TransitionType.Delete, opacity: 0 })
									}
								}
							}
							.border({
								width: this.theme == 'round-button' ? 1 : { right: this.showConfirmButton ? 1 : 0 },
								color: this.bdColor
							})
							.enabled(!this.cancelButtonDisabled || !this.cancelButtonLoading)
							.defaultBtnStyles(this.theme)
							.backgroundColor(this.getCancelBtnBgColor())
							.borderRadius(this.theme == "round-button" ? {
								topLeft: 999,
								bottomLeft: 999,
								topRight: this.showConfirmButton && (this.buttonSpace ?? 0) == 0 ? 0 : 999,
								bottomRight: this.showConfirmButton && (this.buttonSpace ?? 0) == 0 ? 0 : 999
							} : 0)
							.onClick(() => {
								this.onCancel()
							})
						}
						// 确认按钮
						if (this.showConfirmButton) {
							Button({ type: ButtonType.Normal }) {
								Row() {
									if (this.confirmButtonLoading) {
										LoadingProgress()
											.width(getSizeByUnit(this.buttonFontSize ?? this.baseStyle.fontSizeLg as string))
											.color(this.getConfirmBtnFontColor())
											.margin({
												right: this.baseStyle.spaceMini
											})
											.transition({ type: TransitionType.Insert, opacity: 1 })
											.transition({ type: TransitionType.Delete, opacity: 0 })
									} else {
										Text(this.confirmButtonText ?? $r("app.string.ibest_text_confirm"))
											.fontColor(this.getConfirmBtnFontColor())
											.fontSize(getSizeByUnit(this.buttonFontSize ?? this.baseStyle.fontSizeLg as string, true))
											.transition({ type: TransitionType.Insert, opacity: 1 })
											.transition({ type: TransitionType.Delete, opacity: 0 })
									}
								}
							}
							.enabled(!this.confirmButtonDisabled || !this.confirmButtonLoading)
							.defaultBtnStyles(this.theme)
							.backgroundColor(this.getConfirmBtnBgColor())
							.borderRadius(this.theme == "round-button" ? {
								topLeft: this.showCancelButton && (this.buttonSpace ?? 0) == 0 ? 0 : 999,
								bottomLeft: this.showCancelButton && (this.buttonSpace ?? 0) == 0 ? 0 : 999,
								topRight: 999,
								bottomRight: 999
							} : 0)
							.onClick(() => {
								this.onConfirm()
							})
						}
					}
					.border({ width: { top: this.theme == 'round-button' ? 0 : 1 }, color: this.bdColor })
					.padding(this.theme == "round-button" ? {
						top: this.baseStyle.spaceXs,
						left: this.baseStyle.spaceLg,
						right: this.baseStyle.spaceLg,
						bottom: this.baseStyle.spaceMd
					} : "")
				}
			}
			.width(CONTAINER_SIZE.FULL)
			.backgroundColor(this.contentBg)
			.backgroundImage(this.bgImage)
			.backgroundImageSize(ImageSize.FILL)
			.borderRadius(getSizeByUnit(this.dialogBorderRadius ?? this.baseStyle.spaceMd as string))
			.clip(true)
			this.placeRow()
		}
		.width(getSizeByUnit(this.dialogWidth ?? convertDimensionsWidthUnit(320)))
		.animation({ duration: 200, curve: Curve.EaseInOut })
	}
}

@ComponentV2
export struct IBestDialog {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 弹框展示状态
	 */
	@Param @Require visible: boolean
	/**
	 * 弹窗宽度
	 */
	@Param dialogWidth: IBestStringNumber = convertDimensionsWidthUnit(320)
	/**
	 * 弹窗圆角
	 */
	@Param dialogBorderRadius: IBestStringNumber = this.baseStyle.spaceMd as string
	/**
	 * 背景色
	 */
	@Param bgColor: ResourceColor = ''
	/**
	 * 背景图片
	 */
	@Param bgImage: ResourceStr = ''
	/**
	 * 标题
	 */
	@Param title: ResourceStr = ''
	/**
	 * 标题颜色
	 */
	@Param titleColor: ResourceColor = ''
	/**
	 * 标题的fontSize
	 */
	@Param titleFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 标题的padding-top值
	 */
	@Param titlePaddingTop: IBestStringNumber = convertDimensionsWidthUnit(26)
	/**
	 * 标题的padding-left与padding-right值
	 */
	@Param titlePaddingX: IBestStringNumber = convertDimensionsWidthUnit(24)
	/**
	 * 标题的padding-top值
	 */
	@Param titleLineHeight: IBestStringNumber = convertDimensionsWidthUnit(24)
	/**
	 * 标题的对齐方式
	 */
	@Param titleTextAlign: 'left' | 'center' | 'right' = 'center'
	/**
	 * 文本内容，支持通过 \n 换行
	 */
	@Param message: ResourceStr = ''
	/**
	 * 内容区域的fontColor 默认#323233
	 */
	@Param messageFontColor: ResourceColor = ''
	/**
	 * 内容区域的fontSize
	 */
	@Param messageFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 内容区域的行高 lineHeight
	 */
	@Param messageLineHeight: IBestStringNumber = this.baseStyle.lineHeightMd as string
	/**
	 * 内容区域的padding-top值
	 */
	@Param messagePaddingTop: IBestStringNumber = convertDimensionsWidthUnit(8)
	/**
	 * 内容区域的padding-left与padding-right值
	 */
	@Param messagePaddingX: IBestStringNumber = convertDimensionsWidthUnit(24)
	/**
	 * 内容区域的padding-bottom值
	 */
	@Param messagePaddingBottom: IBestStringNumber = convertDimensionsWidthUnit(26)
	/**
	 * 内容区域的文字对齐方式
	 */
	@Param messageTextAlign: 'left' | 'center' | 'right' = 'center'
	/**
	 * 内容区域最大高度
	 */
	@Param messageMaxHeight: IBestStringNumber = 'auto'
	/**
	 * 样式风格
	 */
	@Param theme: 'default' | 'round-button' = 'default'
	/**
	 * 按钮间距
	 */
	@Param buttonSpace: IBestStringNumber = 0
	/**
	 * 是否展示确认按钮
	 */
	@Param showConfirmButton: boolean = true
	/**
	 * 是否展示取消按钮
	 */
	@Param showCancelButton: boolean = false
	/**
	 * 确认按钮文案
	 */
	@Param confirmButtonText: ResourceStr = $r("app.string.ibest_text_confirm")
	/**
	 * 取消按钮的文案
	 */
	@Param cancelButtonText: ResourceStr = $r("app.string.ibest_text_cancel")
	/**
	 * 按钮的文字大小
	 */
	@Param buttonFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 确认按钮的字体颜色
	 */
	@Param confirmButtonColor: ResourceColor = ''
	/**
	 * 确认按钮的背景颜色
	 */
	@Param confirmButtonBgColor: ResourceColor = ''
	/**
	 * 取消按钮的字体颜色
	 */
	@Param cancelButtonColor: ResourceColor = ''
	/**
	 * 取消按钮的背景颜色
	 */
	@Param cancelButtonBgColor: ResourceColor = ""
	/**
	 * 是否禁用确认按钮
	 */
	@Param confirmButtonDisabled: boolean = false
	/**
	 * 是否禁用取消按钮
	 */
	@Param cancelButtonDisabled: boolean = false
	/**
	 * 确认按钮的loading
	 */
	@Param confirmButtonLoading: boolean = false
	/**
	 * 取消按钮的loading
	 */
	@Param cancelButtonLoading: boolean = false
	/**
	 * 弹窗是否为模态窗口，模态窗口有蒙层，非模态窗口无蒙层
	 */
	@Param showOverlay: boolean = true
	/**
	 * 自定义蒙层颜色
	 */
	@Param overlayColor: ResourceColor = '0x33000000'
	/**
	 * 某弹框需要显示在主窗口之外时，是否在子窗口显示此弹窗
	 */
	@Param showInSubWindow: boolean = false
	/**
	 * 是否在点击遮罩层后关闭弹窗
	 */
	@Param closeOnClickOverlay: boolean = false
	/**
	 * 是否允许返回键关闭
	 */
	@Param closeOnBackPress: boolean = true
	/**
	 * 弹窗在竖直方向上的对齐方式 默认center
	 */
	@Param alignment: 'center' | 'top' | 'bottom' = 'center'
	/**
	 * 弹窗相对alignment所在位置的横向偏移量
	 */
	@Param offsetX: IBestStringNumber = 0
	/**
	 * 弹窗相对alignment所在位置的纵向偏移量。
	 */
	@Param offsetY: IBestStringNumber = 0
	/**
	 * 弹窗避让键盘后，和键盘之间的距离
	 */
	@Param keyboardAvoidDistance: LengthMetrics = LengthMetrics.vp(16)
	/**
	 * 弹窗显示层级
     */
	@Param levelMode: LevelMode = LevelMode.OVERLAY
	/**
	 * 页面级弹窗需要显示的层级下的节点 uniqueId, 仅当levelMode属性设置为LevelMode.EMBEDDED时生效
	 */
	@Param levelUniqueId: number = 0
	/**
	 * 关闭前的回调函数，返回 false 可阻止关闭，支持返回 Promise
	 */
	@Event beforeClose?: (action: 'cancel' | 'confirm') => Promise<boolean> | boolean = undefined
	/**
	 * 弹框打开回调
	 */
	@Event onOpen: () => void = () => {}
	/**
	 * 弹框关闭回调
	 */
	@Event onClose: () => void = () => {}
	/**
	 * 点击取消的回调
	 */
	@Event onCancel: () => void = () => {}
	/**
	 * 点击确认的的回调
	 */
	@Event onConfirm: () => void = () => {}
	/**
	 * 标题区域的builder
	 */
	@BuilderParam titleBuilder: CustomBuilder
	/**
	 * 内容区域的builder
	 */
	@BuilderParam defaultBuilder: CustomBuilder
	/**
	 * 底部区域的builder
	 */
	@BuilderParam footerBuilder: CustomBuilder
	@Event $visible: (visible: boolean) => void = () => {}
	@Event $confirmButtonLoading: (value: boolean) => void = () => {}
	@Event $cancelButtonLoading: (value: boolean) => void = () => {}
	@Event $confirmButtonDisabled: (value: boolean) => void = () => {}
	@Event $cancelButtonDisabled: (value: boolean) => void = () => {}

	@Builder dialogBuilder(){
		IBestDialogView({
			dialogWidth: this.dialogWidth,
			dialogBorderRadius: this.dialogBorderRadius,
			bgColor: this.bgColor,
			bgImage: this.bgImage,
			title: this.title,
			titleColor: this.titleColor,
			titlePaddingTop: this.titlePaddingTop,
			titlePaddingX: this.titlePaddingX,
			titleLineHeight: this.titleLineHeight,
			titleFontSize: this.titleFontSize,
			titleTextAlign: this.titleTextAlign,
			message: this.message,
			messagePaddingX: this.messagePaddingX,
			messagePaddingTop: this.messagePaddingTop,
			messagePaddingBottom: this.messagePaddingBottom,
			messageFontColor: this.messageFontColor,
			messageFontSize: this.messageFontSize,
			messageLineHeight: this.messageLineHeight,
			messageTextAlign: this.messageTextAlign,
			messageMaxHeight: this.messageMaxHeight,
			theme: this.theme,
			showConfirmButton: this.showConfirmButton,
			showCancelButton: this.showCancelButton,
			confirmButtonText: this.confirmButtonText,
			cancelButtonText: this.cancelButtonText,
			buttonFontSize: this.buttonFontSize,
			confirmButtonColor: this.confirmButtonColor,
			confirmButtonBgColor: this.confirmButtonBgColor,
			cancelButtonColor: this.cancelButtonColor,
			cancelButtonBgColor: this.cancelButtonBgColor,
			confirmButtonDisabled: this.confirmButtonDisabled,
			cancelButtonDisabled: this.cancelButtonDisabled,
			confirmButtonLoading: this.confirmButtonLoading,
			cancelButtonLoading: this.cancelButtonLoading,
			titleBuilder: this.titleBuilder,
			defaultBuilder: this.defaultBuilder,
			footerBuilder: this.footerBuilder,
			onCancel: () => {
				this.handleCancel()
			},
			onConfirm: () => {
				this.handleConfirm()
			},
			onClickOverlay: () => {
				if(this.closeOnClickOverlay){
					this.handleCancel()
				}
			}
		})
	}

	private promptAction = this.getUIContext().getPromptAction()
	private dialogId: number = 0
	@Monitor("visible") visibleChange(){
		if(this.visible){
			this.open()
		}else{
			this.promptAction.closeCustomDialog(this.dialogId)
		}
	}
	getAlignment() {
		switch (this.alignment) {
			case 'center':
				return DialogAlignment.Center
			case 'top':
				return DialogAlignment.Top
			case 'bottom':
				return DialogAlignment.Bottom
			default:
				return DialogAlignment.Center
		}
	}
	async open() {
		this.dialogId = await this.promptAction.openCustomDialog({
			builder: () => {
				this.dialogBuilder()
			},
			backgroundBlurStyle: BlurStyle.NONE,
			cornerRadius: 0,
			alignment: this.getAlignment(),
			offset: {
				dx: this.offsetX,
				dy: this.offsetY
			},
			isModal: this.showOverlay,
			maskColor: this.overlayColor,
			showInSubWindow: this.showInSubWindow,
			keyboardAvoidDistance: this.keyboardAvoidDistance,
			levelMode: this.levelMode,
			levelUniqueId: this.levelUniqueId,
			// immersiveMode: ImmersiveMode.EXTEND,
			onDidAppear: () => {
				this.onOpen()
			},
			onDidDisappear: () => {
				this.onClose()
			},
			onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
				// 1 点击遮罩返回  0 物理返回(左滑右滑、返回键)
				let reason = dismissDialogAction.reason
				if (reason == DismissReason.PRESS_BACK && this.closeOnBackPress || reason == DismissReason.TOUCH_OUTSIDE && this.closeOnClickOverlay) {
					this.close()
				}
			}
		})
	}
	// 关闭弹框
	close() {
		this.$visible(false)
	}
	// 结束
	async handleBeforeClose(action: 'cancel' | 'confirm') {
		let status = true
		try {
			if (this.beforeClose) {
				status = await this.beforeClose(action)
			}
		} catch (e) {
			status = false
		}
		return status
	}
	// 点击取消的回调
	async handleCancel() {
		if (this.cancelButtonDisabled || this.cancelButtonLoading) {
			return
		}
		if (this.beforeClose) {
			this.$cancelButtonLoading(true)
			const status = await this.handleBeforeClose('cancel')
			this.$cancelButtonLoading(false)
			if (!status) {
				return
			}
		}
		this.$cancelButtonDisabled(true)
		this.close()
		this.onCancel()
		// 等待动画结束
		await sleep()
		this.$cancelButtonDisabled(false)
	}
	// 点击确定的回调
	async handleConfirm() {
		if (this.confirmButtonDisabled || this.confirmButtonLoading) {
			return
		}
		if (this.beforeClose) {
			this.$confirmButtonLoading(true)
			const status = await this.handleBeforeClose('confirm')
			this.$confirmButtonLoading(false)
			if (!status) {
				return
			}
		}
		this.$confirmButtonDisabled(true)
		this.close()
		this.onConfirm()
		// 等待动画结束
		await sleep()
		this.$confirmButtonDisabled(false)
		this.$confirmButtonLoading(false)
	}
	build() {}
}