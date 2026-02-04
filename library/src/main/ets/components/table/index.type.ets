import { AnyType } from '../../model/AnyType'
/**
 * 组件名称
 */
export const COMPONENT_NAME = "TABLE"
/**
 * Table事件名称
 */

export enum TABLE_EVENT_NAME {
	/**
	 * 获取所有列信息
	 */
	SEND_COLUMN_ITEM = "SEND_ITEM",
	/**
	 * 列属性变化
     */
	COLUMN_ITEM_CHANGE = "COLUMN_ITEM_CHANGE"
}
/**
 * 单元格位置
 */
export type IBestCellPosition = "left" | "right" | "body"
/**
 * 列信息
 */
export class IBestTableColumnData {
	/**
	 * 列标题
	 */
	title?: ResourceStr = ""
	/**
	 * 属性
	 */
	prop: string = ""
}
@ObservedV2
class IBestTableColumnType extends IBestTableColumnData {
	/**
	 * 列是否显示
	 */
	@Trace show?: boolean = true
	/**
	 * 列宽度
	 */
	cellWidth: number = 0
	/**
	 * 列最小宽度
	 */
	minWidth: number = 0
	/**
	 * 单元格对齐方式
	 */
	cellAlign?: 'left' | 'center' | 'right' = "left"
	/**
	 * 表头对齐方式, 若不设置该项，则使用单元格的对齐方式
	 */
	headerAlign?: 'left' | 'center' | 'right' = "left"
	/**
	 * 列是否固定在左侧或者右侧。 true 表示固定在左侧
	 */
	fixed?: boolean | 'left' | 'right'
	/**
	 * 父标题属性
	 */
	parentProp: string = ""
	/**
	 * 子列
	 */
	@Trace children: IBestTableColumnInfo[] = []
	/**
	 * 格式化函数
	 */
	formatter?: (row: AnyType, column: IBestTableColumnData, rowIndex: number, columnIndex: number) => string
	/**
	 * 自定义表头内容
     */
	headerBuilder?: (column: IBestTableColumnData, columnIndex: number) => void
	/**
	 * 自定义单元格内容
	 */
	cellBuilder?: (row: AnyType, column: IBestTableColumnData, rowIndex: number, columnIndex: number) => void
}
export class IBestTableColumnInfo extends IBestTableColumnType {
	constructor(value?: IBestTableColumnType) {
		super()
		if(value){
			this.show = value.show ?? true
			this.title = value.title ?? ""
			this.prop = value.prop ?? ""
			this.cellWidth = value.cellWidth ?? 0
			this.minWidth = value.minWidth ?? 0
			this.cellAlign = value.cellAlign ?? 'left'
			this.headerAlign = value.headerAlign ?? this.cellAlign
			this.fixed = value.fixed ?? false
			this.parentProp = value.parentProp
			this.formatter = value.formatter
			this.headerBuilder = value.headerBuilder
			this.cellBuilder = value.cellBuilder
		}
	}
}