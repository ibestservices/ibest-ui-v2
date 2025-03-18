import { IBestStringNumber } from '../../model/Global.type'
import { COLOR_TYPE, ColorType } from '../../theme-chalk/src/color.type'
import { convertDimensionsWidthUnit } from '../../utils/utils'
import { IBestPopup } from '../popup'
import { IBestCalendar } from './index'
import { IBestCalendarConfirmResult, SelectedStyleType, SelectType, WeekDayType } from './index.type'
@ComponentV2
export struct IBestCalendarDialog {
	/**
	 * 弹框展示状态
	 */
	@Param @Require visible: boolean
	/**
	 * 底部偏移
	 */
	@Param offsetY: number = 0
	/**
	 * 是否为模态窗口
	 */
	@Param isModal: boolean = true
	/**
	 * 背板的圆角半径
	 */
	@Param cornerRadius: IBestStringNumber = convertDimensionsWidthUnit(10)
	/**
	 * 默认选中日期
	 */
	@Param defaultSelectedDate: string[] = []
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
	 * 选择回调
	 */
	@Event onConfirm: (value: IBestCalendarConfirmResult[]) => void = () => {}
	@Event $visible: (value: boolean) => void = () => {}
	// 已选日期
	@Local selectedDate: IBestCalendarConfirmResult[] = []
	@Local popupVisible: boolean = false
	@Monitor("popupVisible") popupVisibleChange(){
		this.$visible(this.popupVisible)
	}
	@Monitor("visible") visibleChange(){
		this.popupVisible = this.visible
	}
	@Builder baseBuilder() {
		IBestCalendar({
			defaultSelectedDate: this.selectedDate.length ? this.selectedDate.map(item => item.dateStr) : this.defaultSelectedDate,
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
			confirmBtnColor: this.confirmBtnColor,
			confirmBtnText: this.confirmBtnText,
			onConfirm: (value): void => this.onGetCalendarResult(value)
		})
	}
	/**
	 * 获取日历选择结果 触发onConfirm回调函数 并关闭弹框
	 */
	onGetCalendarResult(value: IBestCalendarConfirmResult[]) {
		if (value.length) {
			this.selectedDate = value
			this.onConfirm(this.selectedDate)
			this.popupVisible = false
		}
	}
	build() {
		IBestPopup({
			visible: this.popupVisible!!,
			offsetY: this.offsetY,
			isModal: this.isModal,
			cornerRadius: this.cornerRadius,
			popupAlign: "bottom",
			popupHeight: "auto",
			safeAreaInsetBottom: true,
			contentBuilder: (): void => this.baseBuilder()
		})
	}
}