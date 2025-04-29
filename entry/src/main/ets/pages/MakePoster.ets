import {
	IBestButton,
	IBestCanvasContent,
	IBestCanvasDrawer,
	IBestCellGroup,
	IBestDialog,
	IBestField,
	IBestForm,
	IBestFormController,
	IBestFormRule,
	IBestRadio,
	IBestRadioGroup,
	IBestToast,
	IBestUploader,
	IBestUploaderFile
} from '@ibestservices/ibest-ui-v2'
import { FONT_SIZE, modeColor, SPACE } from '../assets/styles/BaseStyle'
import CustomNavBar from '../components/CustomNavBar'
import { savePixelMap, shareImage } from '../utils/utils'
import { common } from '@kit.AbilityKit'
@Builder
export function MakePosterBuilder(){
	MakePosterPage()
}

@ObservedV2
class PosterForm{
	@Trace canvasWidth: number | string = ""
	@Trace canvasHeight: number | string = ""
	@Trace canvasBgType: string = ''
	@Trace canvasBgColor: string = ''
	@Trace canvasBgImg: string = ''
	@Trace radius: number | string = ''
	@Trace contentList: IBestCanvasContent[] = []
}

@Entry
@ComponentV2
struct MakePosterPage {
	@Param title: string = ""

	@Local formId: string = "posterForm"
	@Local form: PosterForm = new PosterForm()
	@Local canvasShow: boolean = false
	@Local pixelMap: PixelMap | null = null
	@Local imgVisible: boolean = false

	private formController: IBestFormController = new IBestFormController()
	private rules: IBestFormRule = {
		"canvasWidth": [
			{ required: true, message: '请输入海报宽度' }
		],
		"canvasHeight": [
		  	{ required: true, message: '请输入海报高度' }
		],
		"canvasBgType": [
		  	{ required: true, message: '请选择海报背景类型' }
		],
		"canvasBgColor": [
		  	{ required: true, message: '请输入海报背景颜色' }
		],
		"contentType": [
		  	{ required: true, message: '请选择内容类型' }
		],
		"canvasBgImg": [
		  	{ required: true, message: '请选择海报背景图片' }
		],
		"text": [
		    { required: true, message: '请输入文字' }
		],
		"image": [
		    { required: true, message: '请选择图片' }
		],
		"width": [
		    { required: true, message: '请输入宽度' }
		],
		"height": [
		    { required: true, message: '请输入高度'}
		]
	}
	private context = getContext(this) as common.UIAbilityContext

	@Builder bgTypeBuilder(){
		IBestRadioGroup({group: "radioGroup", active: this.form.canvasBgType!!, placeDirection: Axis.Horizontal}){
			IBestRadio({
				group: "radioGroup",
				name: "color",
				label: "颜色",
				iconSize: 14,
				labelFontSize: 14
			})
			IBestRadio({
				group: "radioGroup",
				name: "img",
				label: "图片",
				iconSize: 14,
				labelFontSize: 14
			})
		}
	}
	@Builder selectImgBuilder(){
		IBestUploader({
			fileList: this.form.canvasBgImg ? [new IBestUploaderFile({
				url: this.form.canvasBgImg
			})] : [],
			max: 1,
			onChange: (files: IBestUploaderFile[]) => {
				this.form.canvasBgImg = files[0].previewUri as string
			}
		})
	}

	@Builder imgBuilder(){
		Column({space: SPACE.MD}){
			Image(this.pixelMap)
				.width(this.form.canvasWidth)
				.height(this.form.canvasHeight)
			Row({space: SPACE.MD}){
				SaveButton({ text: SaveDescription.SAVE_IMAGE })
					.onClick((event: ClickEvent, result: SaveButtonOnClickResult) => {
						if (result == SaveButtonOnClickResult.SUCCESS) {
							this.saveImg(this.pixelMap)
						}
					})
				IBestButton({
					text: "分享",
					btnWidth: 100,
					btnHeight: 40,
					round: true,
					onBtnClick: () => {
						shareImage(this.context, this.pixelMap!)
					}
				})
			}
		}
		.padding(SPACE.MD)
	}
	async saveImg(pixelMap: PixelMap | null){
		if(pixelMap){
			await savePixelMap(this.context, pixelMap)
			IBestToast.show({ message: `截图保存成功` })
		}
	}
	deleteContent(index: number){
		this.form.contentList.splice(index, 1)
	}
	getRadius(){
		return Number(this.form.radius)
	}

