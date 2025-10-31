import dayjs from '@hview/dayjs'
import { IBestPicker } from '../picker'
import { IBestPickerOption } from '../picker/index.type'
import { COMPONENT_NAME, DATE_TIME_PICKER_EVENT_NAME, IBestDateTimePickerResult } from './index.type'
import { emitter } from '../../utils/eventEmitter'
import { convertDimensionsWidthUnit, getEventName, getResourceStr } from '../../utils/utils'
import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
@ComponentV2
export struct IBestDateTimePicker {
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local language: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.LANGUAGE)!
	/**
	 * 分组id
	 */
	@Param groupId: IBestStringNumber = ""
	/**
	 * 已选择的值
	 */
	@Param @Require value: string[]
	/**
	 * 最小时间
	 */
	@Param @Once minDate: Date = dayjs(new Date().getFullYear() + '-01-01 00:00:00').subtract(10, 'year').toDate()
	/**
	 * 最大时间
	 */
	@Param @Once maxDate: Date = dayjs(new Date().getFullYear() + '-01-01 00:00:00').add(10, 'year').toDate()
	/**
	 * 是否显示单位
	 */
	@Param showUnit: boolean = false
	/**
	 * 标题
	 */
	@Param title: string = ""
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
	 * 选项字体大小
	 */
	@Param optionFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 是否显示秒
     */
	@Param showSecond: boolean = true
	/**
	 * 外部圆角
	 * @since 1.0.0
	 */
	@Param radius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0
	/**
	 * 确认按钮点击事件
	 */
	@Event onConfirm: (value: IBestDateTimePickerResult) => void = () => {}
	/**
	 * 取消按钮点击事件
	 */
	@Event onCancel: () => void = () => {}
	/**
	 * 选中项改变事件
	 */
	@Event onChange: (value: IBestDateTimePickerResult) => void = () => {}
	@Event $value: (value: string[]) => void = () => {}

	// 唯一id
	@Local uniId: number = 0
	// 选项列表
	@Local options: IBestPickerOption[][] = []
	@Local listType: string[] = []
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
			emitter.on(getEventName(COMPONENT_NAME, DATE_TIME_PICKER_EVENT_NAME.COLUMN_CHANGE, this.groupId),this.uniId, (uniId: number, selectedValues: string[]): void => this.handleGroupChange(uniId, selectedValues))
		}
	}
	aboutToDisappear(): void {
		if(this.groupId) {
			emitter.off(getEventName(COMPONENT_NAME, DATE_TIME_PICKER_EVENT_NAME.COLUMN_CHANGE, this.groupId), this.uniId)
		}
	}
	// 初始化
	@Monitor("language.value")
	init(){
		let list =  ["year", "month", "day", "hour", "minute"]
		let arr: IBestPickerOption[][] = []
		if(this.showSecond){
			list.push("second")
		}
		this.listType = list
		this.options = []
		this.listType.forEach((item) => {
			let list = this.getListByType(item)
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
	// 是否是最小日
	isMinDay = (day: number): boolean => day === this.minDate.getDate()
	// 是否是最大日
	isMaxDay = (day: number): boolean => day === this.maxDate.getDate()
	// 是否是最小小时
	isMinHour = (hour: number): boolean => hour === this.minDate.getHours()
	// 是否是最大小时
	isMaxHour = (hour: number): boolean => hour === this.maxDate.getHours()
	// 是否是最小分钟
	isMinMinute = (minute: number): boolean => minute === this.minDate.getMinutes()
	// 是否是最大分钟
	isMaxMinute = (minute: number): boolean => minute === this.maxDate.getMinutes()
	// 格式化数值
	formatValue(value: number): string {
		return value < 10 ? "0" + value : (value + "")
	}
	getValue(type: string): number{
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
			case 'hour':
				return minDate.getHours()
			case 'minute':
				return minDate.getMinutes()
			case 'second':
				return minDate.getSeconds()
			default:
				return 0
		}
	}
	getListByType(type: string){
		switch (type){
			case 'year':
				return this.getYearsList()
			case 'month':
				return this.getMonthsList()
			case 'day':
				return this.getDaysList()
			case 'hour':
				return this.getHoursList()
			case 'minute':
				return this.getMinutesList()
			case 'second':
				return this.getSecondList()
			default:
				return []
		}
	}
	// 获取年份列表
	getYearsList(): IBestPickerOption[] {
		let yearsList: IBestPickerOption[] = []
		for(let i = this.minDate.getFullYear(); i <= this.maxDate.getFullYear(); i++){
			yearsList.push({
				value: i + "",
				text: i + (this.showUnit ? getResourceStr($r("app.string.ibest_year")) : "")
			})
		}
		return yearsList
	}
	// 获取月份列表
	getMonthsList(): IBestPickerOption[] {
		let monthsList: IBestPickerOption[] = []
		let year = this.getValue("year")
		let minMonth = this.isMinYear(year) ? this.minDate.getMonth() + 1 : 1
		let maxMonth = this.isMaxYear(year) ? this.maxDate.getMonth() + 1 : 12
		for(let i = minMonth; i <= maxMonth; i++){
			monthsList.push({
				value: this.formatValue(i),
				text: this.formatValue(i) + (this.showUnit ? getResourceStr($r("app.string.ibest_month")) : "")
			})
		}
		return monthsList
	}
	// 获取日期列表
	getDaysList(): IBestPickerOption[] {
		let daysList: IBestPickerOption[] = []
		let year = this.getValue("year")
		let month = this.getValue("month")
		let minDay = this.isMinYear(year) && this.isMinMonth(month) ? this.minDate.getDate() : 1
		let maxDay = this.isMaxYear(year) && this.isMaxMonth(month) ? this.maxDate.getDate() : dayjs(year+"-"+month).daysInMonth()
		for(let i = minDay; i <= maxDay; i++){
			daysList.push({
				value: this.formatValue(i),
				text: this.formatValue(i) + (this.showUnit ? getResourceStr($r("app.string.ibest_day")) : "")
			})
		}
		return daysList
	}
	// 获取小时列表
	getHoursList(): IBestPickerOption[] {
		let hoursList: IBestPickerOption[] = []
		let year = this.getValue("year")
		let month = this.getValue("month")
		let day = this.getValue("day")
		let min = this.isMinYear(year) && this.isMinMonth(month) && this.isMinDay(day) ? this.minDate.getHours() : 0
		let max = this.isMaxYear(year) && this.isMaxMonth(month) && this.isMaxDay(day) ? this.maxDate.getHours() : 23
		for(let i = min; i <= max; i++){
			hoursList.push({
				value: this.formatValue(i),
				text: this.formatValue(i) + (this.showUnit ? getResourceStr($r("app.string.ibest_hour")) : "")
			})
		}
		return hoursList
	}
	// 获取分钟列表
	getMinutesList(): IBestPickerOption[] {
		let minutesList: IBestPickerOption[] = []
		let year = this.getValue("year")
		let month = this.getValue("month")
		let day = this.getValue("day")
		let hour = this.getValue("hour")
		let min = this.isMinYear(year) && this.isMinMonth(month) && this.isMinDay(day) && this.isMinHour(hour) ? this.minDate.getMinutes() : 0
		let max = this.isMaxYear(year) && this.isMaxMonth(month) && this.isMaxDay(day) && this.isMaxHour(hour) ? this.maxDate.getMinutes() : 59
		for(let i = min; i <= max; i++){
			minutesList.push({
				value: this.formatValue(i),
				text: this.formatValue(i) + (this.showUnit ? getResourceStr($r("app.string.ibest_minute")) : "")
			})
		}
		return minutesList
	}
	// 获取秒列表
	getSecondList(): IBestPickerOption[] {
		let secondsList: IBestPickerOption[] = []
		let year = this.getValue("year")
		let month = this.getValue("month")
		let day = this.getValue("day")
		let hour = this.getValue("hour")
		let minute = this.getValue("minute")
		let min = this.isMinYear(year) && this.isMinMonth(month) && this.isMinDay(day) && this.isMinHour(hour) && this.isMinMinute(minute) ? this.minDate.getSeconds() : 0
		let max = this.isMaxYear(year) && this.isMaxMonth(month) && this.isMaxDay(day) && this.isMaxHour(hour) && this.isMaxMinute(minute) ? this.maxDate.getSeconds() : 59
		for(let i = min; i <= max; i++){
			secondsList.push({
				value: this.formatValue(i),
				text: this.formatValue(i) + (this.showUnit ? getResourceStr($r("app.string.ibest_second")) : "")
			})
		}
		return secondsList
	}
	// 列变化
	changeColumn(columnIndex: number){
		if(columnIndex < this.options.length - 1){
			this.init()
		}
		this.onChange(this.getResult())
		if(this.groupId) {
			emitter.emit(getEventName(COMPONENT_NAME, DATE_TIME_PICKER_EVENT_NAME.COLUMN_CHANGE, this.groupId), this.uniId, this.modelValue)
		}
	}
	// 获取组件结果
	getResult() {
		let result: IBestDateTimePickerResult = {
			year: this.modelValue[0],
			month: this.modelValue[1],
			day: this.modelValue[2],
			hour: this.modelValue[3],
			minute: this.modelValue[4],
			second: this.modelValue[5]
		}
		return result
	}
	// 处理同组日期变化
	handleGroupChange(uniId: number, selectedValues: string[]) {
		if(this.uniId > uniId){
			let selectDate = dayjs(selectedValues.slice(0, 3).join('-') + ' ' + selectedValues.slice(3).join(":")).toDate()
			this.minDate = selectDate
			if(selectDate > this.maxDate || selectDate < this.minDate){
				this.$value(selectedValues)
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
			optionFontSize: this.optionFontSize,
			radius: this.radius,
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