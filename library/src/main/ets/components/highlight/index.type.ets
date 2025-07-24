import { IBestStringNumber } from "../../model/Global.type"
export interface Chunk {
	start: number
	end: number
	highlight: boolean
	color?: ResourceColor
	fontSize?: IBestStringNumber
}
export type Chunks = Array<Chunk>
export interface IBestHighlightKeywords {
	text: ResourceStr
	color?: ResourceColor
	fontSize?: IBestStringNumber
}