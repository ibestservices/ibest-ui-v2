import dayjs, { Dayjs } from '@hview/dayjs'
import { Lunar } from 'lunar'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { COLOR_TYPE, ColorType } from '../../theme-chalk/src/color.type'
import { GRAY_COLOR } from '../../theme-chalk/src/color'
import {
	HeaderItemType,
	IBestCalendarConfirmResult,
	IBestCalendarDay,
	IBestCalendarDayItem,
	SelectedStyleType,
	SelectType,
	WeekDayType
} from './index.type'
import { convertDimensionsWidthUnit, getComponentsInfo, getSizeByUnit } from '../../utils/utils'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { isBeforeToday, set16ToRgb } from './utils'
import { IBestCalendarColor } from './color'
import { IBestIcon } from '../icon'
import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'
import { getDefaultBaseStyle } from '../../theme-chalk/src'
@Extend(Text) function headerStyle(itemWidth: IBestStringNumber){
    .width(getSizeByUnit(itemWidth))
    .height(CONTAINER_SIZE.FULL)
    .textAlign(TextAlign.Center)
    .fontSize(getDefaultBaseStyle().fontSizeSm)
    .fontColor(IBestCalendarColor.textColor)
}
@Extend(Text) function clockStyle(fontColor: ResourceColor){
    .fontSize(getDefaultBaseStyle().fontSizeSm)
    .fontColor(fontColor)
}
@ComponentV2
struct CalendarItem {
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Local fontColor: ResourceColor = IBestCalendarColor.textColor
    @Local bgColor: ResourceColor = "transparent"
    @Param @Require dayItem: IBestCalendarDay
    @Param @Require index: number
    @Param @Require itemWidth: IBestStringNumber
    @Param @Require isShowLunar: boolean
    @Param @Require type: ColorType
    @Param @Require selectType: SelectType
    @Param @Require selectedStyleType: SelectedStyleType
    @Param @Require selectedColor: string
    @Param @Require clock: boolean
    @Param @Require clockSuccessText: ResourceStr
    @Param @Require isShowUnClock: boolean
    @Param @Require unClockText: ResourceStr
    @Consumer() daysList: IBestCalendarDay[] = []
    @Consumer() selectedList: IBestCalendarDay[] = []
	@BuilderParam dayItemBuilder?: ($$: IBestCalendarDayItem) => void

    selectedListChange(){
        this.itemChange()
    }

