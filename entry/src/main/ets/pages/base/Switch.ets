import { IBestDialogUtil, IBestSwitch } from '@ibestservices/ibest-ui-v2';
import { CONTAINER_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function SwitchBuilder(_: string, title: string){
	SwitchPage({title})
}

@Entry
@ComponentV2
struct SwitchPage {
	@Param title: string = ''
	@Local value: boolean = false
	@Local value1: boolean = true
	@Local value2: boolean = false
	@Local stringValue: string = 'off'
	@Local numberValue: number = 1
	@Local value3: boolean = true
	@Local value4: boolean = false
	@Local value5: boolean = true
	@Local value6: boolean = false
	@Local value7: boolean = true
	@Local value8: boolean = true

	@Local arrowDirection: 'left' | 'right' = 'left'
	@Builder Arrow() {
		Row() {
			Image($r('app.media.title_back'))
				.width(CONTAINER_SIZE.FOURTEEN)
				.fillColor(this.arrowDirection === 'left' ? '#db3131' : '#e2e3e7')
				.rotate({
					angle: this.arrowDirection === 'left' ? 0 : -180
				}).animation({
				duration: 200,
			})
		}
	}
	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法' }) {
						IBestSwitch({
							value: this.value!!
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义尺寸' }) {
						IBestSwitch({
							value: this.value1!!,
							switchSize: 20,
							componentWidth: 60
						}).margin({
							bottom: SPACE.SM
						})
						IBestSwitch({
							value: this.value1!!,
							componentPadding: 4
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '文字图标' }) {
						IBestSwitch({
							value: this.value2!!,
							inactiveText: "OFF",
							activeText: "ON",
							componentWidth: 70
						}).margin({
							bottom: SPACE.SM
						})
						IBestSwitch({
							value: this.value2!!,
							inactiveIcon: $r("app.media.icon_dark"),
							activeIcon: $r("app.media.icon_light"),
							activeTextColor: "#f0ff86"
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '扩展value类型' }) {
						Row({space: SPACE.SM}){
							Text("string")
							IBestSwitch({
								value: this.stringValue!!,
								inactiveValue: "off",
								activeValue: "on"
							})
							Text(this.stringValue)
						}
						.margin({
							bottom: SPACE.SM
						})
						Row({space: SPACE.SM}){
							Text("number")
							IBestSwitch({
								value: this.numberValue!!,
								inactiveValue: 0,
								activeValue: 1
							})
							Text(this.numberValue.toString())
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '禁用状态' }) {
						IBestSwitch({
							value: this.value3!!,
							disabled: true
						}).margin({
							bottom: SPACE.SM
						})
						IBestSwitch({
							value: this.value4!!,
							disabled: true
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '加载状态' }) {
						IBestSwitch({
							value: this.value5!!,
							loading: true,
						}).margin({
							bottom: SPACE.SM
						})
						IBestSwitch({
							value: this.value6!!,
							loading: true,
							activeColor: '#07c160'
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义按钮' }) {
						IBestSwitch({
							value: this.value7!!,
							activeColor: '#db3131',
							buttonBuilder: () => this.Arrow(),
							onChange: (value) => {
								this.arrowDirection = value ? 'left' : 'right'
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '异步控制' }) {
						IBestSwitch({
							value: this.value8!!,
							beforeChange: () => {
								return new Promise((resolve, reject) => {
									IBestDialogUtil.open({
										title: "提示",
										message: "确定更改状态?",
										showCancelButton: true,
										onConfirm: () => {
											resolve(true)
										},
										onCancel: () => {
											reject(false)
										}
									})
								})
							}
						})
					}
				}
				ListItem().height(50)
			}
			.layoutWeight(1)
			.padding({ left: SPACE.SM, right: SPACE.SM })
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}