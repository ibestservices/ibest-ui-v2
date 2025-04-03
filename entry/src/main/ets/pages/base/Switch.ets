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
	@Local value3: boolean = true
	@Local value4: boolean = false
	@Local value5: boolean = true
	@Local value6: boolean = true
	@Local value7: boolean = true

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
					ComponentShowContainer({ title: '禁用状态' }) {
						Column({space: SPACE.MD}){
							IBestSwitch({
								value: this.value1!!,
								disabled: true
							})
							IBestSwitch({
								value: this.value2!!,
								disabled: true
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '加载状态' }) {
						Column({space: SPACE.MD}) {
							IBestSwitch({
								value: this.value3!!,
								loading: true,
							})
							IBestSwitch({
								value: this.value4!!,
								loading: true,
								activeColor: '#07c160'
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义大小' }) {
						IBestSwitch({
							value: this.value5!!,
							switchSize: 20
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义按钮' }) {
						IBestSwitch({
							value: this.value6!!,
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
							value: this.value7!!,
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
			}
			.layoutWeight(1)
			.padding({ left: SPACE.SM, right: SPACE.SM })
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}