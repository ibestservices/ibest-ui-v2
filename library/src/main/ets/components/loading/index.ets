import { GRAY_COLOR } from '../../theme-chalk/src/color'
import { IBestUIBaseStyle } from '../../theme-chalk/src/index.type'
import { IBestStorageKey, IBestStringNumber, IBestLoadingIconType } from '../../model/Global.type'
import { IBestLoadingCircular } from './circular'
import { IBestLoadingSpinner } from './spinner'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestLoadingColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestLoading {
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyle = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE, () => new IBestUIBaseStyle({})) as IBestUIBaseStyle
	/**
	 * 类型，可选值为 spinner
	 */
	@Param loadingIconType: IBestLoadingIconType = 'circular'
	/**
	 * loading的尺寸
	 */
	@Param loadingSize: IBestStringNumber = convertDimensionsWidthUnit(30)
	/**
	 * loading的颜色
	 */
	@Param loadingColor: ResourceColor = GRAY_COLOR.GRAY_5
	/**
	 * loading的线条宽度
	 */
	@Param loadingStrokeWidth: Length = this.loadingIconType === 'spinner' ? 3 : 2
	/**
	 * loading的遮罩颜色
	 */
	@Param loadingMaskColor: ResourceColor = 'transparent'
	/**
	 * 加载的文案
	 */
	@Param loadingText: ResourceStr = ""
	/**
	 * loading的文字颜色
	 */
	@Param loadingTextColor: ResourceColor = IBestLoadingColor.textColor
	/**
	 * loading的文字大小
	 */
	@Param loadingTextFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 菊花图的每条线的长度
	 */
	@Param spinnerStrokeHeight: IBestStringNumber = convertDimensionsWidthUnit(8)
	/**
	 * 是否垂直排列图标和文字内容
	 */
	@Param vertical: boolean = true
	/**
	 * 图标与文字间距
     */
	@Param space: IBestStringNumber = this.baseStyle.spaceXs as string
	/**
	 * 默认插槽 loading覆盖的插槽
	 */
	@BuilderParam defaultBuilder: CustomBuilder
	/**
	 * loading的图标的插槽
	 */
	@BuilderParam loadingIconBuilder: CustomBuilder
	/**
	 * loading的文案的插槽
	 */
	@BuilderParam loadingTextBuilder: CustomBuilder
	/**
	 * 当前stack容器的尺寸
	 */
	@Local sizeValue: SizeOptions = {}

	@Builder LoadingContent() {
		if (this.loadingIconBuilder) {
			this.loadingIconBuilder()
		} else {
			if (this.loadingIconType === 'spinner') {
				IBestLoadingSpinner({
					spinnerSize: this.loadingSize,
					strokeWidth: this.loadingStrokeWidth,
					strokeHeight: this.spinnerStrokeHeight,
					color: this.loadingColor,
				})
			} else {
				IBestLoadingCircular({
					circularSize: this.loadingSize,
					color: this.loadingColor,
					strokeWidth: this.loadingStrokeWidth
				})
			}
		}
		if (this.loadingTextBuilder) {
			this.loadingTextBuilder()
		} else {
			if (this.loadingText) {
				Text(this.loadingText)
					.fontSize(getSizeByUnit(this.loadingTextFontSize, true))
					.fontColor(this.loadingTextColor)
			}
		}
	}
	build() {
		Stack() {
			if (this.defaultBuilder) {
				this.defaultBuilder()
			}
			if (this.vertical) {
				Column({space: getSizeByUnit(this.space)}) {
					this.LoadingContent()
				}
				.justifyContent(FlexAlign.Center)
				.width(this.sizeValue.width || 'auto')
				.height(this.sizeValue.height || 'auto')
				.backgroundColor(this.loadingMaskColor)
			} else {
				Row({space: getSizeByUnit(this.space)}) {
					this.LoadingContent()
				}
				.justifyContent(FlexAlign.Center)
				.width(this.sizeValue.width || 'auto')
				.height(this.sizeValue.height || 'auto')
				.backgroundColor(this.loadingMaskColor)
			}
		}.onSizeChange((_: SizeOptions, newValue: SizeOptions) => {
			this.sizeValue = newValue
		})
	}
}