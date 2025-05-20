/**
 * 扩展键类型
 */
export type IBestCarKeyboardKeyType = 'text' | 'delete'
/**
 * 基础键数据类型
 */
@ObservedV2
export class IBestCarKeyboardKey {
	type: IBestCarKeyboardKeyType = 'text'
	text: string = ''
	@Trace disabled?: boolean = false
	constructor(type: IBestCarKeyboardKeyType, text: string = '') {
		this.type = type
		this.text = text
	}
}