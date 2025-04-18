import { IBestSlider, IBestToast } from '@ibestservices/ibest-ui-v2'
import { COLOR_BLUE, CONTAINER_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import CustomNavBar from '../../components/CustomNavBar'

@Builder
export function SliderBuilder(_: string, title: string){
	SliderPage({title})
}

@Entry
@ComponentV2
struct SliderPage {
	@Param title: string = ''
	@Local value: number = 30
	@Local value1: [number, number] = [20, 60]
	@Local value2: number = 30
	@Local value3: number = 30
	@Local value4: number = 30
	@Local value5: number = 30
	@Local value6: number = 30
	@Local value7: number = 30
	@Local value8: [number, number] = [20, 60]

	@Builder customBtn(){
		Text(this.value6.toString())
			.height(18)
			.borderRadius(9999)
			.padding({ left: 10, right: 10 })
			.backgroundColor(COLOR_BLUE.TEXT)
			.fontColor(COLOR_BLUE.DEFAULT)
			.fontSize(12)
	}

	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法' }) {
						Column({ space: 20 }){
							IBestSlider({
								value: this.value!!,
								onChange: val => {
									console.log(val.toString())
									IBestToast.show(val.toString())
								}
							})
							IBestSlider({
								value: this.value!!,
								reverse: true,
								onChange: val => {
									console.log(val.toString())
									IBestToast.show(val.toString())
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '双滑块' }) {
						Column({ space: 20 }){
							IBestSlider({
								value: this.value1!!,
								onChange: val => {
									console.log(val.toString())
									IBestToast.show(val.toString())
								}
							})
							IBestSlider({
								value: this.value1!!,
								reverse: true,
								onChange: val => {
									console.log(val.toString())
									IBestToast.show(val.toString())
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '指定选择范围' }) {
						IBestSlider({
							value: this.value2!!,
							min: -50,
							max: 50,
							onChange: val => {
								IBestToast.show(val.toString())
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '禁用' }) {
						IBestSlider({
							value: this.value3!!,
							disabled: true
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '指定步长' }) {
						IBestSlider({
							value: this.value4!!,
							step: 10,
							onChange: val => {
								IBestToast.show(val.toString())
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义样式' }) {
						IBestSlider({
							value: this.value5!!,
							barHeight: 8,
							activeColor: "#ee0a24",
							onChange: val => {
								IBestToast.show(val.toString())
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义按钮' }) {
						IBestSlider({
							value: this.value6!!,
							customButton: (): void => this.customBtn(),
							onChange: val => {
								IBestToast.show(val.toString())
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '垂直方向' }) {
						Row({ space: 80 }){
							Row({ space: 30 }){
								IBestSlider({
									value: this.value7!!,
									vertical: true,
									onChange: val => {
										console.log(val.toString())
										IBestToast.show(val.toString())
									}
								})
								IBestSlider({
									value: this.value7!!,
									vertical: true,
									reverse: true,
									onChange: val => {
										console.log(val.toString())
										IBestToast.show(val.toString())
									}
								})
							}
							Row({ space: 30 }){
								IBestSlider({
									value: this.value8!!,
									vertical: true,
									onChange: val => {
										console.log(val.toString())
										IBestToast.show(val.toString())
									}
								})
								IBestSlider({
									value: this.value8!!,
									vertical: true,
									reverse: true,
									onChange: val => {
										console.log(val.toString())
										IBestToast.show(val.toString())
									}
								})
							}
						}
						.width(CONTAINER_SIZE.FULL)
						.height(300)
						.justifyContent(FlexAlign.Center)
					}
				}
				ListItem().height(50)
			}
			.layoutWeight(1)
			.padding({ left: SPACE.XS, right: SPACE.XS })
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}