import { IBestIconData } from './config';
import { IBestIconDataType } from './index.type';
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils';
import { IBestIconColor } from './color';
import { IBestStringNumber } from '../../model/Global.type';

@ComponentV2
export struct IBestIcon {
	/**
	 * 图标名称或图片链接
	 */
	@Param @Require name: keyof IBestIconDataType | ResourceStr
	/**
	 * 图标颜色
	 */
	@Param color: ResourceColor = IBestIconColor.iconColor
	/**
	 * 图标大小
	 */
	@Param iconSize: IBestStringNumber = convertDimensionsWidthUnit(16)
	/**
	 * 图标圆角
	 */
	@Param iconRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0
	/**
	 * 点击回调
	 */
	@Event onIconClick: (event: TouchEvent) => void = () => {}
	isOnlineImage(): boolean {
		return (this.name as string).startsWith("http")
	}
	build() {
		if (typeof this.name == "string" && !this.isOnlineImage()) {
			Text(Object(IBestIconData)[this.name])
				.fontFamily('ibestFont')
				.fontColor(this.color)
				.fontSize(getSizeByUnit(this.iconSize))
				.borderRadius(getSizeByUnit(this.iconRadius))
				.onTouch(event => {
					event.type == TouchType.Up && this.onIconClick(event)
				})
		} else {
			Image(this.name)
				.width(getSizeByUnit(this.iconSize))
				.aspectRatio(1)
				.fillColor(this.color)
				.borderRadius(getSizeByUnit(this.iconRadius))
				.onTouch(event => {
					event.type == TouchType.Up && this.onIconClick(event)
				})
		}
	}
}