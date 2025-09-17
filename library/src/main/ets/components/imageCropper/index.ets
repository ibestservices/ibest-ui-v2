import image from '@ohos.multimedia.image'
import common from '@ohos.app.ability.common'
import fs from '@ohos.file.fs'
import { request } from '@kit.BasicServicesKit'
import { generateId, getComponentsInfo, getComponentSnapshot, getSizeByUnit } from '../../utils/utils'
import { IBestImageCropperController } from './index.type'
import { IBestImageCropperColor } from './color'
import GlobalStore from '../../utils/GlobalStore'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { buffer } from '@kit.ArkTS'
import { IBestStringNumber } from '../../model/Global.type'

@ComponentV2
export struct IBestImageCropper {
	/**
	 * 需要裁剪的图片地址
	 */
	@Param @Require url: ResourceStr
	/**
	 * 组件宽度
     */
	@Param componentWidth: IBestStringNumber = "100%"
	/**
	 * 组件高度
     */
	@Param componentHeight: IBestStringNumber = "100%"
	/**
	 * 背景色
     */
	@Param bgColor: ResourceColor = "#000"

	/*
	 * 裁剪形状
	 */
	@Param shape: 'rect' | 'circle' = "rect"
	/**
	 * 蒙层颜色
     */
	@Param maskColor: ResourceColor = "rgba(0,0,0,0.6)"
	/**
	 * 裁剪区域宽度或直径
     */
	@Param centerWidth: IBestStringNumber = "60%"
	/**
	 * 裁剪区域高度, 仅当shape为rect时有效
     */
	@Param centerHeight: IBestStringNumber = "60%"
	/**
	 * 是否显示裁剪区域边框
     */
	@Param showBorder: boolean = true
	/**
	 * 边框颜色
     */
	@Param bdColor: ResourceColor = IBestImageCropperColor.borderColor
	/**
	 * 最大缩放比例
	 */
	@Param maxScale: number = 2
	/**
	 * 是否开启旋转, 开启后不可移动
	 * @since 1.0.3
	 */
	@Param enableRotate: boolean = false
	/**
	 * 最大旋转角度, 默认180°, 即顺时针最大180°, 逆时针最大180°
	 * @since 1.0.3
	 */
	@Param maxAngle: number = 180
	/**
	 * 控制器实例
     */
	@Param controller: IBestImageCropperController = new IBestImageCropperController()

