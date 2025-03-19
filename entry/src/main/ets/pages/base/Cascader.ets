import { IBestCascader, IBestCascaderContent, IBestCascaderOption, IBestCell, IBestNavBar, IBestToast } from '@ibestservices/ibest-ui-v2'
import { modeColor, SPACE } from '../../assets/styles/BaseStyle'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import { regionData } from '@ibestservices/area-data'
import RouterUtil from '../../utils/routerUtil'
@Builder
export function CascaderBuilder(name: string, title: string){
	CascaderPage({title})
}

@Entry
@ComponentV2
struct CascaderPage {
	@Param title: string = ''
	@Local visible: boolean = false
	@Local fieldValue: string = '请选择地区'
	@Local selectValue: string[] = []

	@Local visible1: boolean = false
	@Local fieldValue1: string = '请选择地区'
	@Local selectValue1: string[] = []

	@Local visible2: boolean = false
	@Local fieldValue2: string = '江苏省,南京市,雨花台区'
	@Local selectValue2: string[] = ["320000", "320100", "320114"]

	@Local visible3: boolean = false
	@Local fieldValue3: string = '请选择地区'
	@Local selectValue3: string[] = []
	@Local data1: IBestCascaderOption[] = [
		{
			text: "江苏省",
			value: "320000"
		},
		{
			text: "安徽省",
			value: "340000"
		}
	]
	lazyLoad(value: string | number, level: number, cb: (arr: IBestCascaderOption[]) => void){
		IBestToast.show({
			type: "loading"
		})
		setTimeout(() => {
			IBestToast.hide()
			cb(value == "320000" ? [
				{
					text: "南京市",
					value: "320100",
					isEnd: level >= 1
				},
				{
					text: "苏州市",
					value: "320500",
					isEnd: level >= 1
				}
			] : [
				{
					text: "合肥市",
					value: "340100",
					isEnd: level >= 1
				},
				{
					text: "黄山市",
					value: "341000",
					isEnd: level >= 1
				}
			])
		}, 2000)
	}

	@Local visible4: boolean = false
	@Local fieldValue4: string = '请选择地区'
	@Local selectValue4: string[] = []
	@Local data2: IBestCascaderOption[] = [
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
					disabled: true,
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
					disabled: true,
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

	@Local selectValue5: string[] = []

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
					ComponentShowContainer({ title: '基础用法', titlePaddingLeft: SPACE.XS }) {
						IBestCell({
							title: '地区',
							value: this.fieldValue,
							isLink: true,
							hasBorder: false,
							onCellClick: () => {
								this.visible = true
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义颜色', titlePaddingLeft: SPACE.XS }) {
						IBestCell({
							title: '地区',
							value: this.fieldValue1,
							isLink: true,
							hasBorder: false,
							onCellClick: () => {
								this.visible1 = true
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义单项高度', titlePaddingLeft: SPACE.XS }) {
						IBestCell({
							title: '地区',
							value: this.fieldValue2,
							isLink: true,
							hasBorder: false,
							onCellClick: () => {
								this.visible2 = true
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '异步加载选项', titlePaddingLeft: SPACE.XS }) {
						IBestCell({
							title: '地区',
							value: this.fieldValue3,
							isLink: true,
							hasBorder: false,
							onCellClick: () => {
								this.visible3 = true
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '禁用选项', titlePaddingLeft: SPACE.XS }) {
						IBestCell({
							title: '地区',
							value: this.fieldValue4,
							isLink: true,
							hasBorder: false,
							onCellClick: () => {
								this.visible4 = true
							}
						})
					}
				}
				ListItem(){
					ComponentShowContainer({ title: '平铺展示', titlePaddingLeft: SPACE.XS }) {
						IBestCascaderContent({
							value: this.selectValue5!!,
							options: regionData
						})
					}
				}
				ListItem().height(50)
			}
			.layoutWeight(1)
			.padding({ left: SPACE.SM, right: SPACE.SM })
			// 基础用法
			IBestCascader({
				visible: this.visible!!,
				value: this.selectValue!!,
				options: regionData,
				onConfirm: (value: IBestCascaderOption[]) => {
					this.fieldValue = value.map(item => item.text).join(',')
				}
			})
			// 自定义颜色
			IBestCascader({
				visible: this.visible1!!,
				value: this.selectValue1!!,
				options: regionData,
				activeColor: '#ee0a24',
				onConfirm: (value: IBestCascaderOption[]) => {
					this.fieldValue1 = value.map(item => item.text).join(',')
				}
			})
			// 自定义高度
			IBestCascader({
				visible: this.visible2!!,
				value: this.selectValue2!!,
				options: regionData,
				itemHeight: 50,
				onConfirm: (value: IBestCascaderOption[]) => {
					this.fieldValue2 = value.map(item => item.text).join(',')
				}
			})
			// 异步加载
			IBestCascader({
				visible: this.visible3!!,
				value: this.selectValue3!!,
				options: this.data1,
				lazy: true,
				lazyLoad: this.lazyLoad,
				onConfirm: (value: IBestCascaderOption[]) => {
					this.fieldValue3 = value.map(item => item.text).join(',')
				}
			})
			// 禁用选项
			IBestCascader({
				visible: this.visible4!!,
				options: this.data2,
				value: this.selectValue4!!,
				onConfirm: (value: IBestCascaderOption[]) => {
					this.fieldValue4 = value.map(item => item.text).join(',')
				}
			})
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}