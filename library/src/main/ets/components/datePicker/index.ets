import dayjs from '@hview/dayjs'
import { IBestPicker } from '../picker'
import { IBestPickerOption } from '../picker/index.type'
import { COMPONENT_NAME, DATE_PICKER_EVENT_NAME, DatePickerColumnType, IBestDatePickerResult } from './index.type'
import { emitter } from '../../utils/EventEmitter'
import { convertDimensionsWidthUnit, getEventName, getResourceStr } from '../../utils/utils'
import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { AppStorageV2 } from '@kit.ArkUI'
import { Lunar } from 'lunar'

@ComponentV2
export struct IBestDatePicker {
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local language: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.LANGUAGE)!
	/**
	 * 分组id
	 */
	@Param @Once groupId: string = ""
	/**
	 * 已选择的值
	 */
	@Param @Require value: string[]
	/**
	 * 最小时间
	 */
	@Param @Once minDate: Date = dayjs().subtract(10, 'year').toDate()
	/**
	 * 最大时间
	 */
	@Param @Once maxDate: Date = dayjs().add(10, 'year').toDate()
	/**
	 * 是否显示日列
	 */
	@Param isShowDay: boolean = true
	/**
	 * 是否显示单位
	 */
	@Param showUnit: boolean = false
	/**
	 * 标题
	 */
	@Param title: ResourceStr = ""
	/**
	 * 单项高度
	 */
	@Param itemHeight: IBestStringNumber = convertDimensionsWidthUnit(44)
	/**
	 * 确认按钮文字
	 */
	@Param confirmText: ResourceStr = $r("app.string.ibest_text_confirm")
	/**
	 * 取消按钮文字
	 */
	@Param cancelText: ResourceStr = $r("app.string.ibest_text_cancel")
	/**
	 * 是否显示顶部栏
	 */
	@Param showToolBar: boolean = true
	/**
	 * 可见选项数量
  	 */
	@Param visibleItemCount: number = 6
	/**
	 * 是否横向
	 */
	@Param horizontal: boolean = false
	/**
	 * 单项宽度, 仅横向时生效
	 */
	@Param itemWidth: IBestStringNumber = convertDimensionsWidthUnit(44)
	/**
	 * 高度, 仅横向时生效
	 */
	@Param contentHeight: IBestStringNumber = convertDimensionsWidthUnit(44)
	/**
	 * 选项字体大小
	 */
	@Param optionFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 是否显示农历日期
	 * @since 0.0.8
	 */
	@Param lunar: boolean = false
	/**
	 * 过滤器
	 */
	@Event filter: (type: DatePickerColumnType, options: IBestPickerOption[]) => IBestPickerOption[] = (_, options) => options
	/**
	 * 确认按钮点击事件
	 */
	@Event onConfirm: (value: IBestDatePickerResult) => void = () => {}
	/**
	 * 取消按钮点击事件
	 */
	@Event onCancel: () => void = () => {}
	/**
	 * 选中项改变事件
	 */
	@Event onChange: (value: IBestDatePickerResult) => void = () => {}
	@Event $value: (value: string[]) => void = () => {}

	// 唯一id
	@Local uniId: number = 0
	// 列表类型
	@Local listType: DatePickerColumnType[] = ["year", "month", "day"]
	// 选项列表
	@Local options: IBestPickerOption[][] = []
	@Local modelValue: string[] = []
	@Monitor("value") valueChange(){
		if(this.value.length){
			this.modelValue = this.value
		}
	}
	@Monitor("modelValue") modelValueChange(){
		if(this.modelValue.length){
			this.$value(this.modelValue)
		}
	}

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		this.modelValue = this.value
		this.init()
		if(this.groupId){
			// 监听日期picker变化
			emitter.on(getEventName(COMPONENT_NAME, DATE_PICKER_EVENT_NAME.COLUMN_CHANGE, this.groupId),this.uniId, (uniId: number, selectedValues: string[]): void => this.handleGroupChange(uniId, selectedValues))
		}
	}
	aboutToDisappear(): void {
		if(this.groupId) {
			emitter.off(getEventName(COMPONENT_NAME, DATE_PICKER_EVENT_NAME.COLUMN_CHANGE, this.groupId), this.uniId)
		}
	}
	// 初始化
	@Monitor("language.value")
	init(){
		let arr: IBestPickerOption[][] = []
		if(!this.isShowDay){
			this.listType = ["year", "month"]
		}
		this.listType.forEach((item) => {
			let list = item == "year" ? this.getYearsList() : item == "month" ? this.getMonthsList() : this.getDaysList()
			arr.push(list)
		})
		this.options = arr
	}
	// 是否是最小年份
	isMinYear = (year: number): boolean => year === this.minDate.getFullYear()
	// 是否是最大年份
	isMaxYear = (year: number): boolean => year === this.maxDate.getFullYear()
	// 是否是最小月份
	isMinMonth = (month: number): boolean => month === this.minDate.getMonth() + 1
	// 是否是最大月份
	isMaxMonth = (month: number): boolean => month === this.maxDate.getMonth() + 1
	// 格式化数值
	formatValue(value: number): string {
		return value < 10 ? "0" + value : value.toString()
	}
	getValue(type: DatePickerColumnType): number{
		let minDate = this.minDate
		let columnsType = this.listType
		const index = columnsType.indexOf(type)
		const value = this.modelValue[index]
		if (value) {
			return Number(value)
		}
		switch (type) {
			case 'year':
				return minDate.getFullYear()
			case 'month':
				return minDate.getMonth() + 1
			case 'day':
				return minDate.getDate()
		}
	}
	// 获取年份列表
	getYearsList(): IBestPickerOption[] {
		let yearsList: IBestPickerOption[] = []
		let unit = this.showUnit ? getResourceStr($r("app.string.ibest_year")) : ""
		for(let i = this.minDate.getFullYear(); i <= this.maxDate.getFullYear(); i++){
			yearsList.push({
				value: i.toString(),
				text: i + unit
			})
		}
		return this.filter("year", yearsList)
	}
	// 获取月份列表
	getMonthsList(): IBestPickerOption[] {
		let monthsList: IBestPickerOption[] = []
		let year = this.getValue("year")
		let minMonth = this.isMinYear(year) ? this.minDate.getMonth() + 1 : 1
		let maxMonth = this.isMaxYear(year) ? this.maxDate.getMonth() + 1 : 12
		let unit = this.showUnit ? getResourceStr($r("app.string.ibest_month")) : ""
		for(let i = minMonth; i <= maxMonth; i++){
			let value = this.formatValue(i)
			let text = ''
			if(this.lunar){
				text = Lunar.fromDate(new Date(year, i, 1)).getMonthInChinese()
			}else {
				text = this.formatValue(i)
			}
			monthsList.push({
				value,
				text: text + unit
			})
		}
		return this.filter("month", monthsList)
	}
	// 获取日期列表
	getDaysList(): IBestPickerOption[] {
		let daysList: IBestPickerOption[] = []
		let year = this.getValue("year")
		let month = this.getValue("month")
		let minDay = this.isMinYear(year) && this.isMinMonth(month) ? this.minDate.getDate() : 1
		let maxDay = this.isMaxYear(year) && this.isMaxMonth(month) ? this.maxDate.getDate() : dayjs(year+"-"+month).daysInMonth()
		let unit = this.showUnit ? getResourceStr($r("app.string.ibest_day")) : ""
		for(let i = minDay; i <= maxDay; i++){
			let value = this.formatValue(i)
			let text = ''
			if(this.lunar){
				text = Lunar.fromDate(dayjs(year+"-"+month+"-"+i).toDate()).getDayInChinese()
			}else{
				text = this.formatValue(i) + unit
			}
			daysList.push({
				value,
				text: text
			})
		}
		return this.filter("day", daysList)
	}
	// 列变化
	changeColumn(columnIndex: number){
		if(columnIndex < this.options.length - 1){
			this.init()
		}
		this.onChange(this.getResult())
		if(this.groupId) {
			emitter.emit(getEventName(COMPONENT_NAME, DATE_PICKER_EVENT_NAME.COLUMN_CHANGE, this.groupId), this.uniId, this.modelValue)
		}
	}
	// 获取组件结果
	getResult(): IBestDatePickerResult {
		let dateStr = this.modelValue.join("-")
		let date = dayjs(dateStr).toDate()
		let result: IBestDatePickerResult = {
			date,
			dateStr,
			year: this.modelValue[0],
			month: this.modelValue[1]
		}
		if(this.isShowDay){
			result.day = this.modelValue[2]
		}
		if(this.lunar){
			let lunar = Lunar.fromDate(date)
			result.lunarMonth = lunar.getMonthInChinese()
			result.lunarDay = lunar.getDayInChinese()
		}
		return result
	}
	// 处理同组日期变化
	handleGroupChange(uniId: number, selectedValues: string[]) {
		if(this.uniId > uniId){
			let selectDate = dayjs(selectedValues.join("-")).toDate()
			this.minDate = selectDate
			if(selectDate > this.maxDate || selectDate < this.minDate){
				this.modelValue = selectedValues
			}
			this.init()
		}
	}

	build() {
		IBestPicker({
			groupId: this.groupId,
			value: this.modelValue!!,
			title: this.title,
			options: this.options,
			showToolBar: !this.groupId && this.showToolBar,
			visibleItemCount: this.visibleItemCount,
			itemHeight: this.itemHeight,
			confirmText: this.confirmText,
			cancelText: this.cancelText,
			horizontal: this.horizontal,
			itemWidth: this.itemWidth,
			contentHeight: this.contentHeight,
			optionFontSize: this.optionFontSize,
			onConfirm: () => {
				this.onConfirm(this.getResult())
			},
			onCancel: () => {
				this.onCancel()
			},
			onChange: (selectedValues, selectTexts, columnIndex) => {
				this.changeColumn(columnIndex)
			}
		})
	}
}