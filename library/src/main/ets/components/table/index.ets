import { generateId, getEventName, getResourceStr, getSizeByUnit } from '../../utils/utils'
import { AnyType } from '../../model/AnyType'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import ibestEmitter from '../../utils/eventEmitter'
import { IBestTableColor } from './color'
import { COMPONENT_NAME, IBestCellPosition, IBestTableColumnData, IBestTableColumnInfo, TABLE_EVENT_NAME } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'

@Extend(Scroll) function ibestTableFixScrollStyle(position: string){
	.scrollBar(BarState.Off)
	.enableScrollInteraction(false)
	.edgeEffect(EdgeEffect.None)
	.position(position == 'left' ? {left: 0, top: 0} : {right: 0, top: 0})
}

@ComponentV2
export struct IBestTable {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 表格id
	 */
	@Param @Require tableId: IBestStringNumber
	/**
	 * 表格数据
	 */
	@Param @Require data: AnyType[]
	/**
	 * 斑马纹
	 */
	@Param stripe: boolean = false
	/**
	 * 是否显示纵向边框
	 */
	@Param showBorder: boolean = false
	/**
	 * 高度
	 */
	@Param fixHeight: IBestStringNumber = ""
	/**
	 * 最大高度
	 */
	@Param maxHeight?: IBestStringNumber = undefined
	/**
	 * 表头背景色
	 */
	@Param headerBgColor: ResourceColor = IBestTableColor.headerBgColor
	/**
	 * 表头文字颜色
	 */
	@Param headerTextColor: ResourceColor = IBestTableColor.headerTextColor
	/**
	 * 表头文字大小
	 */
	@Param headerFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 边框色
	 */
	@Param bdColor: ResourceColor = IBestTableColor.borderColor
	/**
	 * 单元格背景颜色
	 */
	@Param cellBgColor: ResourceColor = IBestTableColor.cellBgColor
	/**
	 * 斑马纹背景色
	 */
	@Param stripeBgColor: ResourceColor = IBestTableColor.cellStripeColor
	/**
	 * 单元格文字颜色
	 */
	@Param cellTextColor: ResourceColor = IBestTableColor.cellTextColor
	/**
	 * 单元格文字大小
	 */
	@Param cellFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 单元格内边距
	 */
	@Param cellPadding: Length | Padding | LocalizedPadding = { left: this.baseStyle.spaceX, right: this.baseStyle.spaceX, bottom: this.baseStyle.spaceXs, top: this.baseStyle.spaceXs }
	/**
	 * 是否显示合计
	 */
	@Param showSummary: boolean = false
	/**
	 * 显示摘要行第一列的文本
	 */
	@Param sumText: ResourceStr = $r("app.string.ibest_text_sum")
	/**
	 * 自定义合计函数
	 */
	@Event summaryMethod?: (data: AnyType[], column: IBestTableColumnData) => IBestStringNumber[] = undefined
	/**
	 * 合并行列计算方法
	 * @since 1.1.1
	 */
	@Event spanMethod: (row: AnyType, column: IBestTableColumnData, rowIndex: number, columnIndex: number) => number[] = () => [1,1]
	/**
	 * 默认插槽
	 */
	@BuilderParam defaultBuilder: CustomBuilder

	@Local uniId: number = 0
	@Local columnList: IBestTableColumnInfo[] = []
	@Local leftFixedColumnList: IBestTableColumnInfo[] = []
	@Local rightFixedColumnList: IBestTableColumnInfo[] = []
	@Provider() rowHeightList: number[] = Array(this.data.length).fill(0)
	@Provider() columnWidthList: number[] = []
	@Local headerHeight: number = 0
	@Local footerHeight: number = 0
	private headerScroller: Scroller = new Scroller()
	private bodyHorizontalScroller: Scroller = new Scroller()
	private bodyVerticalScroller: Scroller = new Scroller()
	private leftFixedBodyScroller: Scroller = new Scroller()
	private rightFixedBodyScroller: Scroller = new Scroller()
	private footerScroller: Scroller = new Scroller()
	private timer: number = -1

