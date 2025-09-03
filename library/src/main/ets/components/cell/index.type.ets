import { IBestStringNumber } from "../../model/Global.type"

export enum ARROW_DIRECTION {
	TOP = 'top',
	RIGHT = 'right',
	BOTTOM = 'bottom',
	LEFT = 'left'
}
export interface CellSizeType {
	padding: IBestStringNumber
	fontSize: IBestStringNumber
	labelFontSize: IBestStringNumber
}