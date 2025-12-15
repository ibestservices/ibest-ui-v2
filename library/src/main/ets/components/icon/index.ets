import { IBestIconData } from './config';
import { IBestIconDataType } from './index.type';
import { convertDimensionsWidthUnit, getResourceStr, getSizeByUnit } from '../../utils/utils';
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type';
import { IBestGlobalConfig } from '../../model/GlobalConfig';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct IBestIcon {
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
	@Param iconSize: IBestStringNumber = convertDimensionsWidthUnit(16)
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
	getFontFamily(){
		let arr = ["ibestFont", getResourceStr(this.fontName)].concat(this.config.fontNames.map(e => getResourceStr(e)))
		return Array.from<string>(new Set(arr.filter(e => e))).join(",")
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