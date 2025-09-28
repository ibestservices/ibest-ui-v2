import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getComponentsInfo, getSizeByUnit } from '../../utils/utils'
import { IBestIcon } from '../icon'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestNoticeBar{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 通知栏模式
     */
	@Param mode?: 'closeable' | 'link' = undefined
	/**
	 * 通知栏高度
     */
	@Param barHeight: IBestStringNumber = convertDimensionsWidthUnit(40)
	/**
	 * 背景色
     */
	@Param bgColor: ResourceColor = "#fffbe8"
	/**
	 * 左右内边距
     */
	@Param leftRightPadding: IBestStringNumber = convertDimensionsWidthUnit(16)
	/**
	 * 自定义左侧图标
     */
	@Param leftIcon: ResourceStr = ''
	/**
	 * 左侧图标尺寸
     */
	@Param leftIconSize: IBestStringNumber = convertDimensionsWidthUnit(16)
	/**
	 * 左侧图标颜色
     */
	@Param leftIconColor: ResourceColor = "#ed6a0c"
	/**
	 * 通知文本
     */
	@Param text: ResourceStr = ''
	/**
	 * 文本颜色
     */
	@Param textColor: ResourceColor = "#ed6a0c"
	/**
	 * 文本大小
     */
	@Param textFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 右侧图标名称
	 * @deprecated 请使用rightIcon
     */
	@Param rightIconName: string = ''
	/**
	 * 自定义右侧图标
     */
	@Param rightIcon: ResourceStr = ""
	/**
	 * 右侧图标大小
     */
	@Param rightIconSize: IBestStringNumber = convertDimensionsWidthUnit(16)
	/**
	 * 右侧图标颜色
     */
	@Param rightIconColor: ResourceColor = "#ed6a0c"
	/**
	 * 是否开启滚动播放，内容长度溢出时默认开启
     */
	@Param @Once scrollable?: boolean = undefined
	/**
	 * 动画延迟时间(s)
     */
	@Param delay: number = 1
	/**
	 * 滚动速率(vp/s)
     */
	@Param speed: number = 60
	/**
	 * 是否开启换行, 为true时滚动不生效
     */
	@Param wrapable: boolean = false
	/**
	 * 垂直滚动
     */
	@Param vertical: boolean = false
	/**
	 * 垂直滚动内容
     */
	@Param verticalTextList: string[] = []
	/**
	 * 垂直滚动间隔 单位秒
     */
	@Param verticalInterval: number = 3
	/**
	 * 圆角
	 */
	@Param radius: IBestStringNumber = 0
	/**
	 * 点击通知栏回调
     */
	@Event onBarClick: () => void = () => {}
	/**
	 * 关闭通知栏触发
     */
	@Event onClose: () => void = () => {}
	/**
	 * 垂直滚动时,点击文字回调
     */
	@Event onTextClick: (index: number) => void = () => {}

	@Local uniId: number = 0
	@Local isShow: boolean = true
	@Local transX: number = 0
	@Local duration: number = 0
	private contentWidth: number = 0
	private textWidth: number = 0
	private startTimer: number = 0
	private uiContext = this.getUIContext()

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		this.init()
	}

	@Monitor("text")
	init(){
		if(!this.isShow){
			return
		}
		clearTimeout(this.startTimer)
		this.transX = 0
		this.duration = 0
		if(this.scrollable === false || this.wrapable){
			return
		}
		setTimeout(() => {
			let contentWidth = getComponentsInfo(this.uiContext, `ibest_noticeBar_${this.uniId}`).width
			let textWidth = getComponentsInfo(this.uiContext, `ibest_noticeBar_text_${this.uniId}`).width
			this.contentWidth = contentWidth
			this.textWidth = textWidth
			this.reset()
		}, 50)
	}
	reset(){
		this.startTimer = setTimeout(() => {
			if (this.textWidth > this.contentWidth && this.scrollable === undefined) {
				this.scrollable = true
			}
			if(this.scrollable) {
				this.duration = this.textWidth / +this.speed
				this.transX = -this.textWidth
			}
		}, +this.delay * 1000)
	}
	onFinish(){
		this.transX = this.contentWidth
		this.duration = 0
		setTimeout(() => {
			this.duration = (this.contentWidth + this.textWidth) / +this.speed
			this.transX = -this.textWidth
		}, 100)
	}

	build() {
		Row(){
			if(this.leftIcon){
				Row(){
					IBestIcon({
						name: this.leftIcon,
						iconSize: this.leftIconSize,
						color: this.leftIconColor
					})
				}
				.constraintSize({minWidth: convertDimensionsWidthUnit(24)})
			}
			if(this.vertical){
				Swiper() {
					ForEach(this.verticalTextList, (item: string, index: number) => {
						Text(item)
							.width(CONTAINER_SIZE.FULL)
							.fontColor(this.textColor)
							.fontSize(getSizeByUnit(this.textFontSize, true))
							.maxLines(1)
							.textOverflow({overflow: TextOverflow.Ellipsis})
							.onClick(() => {
								this.onTextClick(index)
							})
					}, (item: string) => item)
				}
				.layoutWeight(1)
				.height(CONTAINER_SIZE.FULL)
				.vertical(true)
				.interval(this.verticalInterval*1000)
				.autoPlay(true)
				.indicator(false)
				.disableSwipe(true)
			}else{
				Scroll(){
					Text(this.text)
						.width(this.scrollable === false || this.wrapable ? CONTAINER_SIZE.FULL : "auto")
						.fontColor(this.textColor)
						.fontSize(getSizeByUnit(this.textFontSize, true))
						.maxLines(this.wrapable || this.scrollable ? undefined : 1)
						.textOverflow(this.wrapable || this.scrollable ? undefined : {overflow: TextOverflow.Ellipsis})
						.id(`ibest_noticeBar_text_${this.uniId}`)
						.translate({x: this.transX})
						.animation({
							duration: this.duration * 1000,
							curve: Curve.Linear,
							onFinish: (): void => this.onFinish()
						})
				}
				.layoutWeight(1)
				.scrollable(ScrollDirection.None)
				.align(Alignment.Start)
				.id(`ibest_noticeBar_${this.uniId}`)
			}
			if(this.rightIcon || this.mode){
				Row(){
					IBestIcon({
						name: this.rightIcon || (this.mode == "closeable" ? "cross" : "arrow"),
						iconSize: this.rightIconSize,
						color: this.rightIconColor
					})
				}
				.constraintSize({minWidth: convertDimensionsWidthUnit(24)})
				.justifyContent(FlexAlign.End)
				.onClick(() => {
					if(this.mode == "closeable"){
						this.isShow = false
						this.onClose()
					}
				})
			}
		}
		.height(this.wrapable ? "auto" : getSizeByUnit(this.barHeight))
		.constraintSize({minHeight: this.wrapable ? getSizeByUnit(this.barHeight) : ""})
		.backgroundColor(this.bgColor)
		.borderRadius(getSizeByUnit(this.radius))
		.padding({
			left: getSizeByUnit(this.leftRightPadding),
			right: getSizeByUnit(this.leftRightPadding),
			top: this.wrapable ? convertDimensionsWidthUnit(8) : 0,
			bottom: this.wrapable ? convertDimensionsWidthUnit(8) : 0
		})
		.visibility(this.isShow ? Visibility.Visible : Visibility.None)
		.clip(true)
		.onAreaChange(() => {
			this.init()
		})
		.onClick(() => {
			this.onBarClick()
		})
	}
}