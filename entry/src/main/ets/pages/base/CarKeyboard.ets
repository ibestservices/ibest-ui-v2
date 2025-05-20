import { IBestCell, IBestCellGroup, IBestCarKeyboard } from '@ibestservices/ibest-ui-v2';
import { modeColor, SPACE } from '../../assets/styles/BaseStyle';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function CarKeyboardBuilder(_:string, title: string){
	CarKeyboardPage({title})
}

@Entry
@ComponentV2
struct CarKeyboardPage {
	@Param title: string = ''
	@Local visible: boolean = false
	@Local value: string = ''
	@Local visible1: boolean = false
	@Local value1: string = ''
	@Local visible2: boolean = false
	@Local value2: string = ''

	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					IBestCellGroup({ inset: true }) {
						IBestCell({
							title: '默认键盘',
							value: this.value,
							clickable: true,
							onCellClick: () => {
								this.visible = true
							}
						})
						IBestCell({
							title: '最大长度',
							value: this.value1,
							clickable: true,
							onCellClick: () => {
								this.visible1 = true
							}
						})
						IBestCell({
							title: '自定义样式',
							value: this.value2,
							clickable: true,
							hasBorder: false,
							onCellClick: () => {
								this.visible2 = true
							}
						})
					}
				}
			}
			.layoutWeight(1)
			.padding({ top: SPACE.SM, bottom: SPACE.SM })
			IBestCarKeyboard({
				visible: this.visible!!,
				value: this.value!!
			})
			IBestCarKeyboard({
				visible: this.visible1!!,
				value: this.value1!!,
				maxLength: 7
			})
			IBestCarKeyboard({
				visible: this.visible2!!,
				value: this.value2!!,
				title: "车牌键盘",
				keyHeight: 36
			})
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}