	build() {
		NavDestination() {
			CustomNavBar({title: "制作海报"})
			Scroll(){
				Column({space: SPACE.MD}){
					IBestForm({
						formId: this.formId,
						labelWidth: 100,
						rules: this.rules,
						controller: this.formController
					}){
						Row().height(1)
						IBestCellGroup({inset: true}){
							IBestField({
								formId: this.formId,
								prop: "canvasWidth",
								label: "海报宽度",
								value: this.form.canvasWidth!!,
								type: "number",
								placeholder: "请输入海报宽度, 最小为100",
								min: 100
							})
							IBestField({
								formId: this.formId,
								prop: "canvasHeight",
								label: "海报高度",
								value: this.form.canvasHeight!!,
								type: "number",
								placeholder: "请输入海报高度, 最小为100",
								min: 100
							})
							IBestField({
								formId: this.formId,
								prop: "radius",
								label: "海报圆角",
								value: this.form.radius!!,
								type: "number",
								placeholder: "请输入海报圆角"
							})
							IBestField({
								formId: this.formId,
								prop: "canvasBgType",
								label: "海报背景类型",
								value: this.form.canvasBgType!!,
								hasBorder: this.form.canvasBgType !== "",
								customRightContent: (): void => this.bgTypeBuilder()
							})
							if(this.form.canvasBgType === "color"){
								IBestField({
									formId: this.formId,
									prop: "canvasBgColor",
									label: "海报背景颜色",
									value: this.form.canvasBgColor!!,
									placeholder: "请输入海报背景颜色, 例如 #fff",
									hasBorder: false
								})
							} else if(this.form.canvasBgType === "img"){
								IBestField({
									formId: this.formId,
									prop: "canvasBgImg",
									label: "海报背景图片",
									value: this.form.canvasBgImg,
									hasBorder: false,
									customRightContent: (): void => this.selectImgBuilder()
								})
							}
						}
						ForEach(this.form.contentList, (item: IBestCanvasContent, index: number) => {
							contentItem({
								item: item,
								formId: this.formId,
								index: index,
								delete: (): void => this.deleteContent(index)
							})
						}, (_: IBestCanvasContent, index: number) => index.toString())
					}
					IBestButton({
						text: "添加内容",
						type: "primary",
						round: true,
						btnWidth: "90%",
						onBtnClick: () => {
							this.form.contentList.push(new IBestCanvasContent())
							console.log("contentList", JSON.stringify(this.form.contentList))
						}
					})
					IBestButton({
						text: "生成海报",
						type: "primary",
						round: true,
						btnWidth: "90%",
						onBtnClick: () => {
							this.formController.validate(valid => {
								if(valid){
									this.canvasShow = true
								}
							})
						}
					})
					Row().height(50)
				}
			}
			.layoutWeight(1)
			.align(Alignment.Top)
			if(this.canvasShow){
				IBestCanvasDrawer({
					canvasWidth: Number(this.form.canvasWidth),
					canvasHeight: Number(this.form.canvasHeight),
					canvasBgColor: this.form.canvasBgColor,
					canvasBgImg: this.form.canvasBgImg,
					radius: this.getRadius(),
					contentList: this.form.contentList,
					onDrawFinish: pixelMap => {
						this.pixelMap = pixelMap
						this.canvasShow = false
						this.imgVisible = true
					}
				})
			}
			IBestDialog({
				visible: this.imgVisible!!,
				defaultBuilder: () => this.imgBuilder()
			})
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}

@ComponentV2
struct contentItem{
	@Param @Require item: IBestCanvasContent
	@Param @Require formId: string
	@Param @Require index: number = 0
	@Local groupId: string = "radioGroup" + this.index
	@Local text: string = ""
	@Local fontColor: string = ""
	@Event delete: (index: number) => void = () => {}
	@Builder contentTypeBuilder(){
		IBestRadioGroup({group: this.groupId, active: this.item.type!!, placeDirection: Axis.Horizontal}){
			IBestRadio({
				group: this.groupId,
				name: "text",
				label: "文字",
				iconSize: 14,
				labelFontSize: 14
			})
			IBestRadio({
				group: this.groupId,
				name: "image",
				label: "图片",
				iconSize: 14,
				labelFontSize: 14
			})
		}
	}
	@Builder selectImgBuilder(){
		IBestUploader({
			fileList: this.item.url ? [new IBestUploaderFile({
				url: this.item.url as string
			})] : [],
			max: 1,
			onChange: fileList => {
				this.item.url = fileList[0].previewUri as string
			}
		})
	}
	@Monitor("text") textChange(){
		this.item.text = this.text
	}
	@Monitor("fontColor") fontColorChange(){
		this.item.fontColor = this.fontColor
	}

	build() {
		IBestCellGroup({title: `内容${this.index+1}`, inset: true}){
			Text("删除")
				.fontColor(modeColor.textColor4)
				.fontSize(FONT_SIZE.SM)
				.position({right: 0, top: 17})
				.onClick(() => {
					this.delete(this.index)
				})
			IBestField({
				formId: this.formId,
				prop: `contentType.${this.index}`,
				label: "内容类型",
				value: this.item.type,
				customRightContent: (): void => this.contentTypeBuilder()
			})
			if(this.item.type === "text"){
				IBestField({
					formId: this.formId,
					prop: `text.${this.index}`,
					label: "文字内容",
					value: this.text!!,
					placeholder: "请输入文字内容"
				})
				IBestField({
					formId: this.formId,
					prop: `fontSize.${this.index}`,
					label: "文字大小",
					value: this.item.fontSize!!,
					type: "number",
					placeholder: "请输入文字大小"
				})
				IBestField({
					formId: this.formId,
					prop: `fontColor.${this.index}`,
					label: "文字颜色",
					value: this.fontColor!!,
					placeholder: "请输入文字颜色"
				})
			} else if(this.item.type === "image"){
				IBestField({
					formId: this.formId,
					prop: `image.${this.index}`,
					label: "图片",
					value: this.item.url as string,
					customRightContent: (): void => this.selectImgBuilder()
				})
				IBestField({
					formId: this.formId,
					prop: `width.${this.index}`,
					label: "宽度",
					value: this.item.width!!,
					type: "number",
					placeholder: "请输入图片宽度"
				})
				IBestField({
					formId: this.formId,
					prop: `height.${this.index}`,
					label: "高度",
					value: this.item.height!!,
					type: "number",
					placeholder: "请输入图片高度"
				})
				IBestField({
					formId: this.formId,
					prop: `radius.${this.index}`,
					label: "圆角",
					value: this.item.borderRadius!!,
					type: "number",
					placeholder: "请输入图片圆角"
				})
				IBestField({
					formId: this.formId,
					prop: `angle.${this.index}`,
					label: "旋转角度",
					value: this.item.deg!!,
					type: "number",
					placeholder: "请输入图片旋转角度"
				})
			}
			IBestField({
				formId: this.formId,
				prop: `top.${this.index}`,
				label: "顶部距离",
				value: this.item.top!!,
				type: "number",
				placeholder: "请输入顶部距离"
			})
			IBestField({
				formId: this.formId,
				prop: `left.${this.index}`,
				label: "左侧距离",
				value: this.item.left!!,
				type: "number",
				placeholder: "请输入左侧距离",
				hasBorder: false
			})
		}
	}
}