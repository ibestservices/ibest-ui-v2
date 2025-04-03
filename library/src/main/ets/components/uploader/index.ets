import { FileSelectOptions, IBestUploaderFile, IBestUploaderSelectType } from './index.type'
import { isImageFile, isImageUrl } from './utils'
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { picker } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { IBestLoading } from '../loading'
import fs from '@ohos.file.fs'
import { IBestIcon, IBestImagePreview } from '../../../../../Index'
import { convertDimensions, convertDimensionsWidthUnit, getLengthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestUploaderColor } from './color'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'

@ComponentV2
export struct IBestUploader {
	/**
	 * 文件列表
	 */
	@Param fileList: IBestUploaderFile[] = []
	/**
	 * 选择类型
	 */
	@Param selectType: IBestUploaderSelectType = "image"
	/**
	 * 触发器背景色
     */
	@Param uploaderBgColor: ResourceColor = IBestUploaderColor.uploaderBgColor
	/**
	 * 自定义触发器图标
	 */
	@Param uploaderIcon: ResourceStr = "photograph"
	/**
	 * 触发器图标大小
	 */
	@Param uploaderIconSize: IBestStringNumber = convertDimensionsWidthUnit(24)
	/**
	 * 触发器图标颜色
	 */
	@Param uploaderIconColor: ResourceColor = IBestUploaderColor.uploaderIconColor
	/**
	 * 最大上传数量
	 */
	@Param max: number = -1
	/**
	 * 文件大小限制，单位为 byte
	 */
	@Param maxSize: number = -1
	/**
	 * 预览大小
	 */
	@Param previewSize: IBestStringNumber = convertDimensionsWidthUnit(80)
	/**
	 * 是否在点击预览图后展示全屏图片预览
	 */
	@Param isPreviewFullImage: boolean = true
	/**
	 * 预览图片裁剪方式
	 */
	@Param imageFit: ImageFit = ImageFit.Cover
	/**
	 * 圆角大小
	 */
	@Param cornerRadius: IBestStringNumber = 0
	/**
	 * 是否显示删除按钮
	 */
	@Param showDelete: boolean = true
	/**
	 * 文件选择配置项
	 */
	@Param fileSelectOptions?: FileSelectOptions = undefined
	/**
	 * 禁用
	 */
	@Param disabled: boolean = false
	/**
	 * 是否展示预览列表
     */
	@Param showPreviewList: boolean = true
	/**
	 * 自定义上传触发器
	 */
	@BuilderParam customUploader: CustomBuilder
	/**
	 * 自定义预览样式
	 */
	@BuilderParam customPreviewBuilder: (file: IBestUploaderFile, index: number) => void
	/**
	 * 文件插入前回调
	 */
	@Event onBeforeInsert: (file: IBestUploaderFile) => boolean = () => true
	/**
	 * 文件全部插入后回调
	 */
	@Event onChange: (insertFile: IBestUploaderFile[], allFile: IBestUploaderFile[]) => void = () => {}
	/**
	 * 超出限制后回调
	 */
	@Event onExceed: () => void = () => {}
	@Event $fileList: (fileList: IBestUploaderFile[]) => void = () => {}

	private context = getContext(this) as common.Context

