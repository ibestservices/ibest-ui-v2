import { IBestPasswordInput } from '@ibestservices/ibest-ui-v2'
import { modeColor, SPACE } from '../../assets/styles/BaseStyle'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import CustomNavBar from '../../components/CustomNavBar'

@Builder
export function PasswordInputBuilder(_: string, title: string){
	PasswordInputPage({title})
}

@Entry
@ComponentV2
struct PasswordInputPage {
	@Param title: string = ''
	@Local value: string = '123'
	@Local value1: string = '123'
	@Local value2: string = '123'
	@Local value3: string = '123'
	@Local value4: string = '123'
	@Local errorTip: string = ''
	@Local value5: string = '123'
	@Monitor("value4")
	valueChange(){
		if (this.value4.length === 6 && this.value4 !== '123456') {
			this.errorTip = '密码错误';
		} else {
			this.errorTip = ''
		}
	}

	build() {
		NavDestination(){
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法' }) {
						IBestPasswordInput({
							value: this.value!!,
							numberKeyboardConfig:{
								extraKey: ".",
								styleType: "custom"
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义长度' }) {
						IBestPasswordInput({
							value: this.value1!!,
							inputLength: 4
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '格子间距' }) {
						IBestPasswordInput({
							value: this.value2!!,
							space: 12
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '明文展示' }) {
						IBestPasswordInput({
							value: this.value3!!,
							isHidden: false
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义样式' }) {
						Column({space: SPACE.SM}){
							IBestPasswordInput({
								value: this.value3!!,
								bdColor: '#3d8af2',
								cellTextColor: '#3d8af2'
							})
							IBestPasswordInput({
								value: this.value3!!,
								space: 12,
								cellBgColor: "#1c1c1e",
								cellTextColor: "#fff",
								highlightType: "shadow"
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '提示信息' }) {
						IBestPasswordInput({
							value: this.value4!!,
							tip: "密码为6位数字",
							errorTip: this.errorTip
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '使用系统键盘' }) {
						IBestPasswordInput({
							value: this.value5!!,
							useSystemKeyboard: true
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