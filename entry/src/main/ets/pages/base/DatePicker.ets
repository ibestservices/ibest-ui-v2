import { IBestDatePicker, IBestPickerOption, IBestToast } from '@ibestservices/ibest-ui-v2'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import { modeColor, SPACE } from '../../assets/styles/BaseStyle'
import CustomNavBar from '../../components/CustomNavBar'
import dayjs from '@hview/dayjs'
@Builder
export function DatePickerBuilder(_: string, title: string){
	DatePickerPage({title})
}

@Entry
@ComponentV2
struct DatePickerPage {
	@Param title: string = ''
	@Local selectValue: string[] = dayjs().format("YYYY-MM-DD").split("-")
	@Local selectValue1: string[] = dayjs().format("YYYY-MM").split("-")
	@Local selectValue2: string[] = dayjs().format("YYYY-MM-DD").split("-")
	@Local selectValue3: string[] = dayjs().format("YYYY-MM").split("-")
	@Local selectValue4: string[] = []
	@Local minDate: Date = dayjs().subtract(5, 'year').toDate()
	@Local maxDate: Date = dayjs().add(5, 'year').toDate()
	filter(type: string, options: IBestPickerOption[]): IBestPickerOption[]{
		if (type === 'month') {
			return options.filter((option) => Number(option.value) % 6 === 0)
		}
		return options
	}
	build() {
		NavDestination() {
			CustomNavBar({title: this.title})
			List() {
				ListItem() {
					ComponentShowContainer({ title: '基础用法', titlePaddingLeft: SPACE.SM, card: true }) {
						IBestDatePicker({
							title: "选择日期",
							minDate: this.minDate,
							maxDate: this.maxDate,
							value: this.selectValue!!,
							onConfirm: value => {
								IBestToast.show(value.dateStr)
							},
							onChange: value => {
								IBestToast.show(value.dateStr)
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: "选项类型", titlePaddingLeft: SPACE.SM, card: true }) {
						IBestDatePicker({
							title: "选择年月",
							minDate: this.minDate,
							maxDate: this.maxDate,
							isShowDay: false,
							value: this.selectValue1!!,
							onConfirm: value => {
								IBestToast.show(value.dateStr)
							},
							onChange: value => {
								IBestToast.show(value.dateStr)
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: "显示单位", titlePaddingLeft: SPACE.SM, card: true }) {
						IBestDatePicker({
							title: "选择日期",
							minDate: this.minDate,
							maxDate: this.maxDate,
							showUnit: true,
							value: this.selectValue2!!,
							onConfirm: value => {
								IBestToast.show(value.dateStr)
							},
							onChange: value => {
								IBestToast.show(value.dateStr)
							}
						})
					}
				}
				ListItem() {
					ComponentShowContainer({ title: "过滤选项", titlePaddingLeft: SPACE.SM, card: true }) {
						IBestDatePicker({
							title: "选择年月",
							minDate: this.minDate,
							maxDate: this.maxDate,
							isShowDay: false,
							filter: this.filter,
							value: this.selectValue3!!,
							onConfirm: value => {
								IBestToast.show(value.dateStr)
							},
							onChange: value => {
								IBestToast.show(value.dateStr)
							}
						})
					}
				}
				ListItem(){
					ComponentShowContainer({title: "显示农历", titlePaddingLeft: SPACE.SM, card: true}){
						IBestDatePicker({
							title: "选择年月日",
							value: this.selectValue4!!,
							lunar: true,
							showUnit: true,
							onConfirm: (value) => {
								IBestToast.show(value.year + "年" + value.lunarMonth + "月" + value.lunarDay)
							},
							onChange: (value) => {
								IBestToast.show(value.year + "年" + value.lunarMonth + "月" + value.lunarDay)
							}
						})
					}
				}
				ListItem().height(50)
			}
			.layoutWeight(1)
		}
		.hideTitleBar(true)
		.backgroundColor(modeColor.bg)
	}
}