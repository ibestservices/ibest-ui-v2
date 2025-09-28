import { IBestIconData } from './config';
import { IBestIconDataType } from './index.type';
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils';
import { IBestStringNumber } from '../../model/Global.type';

@ComponentV2
export struct IBestIcon {
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
	@Param iconAnimation: AnimateParam = {}
	/**
	 * 点击回调
	 */
	@Event onIconClick: (event: TouchEvent) => void = () => {}
	isOnlineImage(): boolean {
		return (this.name as string).startsWith("http")
	}
	build() {
		if (typeof this.name == "string" && !this.isOnlineImage()) {
			Text(this.fontName ? this.name : Object(IBestIconData)[this.name as string])
				.fontFamily(this.fontName || "ibestFont")
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