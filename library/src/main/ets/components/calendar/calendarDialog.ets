import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { COLOR_TYPE, ColorType } from '../../theme-chalk/src/color.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit } from '../../utils/utils'
import { IBestPopup } from '../popup'
import { IBestCalendar } from './index'
import { IBestCalendarConfirmResult, IBestCalendarDayItem, SelectedStyleType, SelectType, WeekDayType } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestCalendarDialog {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 弹框展示状态
	 */
	@Param @Require visible: boolean
	/**
	 * 已选日期
	 * @since 1.0.3
	 */
	@Param value: string | string[] = []
	/**
	 * 默认选中日期
	 * @deprecated since 1.0.3
	 * @useinstead value
	 */
	@Param defaultSelectedDate: string[] = []
	/**
	 * 底部偏移
	 */
	@Param offsetY: number = 0
	/**
	 * 是否为模态窗口
	 */
	@Param isModal: boolean = true
	/**
	 * 弹框圆角半径
	 */
	@Param cornerRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = this.baseStyle.borderRadiusXl as string
	/**
	 * 单项宽度
	 */
	@Param itemWidth: IBestStringNumber = convertDimensionsWidthUnit(50)
	/**
	 * 每周第一天是周几
	 */
	@Param weekFirstDay: WeekDayType = 1
	/**
	 * 是否显示农历
	 */
	@Param isShowLunar: boolean = false
	/**
	 * 选择类型
	 */
	@Param selectType: SelectType = "single"
	/**
	 * 选中样式
	 */
	@Param selectedStyleType: SelectedStyleType = "normal"
	/**
	 * 选中主题颜色
	 */
	@Param type: ColorType = COLOR_TYPE.PRIMARY
	/**
	 * 自定义选中颜色
	 */
	@Param selectedColor: string = ""
	/**
	 * 日期区间最多可选天数 默认无限制
	 */
	@Param maxRange: number = -1
	/**
	 * 最小日期
	 */
	@Param minDate?: Date = undefined
	/**
	 * 最大日期
	 */
	@Param maxDate?: Date = undefined
	/**
	 * 是否显示月份背景水印
	 */
	@Param isShowMark: boolean = false
	/**
	 * 是否显示头部
	 */
	@Param isShowHeader: boolean = true
	/**
	 * 确认按钮颜色，默认type主题色
	 */
	@Param confirmBtnColor: ResourceColor = ""
	/**
	 * 确认按钮文案
	 */
	@Param confirmBtnText: ResourceStr = $r("app.string.ibest_text_confirm")
	/**
	 * 打卡模式
	 */
	@Param clock: boolean = false
	/**
	 * 打卡成功提示
	 */
	@Param clockSuccessText: ResourceStr = $r("app.string.ibest_calendar_clocked")
	/**
	 * 是否显示未打卡
	 */
	@Param isShowUnClock: boolean = true
	/**
	 * 未打卡提示
	 */
	@Param unClockText: ResourceStr = $r("app.string.ibest_calendar_unclock")
	/**
	 * 是否显示其他月份日期
	 * @since 0.0.8
	 */
	@Param showOtherMonthDate: boolean = true
	/**
	 * 自定义日期项插槽
	 */
	@BuilderParam dayItemBuilder: ($$: IBestCalendarDayItem) => void
	/**
	 * 选择回调
	 */
	@Event onConfirm: (value: IBestCalendarConfirmResult[]) => void = () => {}
	@Event $visible: (value: boolean) => void = () => {}
	@Event $value: (value: string | string[]) => void = () => {}
	// 已选日期
	@Local selectedValue: string | string[] = []
	@Event $selectedValue: (value: string | string[]) => void = () => {}

	@Builder baseBuilder() {
		IBestCalendar({
			value: this.selectedValue,
			itemWidth: this.itemWidth,
			isShowLunar: this.isShowLunar,
			selectType: this.selectType,
			selectedStyleType: this.selectedStyleType,
			type: this.type,
			weekFirstDay: this.weekFirstDay,
			minDate: this.minDate,
			maxDate: this.maxDate,
			maxRange: this.maxRange,
			selectedColor: this.selectedColor,
			isShowMark: this.isShowMark,
			isShowConfirmBtn: this.selectType != "single",
			isShowHeader: this.isShowHeader,
			showOtherMonthDate: this.showOtherMonthDate,
			confirmBtnColor: this.confirmBtnColor,
			confirmBtnText: this.confirmBtnText,
			clock: this.clock,
			clockSuccessText: this.clockSuccessText,
			isShowUnClock: this.isShowUnClock,
			unClockText: this.unClockText,
			dayItemBuilder: this.dayItemBuilder,
			$value: (value: string | string[]): void => this.$selectedValue(value),
			onConfirm: (value): void => this.onGetCalendarResult(value)
		})
	}

	aboutToAppear(): void {
		this.selectedValue = this.value || this.defaultSelectedDate
	}
	@Monitor("value", "value.length")
	valueChange(){
		this.selectedValue = this.value
	}
	@Monitor("visible")
	visibleChange(){
		if(this.visible){
			this.valueChange()
		}
	}
	// 获取日历选择结果 触发onConfirm回调函数 并关闭弹框
	onGetCalendarResult(value: IBestCalendarConfirmResult[]) {
		if (value.length) {
			this.$value(value.length == 1 ? value[0].dateStr : value.map(item => item.dateStr))
			this.onConfirm(value)
			this.$visible(false)
		}
	}
	build() {
		IBestPopup({
			visible: this.visible,
			offsetY: this.offsetY,
			isModal: this.isModal,
			cornerRadius: this.cornerRadius,
			popupAlign: "bottom",
			popupHeight: "auto",
			closeOnBackPress: true,
			safeAreaInsetBottom: true,
			contentBuilder: (): void => this.baseBuilder(),
			$visible: (value): void => this.$visible(value)
		})
	}
}