    aboutToAppear(): void {
        this.itemChange()
    }
    isToday(){
        return this.dayItem.dateStr == dayjs().format('YYYY-MM-DD')
    }
    @Monitor("dayItem.isSelected") isSelectedChange(){
        this.itemChange()
    }
    @Monitor("dayItem.isClock") isClockChange(){
        this.itemChange()
    }
    itemChange(){
        let item = this.dayItem
        if(item.isDisabled){
            this.fontColor = GRAY_COLOR.GRAY_7
            this.bgColor = IBestCalendarColor.disabledBg
        }else if(this.selectType == "range"){ // 范围选择
            if(this.clock){
                this.fontColor = item.isClock ? IBestCalendarColor.textWhite : item.isCurMonthDay ? this.isToday() ? this.baseStyle[this.type] : IBestCalendarColor.textColor : GRAY_COLOR.GRAY_7
                this.bgColor = item.isClock ? this.baseStyle[this.type] : "transparent"
            }else if(this.selectedList.length){
                let dateStr = item.dateStr
                let first = this.selectedList[0]
                let last = this.selectedList[this.selectedList.length - 1]
                this.fontColor = item.isSelected ? dateStr == first.dateStr || dateStr == last.dateStr ? IBestCalendarColor.textWhite : this.selectedColor || this.baseStyle[this.type] : item.isCurMonthDay ? IBestCalendarColor.textColor : GRAY_COLOR.GRAY_7
                this.bgColor = item.isSelected ? dateStr == first.dateStr || dateStr == last.dateStr ? this.selectedColor || this.baseStyle[this.type]
                    : this.selectedColor ? set16ToRgb(this.selectedColor) : this.baseStyle[this.type + "Opacity"] : "transparent"
            }else{
                this.fontColor = item.isSelected ? this.selectedColor || IBestCalendarColor.textColor : item.isCurMonthDay ? IBestCalendarColor.textColor : GRAY_COLOR.GRAY_7
                this.bgColor = item.isSelected ? this.selectedColor ? set16ToRgb(this.selectedColor) : this.baseStyle[this.type + "Opacity"] : "transparent"
            }
        }else{
            this.fontColor = item.isCurMonthDay ? this.dayItem.isSelected ? IBestCalendarColor.textWhite : IBestCalendarColor.textColor : GRAY_COLOR.GRAY_7
            this.bgColor = item.isSelected ? this.selectedColor || this.baseStyle[this.type] : "transparent"
        }
    }
    getMultipleBorderRadius (): Length | BorderRadiuses{
        let borderRadius = this.baseStyle.borderRadiusMd
        if (this.dayItem.isSelected) {
            const prevDay = this.daysList[this.index - 1]
            const nextDay = this.daysList[this.index + 1]
            const prevSelected = prevDay?.isSelected
            const nextSelected = nextDay?.isSelected
            if (prevSelected && nextSelected) {
                return ""
            }
            if (prevSelected) {
                return {
                    topRight: borderRadius,
                    bottomRight: borderRadius
                }
            }
            if (nextSelected) {
                return {
                    topLeft: borderRadius,
                    bottomLeft: borderRadius
                }
            }
            return borderRadius
        }
        return ''
    }
    getDisabledBorderRadius(): Length | BorderRadiuses{
        let borderRadius = this.baseStyle.borderRadiusMd
        const prevDay = this.daysList[this.index - 1]
        const nextDay = this.daysList[this.index + 1]
        const prevDisabled = prevDay?.isDisabled
        const nextDisabled = nextDay?.isDisabled

        if (prevDisabled && nextDisabled) {
            return ""
        }
        if (prevDisabled) {
            return {
                topRight: borderRadius,
                bottomRight: borderRadius
            }
        }
        if (nextDisabled) {
            return {
                topLeft: borderRadius,
                bottomLeft: borderRadius
            }
        }
        return borderRadius
    }
    getOutBorderRadius(): Length | BorderRadiuses {
        if(this.dayItem.isDisabled){
            return this.getDisabledBorderRadius()
        }else if(this.selectedList.length <= 1){
            return this.baseStyle.borderRadiusMd
        }else {
            return this.getMultipleBorderRadius()
        }
    }

    build() {
        Row() {
			if(this.dayItemBuilder){
				this.dayItemBuilder({
					date: this.dayItem.date,
					dateStr: this.dayItem.dateStr,
					day: this.dayItem.day,
					month: this.dayItem.month,
					year: this.dayItem.year,
					weekNum: this.dayItem.weekNum,
					lunarMonth: this.dayItem.lunarMonth,
					lunarDay: this.dayItem.lunarDay,
					isSelected: this.dayItem.isSelected,
					isCurMonthDay: this.dayItem.isCurMonthDay,
					isDisabled: this.dayItem.isDisabled,
					isClock: this.dayItem.isClock
				})
			}else {
				Column({ space: this.baseStyle.spaceMini as string }) {
					Text(this.dayItem.day)
						.fontSize(this.baseStyle.fontSizeMd)
						.fontColor(this.fontColor)
					if (this.isShowLunar) {
						Text(this.dayItem.lunarDay)
							.clockStyle(this.fontColor)
					} else if (this.clock && this.dayItem.isCurMonthDay && isBeforeToday(this.dayItem.date)) {
						if (this.dayItem.isClock) {
							Text(this.clockSuccessText)
								.clockStyle(this.fontColor)
						} else if (this.isShowUnClock) {
							Text(this.unClockText)
								.clockStyle(this.fontColor)
						}
					}
				}
				.width(getSizeByUnit(this.itemWidth))
				.aspectRatio(1)
				.backgroundColor(this.selectType == "single" ? this.bgColor : "")
				.borderRadius(this.selectedStyleType == "circle" ? this.baseStyle.borderRadiusMax :
				this.baseStyle.borderRadiusMd)
				.justifyContent(FlexAlign.Center)
			}
        }
        .width(CONTAINER_SIZE.FULL)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.selectType == "single" || this.dayItemBuilder ? "" : this.bgColor)
        .borderRadius(this.getOutBorderRadius())
    }
}

