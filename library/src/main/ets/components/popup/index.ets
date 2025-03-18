import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { PopupAlign, PopupBaseController } from './index.type'
import { IBestUIBaseStyle } from '../../theme-chalk/src/index.type'
import { IBestPopupColor } from './color'
import { IBestIcon } from '../icon'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2, ImmersiveMode } from '@kit.ArkUI'
import GlobalStore from '../../utils/GlobalStore'

const popupDuration = 200
const hideDuration = 220

interface PopupSize{
	width: IBestStringNumber
	height: IBestStringNumber
}

@ComponentV2
export struct IBestPopupBaseContent{
	@Local isLandscape: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.IS_LANDSCAPE)!
	@Local topAvoidHeight: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.TOP_AVOID_HEIGHT)!
	@Local bottomBarHeight: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.BOTTOM_BAR_HEIGHT)!
	@Local transX: IBestStringNumber = ""
	@Local transY: IBestStringNumber = ""
	/**
	 * 弹框显示位置
	 */
	@Param popupAlign: PopupAlign = 'center'
	/**
	 * 弹框宽度
	 */
	@Param popupWidth: IBestStringNumber = ""
	/**
	 * 弹框高度
	 */
	@Param popupHeight: IBestStringNumber = ""
	/**
	 * 背景图片
	 */
	@Param bgImage: ResourceStr = ""
	/**
	 * 是否显示头部
	 */
	@Param isShowHeader: boolean = false
	/**
	 * 标题
	 */
	@Param title: ResourceStr = ""
	/**
	 * 标题字体颜色
	 */
	@Param titleColor: ResourceColor = IBestPopupColor.titleColor
	/**
	 * 是否显示关闭图标
	 */
	@Param isShowClose: boolean = true
	/**
	 * 自定义关闭图标
	 */
	@Param closeIcon: ResourceStr = "cross"
	/**
	 * 关闭图标颜色
	 */
	@Param closeIconColor: ResourceColor = IBestPopupColor.closeIconColor
	/**
	 * 背板的圆角半径
	 */
	@Param cornerRadius: IBestStringNumber = 0
	/**
	 * 底部偏移
	 */
	@Param offsetY: number = 0
	/**
	 * 是否开启顶部安全区适配
	 */
	@Param safeAreaInsetTop: boolean = false
	/**
	 * 是否开启底部安全区适配
	 */
	@Param safeAreaInsetBottom: boolean = false
	/**
	 * 自定义头部
	 */
	@BuilderParam headerBuilder: CustomBuilder
	/**
	 * 自定义内容
	 */
	@BuilderParam contentBuilder: CustomBuilder
	@Param baseController: PopupBaseController = new PopupBaseController()
	/**
	 * 点击遮罩
	 */
	@Event onClickOverlay: () => void = () => {}
	@Event close: () => void = () => {}
	@Builder placeRow(){
		Blank()
			.onClick(() => {
				this.onClickOverlay()
			})
	}
	@Computed
	get popupSize(): PopupSize{
		switch (this.popupAlign){
			case "left":
			case "right":
				return {
					width: this.popupWidth || (this.isLandscape.value ? "70%" : "60%"),
					height: this.popupHeight || "100%"
				}
			case "top":
			case "bottom":
				return {
					width: this.popupWidth || "100%",
					height: this.popupHeight || (this.isLandscape.value ? "70%" : "40%")
				}
			case "center":
				return {
					width: this.popupWidth || "",
					height: this.popupHeight || ""
				}
		}
	}
	aboutToAppear(): void {
		this.baseController.hide = (): void => this.init()
		this.init()
	}
	// 初始化
	init(){
		switch (this.popupAlign){
			case "left":
				this.transX = "-100%"
				break
			case "right":
				this.transX = "100%"
				break
			case "top":
				this.transY = "-100%"
				break
			case "bottom":
				this.transY = "100%"
				break
		}
	}
	// 变换显示
	trans(){
		switch (this.popupAlign){
			case "left":
			case "right":
				this.transX = 0
				break
			case "top":
			case "bottom":
				this.transY = 0
				break
		}
	}

	build() {
		Column(){
			if(this.popupAlign == 'center' || this.popupAlign == 'bottom'){
				this.placeRow()
			}
			Row(){
				if(this.popupAlign == 'center' || this.popupAlign == 'right'){
					this.placeRow()
				}
				Column(){
					if(this.isShowHeader){
						if(this.headerBuilder){
							this.headerBuilder()
						}else{
							PopupTitle({
								title: this.title,
								titleColor: this.titleColor,
								isShowClose: this.isShowClose,
								closeIcon: this.closeIcon,
								closeIconColor: this.closeIconColor,
								close: (): void => this.close()
							})
						}
					}
					if(this.contentBuilder){
						this.contentBuilder()
					}
				}
				.width(getSizeByUnit(this.popupSize.width))
				.height(getSizeByUnit(this.popupSize.height))
				.backgroundColor(IBestPopupColor.bgColor)
				.backgroundImage(this.bgImage)
				.backgroundImageSize(ImageSize.FILL)
				.padding({
					top: this.safeAreaInsetTop && (this.popupAlign == "left" || this.popupAlign == "right" || this.popupAlign
						== "top") ? convertDimensionsWidthUnit(this.topAvoidHeight.value as number) : 0,
					bottom: this.safeAreaInsetBottom && (this.popupAlign == "left" || this.popupAlign == "right" || this.popupAlign
						== "bottom") ? convertDimensionsWidthUnit(this.bottomBarHeight.value as number) : 0
				})
				.alignItems(HorizontalAlign.Start)
				.borderRadius(getSizeByUnit(this.cornerRadius))
				.translate({
					x: (this.popupAlign == "left" || this.popupAlign == "right") ? this.transX : "",
					y: (this.popupAlign == "top" || this.popupAlign == 'bottom') ? this.transY : ""
				})
				.animation({ duration: popupDuration, curve: Curve.EaseInOut })
				.onAppear(() => {
					setTimeout(() => {
						this.trans()
					}, 100)
				})
				if(this.popupAlign == 'center' || this.popupAlign == 'left'){
					this.placeRow()
				}
			}
			.width(['left', 'center', 'right'].includes(this.popupAlign) ? CONTAINER_SIZE.FULL : "")
			if(this.popupAlign == 'center' || this.popupAlign == 'top'){
				this.placeRow()
			}
		}
		.height(CONTAINER_SIZE.FULL)
		.offset({x: 0, y: this.offsetY})
		.clip(true)
	}
}