	@Builder headerBuilder(position: IBestCellPosition){
		HeaderCellRow({
			cellPosition: position,
			columnList: this.getColumnList(position),
			isMultiLevelHeader: this.isMultiLevelHeader,
			headerBgColor: this.headerBgColor,
			headerFontSize: this.headerFontSize,
			headerTextColor: this.headerTextColor,
			cellFontSize: this.cellFontSize,
			cellPadding: this.cellPadding,
			cellTextColor: this.cellTextColor,
			showBorder: this.showBorder,
			bdColor: this.bdColor,
			stripe: this.stripe,
			stripeBgColor: this.stripeBgColor,
			cellBgColor: this.cellBgColor
		})
	}
	@Builder bodyBuilder(position: IBestCellPosition){
		Column(){
			ForEach(this.data, (item: AnyType, index: number) => {
				BodyCellRow({
					cellPosition: position,
					item,
					rowIndex: index,
					columnList: this.getColumnList(position),
					isMultiLevelHeader: this.isMultiLevelHeader,
					headerBgColor: this.headerBgColor,
					headerFontSize: this.headerFontSize,
					headerTextColor: this.headerTextColor,
					cellFontSize: this.cellFontSize,
					cellPadding: this.cellPadding,
					cellTextColor: this.cellTextColor,
					showBorder: this.showBorder,
					bdColor: this.bdColor,
					stripe: this.stripe,
					cellBgColor: this.cellBgColor,
					stripeBgColor: this.stripeBgColor,
					spanMethod: this.spanMethod
				})
			}, (_: AnyType, index: number) => `${generateId()}_${index}`)
		}
		.alignItems(HorizontalAlign.Start)
	}
	@Builder footerBuilder(position: IBestCellPosition){
		FooterCellRow({
			data: this.data,
			cellPosition: position,
			columnList: this.getColumnList(position),
			isMultiLevelHeader: this.isMultiLevelHeader,
			headerBgColor: this.headerBgColor,
			headerFontSize: this.headerFontSize,
			headerTextColor: this.headerTextColor,
			cellFontSize: this.cellFontSize,
			cellPadding: this.cellPadding,
			cellTextColor: this.cellTextColor,
			showBorder: this.showBorder,
			bdColor: this.bdColor,
			stripe: this.stripe,
			stripeBgColor: this.stripeBgColor,
			cellBgColor: this.cellBgColor,
			summaryMethod: this.summaryMethod,
			sumText: this.sumText
		})
	}
	@Styles ibestTableFixBodyStyle(){
		.height(this.fixHeight ? CONTAINER_SIZE.FULL : '')
		.constraintSize({maxHeight: this.maxHeight ? `calc(${this.maxHeight} - ${this.headerHeight}vp - ${this.footerHeight}vp)` : undefined})
		.align(Alignment.Start)
	}

