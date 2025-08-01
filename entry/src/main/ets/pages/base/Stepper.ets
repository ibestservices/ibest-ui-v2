import { modeColor, SPACE } from '../../assets/styles/BaseStyle'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import { IBestStepper } from '@ibestservices/ibest-ui-v2'
import CustomNavBar from '../../components/CustomNavBar'

@Builder
export function StepperBuilder(_: string, title: string){
	StepperPage({title})
}

@Entry
@ComponentV2
struct StepperPage {
	@Param title: string = ''

	@Local value: number = 1
	@Local value1: number = 1
	@Local value2: number = 1
	@Local value3: number = 1
	@Local value4: number = 1
	@Local value5: number = 10
	@Local value6: number = 14
	@Local value7: number = 1
	
	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法' }) {
						IBestStepper({
							value: this.value!!
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '步长设置' }) {
						IBestStepper({
							value: this.value1!!,
							step: 2
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '限制输入范围' }) {
						IBestStepper({
							value: this.value2!!,
							min: 5,
							max: 8
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '禁用状态' }) {
						IBestStepper({
							value: this.value4!!,
							disabled: true
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '禁用输入框' }) {
						IBestStepper({
							value: this.value5!!,
							disableInput: true
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '固定小数位数' }) {
						IBestStepper({
							value: this.value6!!,
							step: 0.2,
							decimalLength: 1
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义大小' }) {
						IBestStepper({
							value: this.value7!!,
							inputWidth: 40,
							buttonSize: 32
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