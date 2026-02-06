import {
	IBestButton,
	IBestCell,
	IBestCheckbox,
	IBestCheckboxBuilderParams,
	IBestCheckboxGroup,
	IBestCheckboxGroupController,
	IBestDialogUtil,
	IBestIcon
} from '@ibestservices/ibest-ui-v2';
import { CONTAINER_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function CheckboxBuilder(_: string, title: string){
	CheckboxPage({title})
}

@Entry
@ComponentV2
struct CheckboxPage {
	@Param title: string = ''
	@Local isChecked: boolean = true
	@Local isChecked1: string = '1'
	@Local isChecked2: number = 1
	@Local group: string = "group"
	@Local activeList: string[] = ["1", "2"]
	@Local group1: string = "group1"
	@Local activeList1: number[] = [1]
	@Local group2: string = "group2"
	@Local activeList2: string[] = ["1", "2"]
	@Local group3: string = "group3"
	@Local activeList3: string[] = ["1"]
	@Local group4: string = "group4"
	@Local activeList4: string[] = ["2"]
	@Local isIndeterminate: boolean = true
	@Local isIndeterminateCheckAll: boolean = false
	@Local group5: string = "group5"
	@Local activeList5: string[] = []
	@Local cellCheckedMaxNum: number = 2
	private controller: IBestCheckboxGroupController = new IBestCheckboxGroupController()
	private controller1: IBestCheckboxGroupController = new IBestCheckboxGroupController()
	@Builder iconBuilder($$: IBestCheckboxBuilderParams){
		IBestIcon({
			name: "like-o",
			color: "#fff",
			iconSize: 18
		})
			.opacity($$.checked ? 1 : 0)
	}
	@Builder labelBuilder($$: IBestCheckboxBuilderParams) {
		Text($$.checked ? "选中" : "未选中")
	}
	@Builder CellCheckbox(name: string, group: string) {
		IBestCheckbox({
			name,
			group
		})
	}
	handleCellClick(name: string) {
		const index = this.activeList5.indexOf(name)
		if (index > -1) {
			this.activeList5.splice(index, 1)
		} else {
			this.activeList5.push(name)
		}
	}
	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法' }) {
						IBestCheckbox({
							value: this.isChecked!!,
							label: this.isChecked + ""
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '禁用状态', space: SPACE.SM }) {
						IBestCheckbox({
							value: false,
							disabled: true,
							label: '复选框'
						})
						IBestCheckbox({
							value: true,
							disabled: true,
							label: '复选框'
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义形状' }) {
						IBestCheckbox({
							value: this.isChecked!!,
							shape: 'square',
							radius: 4,
							label: '自定义形状'
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义颜色', space: SPACE.SM }) {
						IBestCheckbox({
							value: this.isChecked!!,
							checkedColor: '#ee0a24',
							label: '自定义颜色'
						})
						IBestCheckbox({
							value: this.isChecked!!,
							bdColor: '#ee0a24',
							bgColor: "#fff",
							label: '自定义背景色'
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义大小' }) {
						IBestCheckbox({
							value: this.isChecked!!,
							iconSize: 30,
							label: '自定义大小'
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '自定义内容', space: SPACE.MD }) {
						IBestCheckbox({
							value: this.isChecked!!,
							iconBuilder: this.iconBuilder,
							label: '自定义图标'
						})
						IBestCheckbox({
							value: this.isChecked!!,
							defaultBuilder: this.labelBuilder
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '左侧文本' }) {
						IBestCheckbox({
							value: this.isChecked!!,
							labelPosition: 'left',
							label: '左侧文本'
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '禁用文本点击' }) {
						IBestCheckbox({
							value: this.isChecked!!,
							label: '复选框',
							labelDisabled: true
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '异步切换' }) {
						IBestCheckbox({
							value: this.isChecked!!,
							label: '复选框',
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
				ListItem() {
					ComponentShowContainer({ title: '其他类型', space: SPACE.SM }) {
						IBestCheckbox({
							value: this.isChecked1!!,
							label: "string：" + this.isChecked1,
							trueValue: "1",
							falseValue: "2"
						})
						IBestCheckbox({
							value: this.isChecked2!!,
							label: "number：" + this.isChecked2.toString(),
							trueValue: 1,
							falseValue: 0
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '复选框组', space: SPACE.SM }) {
						Text("选中标识 " + this.activeList.join(',')).fontSize(14)
						IBestCheckboxGroup({ group: this.group, activeList: this.activeList!!, beforeChange: () => {
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
						}}) {
							IBestCheckbox({
								group: this.group,
								label: '复选框1',
								name: '1'
							})
							IBestCheckbox({
								group: this.group,
								label: '复选框2',
								name: '2'
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '水平排列', space: SPACE.SM }) {
						Text("选中标识 " + this.activeList1.join(',')).fontSize(14)
						IBestCheckboxGroup({ group: this.group1, activeList: this.activeList1!!, placeDirection: Axis.Horizontal }) {
							IBestCheckbox({
								group: this.group1,
								label: '复选框1',
								name: 1
							})
							IBestCheckbox({
								group: this.group1,
								label: '复选框2',
								name: 2
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '限制最大可选数', space: SPACE.SM }) {
						Text("选中标识 " + this.activeList2.join(',')).fontSize(14)
						IBestCheckboxGroup({ group: this.group2, activeList: this.activeList2!!, max: 2 }) {
							IBestCheckbox({
								group: this.group2,
								label: '复选框1',
								name: '1'
							})
							IBestCheckbox({
								group: this.group2,
								label: '复选框2',
								name: '2'
							})
							IBestCheckbox({
								group: this.group2,
								label: '复选框3',
								name: '3'
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '全选与反选', space: SPACE.SM }) {
						Text("选中标识 " + this.activeList3.join(',')).fontSize(14)
						IBestCheckboxGroup({ group: this.group3, activeList: this.activeList3!!, controller: this.controller }) {
							IBestCheckbox({
								group: this.group3,
								label: '复选框1',
								name: '1'
							})
							IBestCheckbox({
								group: this.group3,
								label: '复选框2',
								name: '2'
							})
							IBestCheckbox({
								group: this.group3,
								label: '复选框3',
								name: '3'
							})
						}
						Row({ space: SPACE.SM }) {
							IBestButton({
								text: '全选',
								type: 'primary',
								onBtnClick: () => {
									this.controller.toggleAll(true)
								}
							})
							IBestButton({
								text: '反选',
								type: 'warning',
								onBtnClick: () => {
									this.controller.toggleAll()
								}
							})
							IBestButton({
								text: '取消选中',
								onBtnClick: () => {
									this.controller.toggleAll(false)
								}
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '不确定状态', space: SPACE.SM }) {
						Column({space: SPACE.SM}) {
							Text("选中标识 " + this.activeList4.join(',')).fontSize(14)
							IBestCheckbox({
								value: this.isIndeterminateCheckAll!!,
								label: '全选',
								indeterminate: this.isIndeterminate,
								onChange: checked => {
									this.isIndeterminate = false
									this.controller1.toggleAll(checked as boolean)
								}
							})
						}
						.alignItems(HorizontalAlign.Start)
						.width(CONTAINER_SIZE.FULL)
						.padding({ bottom: SPACE.SM })
						.border({ width: { bottom: 1 }, color: "#ccc" })
						IBestCheckboxGroup({
							group: this.group4,
							activeList: this.activeList4!!,
							controller: this.controller1,
							onChange: checkedNames => {
								const length = checkedNames.length
								this.isIndeterminate = length < 2 && length > 0
								this.isIndeterminateCheckAll = length === 2
							}
						}) {
							IBestCheckbox({
								group: this.group4,
								label: '复选框1',
								name: '1'
							})
							IBestCheckbox({
								group: this.group4,
								label: '复选框2',
								name: '2'
							})
						}
					}
				}
				ListItem() {
					ComponentShowContainer({ title: '搭配单元格组件使用', }) {
						IBestCheckboxGroup({
							group: this.group5,
							activeList: this.activeList5!!,
							max: this.cellCheckedMaxNum,
							space: 0
						}) {
							IBestCell({
								clickable: true,
								title: '复选框1',
								disabled: this.activeList5.length >= this.cellCheckedMaxNum && !this.activeList5.includes('1'),
								rightIconBuilder: (): void => this.CellCheckbox('1', this.group5),
								onCellClick: (): void => this.handleCellClick('1')
							})
							IBestCell({
								clickable: true,
								title: '复选框2',
								disabled: this.activeList5.length >= this.cellCheckedMaxNum && !this.activeList5.includes('2'),
								rightIconBuilder: (): void => this.CellCheckbox('2', this.group5),
								onCellClick: (): void => this.handleCellClick('2')
							})
							IBestCell({
								clickable: true,
								title: '复选框3',
								disabled: this.activeList5.length >= this.cellCheckedMaxNum && !this.activeList5.includes('3'),
								hasBorder: false,
								rightIconBuilder: (): void => this.CellCheckbox('3', this.group5),
								onCellClick: (): void => this.handleCellClick('3')
							})
						}
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