@ComponentV2
struct PopupTitle {
	@Local baseStyle: IBestUIBaseStyle = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE, () => new IBestUIBaseStyle({})) as IBestUIBaseStyle
	@Param title: ResourceStr = ''
	@Param titleColor: ResourceColor = ''
	@Param isShowClose: boolean = true
	@Param closeIcon: ResourceStr = "cross"
	@Param closeIconColor: ResourceColor = IBestPopupColor.closeIconColor
	@Event close: () => void = () => {}
	build() {
		Row(){
			Text(this.title)
				.fontSize(this.baseStyle.fontSizeLg)
				.fontColor(this.titleColor)
			IBestIcon({
				name: this.closeIcon,
				iconSize: convertDimensionsWidthUnit(20),
				color: this.closeIconColor
			})
				.onClick(() => {
					this.close()
				})
				.visibility(this.isShowClose ? Visibility.Visible : Visibility.None)
		}
		.width(CONTAINER_SIZE.FULL)
		.height(convertDimensionsWidthUnit(40))
		.padding({ left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd })
		.justifyContent(FlexAlign.SpaceBetween)
		.alignItems(VerticalAlign.Center)
	}
}

@ComponentV2
export struct IBestPopup{
	@Local topAvoidHeight: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.TOP_AVOID_HEIGHT)!
	/**
	 * 弹框展示状态
	 */
	@Param @Require visible: boolean = false
	/**
	 * 弹框显示位置
	 */
	@Param popupAlign: PopupAlign = 'center'
	/**
	 * 弹框宽度
	 */
	@Param popupWidth: IBestStringNumber = ""
	/**
	 * 弹框高度
	 */
	@Param popupHeight: IBestStringNumber = ""
	/**
	 * 背景图片
	 */
	@Param bgImage: ResourceStr = ""
	/**
	 * 是否显示头部标题栏
	 */
	@Param isShowHeader: boolean = false
	/**
	 * 标题
	 */
	@Param title: ResourceStr = ""
	/**
	 * 标题字体颜色
	 */
	@Param titleColor: ResourceColor = IBestPopupColor.titleColor
	/**
	 * 是否显示关闭图标
	 */
	@Param isShowClose: boolean = true
	/**
	 * 自定义关闭图标
	 */
	@Param closeIcon: ResourceStr = "cross"
	/**
	 * 关闭图标颜色
	 */
	@Param closeIconColor: ResourceColor = IBestPopupColor.closeIconColor
	/**
	 * 底部偏移
	 */
	@Param offsetY: number = 0
	/**
	 * 是否为模态窗口
	 */
	@Param isModal: boolean = true
	/**
	 * 蒙层颜色
	 */
	@Param maskColor: ResourceColor = "0x33000000"
	/**
	 * 背板的圆角半径
	 */
	@Param cornerRadius: IBestStringNumber = 0
	/**
	 * 是否允许点击遮罩关闭
	 */
	@Param closeOnClickOverlay: boolean = true
	/**
	 * 是否允许返回键关闭
	 */
	@Param closeOnBackPress: boolean = false
	
	/**
	 * 是否开启顶部安全区适配
	 */
	@Param safeAreaInsetTop: boolean = false
	/**
	 * 是否开启底部安全区适配
	 */
	@Param safeAreaInsetBottom: boolean = false
	/**
	 * 自定义头部 优先级大于title
	 */
	@BuilderParam headerBuilder: CustomBuilder
	/**
	 * 自定义内容
	 */
	@BuilderParam contentBuilder: CustomBuilder
	/**
	 * 弹框打开回调
	 */
	@Event onOpen: () => void = () => {}
	/**
	 * 弹框关闭回调
	 */
	@Event onClose: () => void = () => {}
	@Event $visible: (visible: boolean) => void = () => {}
	private baseController: PopupBaseController = new PopupBaseController()
	private promptAction = this.getUIContext().getPromptAction()
	private dialogId: number = 0
	@Monitor("visible") visibleChange(){
		if(this.visible){
			this.open()
		}else{
			this.baseController.hide()
			setTimeout(() => {
				this.promptAction.closeCustomDialog(this.dialogId)
			}, hideDuration)
		}
	}
	@Builder defaultContentBuilder() {
		IBestPopupBaseContent({
			popupAlign: this.popupAlign,
			popupWidth: this.popupWidth,
			popupHeight: this.popupHeight,
			bgImage: this.bgImage,
			isShowHeader: this.isShowHeader,
			title: this.title,
			titleColor: this.titleColor,
			isShowClose: this.isShowClose,
			closeIcon: this.closeIcon,
			closeIconColor: this.closeIconColor,
			cornerRadius: this.cornerRadius,
			offsetY: this.offsetY,
			safeAreaInsetTop: this.safeAreaInsetTop,
			safeAreaInsetBottom: this.safeAreaInsetBottom,
			headerBuilder: this.headerBuilder,
			contentBuilder: this.contentBuilder,
			baseController: this.baseController,
			onClickOverlay: () => {
				if(this.closeOnClickOverlay){
					this.close()
				}
			},
			close: (): void => this.close()
		})
	}
	getAlignment() {
		switch (this.popupAlign) {
			case 'left':
				return DialogAlignment.TopStart
			case 'right':
				return DialogAlignment.TopEnd
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
				this.defaultContentBuilder()
			},
			width: CONTAINER_SIZE.FULL,
			height: px2vp(GlobalStore.screenHeight),
			backgroundBlurStyle: BlurStyle.NONE,
			cornerRadius: 0,
			alignment: this.getAlignment(),
			offset: { dx: 0, dy: -(this.topAvoidHeight.value as number) },
			isModal: this.isModal,
			maskColor: this.maskColor,
			// autoCancel: this.closeOnClickOverlay,
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
	build() {}
}