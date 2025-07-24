import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { IBestWatermarkColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'
import GlobalStore from '../../utils/GlobalStore'
import { base64ToPixelMap, getResourceStr } from '../../utils/utils'
import { IBestDrawCanvasItemArgs, IBestWatermarkCountData } from './index.type'

@ComponentV2
export struct IBestWatermark {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local colorMode: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.COLOR_MODE)!
	/**
	 * 图片水印的宽度
	 */
	@Param waterMarkWidth: number = 100
	/**
	 * 图片水印的高度
	 */
	@Param waterMarkHeight: number = 100
	/**
	 * 水印透明度
	 */
	@Param waterMarkOpacity: number = 0.3
	/**
	 * 水印之间的水平间隔 默认0
	 */
	@Param gapX: number = 0
	/**
	 * 水印之间的垂直间隔 默认0
	 */
	@Param gapY: number = 0
	/**
	 * 旋转角度
	 */
	@Param rotateDeg: number = -22
	/**
	 * 图片水印的链接
	 */
	@Param imageUrl: ResourceStr = ''
	/**
	 * 文字水印
	 */
	@Param text: ResourceStr = ''
	/**
	 * 文字的大小, 单位vp
	 */
	@Param fontSize: number = 14
	/**
	 * 文字字体
	 */
	@Param fontFamily: string = 'sans-serif'
	/**
	 * 文字颜色
	 */
	@Param fontColor: IBestStringNumber | CanvasGradient | CanvasPattern = ''
	/**
	 * 水印的z-index
	 */
	@Param waterMarkZIndex: number = -1
	/**
	 * 背景色
	 */
	@Param bgColor: ResourceColor = ""
	/**
	 * 水印在上层时,内容是否可交互, 仅 waterMarkZIndex 大于0有效
	 * @since 0.0.6
	 */
	@Param contentInteractive: boolean = false
	/**
	 * 默认的插槽
	 */
	@BuilderParam defaultBuilder: CustomBuilder

	// 水印区域的总高度
	@Local waterMarkContainHeight: number = 0
	// 水印区域的总宽度
	@Local waterMarkContainWidth: number = 0
	@Local url: string = ''
	private settings: RenderingContextSettings = new RenderingContextSettings(true)
	private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
	private resourceManager = GlobalStore.context.resourceManager
	private uiContext = this.getUIContext()

	@Builder watermarkContent() {
		Image(this.url)
			.width(this.waterMarkContainWidth)
			.height(this.waterMarkContainHeight)
			.opacity(this.waterMarkOpacity)
			.hitTestBehavior(this.contentInteractive ? HitTestMode.Transparent : HitTestMode.Default)
	}
	getBgColor() {
		return this.bgColor || IBestWatermarkColor.bgColor
	}
	getFontColor() {
		return this.fontColor || (this.colorMode.value === 0 ? "#f5f5f5" : "#323232")
	}
	getText(){
		return getResourceStr(this.text)
	}
	// 清除画布
	clearCanvas() {
		this.context.clearRect(0, 0, this.waterMarkWidth, this.waterMarkHeight)
	}
	// 获取x轴与y轴的绘制数量
	getXYCount(width: number, height: number) {
		// 计算出水平数量
		let countX = Math.ceil(this.waterMarkContainWidth / (width + this.gapX))
		// 保证最少有一个
		if (countX <= 0) {
			countX = 1
		}
		// 计算出垂直数量
		let countY = Math.ceil(this.waterMarkContainHeight / (height + this.gapY))
		// 保证最少有一个
		if (countY <= 0) {
			countY = 1
		}
		// 避免因为旋转导致有部分留白 所以多渲染点
		countY = countY + 2
		countX = countX + 2
		const countData: IBestWatermarkCountData = {
			countX,
			countY
		}
		return countData
	}
	// 创建矩阵绘制canvas
	drawCanvasItem(data: IBestDrawCanvasItemArgs) {
		const width = data.width
		const height = data.height
		const rotateDeg = data.rotateDeg
		const callback = data.callback
		const countData = this.getXYCount(width, height)
		const countX = countData.countX
		const countY = countData.countY
		// 根据计算出的数量创建矩阵
		// i是Y轴
		for (let i = 0; i < countY; i++) {
			// j是X轴
			for (let j = 0; j < countX; j++) {
				const x = width * j + this.gapX * j
				const y = height * i + this.gapY * i
				this.context.save()
				this.context.translate(x, y)
				this.context.rotate(rotateDeg)
				callback()
				// 还原之前保存的状态
				this.context.restore()
			}
		}
		let url: string = this.context.toDataURL("png")
		if (url != "data:image/png") {
			this.url = url
		}
	}
	// 绘制图片
	async handleLayoutImg(rotateDeg: number) {
		let imgModel: PixelMap | ImageBitmap
		if (typeof this.imageUrl == 'string') {
			if(this.imageUrl.startsWith("data:image")){ // base64
				imgModel = await base64ToPixelMap(this.imageUrl)
			} else { // 本地选择的图片 网络图片
				imgModel = new ImageBitmap(this.imageUrl)
			}
		} else {	// Resource
			imgModel = await base64ToPixelMap(this.resourceManager.getMediaContentBase64Sync(this.imageUrl))
		}
		this.drawCanvasItem({
			width: this.waterMarkWidth,
			height: this.waterMarkHeight,
			rotateDeg,
			callback: () => {
				this.context.drawImage(imgModel, 0, 0, this.waterMarkWidth, this.waterMarkHeight)
			}
		})
	}
	// 绘制文字
	handleLayoutText(rotateDeg: number) {
		let text = this.getText()
		this.context.fillStyle = this.getFontColor()
		this.context.font = `${this.uiContext.vp2px(this.fontSize)}px ${this.fontFamily}`
		const data = this.context.measureText(text)
		this.drawCanvasItem({
			width: data.width,
			height: data.height,
			rotateDeg,
			callback: () => {
				this.context.fillText(text, 0, 0)
			}
		})
	}
	// 绘制水印
	drawWaterMark() {
		this.clearCanvas()
		this.context.textBaseline = 'top'
		const rotateDeg = this.rotateDeg * Math.PI / 180
		if(this.text){
			this.handleLayoutText(rotateDeg)
		}else if(this.imageUrl){
			this.handleLayoutImg(rotateDeg)
		}
	}
	build() {
		Stack() {
			Canvas(this.context)
				.width(this.waterMarkContainWidth)
				.height(this.waterMarkContainHeight)
				.onReady(() => {
					this.drawWaterMark()
				})
				.opacity(0)
				.enabled(false)
			if (this.waterMarkZIndex <= 0) {
				this.watermarkContent()
			}
			Column() {
				if (this.defaultBuilder) {
					this.defaultBuilder()
				}
			}
			.onAreaChange((oldValue: Area, newValue: Area) => {
				this.waterMarkContainHeight = newValue.height as number
				this.waterMarkContainWidth = newValue.width as number
			})
			if (this.waterMarkZIndex > 0) {
				this.watermarkContent()
			}
		}
		.backgroundColor(this.getBgColor())
	}
}