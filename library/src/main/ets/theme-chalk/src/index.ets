import { IBestUIBaseStyle, IBestUIBaseStyleObjType, IBestUIBaseStyleType } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'
import { IBestStorageKey } from '../../model/Global.type'
import { mergeObject } from '../../utils/utils'

/**
 * 设置全局样式
 * @param styleData
 */
export function setIBestUIBaseStyle(styleData?: Partial<IBestUIBaseStyleType>) {
	let baseStyle = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE, () => new IBestUIBaseStyle({})) as IBestUIBaseStyleObjType
	if(baseStyle && styleData){
		mergeObject(baseStyle, styleData)
	}else{
		AppStorageV2.remove(IBestStorageKey.BASE_STYLE)
		AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE, () => new IBestUIBaseStyle({}))
	}
}
/**
 * 获取全局样式
 */
export function getDefaultBaseStyle(): IBestUIBaseStyleObjType {
	return AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
}