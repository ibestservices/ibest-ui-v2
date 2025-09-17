import { getEventName, getResourceStr, getSizeByUnit, getComponentsInfo } from '../../utils/utils'
import { AnyType } from '../../model/AnyType'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { emitter } from '../../utils/EventEmitter'
import { IBestTableColor } from './color'
import {
	COMPONENT_NAME,
	IBestCellPosition,
	IBestTableColumnData,
	IBestTableColumnInfo,
	TABLE_EVENT_NAME
} from './index.type'
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
	 * 默认插槽
	 */
	@BuilderParam defaultBuilder: CustomBuilder

	@Local uniId: number = 0
	@Provider() columnList: IBestTableColumnInfo[] = []
	@Provider() leftFixedColumnList: IBestTableColumnInfo[] = []
	@Provider() rightFixedColumnList: IBestTableColumnInfo[] = []
	@Local headerHeight: number = 0
	@Local footerHeight: number = 0
	private uiContext = this.getUIContext()
	private headerScroller: Scroller = new Scroller()
	private bodyHorizontalScroller: Scroller = new Scroller()
	private bodyVerticalScroller: Scroller = new Scroller()
	private leftFixedBodyScroller: Scroller = new Scroller()
	private rightFixedBodyScroller: Scroller = new Scroller()
	private footerScroller: Scroller = new Scroller()

	@Builder headerFooterCellBuilder(cellType: 'header' | 'footer', position: IBestCellPosition){
		HeaderFooterCellRow({
			data: this.data,
			cellType,
			cellPosition: position,
			headerBgColor: this.headerBgColor,
			headerFontSize: this.headerFontSize,
			headerTextColor: this.headerTextColor,
			cellFontSize: this.cellFontSize,
			cellPadding: this.cellPadding,
			cellTextColor: this.cellTextColor,
			showBorder: this.showBorder,
			bdColor: this.bdColor,
			summaryMethod: this.summaryMethod,
			sumText: this.sumText
		})
	}
	@Builder cellBodyBuilder(position: IBestCellPosition){
		Column(){
			ForEach(this.data, (item: AnyType, index: number) => {
				BodyCellRow({
					cellPosition: position,
					item: item,
					rowIndex: index,
					headerBgColor: this.headerBgColor,
					headerFontSize: this.headerFontSize,
					headerTextColor: this.headerTextColor,
					cellFontSize: this.cellFontSize,
					cellPadding: this.cellPadding,
					cellTextColor: this.cellTextColor,
					showBorder: this.showBorder,
					bdColor: this.bdColor,
					cellBgColor: this.cellBgColor,
					stripe: this.stripe,
					stripeBgColor: this.stripeBgColor
				})
			}, (_: AnyType, index: number) => index.toString())
		}
	}
	@Styles ibestTableFixBodyStyle(){
		.height(this.fixHeight ? CONTAINER_SIZE.FULL : '')
		.constraintSize({maxHeight: this.maxHeight ? `calc(${this.maxHeight} - ${this.headerHeight}vp - ${this.footerHeight}vp)` : undefined})
		.align(Alignment.Start)
	}

	aboutToAppear() {
		this.uniId = this.getUniqueId()
		emitter.on(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.SEND_COLUMN_ITEM, this.tableId), this.uniId, (column: IBestTableColumnInfo): void => this.getColumn(column))
		emitter.on(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.COLUMN_ITEM_CHANGE, this.tableId), this.uniId, (column: IBestTableColumnInfo): void => this.updateColumn(column))
	}
	aboutToDisappear(): void {
		emitter.off(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.SEND_COLUMN_ITEM, this.tableId), this.uniId)
		emitter.off(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.COLUMN_ITEM_CHANGE, this.tableId), this.uniId)
	}
	getColumn(column: IBestTableColumnInfo){
		this.columnList.push(new IBestTableColumnInfo(column))
		if(column.fixed){
			let fixed = column.fixed
			if(typeof fixed == 'string' && fixed == 'right'){
				this.rightFixedColumnList.push(new IBestTableColumnInfo(column))
			}else{
				this.leftFixedColumnList.push(new IBestTableColumnInfo(column))
			}
		}
	}
	// 更新列
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
	build() {
		Column(){
			Row(){
				Scroll(this.headerScroller){
					this.headerFooterCellBuilder('header', 'body')
				}
				.width(CONTAINER_SIZE.FULL)
				.align(Alignment.Start)
				.scrollable(ScrollDirection.Horizontal)
				.scrollBar(BarState.Off)
				.enableScrollInteraction(false)
				.edgeEffect(EdgeEffect.None)
				if(this.leftFixedColumnList.length){
					this.headerFooterCellBuilder('header', 'left')
				}
				if(this.rightFixedColumnList.length){
					this.headerFooterCellBuilder('header', 'right')
				}
			}
			.width(CONTAINER_SIZE.FULL)
			.id(`ibest_table_header_${this.uniId}`)
			Row(){
				Scroll(this.bodyVerticalScroller){
					Scroll(this.bodyHorizontalScroller){
						this.cellBodyBuilder("body")
					}
					.width(CONTAINER_SIZE.FULL)
					.align(Alignment.Start)
					.scrollable(ScrollDirection.Horizontal)
					.edgeEffect(EdgeEffect.None)
					.nestedScroll({
						scrollForward: NestedScrollMode.SELF_FIRST,
						scrollBackward: NestedScrollMode.SELF_FIRST
					})
					.onDidScroll(() => {
						let xOffset = this.bodyHorizontalScroller.currentOffset().xOffset
						this.headerScroller.scrollTo({xOffset, yOffset: 0})
						if(this.showSummary){
							this.footerScroller.scrollTo({xOffset, yOffset: 0})
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
				.onDidScroll(() => {
					let yOffset = this.bodyVerticalScroller.currentOffset().yOffset
					if(this.leftFixedColumnList.length){
						this.leftFixedBodyScroller.scrollTo({xOffset: 0, yOffset})
					}
					if(this.rightFixedColumnList.length){
						this.rightFixedBodyScroller.scrollTo({xOffset: 0, yOffset})
					}
				})
				if(this.leftFixedColumnList.length){
					Scroll(this.leftFixedBodyScroller){
						this.cellBodyBuilder("left")
					}
					.ibestTableFixBodyStyle()
					.ibestTableFixScrollStyle('left')
				}
				if(this.rightFixedColumnList.length){
					Scroll(this.rightFixedBodyScroller) {
						this.cellBodyBuilder("right")
					}
					.ibestTableFixBodyStyle()
					.ibestTableFixScrollStyle('right')
				}
			}
			.width(CONTAINER_SIZE.FULL)
			.layoutWeight(this.fixHeight ? 1 : undefined)
			if(this.showSummary){
				Row(){
					Scroll(this.footerScroller){
						this.headerFooterCellBuilder('footer', 'body')
					}
					.width(CONTAINER_SIZE.FULL)
					.align(Alignment.Start)
					.scrollable(ScrollDirection.Horizontal)
					.scrollBar(BarState.Off)
					.enableScrollInteraction(false)
					.edgeEffect(EdgeEffect.None)
					if(this.leftFixedColumnList.length){
						this.headerFooterCellBuilder('footer', 'left')
					}
					if(this.rightFixedColumnList.length){
						this.headerFooterCellBuilder('header', 'right')
					}
				}
				.width(CONTAINER_SIZE.FULL)
				.id(`ibest_table_footer_${this.uniId}`)
			}
			if(this.defaultBuilder){
				this.defaultBuilder()
			}
		}
		.width(CONTAINER_SIZE.FULL)
		.height(getSizeByUnit(this.fixHeight))
		.border({width: {left: this.showBorder ? 1 : 0, top: 1}, color: this.bdColor})
		.constraintSize({maxHeight: getSizeByUnit(this.maxHeight)})
		.onAreaChange(() => {
			let height1 = getComponentsInfo(this.uiContext, `ibest_table_header_${this.uniId}`).height
			let height2 = getComponentsInfo(this.uiContext, `ibest_table_footer_${this.uniId}`).height
			this.headerHeight = height1
			this.footerHeight = height2
		})
	}
}

@ComponentV2
struct HeaderFooterCellRow{
	@Param @Require cellType: 'header' | 'footer'
	@Param @Require cellPosition: IBestCellPosition
	@Param @Require data: AnyType[]
	@Param @Require bdColor: ResourceColor
	@Param @Require headerBgColor: ResourceColor
	@Param @Require cellFontSize: IBestStringNumber
	@Param @Require cellPadding: Length | Padding | LocalizedPadding
	@Param @Require cellTextColor: ResourceColor
	@Param @Require headerFontSize: IBestStringNumber
	@Param @Require headerTextColor: ResourceColor
	@Param @Require showBorder: boolean
	@Param @Require sumText: ResourceStr
	@Consumer() columnList: IBestTableColumnInfo[] = []
	@Consumer() leftFixedColumnList: IBestTableColumnInfo[] = []
	@Consumer() rightFixedColumnList: IBestTableColumnInfo[] = []
	@Event summaryMethod?: (data: AnyType[], column: IBestTableColumnData) => IBestStringNumber[]
	@Local rowHeight: number = 0
	getColumnList(position: IBestCellPosition){
		return position == 'left' ? this.leftFixedColumnList : position == 'right' ? this.rightFixedColumnList : this.columnList
	}
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
			ForEach(this.getColumnList(this.cellPosition), (column: IBestTableColumnInfo, index: number) => {
				TableCell({
					cellType: this.cellType,
					pos: this.cellPosition,
					column: column,
					columnIndex: index,
					rowHeight: this.rowHeight,
					bdColor: this.bdColor,
					cellFontSize: this.cellFontSize,
					cellPadding: this.cellPadding,
					cellTextColor: this.cellTextColor,
					headerFontSize: this.headerFontSize,
					headerTextColor: this.headerTextColor,
					showBorder: this.showBorder,
					summaryList: this.summaryMethod ? this.summaryMethod(this.data, column) : this.getSummary(),
					headerBuilder: column.headerBuilder,
					cellBuilder: column.cellBuilder
				})
			}, (_: IBestTableColumnInfo, index: number) => index.toString())
		}
		.border({width: {bottom: 1}, color: this.bdColor})
		.backgroundColor(this.cellType == 'header' ? this.headerBgColor : IBestTableColor.footerBgColor)
		.position(this.cellPosition == 'left' ? {left: 0, top: 0} : this.cellPosition == 'right' ? {right: 0, top: 0} : undefined)
		.onAreaChange((oldValue: Area, newValue: Area) => {
			if(oldValue.height <= 0){
				this.rowHeight = newValue.height as number
			}
		})
	}
}

@ComponentV2
struct BodyCellRow{
	@Param @Require item: AnyType
	@Param @Require rowIndex: number
	@Param @Require cellPosition: IBestCellPosition
	@Param @Require bdColor: ResourceColor
	@Param @Require headerBgColor: ResourceColor
	@Param @Require cellFontSize: IBestStringNumber
	@Param @Require cellPadding: Length | Padding | LocalizedPadding
	@Param @Require cellTextColor: ResourceColor
	@Param @Require headerFontSize: IBestStringNumber
	@Param @Require headerTextColor: ResourceColor
	@Param @Require showBorder: boolean
	@Param @Require stripe: boolean
	@Param @Require stripeBgColor: ResourceColor
	@Param @Require cellBgColor: ResourceColor
	@Consumer() columnList: IBestTableColumnInfo[] = []
	@Consumer() leftFixedColumnList: IBestTableColumnInfo[] = []
	@Consumer() rightFixedColumnList: IBestTableColumnInfo[] = []
	@Local rowHeight: number = 0
	getColumnList(position: IBestCellPosition){
		return position == 'left' ? this.leftFixedColumnList : position == 'right' ? this.rightFixedColumnList : this.columnList
	}
	build() {
		Row(){
			ForEach(this.getColumnList(this.cellPosition), (column: IBestTableColumnInfo, index1: number) => {
				TableCell({
					cellType: 'body',
					pos: this.cellPosition,
					item: this.item,
					rowIndex: this.rowIndex,
					column: column,
					columnIndex: index1,
					rowHeight: this.rowHeight,
					bdColor: this.bdColor,
					cellFontSize: this.cellFontSize,
					cellPadding: this.cellPadding,
					cellTextColor: this.cellTextColor,
					headerFontSize: this.headerFontSize,
					headerTextColor: this.headerTextColor,
					showBorder: this.showBorder,
					headerBuilder: column.headerBuilder,
					cellBuilder: column.cellBuilder
				})
			}, (_: IBestTableColumnInfo, index1: number) => index1.toString())
		}
		.border({width: {bottom: 1}, color: this.bdColor})
		.backgroundColor(this.stripe && this.rowIndex % 2 == 0 ? this.stripeBgColor : this.cellBgColor)
		.onAreaChange((oldValue: Area, newValue: Area) => {
			if(oldValue.height <= 0){
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
	@Param @Require headerFontSize: IBestStringNumber
	@Param @Require headerTextColor: ResourceColor
	@Param @Require cellFontSize: IBestStringNumber
	@Param @Require cellTextColor: ResourceColor
	@Param @Require cellPadding: Length | Padding | LocalizedPadding
	@Param @Require showBorder: boolean
	@Param @Require bdColor: ResourceColor
	@Param summaryList: IBestStringNumber[] = []
	@Param @Require rowHeight: number
	@BuilderParam headerBuilder: (column: IBestTableColumnData, columnIndex: number) => void
	@BuilderParam cellBuilder: (row: AnyType, column: IBestTableColumnData, rowIndex: number, columnIndex: number) => void
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
	build() {
		Row(){
			if(!(this.column.fixed && this.pos == 'body')){
				if(this.cellType == 'header' && this.headerBuilder){
					this.headerBuilder({title: this.column.title, prop: this.column.prop}, this.columnIndex)
				}else if(this.cellType == 'body' && this.cellBuilder){
					this.cellBuilder(this.item, {title: this.column.title, prop: this.column.prop}, this.rowIndex, this.columnIndex)
				}else{
					Text(this.getText())
						.fontSize(this.cellType == 'header' ? this.headerFontSize : this.cellFontSize)
						.fontColor(this.cellType == 'header' ? this.headerTextColor : this.cellTextColor)
						.fontWeight(this.cellType == 'header' ? 600 : FontWeight.Normal)
						.textAlign(this.getTextAlign())
						.maxLines(1)
						.textOverflow({overflow: TextOverflow.Ellipsis})
				}
			}
		}
		.width(getSizeByUnit(this.column.cellWidth))
		.height(this.rowHeight || 'auto')
		.layoutWeight(!this.column.cellWidth ? 1 : 0)
		.constraintSize({minWidth: getSizeByUnit(this.column.minWidth)})
		.padding(this.cellPadding)
		.border({width: {right: this.showBorder ? 1 : 0}, color: this.bdColor})
		.visibility(this.column.show ? Visibility.Visible : Visibility.None)
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
		emitter.emit(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.SEND_COLUMN_ITEM, this.tableId), {
			show: this.show,
			title: this.title,
			prop: this.prop,
			cellWidth: this.cellWidth,
			minWidth: this.minWidth,
			cellAlign: this.cellAlign,
			headerAlign: this.headerAlign || this.cellAlign,
			fixed: this.fixed,
			formatter: this.formatter,
			headerBuilder: this.headerBuilder,
			cellBuilder: this.cellBuilder
		})
	}
	@Monitor("show")
	showChange(){
		emitter.emit(getEventName(COMPONENT_NAME, TABLE_EVENT_NAME.COLUMN_ITEM_CHANGE, this.tableId), {
			prop: this.prop,
			show: this.show
		})
	}
	build() {}
}