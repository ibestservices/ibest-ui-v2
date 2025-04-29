import {
	IBestButton,
	IBestCheckbox,
	IBestCircleProgress,
	IBestProgress,
	IBestRadio,
	IBestRadioGroup,
	IBestSetUIBaseStyle,
	IBestSwitch,
	IBestTabs,
	IBestTag
} from '@ibestservices/ibest-ui-v2'
import { FONT_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import CustomNavBar from '../../components/CustomNavBar'
import { getRandomColor } from '../../utils/utils'

@Builder
export function ThemeBuilder(_: string, title: string){
	ThemePage({title})
}

@Entry
@ComponentV2
struct ThemePage {
	@Param title: string = ''
	@Local curTabName: string = "1"
	@Local colorText: string = '#07c160'
	@Local group: string = "themeGroup"
	@Local active: string = "1"
	@Local switchValue: boolean = true
	@Local progressValue: number = 50
	aboutToDisappear() {
		IBestSetUIBaseStyle({ primary: '#3D8AF2' })
	}
	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.custom_switch", $r("app.string.color")) }) {
						Row() {
							TextInput({ placeholder: $r("app.string.custom_placeholder", $r("app.string.custom_legal_color")), text: $$this.colorText })
								.fontSize(FONT_SIZE.SM)
								.layoutWeight(1)
								.margin({
									right: SPACE.SM
								})
							IBestButton({
								type: 'primary',
								text: $r("app.string.confirm"),
								round: true,
								buttonSize: 'small',
								onBtnClick: () => {
									IBestSetUIBaseStyle({ primary: this.colorText || '#3D8AF2' })
									this.colorText = getRandomColor()
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.component_button") }) {
						IBestButton({
							type: 'primary',
							text: $r("app.string.button")
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.component_checkbox") }) {
						IBestCheckbox({
							value: true,
							label: $r("app.string.content")
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.component_radio") }) {
						IBestRadioGroup({ group: this.group, active: this.active!! }) {
							IBestRadio({ group: this.group, label: $r("app.string.content"), name: '1' })
							IBestRadio({ group: this.group, label: $r("app.string.content"), name: '2', shape: "dot" })
							IBestRadio({ group: this.group, label: $r("app.string.content"), name: '3', shape: "square" })
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.component_switch") }) {
						Row() {
							IBestSwitch({
								value: this.switchValue!!
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.component_circleprogress") }) {
						IBestCircleProgress({
							value: this.progressValue!!,
							text: `50%`
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.component_progress") }) {
						IBestProgress({
							value: 50
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.component_tab") }) {
						IBestTabs({
							tabsList: [
								{
									label: $r("app.string.custom_option", 1),
									name: "1"
								},
								{
									label: $r("app.string.custom_option", 2),
									name: "2"
								},
								{
									label: $r("app.string.custom_option", 3),
									name: "3"
								},
								{
									label: $r("app.string.custom_option", 4),
									name: "4"
								},
								{
									label: $r("app.string.custom_option", 5),
									name: "5"
								}
							],
							currentName: this.curTabName!!
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: $r("app.string.component_tag") }) {
						IBestTag({
							type: 'primary',
							text: $r("app.string.tag")
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