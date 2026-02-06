import { IBestToast, IBestUploader, IBestUploaderFile } from '@ibestservices/ibest-ui-v2'
import { CONTAINER_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import CustomNavBar from '../../components/CustomNavBar'

@Builder
export function UploaderBuilder(_: string, title: string){
	UploaderPage({title})
}

@Entry
@ComponentV2
struct UploaderPage {
	@Param title: string = ''

	@Local imgList: IBestUploaderFile[] = []
	@Local imgList1: IBestUploaderFile[] = []
	@Local imgList2: IBestUploaderFile[] = [
		new IBestUploaderFile({
			url: "https://img0.baidu.com/it/u=2229144304,3578627907&fm=253&fmt=auto&app=138&f=JPEG?w=467&h=300",
			isImage: true,
			status: "uploading"
		}),
		new IBestUploaderFile({
			url: "https://pic1.zhimg.com/80/v2-03cdb3bff2090e98885fe4951799a1f4_1440w.webp",
			status: "failed"
		})
	]
	@Local imgList3: IBestUploaderFile[] = [
		new IBestUploaderFile({
			url: "https://pic1.zhimg.com/80/v2-03cdb3bff2090e98885fe4951799a1f4_1440w.webp"
		})
	]
	@Local imgList4: IBestUploaderFile[] = []
	@Local imgList5: IBestUploaderFile[] = []
	@Local imgList6: IBestUploaderFile[] = []
	@Local imgList7: IBestUploaderFile[] = []
	@Local imgList8: IBestUploaderFile[] = []
	@Local imgList9: IBestUploaderFile[] = [
		new IBestUploaderFile({
			url: "https://pic1.zhimg.com/80/v2-03cdb3bff2090e98885fe4951799a1f4_1440w.webp"
		})
	]

	@Builder customUploader(){
		Text("选择图片")
			.width(100)
			.height(50)
			.textAlign(TextAlign.Center)
			.backgroundColor("#3D8AF2")
			.fontColor(Color.White)
			.fontSize(14)
	}

	@Builder previewItem(file: IBestUploaderFile, index: number){
		Column() {
			Image(file.url || file.previewUri)
				.width(CONTAINER_SIZE.FULL)
			Text(file.name)
				.width(CONTAINER_SIZE.FULL)
				.fontSize(14)
				.textAlign(TextAlign.Center)
				.maxLines(1)
				.textOverflow({ overflow: TextOverflow.Ellipsis })
				.position({ left: 0, bottom: 0 })
		}
		.width(CONTAINER_SIZE.FULL)
		.height(CONTAINER_SIZE.FULL)
		.justifyContent(FlexAlign.Center)
	}

	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法' }) {
						IBestUploader({
							fileList: this.imgList!!
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '选择文件' }) {
						IBestUploader({
							fileList: this.imgList1!!,
							selectType: "file"
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '上传状态' }) {
						IBestUploader({
							fileList: this.imgList2!!,
							selectType: "file"
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '限制上传数量' }) {
						IBestUploader({
							fileList: this.imgList3!!,
							max: 1
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '限制上传大小' }) {
						IBestUploader({
							fileList: this.imgList4!!,
							maxSize: 1024 * 2
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义上传触发器', space: SPACE.MD }) {
						IBestUploader({
							fileList: this.imgList5!!,
							uploaderIcon: $r("app.media.icon_plus")
						})
						IBestUploader({
							fileList: this.imgList6!!,
							customUploader: (): void => this.customUploader()
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义预览样式' }) {
						IBestUploader({
							fileList: this.imgList7!!,
							previewSize: 120,
							cornerRadius: 8
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义预览内容' }) {
						IBestUploader({
							fileList: this.imgList7!!,
							customPreviewBuilder: (file: IBestUploaderFile, index: number): void => this.previewItem(file, index)
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '插入前处理' }) {
						IBestUploader({
							fileList: this.imgList8!!,
							onBeforeInsert: (file: IBestUploaderFile): boolean => {
								if(file.size as number > 10 * 1024){
									IBestToast.show("请上传10k以下的图片")
									return false
								}
								return true
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '禁用' }) {
						IBestUploader({
							fileList: this.imgList9!!,
							disabled: true
						})
					}
				}
			}
			.layoutWeight(1)
			.padding({ left: SPACE.SM, right: SPACE.SM })
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg2)
	}
}