	aboutToAppear() {
		this.uniId = this.getUniqueId()
		ibestEmitter.on(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.SEND_COLUMN_ITEM, this.tableId), this.uniId, (column: IBestTableColumnInfo): void => this.getColumn(column))
		ibestEmitter.on(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.COLUMN_ITEM_CHANGE, this.tableId), this.uniId, (column: IBestTableColumnInfo): void => this.updateColumn(column))
	}
	aboutToDisappear() {
		ibestEmitter.off(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.SEND_COLUMN_ITEM, this.tableId), this.uniId)
		ibestEmitter.off(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.COLUMN_ITEM_CHANGE, this.tableId), this.uniId)
	}
	getColumn(column: IBestTableColumnInfo){
		if(column.parentProp){
			this.insertDataByProp(this.columnList, column)
		}else {
			this.columnList.push(new IBestTableColumnInfo(column))
		}
		if(column.fixed && !column.parentProp){
			let fixed = column.fixed
			if(typeof fixed == 'string' && fixed == 'right'){
				this.rightFixedColumnList.push(new IBestTableColumnInfo(column))
			}else{
				this.leftFixedColumnList.push(new IBestTableColumnInfo(column))
			}
		}
		clearTimeout(this.timer)
		this.timer = setTimeout(() => {
			this.columnWidthList = Array(this.columnList.length).fill(0)
		}, 0)
	}
	insertDataByProp(list: IBestTableColumnInfo[], data: IBestTableColumnInfo) {
		let targetData: IBestTableColumnInfo | null = null
		const findNodes = (node: IBestTableColumnInfo) => {
			if (node.prop === data.parentProp) {
				targetData = node
			}
			if(targetData){
				return true
			}
			if (node.children && node.children.length) {
				for (let i = 0; i < node.children.length; i++) {
					if (findNodes(node.children[i])) {
						return true
					}
				}
			}
			return false
		}
		for (let i = 0; i < list.length; i++) {
			if (findNodes(list[i])) {
				break
			}
		}
		if (!targetData) {
			console.error(`未找到prop为${data.parentProp}的列`)
			return data
		}
		(targetData as IBestTableColumnInfo).children!.push(new IBestTableColumnInfo(data))
		return data
	}
	updateColumn(column: IBestTableColumnInfo){
		let item = this.columnList.find(e => e.prop == column.prop)
		if(item){
			item.show = column.show
		}
		if(this.leftFixedColumnList){
			let leftItem = this.leftFixedColumnList.find(e => e.prop == column.prop)
			if(leftItem){
				leftItem.show = column.show
			}
		}
		if(this.rightFixedColumnList){
			let rightItem = this.rightFixedColumnList.find(e => e.prop == column.prop)
			if(rightItem){
				rightItem.show = column.show
			}
		}
	}
	getColumnList(position: IBestCellPosition){
		return position == 'left' ? this.leftFixedColumnList : position == 'right' ? this.rightFixedColumnList : this.columnList
	}
	@Computed
	get bodyShow(){
		return this.columnWidthList.length && this.columnWidthList.every(e => e > 0) && this.rowHeightList.every(e => e > 0)
	}
	@Computed
	get isMultiLevelHeader(){
		return this.columnList.some(e => e.children.length)
	}

	build() {
		Column(){
			Row(){
				Scroll(this.headerScroller){
					this.headerBuilder('body')
				}
				.width(CONTAINER_SIZE.FULL)
				.align(Alignment.Start)
				.scrollable(ScrollDirection.Horizontal)
				.scrollBar(BarState.Off)
				.enableScrollInteraction(false)
				.edgeEffect(EdgeEffect.None)
				if(this.leftFixedColumnList.length){
					this.headerBuilder('left')
				}
				if(this.rightFixedColumnList.length){
					this.headerBuilder('right')
				}
			}
			.width(CONTAINER_SIZE.FULL)
			.onAreaChange((_: Area, newValue: Area) => {
				this.headerHeight = newValue.width as number
			})
			if(this.columnWidthList.length) {
				Row() {
					Scroll(this.bodyVerticalScroller) {
						Scroll(this.bodyHorizontalScroller) {
							this.bodyBuilder('body')
						}
						.width(CONTAINER_SIZE.FULL)
						.align(Alignment.Start)
						.scrollable(ScrollDirection.Horizontal)
						.edgeEffect(EdgeEffect.None)
						.nestedScroll({
							scrollForward: NestedScrollMode.SELF_FIRST,
							scrollBackward: NestedScrollMode.SELF_FIRST
						})
						.onDidScroll((xOffset: number) => {
							this.headerScroller.scrollBy(xOffset, 0)
							if(this.showSummary){
								this.footerScroller.scrollBy(xOffset, 0)
							}
						})
					}
					.ibestTableFixBodyStyle()
					.scrollable(this.fixHeight || this.maxHeight ? ScrollDirection.Vertical : ScrollDirection.None)
					.edgeEffect(EdgeEffect.None)
					.nestedScroll({
						scrollForward: NestedScrollMode.SELF_FIRST,
						scrollBackward: NestedScrollMode.SELF_FIRST
					})
					.onDidScroll((_: number, yOffset: number) => {
						if(this.leftFixedColumnList.length){
							this.leftFixedBodyScroller.scrollBy(0, yOffset)
						}
						if(this.rightFixedColumnList.length){
							this.rightFixedBodyScroller.scrollBy(0, yOffset)
						}
					})
					if (this.leftFixedColumnList.length) {
						Scroll(this.leftFixedBodyScroller) {
							this.bodyBuilder("left")
						}
						.ibestTableFixBodyStyle()
						.ibestTableFixScrollStyle('left')
					}
					if (this.rightFixedColumnList.length) {
						Scroll(this.rightFixedBodyScroller) {
							this.bodyBuilder("right")
						}
						.ibestTableFixBodyStyle()
						.ibestTableFixScrollStyle('right')
					}
				}
				.width(CONTAINER_SIZE.FULL)
				.layoutWeight(this.fixHeight ? 1 : undefined)
				.visibility(this.bodyShow ? Visibility.Visible : Visibility.Hidden)
				.animation({duration: this.baseStyle.animationDuration as number})
				if(this.showSummary){
					Row(){
						Scroll(this.footerScroller){
							this.footerBuilder('body')
						}
						.width(CONTAINER_SIZE.FULL)
						.align(Alignment.Start)
						.scrollable(ScrollDirection.Horizontal)
						.scrollBar(BarState.Off)
						.enableScrollInteraction(false)
						.edgeEffect(EdgeEffect.None)
						if(this.leftFixedColumnList.length){
							this.footerBuilder('left')
						}
						if(this.rightFixedColumnList.length){
							this.footerBuilder('right')
						}
					}
					.width(CONTAINER_SIZE.FULL)
					.visibility(this.bodyShow ? Visibility.Visible : Visibility.Hidden)
					.animation({duration: this.baseStyle.animationDuration as number})
					.onAreaChange((_: Area, newValue: Area) => {
						this.footerHeight = newValue.width as number
					})
				}
			}
			if(this.defaultBuilder){
				this.defaultBuilder()
			}
		}
		.width(CONTAINER_SIZE.FULL)
		.height(getSizeByUnit(this.fixHeight))
		.border({
			width: {
				left: this.showBorder || this.isMultiLevelHeader ? 1 : 0,
				top: 1
			},
			color: this.bdColor
		})
		.constraintSize({maxHeight: getSizeByUnit(this.maxHeight)})
	}
}

