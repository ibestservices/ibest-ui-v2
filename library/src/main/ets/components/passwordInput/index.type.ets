import { generateId } from '../../utils/utils'

/**
 * 高亮类型
 */
export type IBestInputHighlightType = 'border' | 'shadow'
/**
 * 输入框model
 */
export class IBestPasswordInputModel {
	public id: string
	public value: string
	constructor(value: string) {
		this.value = value
		this.id = generateId()
	}
}
/**
 * 自定义键盘配置
 */
export interface NumberKeyboardConfig {
	title?: ResourceStr,
	extraKey?: ResourceStr | ResourceStr[],
	closeBtnText?: ResourceStr,
	deleteButtonText?: ResourceStr,
	styleType?: 'default' | 'custom',
	isRandomKeyOrder?: boolean
}