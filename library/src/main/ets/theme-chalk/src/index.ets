import { IBestUIBaseStyle, IBestUIBaseStyleType } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'
import { IBestStorageKey } from '../../model/Global.type'

/**
 * 设置全局样式
 * @param styleData
 */
export function setIBestUIBaseStyle(styleData?: Partial<IBestUIBaseStyleType>) {
	let style = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE, () => new IBestUIBaseStyle({}))
	if(style){
		AppStorageV2.remove(IBestStorageKey.BASE_STYLE)
	}
	AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE, () => new IBestUIBaseStyle(styleData || {}))
}