@ComponentV2
struct HeaderCellRow{
	@Param @Require cellPosition: IBestCellPosition
	@Param @Require columnList: IBestTableColumnInfo[] = []
	@Param @Require isMultiLevelHeader: boolean = false
	@Param @Require bdColor: ResourceColor
	@Param @Require headerBgColor: ResourceColor
	@Param @Require headerFontSize: IBestStringNumber
	@Param @Require headerTextColor: ResourceColor
	@Param @Require cellFontSize: IBestStringNumber
	@Param @Require cellPadding: Length | Padding | LocalizedPadding
	@Param @Require cellTextColor: ResourceColor
	@Param @Require showBorder: boolean
	@Param @Require stripe: boolean
	@Param @Require stripeBgColor: ResourceColor
	@Param @Require cellBgColor: ResourceColor

	@Local rowHeight: number = 0

	build() {
		Row(){
			ForEach(this.columnList, (column: IBestTableColumnInfo, index: number) => {
				TableCell({
					cellType: 'header',
					pos: this.cellPosition,
					column: column,
					columnIndex: index,
					isMultiLevelHeader: this.isMultiLevelHeader,
					rowHeight: this.rowHeight,
					bdColor: this.bdColor,
					cellFontSize: this.cellFontSize,
					cellPadding: this.cellPadding,
					cellTextColor: this.cellTextColor,
					headerBgColor: this.headerBgColor,
					headerFontSize: this.headerFontSize,
					headerTextColor: this.headerTextColor,
					showBorder: this.showBorder,
					stripe: this.stripe,
					stripeBgColor: this.stripeBgColor,
					cellBgColor: this.cellBgColor,
					headerBuilder: column.headerBuilder,
					cellBuilder: column.cellBuilder
				})
			})
		}
		.height(this.rowHeight || "auto")
		.backgroundColor(this.headerBgColor)
		.position(this.cellPosition == 'left' ? {left: 0, top: 0} : this.cellPosition == 'right' ? {right: 0, top: 0} : undefined)
		.onAreaChange((oldValue: Area, newValue: Area) => {
			if(newValue.height != oldValue.height){
				this.rowHeight = newValue.height as number
			}
		})
	}
}

@ComponentV2
struct BodyCellRow{
	@Param @Require cellPosition: IBestCellPosition
	@Param @Require item: AnyType
	@Param @Require rowIndex: number
	@Param @Require columnList: IBestTableColumnInfo[]
	@Param @Require isMultiLevelHeader: boolean = false
	@Param @Require bdColor: ResourceColor
	@Param @Require headerBgColor: ResourceColor
	@Param @Require headerFontSize: IBestStringNumber
	@Param @Require headerTextColor: ResourceColor
	@Param @Require cellFontSize: IBestStringNumber
	@Param @Require cellPadding: Length | Padding | LocalizedPadding
	@Param @Require cellTextColor: ResourceColor
	@Param @Require showBorder: boolean
	@Param @Require stripe: boolean
	@Param @Require stripeBgColor: ResourceColor
	@Param @Require cellBgColor: ResourceColor
	@Consumer() rowHeightList: number[] = []
	@Event spanMethod: (row: AnyType, column: IBestTableColumnData, rowIndex: number, columnIndex: number) => number[] = () => [1,1]

