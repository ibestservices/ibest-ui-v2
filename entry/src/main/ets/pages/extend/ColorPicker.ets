import { IBestButton, IBestColorPicker, IBestField, IBestPopup } from '@ibestservices/ibest-ui-v2';
import { modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function ColorPickerBuilder(_: string, title: string){
	ColorPickerPage({title})
}

@Entry
@ComponentV2
struct ColorPickerPage {
	@Param title: string = ""
	@Local color: string = "#1989fa"
	@Local color1: string = "#1989fa"
	@Local visible: boolean = false
	@Local color2: string = "rgba(238,10,36,0.8)"
	@Local color3: string = "rgba(255, 69, 0, 0.68)"
	@Local color4: string = ""
	@Builder pickerBuilder(){
		Column({space: 20}){
			IBestColorPicker({
				value: this.color1!!
			})
			Row({space: 20}){
				IBestButton({
					text: "取消",
					onBtnClick: () => {
						this.visible = false
					}
				})
				IBestButton({
					type: "primary",
					text: "确定",
					onBtnClick: () => {
						this.visible = false
					}
				})
			}
		}.padding(20)
	}
	build() {
		NavDestination(){
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法' }) {
						Text(this.color).fontColor(this.color).margin({bottom: 10})
						IBestColorPicker({
							value: this.color!!
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '搭配弹框使用' }) {
						IBestField({
							label: '选择颜色',
							value: this.color1,
							placeholder: "请选择颜色",
							labelColor: this.color1,
							isLink: true,
							hasBorder: false,
							onFieldClick: () => {
								this.visible = true
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '透明度' }) {
						Text(this.color2).fontColor(this.color2).margin({bottom: 10})
						IBestColorPicker({
							value: this.color2!!,
							enableAlpha: true
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '预定颜色' }) {
						Text(this.color3).fontColor(this.color3).margin({bottom: 10})
						IBestColorPicker({
							value: this.color3!!,
							enableAlpha: true,
							predefineColors: [
								'#ff4500',
								'#ff8c00',
								'#ffd700',
								'#90ee90',
								'#00ced1',
								'#1e90ff',
								'#c71585',
								'rgba(255, 69, 0, 0.68)',
								'rgba(146, 50, 20, 0.8)',
								'rgba(107, 167, 50, 0.5)',
								'rgb(255, 120, 0)',
								'rgb(125, 255, 0)',
								'#ffced1cc',
								'#c7158577',
								'#1e90ff99'
							]
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义尺寸' }) {
						Text(this.color4).fontColor(this.color4).margin({bottom: 10})
						IBestColorPicker({
							value: this.color4!!,
							panelHeight: 120,
							cursorWidth: 16,
							hueSliderWidth: 20,
							hueSliderHeight: 12,
							predefineBlockWidth: 28,
							predefineColors: [
								'#ff4500',
								'#ff8c00'
							]
						})
					}
				}
				ListItem().height(50)
			}
			.layoutWeight(1)
			.padding({ left: SPACE.SM, right: SPACE.SM })
			// 弹出层
			IBestPopup({
				visible: this.visible!!,
				popupWidth: 320,
				contentBuilder: (): void => this.pickerBuilder()
			})
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}