	@Local uniId: number = 0
	@Local scaleValue: number = 1
	private pinchScaleValue: number = 1
	@Local offsetX: number = 0
	@Local offsetY: number = 0
	@Local positionX: number = 0
	@Local positionY: number = 0
	@Local angle: number = 0
	private pinchAngle: number = 0
	@Local imgInitWidth: number = 0
	@Local imgInitHeight: number = 0
	@Local imgWidth: number = 0
	@Local imgHeight: number = 0
	@Local offsetMaxX: number = 0
	@Local offsetMaxY: number = 0
	@Local realCenterWidth: number = 0
	@Local realCenterHeight: number = 0
	private imgModel: PixelMap | null = null
	private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right
	| PanDirection.Up | PanDirection.Down })
	private settings: RenderingContextSettings = new RenderingContextSettings(true)
	private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
	private uiContext = this.getUIContext()
	private pageContext = this.uiContext.getHostContext() as common.UIAbilityContext
	private resourceManager = GlobalStore.context.resourceManager
	private sandBoxPath: string = ""

	@Builder corner(angle: number = 0){
		Path()
			.width(this.realCenterWidth/2)
			.aspectRatio(1)
			.fill(this.maskColor)
			.commands(this.getCommands())
			.stroke(Color.Transparent)
			.rotate({z: 1, angle})
	}

	aboutToAppear() {
		this.uniId = this.getUniqueId()
		this.controller.setScale = (scale: number): void => this.setScale(scale)
		this.controller.setAngle = (angle: number): void => this.setAngle(angle)
		this.controller.reset = (): void => this.reset()
		this.controller.getResult = (callBack?: (result: PixelMap) => void): Promise<PixelMap> => this.getResult(callBack)
		this.getCenterSize()
	}
	aboutToDisappear(): void {
		this.clearCache()
	}
	@Monitor("enableRotate")
	enableRotateChange(){
		this.pinchAngle = this.angle = 0
		this.positionX = this.positionY = this.offsetX = this.offsetY = 0
	}
	// 获取透镜尺寸
	getCenterSize(){
		setTimeout(() => {
			let size = getComponentsInfo(this.uiContext, this.getId())
			this.realCenterWidth = size.width
			this.realCenterHeight = this.shape == 'circle' ? size.width : size.height
			if (this.url) {
				this.init()
			}
		}, 50)
	}
	// 清理沙箱缓存
	clearCache(){
		try {
			fs.unlinkSync(this.sandBoxPath)
		}catch(e){}
	}
	// 根据图片信息初始化参数
	@Monitor("url")
	async init() {
		if(!this.url){
			this.imgModel = null
			return
		}
		this.resetParams()
		if(this.sandBoxPath){
			this.clearCache()
		}
		let path = `${this.pageContext.cacheDir}/${generateId()}_${Date.now()}.jpg`
		this.sandBoxPath = path
		if (typeof this.url == 'string') {
			if (this.url.startsWith("http")) { // 网络图片
				let task = await request.agent.create(this.pageContext, {
					action: request.agent.Action.DOWNLOAD,
					url: this.url,
					overwrite: true,
					saveas: path
				})
				task.on('completed', () => {
					this.getImageInfo(path)
				})
				await task.start()
				return
			}else if(this.url.startsWith("data:image")) { // base64
				let base64 = this.url.replace(/^data:image\/\w+;base64,/, "")
				let dataBuffer = buffer.from(base64, 'base64')
				this.writeToSandBox(dataBuffer.buffer)
			} else { // 本地选择的图片 \ 沙箱路径
				let file = fs.openSync(this.url, fs.OpenMode.CREATE)
				fs.copyFileSync(file.fd, path)
			}
		} else {	// Resource
			this.writeToSandBox(this.resourceManager.getMediaContentSync(this.url.id, 0).buffer)
		}
		this.getImageInfo(path)
	}
	// 获取图片信息
	async getImageInfo(path: string) {
		let imageSource = image.createImageSource(path)
		this.imgModel = await imageSource.createPixelMap()
		let imageInfo = await imageSource.getImageInfo()
		let width = this.uiContext.px2vp(imageInfo.size.width)
		let height = this.uiContext.px2vp(imageInfo.size.height)
		let aspect = width / height
		if (width > height) { // 横向图片
			this.imgInitHeight = this.realCenterHeight
			this.imgInitWidth = this.imgInitHeight * aspect
		} else { // 纵向图片
			this.imgInitWidth = this.realCenterWidth
			this.imgInitHeight = this.imgInitWidth / aspect
		}
		this.setParams()
	}
	// 设置参数
	setParams() {
		this.setImgSize()
		this.offsetMaxX = Math.abs(Number(((this.imgWidth - this.realCenterWidth) / 2).toFixed()))
		this.offsetMaxY = Math.abs(Number(((this.imgHeight - this.realCenterHeight) / 2).toFixed()))
		this.offsetX = this.offsetX >= this.offsetMaxX ? this.offsetMaxX : this.offsetX <= -this.offsetMaxX ? -this.offsetMaxX : this.offsetX
		this.offsetY = this.offsetY >= this.offsetMaxY ? this.offsetMaxY : this.offsetY <= -this.offsetMaxY ? -this.offsetMaxY : this.offsetY
		this.positionX = this.offsetX
		this.positionY = this.offsetY
	}
	// 设置图片动态尺寸
	setImgSize() {
		this.imgWidth = Number((this.imgInitWidth * this.scaleValue).toFixed())
		this.imgHeight = Number((this.imgInitHeight * this.scaleValue).toFixed())
	}
	// 重置参数
	resetParams(){
		this.scaleValue = 1
		this.pinchScaleValue = 1
		this.offsetX = 0
		this.offsetY = 0
		this.positionX = 0
		this.positionY = 0
		this.offsetMaxX = 0
		this.offsetMaxY = 0
		this.angle = 0
		this.pinchAngle = 0
	}
	getCommands(){
		let width = this.uiContext.vp2px(this.realCenterWidth/2)
		return `M0 ${width} V0 0 L${width} 0 A${width} ${width} 0 0 0 0 ${width}`
	}
	getId(){
		return `ibest_imagecrop_${this.uniId}`
	}
	// 绘制
	drawImg(){
		this.context.clearRect(0, 0, this.realCenterWidth, this.realCenterHeight)
		this.context.reset()
		this.context.translate(this.realCenterWidth / 2, this.realCenterHeight / 2)
		this.context.rotate(this.angle * Math.PI / 180)
		this.context.drawImage(this.imgModel, this.offsetX - this.imgWidth / 2, this.offsetY - this.imgHeight / 2, this.imgWidth, this.imgHeight)
	}
	// 将arrayBuffer写入沙箱
	writeToSandBox(arrayBuffer: ArrayBuffer | ArrayBufferLike) {
		let file = fs.openSync(this.sandBoxPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
		fs.writeSync(file.fd, arrayBuffer)
		fs.closeSync(file.fd)
	}
	// 设置比例
	setScale(scale: number){
		scale = scale < 1 ? 1 : scale > this.maxScale ? this.maxScale : scale
		this.pinchScaleValue = this.scaleValue = scale
		this.setParams()
	}
	// 设置角度
	setAngle(angle: number){
		if(this.enableRotate){
			angle = angle < -this.maxAngle ? -this.maxAngle : angle > this.maxAngle ? this.maxAngle : angle
			this.pinchAngle = this.angle = angle
		}else {
			console.warn('旋转功能未启用')
		}
	}
	// 重置
	reset(){
		this.resetParams()
		this.setParams()
	}
	// 获取最终截取结果
	getResult(callBack?: (result: PixelMap) => void): Promise<PixelMap> {
		return new Promise((resolve, reject) => {
			this.drawImg()
			setTimeout(() => {
				let res = getComponentSnapshot(this.uiContext, this.getId())
				if(callBack){
					callBack(res)
				}else{
					resolve(res)
				}
			}, 100)
		})
	}
	build() {
		Stack({ alignContent: Alignment.Center }) {
			Image(this.imgModel)
				.width(this.imgInitWidth)
				.height(this.imgInitHeight)
				.objectFit(ImageFit.Contain)
				.scale({ x: this.scaleValue, y: this.scaleValue, z: 1 })
				.translate({ x: this.offsetX, y: this.offsetY, z: 0 })
				.rotate({z: 1, angle: this.angle})
				.animation({
					duration: 100
				})
				.visibility(this.url ? Visibility.Visible : Visibility.Hidden)
			Canvas(this.context)
				.width(getSizeByUnit(this.centerWidth))
				.height(getSizeByUnit(this.centerHeight))
				.aspectRatio(this.shape == 'circle' ? 1 : undefined)
				.borderRadius(this.shape == 'circle' ? this.realCenterWidth / 2 : 0)
				.position({left: -9999, top: -9999})
				.clip(true)
				.id(this.getId())
			Column(){
				Row()
					.width(CONTAINER_SIZE.FULL)
					.layoutWeight(1)
					.backgroundColor(this.maskColor)
				Row(){
					Row()
						.layoutWeight(1)
						.height(CONTAINER_SIZE.FULL)
						.backgroundColor(this.maskColor)
					Stack({alignContent: Alignment.Center}){
						if(this.shape == 'circle'){
							Flex({wrap: FlexWrap.Wrap}){
								this.corner()
								this.corner(90)
								this.corner(-90)
								this.corner(180)
							}
							if(this.showBorder){
								Circle()
									.width(this.realCenterWidth-1)
									.aspectRatio(1)
									.fillOpacity(0)
									.stroke(this.bdColor)
							}
						}
					}
					.width(getSizeByUnit(this.centerWidth))
					.height(CONTAINER_SIZE.FULL)
					.border({width: this.shape == 'rect' && this.showBorder ? 1 : 0, color: this.bdColor})
					.clip(true)
					Row()
						.layoutWeight(1)
						.height(CONTAINER_SIZE.FULL)
						.backgroundColor(this.maskColor)
				}
				.width(CONTAINER_SIZE.FULL)
				.height(this.realCenterHeight)
				Row()
					.width(CONTAINER_SIZE.FULL)
					.layoutWeight(1)
					.backgroundColor(this.maskColor)
			}
			.width(CONTAINER_SIZE.FULL)
			.height(CONTAINER_SIZE.FULL)
		}
		.width(getSizeByUnit(this.componentWidth))
		.height(getSizeByUnit(this.componentHeight))
		.backgroundColor(this.bgColor)
		.clip(true)
		.gesture(
			// 移动
			PanGesture(this.panOption)
				.onActionUpdate((event: GestureEvent) => {
					let x = Number((this.positionX + event.offsetX).toFixed())
					let y = Number((this.positionY + event.offsetY).toFixed())
					this.offsetX = x >= this.offsetMaxX ? this.offsetMaxX : x <= -this.offsetMaxX ? -this.offsetMaxX : x
					this.offsetY = y >= this.offsetMaxY ? this.offsetMaxY : y <= -this.offsetMaxY ? -this.offsetMaxY : y
				})
				.onActionEnd(() => {
					this.positionX = this.offsetX
					this.positionY = this.offsetY
				})
		)
		.gesture(
		  	GestureGroup(GestureMode.Parallel,
				// 缩放
				PinchGesture({ fingers: 2 })
					.onActionUpdate((event: GestureEvent) => {
						let scale = Number((this.pinchScaleValue * event.scale).toFixed(1))
						this.scaleValue = scale
						this.setImgSize()
					})
					.onActionEnd(() => {
						this.scaleValue = this.scaleValue < 1 ? 1 : this.scaleValue > this.maxScale ? this.maxScale : this.scaleValue
						this.pinchScaleValue = this.scaleValue
						this.setParams()
					}),
				// 旋转
				RotationGesture({ fingers: 2 })
					.onActionUpdate((event: GestureEvent) => {
						let angle = this.pinchAngle + event.angle
						angle = angle < -this.maxAngle ? -this.maxAngle : angle > this.maxAngle ? this.maxAngle : angle
						this.angle = angle
					})
					.onActionEnd(() => {
						this.pinchAngle = this.angle
					})
		  	)
		)
		.onGestureJudgeBegin((gestureInfo: GestureInfo) => {
			if (gestureInfo.type == GestureControl.GestureType.PAN_GESTURE && this.enableRotate || gestureInfo.type == GestureControl.GestureType.ROTATION_GESTURE && !this.enableRotate) {
				return GestureJudgeResult.REJECT
			}
			return GestureJudgeResult.CONTINUE
		})
	}
}