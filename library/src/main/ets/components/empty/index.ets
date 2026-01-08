import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type';
import { CONTAINER_SIZE } from '../../theme-chalk/src/container';
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type';
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils';
import { IBestEmptyColor } from './color';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct IBestEmpty {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 图片下方的描述文字 默认空字符串
	 */
	@Param description: ResourceStr = ''
	/**
	 * 描述文字颜色 默认 "#969799"
	 */
	@Param descriptionColor: ResourceColor = IBestEmptyColor.textColor
	/**
	 * 描述文字大小
	 */
	@Param descriptionFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 空占位图的高度
	 */
	@Param imageSize: IBestStringNumber = convertDimensionsWidthUnit(160)
	/**
	 * 图片类型，可选值为 error network search default 默认default
	 */
	@Param emptyImage: 'error' | 'network' | 'search' | 'default' = 'default'
	/**
	 * 自定义占位图
	 */
	@Param emptyImgUrl: ResourceStr = ''
	/**
	 * 描述文字底部的builder
	 */
	@BuilderParam defaultBuilder: CustomBuilder
	/**
	 * 占位图的builder
	 */
	@BuilderParam emptyImgBuilder: CustomBuilder
	/**
	 * 描述文字的builder
	 */
	@BuilderParam descriptionBuilder: CustomBuilder
	
	@Styles ibestEmptyImageStyle(){
		.height(getSizeByUnit(this.imageSize))
	}
	@Builder EmptyImg() {
		if (this.emptyImgUrl) {
			Image(this.emptyImgUrl).ibestEmptyImageStyle()
		} else if (this.emptyImage === 'default') {
			Image($r("app.media.ibest_empty")).ibestEmptyImageStyle()
		} else if (this.emptyImage === 'network') {
			Image($r("app.media.ibest_empty_network_error")).ibestEmptyImageStyle()
		} else if (this.emptyImage === 'search') {
			Image($r("app.media.ibest_empty_search_error")).ibestEmptyImageStyle()
		} else if (this.emptyImage === 'error') {
			Image($r("app.media.ibest_empty_error")).ibestEmptyImageStyle()
		}
	}
	build() {
		Column() {
			// 空占位图
			if (this.emptyImgBuilder) {
				this.emptyImgBuilder()
			} else {
				this.EmptyImg()
			}
			// 描述
			if (this.descriptionBuilder) {
				this.descriptionBuilder()
			} else if(this.description) {
				Text(this.description)
					.margin({ top: this.baseStyle.spaceMd })
					.padding({
						left: this.baseStyle.spaceXl,
						right: this.baseStyle.spaceXl
					})
					.fontColor(this.descriptionColor)
					.fontSize(getSizeByUnit(this.descriptionFontSize, true))
			}
			// 底部插槽
			if (this.defaultBuilder) {
				this.defaultBuilder()
			}
		}.width(CONTAINER_SIZE.FULL)
	}
}