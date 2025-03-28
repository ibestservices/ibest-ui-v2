import { IBestCell, IBestCellGroup, IBestNumberKeyboard } from '@ibestservices/ibest-ui-v2'
import { modeColor, SPACE } from '../../assets/styles/BaseStyle'
import CustomNavBar from '../../components/CustomNavBar'

@Builder
export function NumberKeyboardBuilder(_:string, title: string){
	NumberKeyboardPage({title})
}

@Entry
@ComponentV2
struct NumberKeyboardPage {
	@Param title: string = ''
	@Local visible: boolean = false
	@Local value: string = ''
	@Local visible1: boolean = false
	@Local value1: string = ''
	@Local visible2: boolean = false
	@Local value2: string = ''
	@Local visible3: boolean = false
	@Local value3: string = ''
	@Local visible4: boolean = false
	@Local value4: string = ''
	@Local visible5: boolean = false
	@Local value5: string = ''
	@Local visible6: boolean = false
	@Local value6: string = ''
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
							title: '带右侧栏的键盘',
							value: this.value1,
							clickable: true,
							onCellClick: () => {
								this.visible1 = true
							}
						})
						IBestCell({
							title: '身份证号键盘',
							value: this.value2,
							clickable: true,
							onCellClick: () => {
								this.visible2 = true
							}
						})
						IBestCell({
							title: '带标题的键盘',
							value: this.value3,
							clickable: true,
							onCellClick: () => {
								this.visible3 = true
							}
						})
						IBestCell({
							title: '配置多个按键的键盘',
							value: this.value4,
							clickable: true,
							onCellClick: () => {
								this.visible4 = true
							}
						})
						IBestCell({
							title: '配置随机数字的键盘',
							value: this.value5,
							clickable: true,
							onCellClick: () => {
								this.visible5 = true
							}
						})
						IBestCell({
							title: '最大长度',
							value: this.value6 || "点此输入",
							clickable: true,
							hasBorder: false,
							onCellClick: () => {
								this.visible6 = true
							}
						})
					}
				}
			}
			.layoutWeight(1)
			.padding({ top: SPACE.SM })
			IBestNumberKeyboard({
				visible: this.visible!!,
				value: this.value!!,
				onInput: (value: string) => {
					console.log('onInput' + this.value)
				},
				onDelete: () => {
					console.log('删除')
				},
				onClose: () => {
					console.log("关闭")
				}
			})
			IBestNumberKeyboard({
				visible: this.visible1!!,
				value: this.value1!!,
				styleType: "custom",
				extraKey: ".",
				closeButtonText: "完成"
			})
			IBestNumberKeyboard({
				visible: this.visible2!!,
				value: this.value2!!,
				extraKey: "X"
			})
			IBestNumberKeyboard({
				visible: this.visible3!!,
				value: this.value3!!,
				title: "键盘标题",
				extraKey: "."
			})
			IBestNumberKeyboard({
				visible: this.visible4!!,
				value: this.value4!!,
				deleteButtonText: "删除",
				styleType: "custom",
				extraKey: ['00', '.'],
				closeButtonText: "确定"
			})
			IBestNumberKeyboard({
				visible: this.visible5!!,
				value: this.value5!!,
				isRandomKeyOrder: true
			})
			IBestNumberKeyboard({
				visible: this.visible6!!,
				value: this.value6!!,
				maxLength: 6
			})
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}