	@Local rowHeight: number = 0

	build() {
		Row(){
			ForEach(this.columnList, (column: IBestTableColumnInfo, index1: number) => {
				TableCell({
					cellType: 'body',
					pos: this.cellPosition,
					item: this.item,
					rowIndex: this.rowIndex,
					column: column,
					columnIndex: index1,
					isMultiLevelHeader: this.isMultiLevelHeader,
					rowHeight: this.rowHeight,
					bdColor: this.bdColor,
					cellFontSize: this.cellFontSize,
					cellPadding: this.cellPadding,
					cellTextColor: this.cellTextColor,
					headerBgColor: this.headerBgColor,
					headerFontSize: this.headerFontSize,
					headerTextColor: this.headerTextColor,
					showBorder: this.showBorder,
					stripe: this.stripe,
					stripeBgColor: this.stripeBgColor,
					cellBgColor: this.cellBgColor,
					headerBuilder: column.headerBuilder,
					cellBuilder: column.cellBuilder,
					spanMethod: this.spanMethod
				})
			})
		}
		.alignItems(VerticalAlign.Top)
		.onAreaChange((oldValue: Area, newValue: Area) => {
			if(oldValue.height != newValue.height){
				this.rowHeight = newValue.height as number
				if(this.cellPosition == 'body'){
					let rowHeightList = this.rowHeightList.slice()
					rowHeightList[this.rowIndex] = this.rowHeight
					this.rowHeightList = rowHeightList
				}
			}
		})
	}
}

@ComponentV2
struct FooterCellRow{
	@Param @Require cellPosition: IBestCellPosition
	@Param data: AnyType[] = []
	@Param @Require columnList: IBestTableColumnInfo[] = []
	@Param @Require isMultiLevelHeader: boolean = false
	@Param @Require bdColor: ResourceColor
	@Param @Require headerBgColor: ResourceColor
	@Param @Require headerFontSize: IBestStringNumber
	@Param @Require headerTextColor: ResourceColor
	@Param @Require cellFontSize: IBestStringNumber
	@Param @Require cellPadding: Length | Padding | LocalizedPadding
	@Param @Require cellTextColor: ResourceColor
	@Param @Require showBorder: boolean
	@Param @Require stripe: boolean
	@Param @Require stripeBgColor: ResourceColor
	@Param @Require cellBgColor: ResourceColor
	@Param @Require sumText: ResourceStr
	@Param summaryList: IBestStringNumber[] = []
	@Event summaryMethod?: (data: AnyType[], column: IBestTableColumnData) => IBestStringNumber[]

	@Local rowHeight: number = 0

	getSummary(){
		let sums: string[] = []
		this.columnList.forEach((column, index) => {
			if (index === 0) {
				sums[index] = getResourceStr(this.sumText)
				return
			}
			const values = this.data.map((item: AnyType) => Number(item[column.prop]))
			const precisions: number[] = []
			let notNumber = true
			values.forEach((value) => {
				if (!Number.isNaN(+value)) {
					notNumber = false
					const decimal = `${value}`.split('.')[1]
					precisions.push(decimal ? decimal.length : 0)
				}
			})
			const precision: number = Math.max(...precisions)
			if (!notNumber) {
				let sum = values.reduce((prev, curr) => {
					const value = Number(curr)
					if (!Number.isNaN(+value)) {
						return Number.parseFloat(
							(prev + curr).toFixed(Math.min(precision, 20))
						)
					} else {
						return prev
					}
				}, 0)
				sums[index] = sum.toString()
			} else {
				sums[index] = ''
			}
		})
		return sums
	}
	build() {
		Row(){
			ForEach(this.columnList, (column: IBestTableColumnInfo, index: number) => {
				TableCell({
					cellType: 'footer',
					pos: this.cellPosition,
					column: column,
					columnIndex: index,
					rowHeight: this.rowHeight,
					bdColor: this.bdColor,
					cellFontSize: this.cellFontSize,
					cellPadding: this.cellPadding,
					cellTextColor: this.cellTextColor,
					headerBgColor: this.headerBgColor,
					headerFontSize: this.headerFontSize,
					headerTextColor: this.headerTextColor,
					showBorder: this.showBorder,
					stripe: this.stripe,
					stripeBgColor: this.stripeBgColor,
					cellBgColor: this.cellBgColor,
					summaryList: this.summaryList.length ? this.summaryList : this.summaryMethod ? this.summaryMethod(this.data, column) : this.getSummary(),
					sumText: this.sumText
				})
			})
		}
		.backgroundColor(IBestTableColor.footerBgColor)
		.position(this.cellPosition == 'left' ? {left: 0, top: 0} : this.cellPosition == 'right' ? {right: 0, top: 0} : undefined)
		.onAreaChange((oldValue: Area, newValue: Area) => {
			if(newValue.height != oldValue.height){
				this.rowHeight = newValue.height as number
			}
		})
	}
}