	// 选择器触发
	select(){
		if(this.selectType == "image"){
			this.selectImg()
		}else{
			this.selectFile()
		}
	}
	// 选择文件
	selectFile(){
		let options = new picker.DocumentSelectOptions()
		const docPicker = new picker.DocumentViewPicker(this.context)
		options.maxSelectNumber = this.max > 0 ? this.max : 500
		if(this.fileSelectOptions){
			options.defaultFilePathUri = this.fileSelectOptions.defaultFilePathUri
			options.fileSuffixFilters = this.fileSelectOptions.fileSuffixFilters
		}
		docPicker.select(options).then(result => {
			this.onFileSelect(result)
		})
	}
	// 选择图片
	selectImg(){
		let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
		let photoPicker = new photoAccessHelper.PhotoViewPicker()
		PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
		PhotoSelectOptions.maxSelectNumber = this.max > 0 ? this.max : 500
		photoPicker.select(PhotoSelectOptions).then((result: photoAccessHelper.PhotoSelectResult) => {
			this.onFileSelect(result.photoUris)
		})
	}
	// 处理选择的文件
	onFileSelect(uris: string[]){
		if(this.max > 0 && this.fileList.length + uris.length > this.max){
			this.onExceed()
			return
		}
		let initList = [...this.fileList]
		let arr: IBestUploaderFile[] = []
		for (let e of uris) {
			let index = e.lastIndexOf("/")
			let file = fs.openSync(e, fs.OpenMode.READ_ONLY)
			let stat = fs.statSync(file.fd)
			if(this.maxSize > 0 && stat.size > this.maxSize){
				continue
			}
			// 元服务暂不支持
			// let fileName = file.name
			let fullName = e.slice(index + 1)
			let fileName = decodeURI(fullName.split(".")[0])
			let cacheUri = this.context.cacheDir + "/" + fullName
			fs.copyFileSync(file.fd, cacheUri)
			let obj = new IBestUploaderFile({
				previewUri: e,
				internalUri: `internal://cache/${fullName}`,
				cacheUri,
				name: fileName,
				size: stat.size,
				isImage: this.selectType == "image" || isImageUrl(e)
			})
			if(this.onBeforeInsert(obj)){
				arr.push(obj)
				initList.push(obj)
			}
		}
		this.$fileList(initList)
		if(arr.length){
			this.onChange(arr, initList)
		}
	}
	// 删除
	remove(index: number){
		let initList = [...this.fileList]
		initList.splice(index, 1)
		this.$fileList(initList)
	}
	// 预览图片
	preview(file: IBestUploaderFile){
		if(this.isPreviewFullImage){
			let imgLists = this.fileList.filter(e => e.isImage || isImageUrl(e.url as string))
			let index = imgLists.findIndex(e => e.internalUri == file.internalUri)
			IBestImagePreview.show(imgLists.map(e => e.url || e.previewUri || ""), { startIndex: index || 0 })
		}
	}

	build() {
		Flex({ wrap: FlexWrap.Wrap, space: {
			main: new LengthMetrics(convertDimensions(8), getLengthUnit()),
			cross: new LengthMetrics(convertDimensions(8), getLengthUnit())
		}}){
			if(this.showPreviewList && this.fileList.length){
				ForEach(this.fileList, (item: IBestUploaderFile, index: number) => {
					UploadItem({
						file: item,
						index,
						previewSize: this.previewSize,
						imageFit: this.imageFit,
						cornerRadius: this.cornerRadius,
						showDelete: this.showDelete,
						disabled: this.disabled,
						customPreviewBuilder: this.customPreviewBuilder,
						remove: (index: number): void => this.remove(index),
						preview: (file: IBestUploaderFile): void => this.preview(file)
					})
				})
			}
			if(this.customUploader){
				Row(){
					this.customUploader()
				}
				.visibility(this.max <= 0 || this.fileList.length < this.max ? Visibility.Visible : Visibility.None)
				.onClick(() => {
					this.select()
				})
			}else{
				Row(){
					IBestIcon({
						name: this.uploaderIcon,
						iconSize: this.uploaderIconSize,
						color: this.uploaderIconColor
					})
				}
				.width(getSizeByUnit(this.previewSize))
				.aspectRatio(1)
				.justifyContent(FlexAlign.Center)
				.borderRadius(getSizeByUnit(this.cornerRadius))
				.clip(true)
				.enabled(!this.disabled)
				.opacity(this.disabled ? 0.5 : 1)
				.stateStyles({
					normal: {
						.backgroundColor(this.uploaderBgColor)
					},
					pressed: {
						.backgroundColor(IBestUploaderColor.activeBg)
					}
				})
				.visibility(this.max > 0 && this.fileList.length >= this.max ? Visibility.None : Visibility.Visible)
				.onClick(() => {
					this.select()
				})
			}
		}
	}
}

@ComponentV2
struct UploadItem{
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local isError: boolean = false

