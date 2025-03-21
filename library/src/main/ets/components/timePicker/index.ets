import { IBestPicker } from '../picker'
import { IBestPickerOption } from '../picker/index.type'
import { COMPONENT_NAME, IBestTimePickerColumnType, TIME_PICKER_EVENT_NAME } from './index.type'
import { emitter } from '../../utils/EventEmitter'
import { clamp, convertDimensionsWidthUnit, getEventName } from '../../utils/utils'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { AppStorageV2 } from '@kit.ArkUI'
@ComponentV2
export struct IBestTimePicker {
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
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
	@Param @Once minTime: string = "00:00:00"
	/**
	 * 最大时间
	 */
	@Param @Once maxTime: string = "23:59:59"
	/**
	 * 列表类型
     */
	@Param listType: IBestTimePickerColumnType[] = ["hour", "minute", "second"]
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
	 * 过滤器
	 */
	@Event filter: (type: IBestTimePickerColumnType, options: IBestPickerOption[]) => IBestPickerOption[] = (_, options) => options
	/**
	 * 确认按钮点击事件
	 */
	@Event onConfirm: (value: string[]) => void = () => {}
	/**
	 * 取消按钮点击事件
	 */
	@Event onCancel: () => void = () => {}
	/**
	 * 选中项改变事件
	 */
	@Event onChange: (value: string[]) => void = () => {}
	@Event $value: (value: string[]) => void = () => {}

	// 唯一id
	@Local uniId: number = 0
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
			emitter.on(getEventName(COMPONENT_NAME, TIME_PICKER_EVENT_NAME.COLUMN_CHANGE, this.groupId), this.uniId, (uniId: number, selectedValues: string[]): void => this.handleGroupTimeChange(uniId, selectedValues))
		}
	}
	aboutToDisappear(): void {
		if(this.groupId) {
			emitter.off(getEventName(COMPONENT_NAME, TIME_PICKER_EVENT_NAME.COLUMN_CHANGE, this.groupId), this.uniId)
		}
	}
	// 初始化
	init(){
		let reg = /^(?:([01]?[0-9]|2[0-3]):)?([0-5]?[0-9]):([0-5]?[0-9])$/
		this.options = []
		if(!reg.test(this.minTime)){
			this.minTime = "00:00:00"
		}
		if(!reg.test(this.maxTime)){
			this.maxTime = "23:59:59"
		}
		this.listType.forEach((item,index) => {
			let list = item == "hour" ? this.getHoursList() : item == "minute" ? this.getMinutesList() : this.getSecondsList()
			let min = list.length ? list[0].value : ""
			let max = list.length ? list[list.length-1].value : ""
			let newValue = this.modelValue[index] || min
			let i = list.findIndex((item) => item.value == newValue)
			if(i == -1){
				if(list.length){
					this.modelValue[index] = this.formatValue(clamp(Number(newValue), Number(min), Number(max)))
				}else{
					this.modelValue[index] = ""
				}
			}else{
				this.modelValue[index] = newValue.toString()
			}
			this.modelValue = this.modelValue.filter(e => e)
			this.options.push(list)
		})
	}
	// 是否是最小小时
	isMinHour = (hour: string): boolean => hour === this.minTime.slice(0, 2)
	// 是否是最大小时
	isMaxHour = (hour: string): boolean => hour === this.maxTime.slice(0, 2)
	// 是否是最小分钟
	isMinMinute = (minute: string): boolean => minute === this.minTime.slice(3, 5)
	// 是否是最大分钟
	isMaxMinute = (minute: string): boolean => minute === this.maxTime.slice(3, 5)
	// 格式化数值
	formatValue(value: number): string {
		return value < 10 ? "0" + value : (value + "")
	}
	getValue(type: IBestTimePickerColumnType): string{
		let minTime = this.minTime
		let columnsType = this.listType
		const index = columnsType.indexOf(type)
		const value = this.value[index]
		if (value) {
			return value
		}
		switch (type) {
			case 'hour':
				return minTime.slice(0, 2)
			case 'minute':
				return minTime.slice(3, 5)
			case 'second':
				return minTime.slice(6)
		}
	}
	// 获取小时列表
	getHoursList(): IBestPickerOption[] {
		let list: IBestPickerOption[] = []
		let min = Number(this.minTime.slice(0, 2))
		let max = Number(this.maxTime.slice(0, 2))
		for(let i = min; i <= max; i++){
			list.push({
				value: this.formatValue(i),
				text: this.formatValue(i) + (this.showUnit ? "时" : "")
			})
		}
		return this.filter("hour", list)
	}
	// 获取分钟列表
	getMinutesList(): IBestPickerOption[] {
		let monthsList: IBestPickerOption[] = []
		let hour = this.getValue("hour")
		let min = this.isMinHour(hour) ? Number(this.minTime.slice(3, 5)) : 0
		let max = this.isMaxHour(hour) ? Number(this.maxTime.slice(3, 5)) : 59
		for(let i = min; i <= max; i++){
			monthsList.push({
				value: this.formatValue(i),
				text: this.formatValue(i) + (this.showUnit ? "分" : "")
			})
		}
		return this.filter("minute", monthsList)
	}
	// 获取日期列表
	getSecondsList(): IBestPickerOption[] {
		let daysList: IBestPickerOption[] = []
		let hour = this.getValue("hour")
		let minute = this.getValue("minute")
		let min = this.isMinHour(hour) && this.isMinMinute(minute) ? Number(this.minTime.slice(6)) : 0
		let max = this.isMaxHour(hour) && this.isMaxMinute(minute) ? Number(this.maxTime.slice(6)) : 59
		for(let i = min; i <= max; i++){
			daysList.push({
				value: this.formatValue(i),
				text: this.formatValue(i) + (this.showUnit ? "秒" : "")
			})
		}
		return this.filter("second", daysList)
	}
	// 列变化
	changeColumn(columnIndex: number){
		if(columnIndex < this.options.length - 1){
			this.init()
		}
		this.onChange(this.value)
		if(this.groupId) {
			emitter.emit(getEventName(COMPONENT_NAME, TIME_PICKER_EVENT_NAME.COLUMN_CHANGE, this.groupId), this.uniId, this.value)
		}
	}
	// 处理同组时间变化
	handleGroupTimeChange(uniId: number, selectedValues: string[]) {
		if(this.uniId > uniId){
			let selectTime = selectedValues.join(":")
			this.minTime = selectTime
			if(selectTime > this.maxTime || selectTime < this.minTime){
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
			onConfirm: (selectedValues) => {
				this.onConfirm(selectedValues as string[])
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