@ComponentV2
struct TableCell{
	@Param item: AnyType = ''
	@Param @Require pos: IBestCellPosition
	@Param @Require cellType: 'header' | 'body' | 'footer'
	@Param rowIndex: number = 0
	@Param @Require column: IBestTableColumnInfo
	@Param @Require columnIndex: number
	@Param isMultiLevelHeader: boolean = false
	@Param @Require headerBgColor: ResourceColor
	@Param @Require headerFontSize: IBestStringNumber
	@Param @Require headerTextColor: ResourceColor
	@Param @Require cellFontSize: IBestStringNumber
	@Param @Require cellTextColor: ResourceColor
	@Param @Require cellPadding: Length | Padding | LocalizedPadding
	@Param @Require showBorder: boolean
	@Param @Require bdColor: ResourceColor
	@Param @Require stripe: boolean
	@Param @Require stripeBgColor: ResourceColor
	@Param @Require cellBgColor: ResourceColor
	@Param summaryList: IBestStringNumber[] = []
	@Param sumText: ResourceStr = ''
	@Param @Require rowHeight: number
	@Consumer() rowHeightList: number[] = []
	@Consumer() columnWidthList: number[] = []
	@Event spanMethod: (row: AnyType, column: IBestTableColumnData, rowIndex: number, columnIndex: number) => number[] = () => [1,1]
	@BuilderParam headerBuilder: (column: IBestTableColumnData, columnIndex: number) => void
	@BuilderParam cellBuilder: (row: AnyType, column: IBestTableColumnData, rowIndex: number, columnIndex: number) => void

	@Local realWidth: IBestStringNumber = 0
	@Local realHeight: IBestStringNumber = 0
	@Local rowSpan: number = 0
	@Local colSpan: number = 0

	aboutToAppear(): void {
		const spanArr = this.getSpanArr()
		this.rowSpan = spanArr[0]
		this.colSpan = spanArr[1]
	}
	getSpanArr(){
		let arr = this.spanMethod(this.item, this.column, this.rowIndex, this.columnIndex)
		if(arr.length != 2 || arr.some(item => item < 0)){
			arr = [1,1]
		}
		return arr
	}
	@Monitor("rowHeightList")
	rowHeightChange(){
		if(this.rowHeightList.length && this.rowHeightList.every(item => item > 0)){
			if(this.cellType != 'body' || this.column.fixed && this.pos == 'body'){
				this.realHeight = this.rowHeight || 'auto'
				return
			}
			let rowSpan = this.getSpanArr()[0]
			if(rowSpan <= 1){
				this.realHeight = 0
			}else {
				this.realHeight = this.rowHeightList.slice(this.columnIndex, this.columnIndex + rowSpan).reduce((prev, curr) => {
					return prev + curr
				}, 0)
			}
		}
	}
	@Monitor("columnWidthList")
	columnWidthChange(){
		if(this.columnWidthList.length && this.columnWidthList.every(item => item > 0)){
			if(this.cellType != 'body'){
				this.realWidth = getSizeByUnit(this.column.cellWidth)
				return
			}
			let colSpan = this.getSpanArr()[1]
			if(colSpan <= 1){
				this.realWidth = 0
			}else {
				this.realWidth = this.columnWidthList.slice(this.columnIndex, this.columnIndex + colSpan).reduce((prev, curr) => {
					return prev + (curr || this.column.cellWidth)
				}, 0)
			}
		}
	}
	getWidth(){
		return this.realWidth || getSizeByUnit(this.column.cellWidth)
	}
	getHeight(){
		return this.rowHeight || 'auto'
	}
	getTextAlign(){
		let align = this.cellType == 'header' ? this.column.headerAlign : this.column.cellAlign
		return align == 'center' ? TextAlign.Center : align == 'right' ? TextAlign.End : TextAlign.Start
	}
	getText(): string{
		if(this.cellType == 'body' && this.column.formatter){
			return this.column.formatter(this.item, {title: this.column.title, prop: this.column.prop}, this.rowIndex, this.columnIndex)
		}else {
			return this.cellType == 'header' ? this.column.title : this.cellType == 'body' ? this.item[this.column.prop]?.toString() : this.summaryList[this.columnIndex].toString()
		}
	}
	getBgColor(){
		if(this.cellType != 'body'){
			return ''
		}else if(this.rowSpan > 1){
			return this.cellBgColor
		}else if(this.rowSpan == 1) {
			return this.stripe && this.rowIndex % 2 == 0 ? this.stripeBgColor : this.cellBgColor
		}else {
			return ''
		}
	}