	@Param @Require file: IBestUploaderFile
	@Param @Require index: number
	@Param @Require previewSize: IBestStringNumber
	@Param @Require imageFit: ImageFit
	@Param @Require cornerRadius: IBestStringNumber
	@Param @Require showDelete: boolean
	@Param @Require disabled: boolean
	@BuilderParam customPreviewBuilder: (file: IBestUploaderFile, index: number) => void

	// 移除文件
	@Event remove: (index: number) => void = () => {}
	// 预览
	@Event preview: (file: IBestUploaderFile) => void = () => {}

	build() {
		Column() {
			if (this.customPreviewBuilder) {
				this.customPreviewBuilder(this.file, this.index)
			} else {
				if (isImageFile(this.file)) {
					if(this.isError){
						IBestIcon({
							name: "photo-fail",
							iconSize: convertDimensionsWidthUnit(32),
							color: IBestUploaderColor.textColor
						})
					}else{
						Image(this.file.url || this.file.previewUri)
							.width(CONTAINER_SIZE.FULL)
							.aspectRatio(1)
							.fillColor(IBestUploaderColor.textColor)
							.objectFit(this.imageFit)
							.draggable(false)
							.onError(() => {
								this.isError = true
							})
							.onClick(() => {
								this.preview(this.file)
							})
					}
				} else {
					IBestIcon({
						name: "description",
						iconSize: convertDimensionsWidthUnit(20),
						color: IBestUploaderColor.textColor
					})
					if (this.file.name) {
						Text(this.file.name)
							.fontColor(IBestUploaderColor.textColor)
							.fontSize(this.baseStyle.fontSizeSm)
							.width(CONTAINER_SIZE.FULL)
							.maxLines(1)
							.textAlign(TextAlign.Center)
							.textOverflow({ overflow: TextOverflow.Ellipsis })
							.padding({ left: this.baseStyle.spaceBase, right: this.baseStyle.spaceBase })
							.margin({ top: this.baseStyle.spaceBase })
					}
				}
			}
			// 状态展示
			if (this.file.status && this.file.status != 'done') {
				Column({ space: convertDimensionsWidthUnit(6) }) {
					if (this.file.status == 'uploading') {
						IBestLoading({
							loadingSize: convertDimensionsWidthUnit(18),
							loadingStrokeWidth: 2,
							loadingColor: IBestUploaderColor.maskTextColor
						})
					} else {
						IBestIcon({
							name: "close",
							iconSize: convertDimensionsWidthUnit(20),
							color: IBestUploaderColor.maskTextColor
						})
					}
					Text(this.file.status == 'failed' ? $r("app.string.ibest_upload_failed") : $r("app.string.ibest_uploading"))
						.fontSize(this.baseStyle.fontSizeSm)
						.fontColor(IBestUploaderColor.maskTextColor)
				}
				.width(CONTAINER_SIZE.FULL)
				.height(CONTAINER_SIZE.FULL)
				.justifyContent(FlexAlign.Center)
				.alignItems(HorizontalAlign.Center)
				.backgroundColor("rgba(50,50,51,0.88)")
				.position({ left: 0, top: 0 })
			}
			// 删除按钮
			if (this.showDelete && !this.disabled) {
				Row() {
					IBestIcon({
						name: "cross",
						iconSize: convertDimensionsWidthUnit(14),
						color: IBestUploaderColor.maskTextColor
					})
						.scale({ x: 0.7, y: 0.7 })
						.translate({ x: "10%", y: "-10%" })
				}
				.width(convertDimensionsWidthUnit(16))
				.aspectRatio(1)
				.position({ right: 0, top: 0 })
				.backgroundColor("rgba(0,0,0,0.7)")
				.borderRadius({ bottomLeft: this.baseStyle.borderRadiusMax })
				.visibility(this.file.status == 'uploading' ? Visibility.None : Visibility.Visible)
				.onClick(() => {
					this.remove(this.index)
				})
			}
		}
		.width(getSizeByUnit(this.previewSize))
		.aspectRatio(1)
		.justifyContent(FlexAlign.Center)
		.alignItems(HorizontalAlign.Center)
		.borderRadius(getSizeByUnit(this.cornerRadius))
		.backgroundColor(isImageFile(this.file) ? '' : IBestUploaderColor.fileBgColor)
		.clip(true)
	}
}