@ComponentV2
export struct IBestCalendar{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Local isLandscape: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.IS_LANDSCAPE)!
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
    @Param @Once selectType: SelectType = "single"
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
     * 是否显示底部确定按钮
     */
    @Param isShowConfirmBtn: boolean = false
    /**
     * 确认按钮颜色
     */
    @Param confirmBtnColor: ResourceColor = ""
    /**
     * 确认按钮文案
     */
    @Param confirmBtnText: ResourceStr = $r("app.string.ibest_text_confirm")
    /**
     * 圆角
     */
    @Param cornerRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = convertDimensionsWidthUnit(10)
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
	 * @since 0.0.2
	 */
	@BuilderParam dayItemBuilder: ($$: IBestCalendarDayItem) => void
    /**
     * 选择回调
     */
    @Event onConfirm: (value: IBestCalendarConfirmResult[]) => void = () => {}

	// 唯一id
	@Local uniId: number = 0
    // 当前点击选择的年月日
    @Local curSelectedDate: string = dayjs().format('YYYY-MM-DD')
    // 当前所在年月份
    @Local curYearMonth: string = dayjs().format('YYYY-MM')
    // 日历头部
    @Local headerList: HeaderItemType[] = [
        {
            text: $r("app.string.ibest_calendar_monday"),
            key: 1
        },
        {
            text: $r("app.string.ibest_calendar_tuesday"),
            key: 2
        },
        {
            text: $r("app.string.ibest_calendar_wednesday"),
            key: 3
        },
        {
            text: $r("app.string.ibest_calendar_thursday"),
            key: 4
        },
        {
            text: $r("app.string.ibest_calendar_friday"),
            key: 5
        },
        {
            text: $r("app.string.ibest_calendar_saturday"),
            key: 6
        },
        {
            text: $r("app.string.ibest_calendar_sunday"),
            key: 0
        }
    ]
    // 列表日期
    @Provider() daysList: IBestCalendarDay[] = []
    // 已选的日期列表
    @Provider() selectedList: IBestCalendarDay[] = []
    // 日期区域高度
    @Local contentHeight: number = 0
    private context = this.getUIContext()

    @Monitor("defaultSelectedDate.length") defaultSelectedDateChange(){
        this.initSelectedList()
        this.daysList.forEach(e => {
            e.isSelected = this.clock ? isBeforeToday(e.date) && this.isSelect(e.dateStr) : this.isSelect(e.dateStr)
            if(this.clock && e.isCurMonthDay){
                e.isClock = isBeforeToday(e.date) ? this.isSelect(e.dateStr) : false
            }
        })
    }

    @Monitor("curSelectedDate") selectDateChange(){
        this.curYearMonth = dayjs(this.curSelectedDate).format('YYYY-MM')
    }

    @Computed
    get curMonth(){
        return dayjs(this.curYearMonth).format('M')
    }

    @Builder contentBuilder(){
        Stack({alignContent: Alignment.Top}) {
            Text(this.curMonth)
                .fontSize(convertDimensionsWidthUnit(150, true))
                .height(convertDimensionsWidthUnit(this.contentHeight))
                .fontColor(IBestCalendarColor.markTextColor)
                .visibility(this.isShowMark ? Visibility.Visible : Visibility.Hidden)
            GridRow({ columns: 7, gutter: { x: 0, y: convertDimensionsWidthUnit(5) }}) {
                ForEach(this.daysList, (item: IBestCalendarDay, index: number) => {
                    GridCol() {
						if(item.isCurMonthDay || this.showOtherMonthDate) {
							CalendarItem({
								dayItem: item,
								index: index,
								type: this.type,
								selectType: this.selectType,
								selectedStyleType: this.selectedStyleType,
								selectedColor: this.selectedColor,
								itemWidth: this.itemWidth,
								isShowLunar: this.isShowLunar,
								clock: this.clock,
								clockSuccessText: this.clockSuccessText,
								isShowUnClock: this.isShowUnClock,
								unClockText: this.unClockText,
								dayItemBuilder: this.dayItemBuilder
							})
								.enabled(!(this.clock || item.isDisabled))
								.onClick(() => {
									this.selectDate(item, index)
								})
						}
                    }
                })
            }
            .width(CONTAINER_SIZE.FULL)
            .id(`ibest_calender_${this.uniId}`)
        }
        .padding(this.isLandscape.value ? undefined : {left: this.baseStyle.spaceXs, right: this.baseStyle.spaceXs})
    }

    aboutToAppear(){
        this.uniId = this.getUniqueId()
        this.init()
        this.initDaysList()
    }
    /**
     * 初始化本地数据
     */
    init(){
        if(this.clock){
            this.selectType = "range"
        }
        let index = this.headerList.findIndex(e => e.key == this.weekFirstDay)
        index = index == -1 ? 1 : index
        // index 变更 headerList顺序
        this.headerList = this.headerList.slice(index).concat(this.headerList.slice(0, index))
        this.initSelectedList()
    }
    // 初始化selectedList
    initSelectedList(){
        let list: IBestCalendarDay[] = []
        if(this.defaultSelectedDate.length){
            if(this.defaultSelectedDate.some(e => !dayjs(e).isValid())){
                return
            }
            this.curSelectedDate = this.defaultSelectedDate[0]
            this.defaultSelectedDate.forEach(e => {
                if(dayjs(e).isValid() && !this.getIsDisabled(dayjs(e))){
                    list.push(new IBestCalendarDay({
                        date: dayjs(e),
                        dateStr: e,
                        weekNum: this.getWeekNum(dayjs(e)),
                        lunarMonth: Lunar.fromDate(dayjs(e).toDate()).getMonthInChinese(),
                        lunarDay: Lunar.fromDate(dayjs(e).toDate()).getDayInChinese(),
                        year: dayjs(e).format('YYYY'),
                        month: dayjs(e).format('MM'),
                        day: dayjs(e).format('D'),
                        isCurMonthDay: true,
                        isSelected: true
                    }))
                }
            })
        }
        this.selectedList = list
    }
    isSelect(dateStr: string){
        return this.selectedList.some(e => e.dateStr == dateStr)
    }
    /**
     * 初始化日历列表
     */
    initDaysList(){
        this.daysList = []
        let list: IBestCalendarDay[] = []
        // 获取当前月份1号是周几
        let firstDayWeekNum = this.getWeekNum(dayjs(this.curYearMonth).date(1))
        // 获取本月多少天
        let curMonthDays = dayjs(this.curYearMonth).daysInMonth()
        // 需补上月多少天
        let preMonthDays: number = this.headerList.findIndex((item) => item.key == firstDayWeekNum)
        // 需补下月多少天
        let nextMonthDays: number = 42 - preMonthDays - curMonthDays
        if(preMonthDays){
            let day = dayjs(this.curYearMonth).subtract(1, 'month')
            // 获取上月多少天
            let preMonthDaysNum = day.daysInMonth()
            for(let i = preMonthDaysNum - preMonthDays + 1; i <= preMonthDaysNum; i++){
                let val = day.date(i)
                let dateStr = val.format('YYYY-MM-DD')
				let lunar = Lunar.fromDate(val.toDate())
				let lunarMonth = lunar.getMonthInChinese() + '月'
                let dayItem = new IBestCalendarDay({
                    date: val,
                    dateStr,
                    weekNum: this.getWeekNum(val),
					lunarMonth,
					lunarDay: lunar.getDay() == 1 ? lunarMonth : lunar.getDayInChinese(),
                    year: val.format('YYYY'),
                    month: val.format('MM'),
                    day: val.format('D'),
                    isCurMonthDay: false,
                    isSelected: this.selectedList.some((item) => item.dateStr === dateStr),
                    isDisabled: this.getIsDisabled(val)
                })
                list.push(dayItem)
            }
        }
        for (let i = 1; i <= curMonthDays; i++) {
            let val = dayjs(this.curYearMonth).date(i)
            let dateStr = val.format('YYYY-MM-DD')
			let lunar = Lunar.fromDate(val.toDate())
			let lunarMonth = lunar.getMonthInChinese() + '月'
            let dayItem = new IBestCalendarDay({
                date: val,
                dateStr,
                weekNum: this.getWeekNum(val),
				lunarMonth,
				lunarDay: lunar.getDay() == 1 ? lunarMonth : lunar.getDayInChinese(),
                year: val.format('YYYY'),
                month: val.format('MM'),
                day: val.format('D'),
                isCurMonthDay: true,
                isSelected: this.selectedList.some((item) => item.dateStr === dateStr),
                isDisabled: this.getIsDisabled(val),
                isClock: this.clock && isBeforeToday(val) ? this.selectedList.some((item) => item.dateStr === dateStr) : false
            })
            list.push(dayItem)
        }
        for (let i = 1; i <= nextMonthDays; i++) {
            let val = dayjs(this.curYearMonth).add(1, 'month').date(i)
            let dateStr = val.format('YYYY-MM-DD')
			let lunar = Lunar.fromDate(val.toDate())
			let lunarMonth = lunar.getMonthInChinese() + '月'
            let dayItem = new IBestCalendarDay({
                date: val,
                dateStr,
                weekNum: this.getWeekNum(val),
				lunarMonth,
				lunarDay: lunar.getDay() == 1 ? lunarMonth : lunar.getDayInChinese(),
                year: val.format('YYYY'),
                month: val.format('MM'),
                day: val.format('D'),
                isCurMonthDay: false,
                isSelected: this.selectedList.some((item) => item.dateStr === dateStr),
                isDisabled: this.getIsDisabled(val)
            })
            list.push(dayItem)
        }
        this.daysList = list
        this.selectedList = this.refreshListParam(this.selectedList)
        this.getDateAreaHeight()
    }
    /**
     * 获取日期区域高度
     */
    getDateAreaHeight(){
        setTimeout(()=>{
            this.contentHeight = getComponentsInfo(this.context, `ibest_calender_${this.uniId}`).height
        }, 0)
    }
    /**
     * 刷新字段
     */
    refreshListParam(list: IBestCalendarDay[]): IBestCalendarDay[]{
        list.forEach((item: IBestCalendarDay) => {
            item.isCurMonthDay = item.date.format('YYYY-MM') == this.curYearMonth
        })
        return list
    }
    /**
     * 获取日期是否禁用
     */
    getIsDisabled(day: Dayjs): boolean{
        return this.minDate != undefined && dayjs(day).isBefore(this.minDate, 'day') || this.maxDate != undefined && dayjs(day).isAfter(this.maxDate, 'day')
    }
    /**
     * 获取日期是周几 0123456
     */
    getWeekNum(date?: string | Dayjs): number{
        return dayjs(date).day()
    }
    /**
     * 切换年、月份
     */
    changeYearMonth(type: string){
        switch (type){
            case "preYear":
                this.curYearMonth = dayjs(this.curYearMonth).subtract(1, 'year').format('YYYY-MM')
                break
            case "preMonth":
                this.curYearMonth = dayjs(this.curYearMonth).subtract(1, 'month').format('YYYY-MM')
                break
            case "nextYear":
                this.curYearMonth = dayjs(this.curYearMonth).add(1, 'year').format('YYYY-MM')
                break
            case "nextMonth":
                this.curYearMonth = dayjs(this.curYearMonth).add(1, 'month').format('YYYY-MM')
                break
        }
        this.initDaysList()
    }
    /**
     * 点击选择日期
     */
    selectDate(item: IBestCalendarDay, index: number){
        switch(this.selectType){
            case "single":
                if(item.isCurMonthDay){
                    this.daysList.forEach(e => {
                        e.isSelected = false
                    })
                    this.daysList[index].isSelected = true
                    this.curSelectedDate = item.dateStr
                }else{
                    this.curSelectedDate = item.dateStr
                    this.initDaysList()
                }
                this.selectedList = [item]
                !this.isShowConfirmBtn && this.confirm()
                break
            case "multiple":
                if(item.isCurMonthDay){
                    this.daysList[index].isSelected = !this.daysList[index].isSelected
                    if(item.isSelected){
                        this.curSelectedDate = item.dateStr
                    }
                    let i = this.selectedList.findIndex(e => e.dateStr == item.dateStr)
                    if(i == -1){
                        this.selectedList.push(item)
                    }else{
                        this.selectedList.splice(i, 1)
                    }
                }else{
                    this.curSelectedDate = item.dateStr
                    let index = this.selectedList.findIndex(e => e.dateStr == item.dateStr)
                    if(index == -1){
                        this.selectedList.push(item)
                    }else{
                        this.selectedList.splice(index, 1)
                    }
                    this.initDaysList()
                }
                // 排序
                this.selectedList.sort((a, b) => {
                    return dayjs(a.date).isBefore(dayjs(b.date)) ? -1 : 1
                })
                !this.isShowConfirmBtn && this.confirm()
                break
            case "range":
                this.curSelectedDate = item.dateStr
                if(this.selectedList.length == 1){  // 已选起始日期 选择结束日期
                    let days: IBestCalendarDay[] = []
                    let isOutRange = false
                    if(item.date.isBefore(this.selectedList[0].date)){
                        days = this.getDateListBetween(item.date, this.selectedList[0].date)
                        isOutRange = this.maxRange > 2 && days.length > this.maxRange
                        if(isOutRange){
                            days = days.slice(-this.maxRange)
                        }
                    }else if(item.date.isAfter(this.selectedList[0].date)){
                        days = this.getDateListBetween(this.selectedList[0].date, item.date)
                        isOutRange = this.maxRange > 2 && days.length > this.maxRange
                        if(isOutRange){
                            days = days.slice(0, this.maxRange)
                        }
                    }
                    if(isOutRange){
						this.context.getPromptAction().showToast({
                            message: $r("app.string.ibest_maximum_limit", this.maxRange),
                            duration: 2000
                        })
                    }
                    this.selectedList = days
                    !this.isShowConfirmBtn && this.confirm()
                }else{  // 已选结束日期  重选
                    this.daysList[index].isSelected = true
                    this.selectedList = [item]
                }
                this.daysList.forEach(e => e.isSelected = this.selectedList.some(f => f.dateStr == e.dateStr))
                if(!item.isCurMonthDay){
                    this.initDaysList()
                }
                break
        }
    }
    /**
     * 获取两个日期之间的所有日期
     */
    getDateListBetween(startDayjs: Dayjs, endDayjs: Dayjs): IBestCalendarDay[]{
        let dateArray: IBestCalendarDay[] = []
        let start = dayjs(startDayjs)
        let end = dayjs(endDayjs)
        while (!start.isAfter(end, 'day')) {
            // 将当前迭代的日期添加到数组中
            dateArray.push(new IBestCalendarDay({
                date: start,
                dateStr: start.format('YYYY-MM-DD'),
                weekNum: this.getWeekNum(start),
                lunarMonth: Lunar.fromDate(start.toDate()).getMonthInChinese(),
                lunarDay: Lunar.fromDate(start.toDate()).getDayInChinese(),
                year: start.format('YYYY'),
                month: start.format('MM'),
                day: start.format('D'),
                isCurMonthDay: start.format('YYYY-MM-DD') == this.curYearMonth,
                isSelected: true
            }))
            // 将开始日期增加一天
            start = start.add(1, 'day')
        }
        return dateArray
    }
    /**
     * 提交
     */
    confirm(){
         this.onConfirm(this.selectedList.map(e => {
            let obj: IBestCalendarConfirmResult = {
                date: e.date.toDate(),
                dateStr: e.dateStr
            }
            if(this.isShowLunar){
                obj.lunarMonth = e.lunarMonth
                obj.lunarDay = e.lunarDay
            }
            return obj
        }))
    }

    build() {
        Column(){
            Row(){
                Row(){
                    IBestIcon({
                        name: "arrow-double-left",
                        iconSize: convertDimensionsWidthUnit(14),
                        color: IBestCalendarColor.textColor
                    }).onClick(() => {
                        this.changeYearMonth("preYear")
                    })
                    IBestIcon({
                        name: "arrow-left",
                        iconSize: convertDimensionsWidthUnit(14),
                        color: IBestCalendarColor.textColor
                    }).onClick(() => {
                        this.changeYearMonth("preMonth")
                    })
                }
                Text(this.curYearMonth)
                    .fontSize(this.baseStyle.fontSizeMd)
                    .fontColor(IBestCalendarColor.textColor)
                Row(){
                    IBestIcon({
                        name: "arrow",
                        iconSize: convertDimensionsWidthUnit(14),
                        color: IBestCalendarColor.textColor
                    }).onClick(() => {
                        this.changeYearMonth("nextMonth")
                    })
                    IBestIcon({
                        name: "arrow-double-right",
                        iconSize: convertDimensionsWidthUnit(14),
                        color: IBestCalendarColor.textColor
                    }).onClick(() => {
                        this.changeYearMonth("nextYear")
                    })
                }
            }
            .width(CONTAINER_SIZE.FULL)
            .height(convertDimensionsWidthUnit(40))
            .padding({left: this.baseStyle.spaceLg, right: this.baseStyle.spaceLg})
            .justifyContent(FlexAlign.SpaceBetween)
            .visibility(this.isShowHeader ? Visibility.Visible : Visibility.None)
            GridRow({ columns: 7 }) {
                ForEach(this.headerList, (item: HeaderItemType) => {
                    GridCol() {
                        Text(item.text).headerStyle(this.itemWidth)
                    }
                }, (_: HeaderItemType, index: number) => index.toString())
            }
            .width(CONTAINER_SIZE.FULL)
            .height(convertDimensionsWidthUnit(30))
            .padding({left: this.baseStyle.spaceXs, right: this.baseStyle.spaceXs})
            if(this.isLandscape.value){
                Scroll() {
                    this.contentBuilder()
                }
                .height('60%')
                .padding({left: this.baseStyle.spaceXs, right: this.baseStyle.spaceXs})
            }else{
                this.contentBuilder()
            }
            if(this.isShowConfirmBtn && !this.clock){
                Button(this.confirmBtnText)
                    .type(ButtonType.Capsule)
                    .width('90%')
                    .height(convertDimensionsWidthUnit(30))
                    .fontSize(this.baseStyle.fontSizeSm)
                    .margin({top: this.baseStyle.spaceXs})
                    .backgroundColor(this.confirmBtnColor || this.baseStyle[this.type])
                    .onClick(() => {
                        this.confirm()
                    })
            }
        }
        .width(CONTAINER_SIZE.FULL)
        .backgroundColor(IBestCalendarColor.bgColor)
		.borderRadius(getSizeByUnit(this.cornerRadius))
    }
}