	build() {
		Column() {
			if (this.cellType == 'header' || !this.column.children.length) {
				Stack({ alignContent: Alignment.TopStart }) {
					if(this.cellType == 'body') {
						Row()
							.width(CONTAINER_SIZE.FULL)
							.height(this.getHeight())
					}
					Row() {
						if (!(this.column.fixed && this.pos == 'body')) {
							if (this.cellType == 'header' && this.headerBuilder) {
								this.headerBuilder({ title: this.column.title, prop: this.column.prop },
									this.columnIndex)
							} else if (this.cellType == 'body' && this.cellBuilder) {
								this.cellBuilder(this.item, { title: this.column.title, prop: this.column.prop },
									this.rowIndex, this.columnIndex)
							} else {
								Text(this.getText())
									.width(CONTAINER_SIZE.FULL)
									.fontSize(this.cellType == 'header' ? this.headerFontSize : this.cellFontSize)
									.fontColor(this.cellType == 'header' ? this.headerTextColor : this.cellTextColor)
									.fontWeight(this.cellType == 'header' ? 600 : FontWeight.Normal)
									.textAlign(this.getTextAlign())
									.maxLines(1)
									.textOverflow({ overflow: TextOverflow.Ellipsis })
							}
						}
					}
					.width(this.getWidth())
					.height(this.cellType == 'body' ? this.realHeight || this.getHeight() : this.rowHeight && !this.column.children.length ? this.rowHeight : 'auto')
					.padding(getSizeByUnit(this.cellPadding))
					.border({
						width: {
							right: this.showBorder || this.isMultiLevelHeader ? 1 : 0,
							bottom: 1
						}, color: this.bdColor
					})
					.backgroundColor(this.getBgColor())
					.visibility(this.rowSpan > 0 && this.colSpan > 0 ? Visibility.Visible : Visibility.Hidden)
				}
			}
			if(this.column.children.length){
				if(this.cellType == 'header'){
					HeaderCellRow({
						cellPosition: this.pos,
						columnList: this.column.children,
						isMultiLevelHeader: true,
						headerBgColor: this.headerBgColor,
						headerFontSize: this.headerFontSize,
						headerTextColor: this.headerTextColor,
						cellFontSize: this.cellFontSize,
						cellPadding: this.cellPadding,
						cellTextColor: this.cellTextColor,
						showBorder: this.showBorder,
						bdColor: this.bdColor,
						stripe: this.stripe,
						stripeBgColor: this.stripeBgColor,
						cellBgColor: this.cellBgColor
					})
				}else if(this.cellType == 'body'){
					BodyCellRow({
						cellPosition: this.pos,
						item: this.item,
						rowIndex: this.rowIndex,
						columnList: this.column.children,
						isMultiLevelHeader: true,
						headerBgColor: this.headerBgColor,
						headerFontSize: this.headerFontSize,
						headerTextColor: this.headerTextColor,
						cellFontSize: this.cellFontSize,
						cellPadding: this.cellPadding,
						cellTextColor: this.cellTextColor,
						showBorder: this.showBorder,
						bdColor: this.bdColor,
						stripe: this.stripe,
						cellBgColor: this.cellBgColor,
						stripeBgColor: this.stripeBgColor,
						spanMethod: this.spanMethod
					})
				}else {
					FooterCellRow({
						cellPosition: this.pos,
						columnList: this.column.children,
						isMultiLevelHeader: true,
						headerBgColor: this.headerBgColor,
						headerFontSize: this.headerFontSize,
						headerTextColor: this.headerTextColor,
						cellFontSize: this.cellFontSize,
						cellPadding: this.cellPadding,
						cellTextColor: this.cellTextColor,
						showBorder: this.showBorder,
						bdColor: this.bdColor,
						stripe: this.stripe,
						stripeBgColor: this.stripeBgColor,
						cellBgColor: this.cellBgColor,
						summaryList: this.summaryList,
						sumText: this.sumText
					})
				}
			}
		}
		.width(this.pos == 'body' ? getSizeByUnit(this.column.cellWidth) : this.getWidth())
		.height(this.getHeight())
		.layoutWeight(!this.column.cellWidth ? 1 : 0)
		.alignItems(HorizontalAlign.Start)
		.constraintSize({ minWidth: getSizeByUnit(this.column.minWidth) })
		.visibility(this.column.show ? Visibility.Visible : Visibility.None)
		.onAreaChange((_: Area, newValue: Area) => {
			if (this.cellType == 'body' && !this.column.parentProp && this.columnWidthList[this.columnIndex] == 0) {
				let columnWidthList = this.columnWidthList.slice()
				columnWidthList[this.columnIndex] = newValue.width as number
				this.columnWidthList = columnWidthList
			}
		})
	}
}

