import { IBestUIBaseStyle, IBestUIBaseStyleType } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'

/**
 * AppStorage命名空间
 */
export const IBEST_UI_NAMESPACE = '__IBEST-UI_BASE_STYLE'
/**
 * 设置全局样式
 * @param styleData
 */
export function setIBestUIBaseStyle(styleData?: Partial<IBestUIBaseStyleType>) {
	if(styleData){
		AppStorageV2.connect(IBestUIBaseStyle, () => new IBestUIBaseStyle(styleData))
	}
}