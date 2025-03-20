import {
    // IBestField,
    IBestNavBar,
    IBestPicker,
    IBestPickerOption,
    IBestPopup,
    IBestToast
} from '@ibestservices/ibest-ui-v2'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import { modeColor, SPACE } from '../../assets/styles/BaseStyle'
import RouterUtil from '../../utils/routerUtil'
@Builder
export function PickerBuilder(name: string, title: string){
	PickerPage({title})
}

@Entry
@ComponentV2
struct PickerPage {
	@Param title: string = ''
	@Local options1: IBestPickerOption[] = [
		{ text: '南京', value: 'Nanjing' },
		{ text: '苏州', value: 'Suzhou' },
		{ text: '常州', value: 'Changzhou' },
		{ text: '扬州', value: 'Yangzhou' },
		{ text: '镇江', value: 'Zhejiang' }
	]
	@Local selectValue: string[] = []
	@Local selectValue1: string[] = []
	@Local selectValue2: string[] = ["Suzhou"]
	@Builder pickerBuilder(){
		IBestPicker({
			options: this.options1,
			title: "标题",
			visibleItemCount: 5,
			value: this.selectValue1!!,
			onChange: (selectedValues, selectTexts) => {
				IBestToast.show(selectTexts.join('-'))
			},
			onConfirm: (selectedValues, selectTexts) => {
				this.visible = false
				this.filedValue = selectTexts.join('-')
			},
			onCancel: () => {
				this.visible = false
			}
		})
	}
	@Local visible: boolean = false
	@Local filedValue: string = ""

	@Local options3: IBestPickerOption[][] = [
		[
			{ text: '周一', value: 'Monday' },
			{ text: '周二', value: 'Tuesday' },
			{ text: '周三', value: 'Wednesday' },
			{ text: '周四', value: 'Thursday' },
			{ text: '周五', value: 'Friday' }
		],
		[
			{ text: '上午', value: 'Morning' },
			{ text: '下午', value: 'Afternoon' },
			{ text: '晚上', value: 'Evening' }
		]
	]
	@Local selectValue3: string[] = []

	@Local options4: IBestPickerOption[] = [
		{
			text: "江苏省",
			value: "320000",
			children: [
				{
					text: "南京市",
					value: "320100",
					children: [
						{
							text: "秦淮区",
							value: "320104"
						},
						{
							text: "雨花台区",
							value: "320114"
						}
					]
				},
				{
					text: "苏州市",
					value: "320500",
					children: [
						{
							text: "姑苏区",
							value: "320508"
						},
						{
							text: "昆山市",
							value: "320583"
						}
					]
				}
			]
		},
		{
			text: "安徽省",
			value: "340000",
			children: [
				{
					text: "合肥市",
					value: "340100",
					children: [
						{
							text: "蜀山区",
							value: "340104"
						},
						{
							text: "合肥高新技术产业开发区",
							value: "340171"
						}
					]
				},
				{
					text: "黄山市",
					value: "341000",
					children: [
						{
							text: "屯溪区",
							value: "341002"
						},
						{
							text: "黄山区",
							value: "341003"
						}
					]
				}
			]
		}
	]
	@Local selectValue4: string[] = []

	build() {
		NavDestination() {
			IBestNavBar({
				title: this.title,
				isShowStatusBar: true,
				onLeftClick: () => {
					RouterUtil.pop()
				}
			})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法', titlePaddingLeft: SPACE.SM, card: true }) {
						IBestPicker({
							options: this.options1,
							title: "标题",
							value: this.selectValue!!,
							onConfirm: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							},
							onChange: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '横向滚动', titlePaddingLeft: SPACE.SM, card: true }) {
						IBestPicker({
							options: this.options1,
							title: "标题",
							value: this.selectValue!!,
							horizontal: true,
							onConfirm: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							},
							onChange: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							}
						})
					}
				}
				// ListItem() {
				// 	ComponentShowContainer({ title: '搭配弹出层使用', titlePaddingLeft: SPACE.SM, card: true }) {
				// 		IBestField({
				// 			label: '城市',
				// 			value: $filedValue,
				// 			placeholder: "请选择城市",
				// 			isLink: true,
				// 			hasBorder: false,
				// 			onFieldClick: () => {
				// 				this.visible = true
				// 			}
				// 		})
				// 	}
				// }
				ListItem() {
					ComponentShowContainer({ title: '默认选中', titlePaddingLeft: SPACE.SM, card: true }) {
						IBestPicker({
							options: this.options1,
							title: "标题",
							value: this.selectValue2!!,
							onConfirm: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							},
							onChange: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '多列选择', titlePaddingLeft: SPACE.SM, card: true }) {
						IBestPicker({
							options: this.options3,
							title: "标题",
							value: this.selectValue3!!,
							onConfirm: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							},
							onChange: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '级联选择', titlePaddingLeft: SPACE.SM, card: true }) {
						IBestPicker({
							options: this.options4,
							title: "标题",
							value: this.selectValue4!!,
							onConfirm: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							},
							onChange: (selectedValues, selectTexts) => {
								IBestToast.show(selectTexts.join('-'))
							}
						})
					}
				}
			}
			.layoutWeight(1)
			.padding({ bottom: SPACE.LG })
			// 弹出层
			IBestPopup({
				visible: this.visible!!,
				popupAlign: "bottom",
				contentBuilder: (): void => this.pickerBuilder()
			})
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}