@ComponentV2
export struct IBestTableColumn{
	/**
	 * 表格id
	 */
	@Param @Require tableId: IBestStringNumber
	/**
	 * 列标题
	 */
	@Param title: ResourceStr = ""
	/**
	 * 属性
	 */
	@Param prop: string = ""
	/**
	 * 列宽度
	 */
	@Param cellWidth: IBestStringNumber = ''
	/**
	 * 列最小宽度
	 */
	@Param minWidth: IBestStringNumber = ''
	/**
	 * 列是否显示
	 */
	@Param show: boolean = true
	/**
	 * 单元格对齐方式
	 */
	@Param cellAlign: 'left' | 'center' | 'right' = 'left'
	/**
	 * 表头对齐方式, 若不设置该项，则使用单元格的对齐方式
	 */
	@Param headerAlign: 'left' | 'center' | 'right' = this.cellAlign
	/**
	 * 列是否固定在左侧或者右侧。 true 表示固定在左侧
	 */
	@Param fixed: boolean | 'left' | 'right' = false
	/**
	 * 父标题属性, 多级表头时传入
	 */
	@Param parentProp: string = ""
	/**
	 * 格式化函数
	 */
	@Event formatter?: (row: AnyType, column: IBestTableColumnData, rowIndex: number, columnIndex: number) => string = undefined
	/**
	 * 自定义表头内容
	 */
	@BuilderParam headerBuilder: (column: IBestTableColumnData, columnIndex: number) => void
	/**
	 * 自定义单元格内容
	 */
	@BuilderParam cellBuilder: (row: AnyType, column: IBestTableColumnData, rowIndex: number, columnIndex: number) => void

	aboutToAppear(): void {
		ibestEmitter.emit(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.SEND_COLUMN_ITEM, this.tableId), {
			show: this.show,
			title: this.title,
			prop: this.prop,
			cellWidth: this.cellWidth,
			minWidth: this.minWidth,
			cellAlign: this.cellAlign,
			headerAlign: this.headerAlign || this.cellAlign,
			fixed: this.fixed,
			parentProp: this.parentProp,
			formatter: this.formatter,
			headerBuilder: this.headerBuilder,
			cellBuilder: this.cellBuilder
		})
	}
	@Monitor("show")
	showChange(){
		ibestEmitter.emit(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.COLUMN_ITEM_CHANGE, this.tableId), {
			prop: this.prop,
			show: this.show
		})
	}
	build() {}
}