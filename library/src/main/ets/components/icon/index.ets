import { IBestIconData } from './config';
import { IBestIconDataType } from './index.type';
import { getResourceStr, getSizeByUnit } from '../../utils/utils';
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type';
import { IBestGlobalConfig } from '../../model/GlobalConfig';
import { AppStorageV2 } from '@kit.ArkUI';
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type';

@ComponentV2
export struct IBestIcon {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local config: IBestGlobalConfig = AppStorageV2.connect(IBestGlobalConfig, IBestStorageKey.GLOBAL_CONFIG)!
	/**
	 * 图标名称、unicode 编码、图片链接
	 */
	@Param @Require name: keyof IBestIconDataType | ResourceStr
	/**
	 * 图标颜色
	 */
	@Param color?: ResourceColor = undefined
	/**
	 * 图标大小
	 */
	@Param iconSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 图标圆角
	 */
	@Param iconRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0
	/**
	 * 字体名称
	 * @since 1.0.3
	 */
	@Param fontName: ResourceStr = ""
	/**
	 * 动画
	 * @since 1.0.4
	 */
	@Param iconAnimation?: AnimateParam = undefined
	/**
	 * 点击回调
	 */
	@Event onIconClick: (event: TouchEvent) => void = () => {}
	isOnlineImage(): boolean {
		return (this.name as string).startsWith("http")
	}
	isSingleUnicodeEscape(str: string) {
		return str.length == 1 && /^[\u0000-\uFFFF]$/.test(str)
	}
	getFontFamily(){
		let name = this.name as string
		if(this.isSingleUnicodeEscape(name)){
			let arr = this.config.fontNames.map(e => getResourceStr(e)).concat([getResourceStr(this.fontName)])
			return Array.from<string>(new Set(arr.filter(e => e))).join(",")
		}else {
			return "ibestFont"
		}
	}
	build() {
		if (typeof this.name == "string" && !this.isOnlineImage()) {
			Text(Object(IBestIconData)[this.name as string] || this.name)
				.fontFamily(this.getFontFamily())
				.fontColor(this.color)
				.fontSize(getSizeByUnit(this.iconSize, true))
				.borderRadius(getSizeByUnit(this.iconRadius))
				.animation(this.iconAnimation)
				.onTouch(event => {
					event.type == TouchType.Up && this.onIconClick(event)
				})
		} else {
			Image(this.name)
				.width(getSizeByUnit(this.iconSize))
				.fillColor(this.color)
				.borderRadius(getSizeByUnit(this.iconRadius))
				.draggable(false)
				.animation(this.iconAnimation)
				.onTouch(event => {
					event.type == TouchType.Up && this.onIconClick(event)
				})
		}
	}
}