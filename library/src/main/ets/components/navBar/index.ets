import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle } from '../../theme-chalk/src/index.type'
import { convertDimensionsWidthUnit, getSizeByUnit } from '../../utils/utils'
import { IBestIcon } from '../icon'
import { IBestNavbarColor } from './color'
import { AppStorageV2 } from '@kit.ArkUI'
import GlobalStore from '../../utils/globalStore'
@ComponentV2
export struct IBestNavBar{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyle = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local topAvoidHeight: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.TOP_AVOID_HEIGHT)!
	/**
	 * 导航栏高度
	 */
	@Param navBarHeight: IBestStringNumber = convertDimensionsWidthUnit(GlobalStore.isApp ? 46 : 56)
	/**
	 * 导航栏背景色
     */
	@Param navBarBgColor: ResourceColor = IBestNavbarColor.bgColor
	/**
	 * 导航栏渐变色
     */
	@Param bgLinearGradient: LinearGradient | undefined = undefined
	/**
	 * 导航栏左右内边距
     */
	@Param leftRightPadding: IBestStringNumber = this.baseStyle.spaceMd as string
	/**
	 * 是否显示下边框
     */
	@Param isShowBorder: boolean = true
	/**
	 * 标题内容
	 */
	@Param title: ResourceStr = ''
	/**
	 * 标题文字颜色
     */
	@Param titleColor: ResourceColor = IBestNavbarColor.textColor
	/**
	 * 标题文字大小
     */
	@Param titleFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 标题图标
     */
	@Param titleIcon: ResourceStr = ""
	/**
	 * 标题图标颜色
     */
	@Param titleIconColor: ResourceColor = IBestNavbarColor.textColor
	/**
	 * 标题图标大小
     */
	@Param titleIconSize: IBestStringNumber = this.baseStyle.fontSizeXl as string
	/**
	 * 标题图标圆角
	 */
	@Param titleIconRadius: IBestStringNumber = 0
	/**
	 * 标题是否加粗
	 */
	@Param titleFontWeight: FontWeight = 600
	/**
	 * 二级标题
     */
	@Param subTitle: ResourceStr = ''
	/**
	 * 二级标题颜色
     */
	@Param subTitleColor: ResourceColor = IBestNavbarColor.subTitleColor
	/**
	 * 二级标题字体大小
     */
	@Param subTitleFontSize: IBestStringNumber = this.baseStyle.fontSizeSm as string
	/**
	 * 是否显示左侧
     */
	@Param isShowLeft: boolean = true
	/**
	 * 左侧图标
     */
	@Param leftIcon: ResourceStr = "arrow-left"
	/**
	 * 左侧图标颜色
     */
	@Param leftIconColor: ResourceColor = IBestNavbarColor.textColor
	/**
	 * 左侧图标大小
     */
	@Param leftIconSize: IBestStringNumber = this.baseStyle.fontSizeXl as string
	/**
	 * 左侧图标圆角
	 */
	@Param leftIconRadius: IBestStringNumber = 0
	/**
	 * 左侧文本内容
     */
	@Param leftLabel: ResourceStr = ''
	/**
	 * 左侧文本颜色
     */
	@Param leftLabelColor: ResourceColor = IBestNavbarColor.textColor
	/**
	 * 左侧文本大小
     */
	@Param leftLabelFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 是否显示右侧
     */
	@Param isShowRight: boolean = false
	/**
	 * 右侧图标
     */
	@Param rightIcon: ResourceStr = ""
	/**
	 * 右侧图标颜色
     */
	@Param rightIconColor: ResourceColor = IBestNavbarColor.textColor
	/**
	 * 右侧图标大小
     */
	@Param rightIconSize: IBestStringNumber = this.baseStyle.fontSizeXl as string
	/**
	 * 右侧图标圆角
	 */
	@Param rightIconRadius: IBestStringNumber = 0
	/**
	 * 右侧文本内容
     */
	@Param rightLabel: ResourceStr = ''
	/**
	 * 右侧文本颜色
     */
	@Param rightLabelColor: ResourceColor = IBestNavbarColor.textColor
	/**
	 * 右侧文本大小
     */
	@Param rightLabelFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
	/**
	 * 是否显示状态栏
	 */
	@Param isShowStatusBar: boolean = false
	/**
	 * 状态栏背景色, 仅isKeepBgColorSame为false时生效
	 */
	@Param statusBarBgColor: ResourceColor = ''
	/**
	 * 是否保持状态栏背景色与标题栏背景色一致
	 */
	@Param isKeepBgColorSame: boolean = true
	/**
	 * 标题对齐方式
	 */
	@Param titleTextAlign: "left" | "center" = "center"
	/**
	 * 是否扩展至安全区域
	 * @since 0.0.8
	 */
	@Param expandSafeAreaType: SafeAreaType[] = [SafeAreaType.SYSTEM, SafeAreaType.CUTOUT]
	/**
	 * 自定义左侧内容
     */
	@BuilderParam leftBuilder: CustomBuilder
	/**
	 * 自定义右侧内容
     */
	@BuilderParam rightBuilder: CustomBuilder
	/**
	 * 自定义标题内容
     */
	@BuilderParam titleBuilder: CustomBuilder
	/**
	 * 左侧点击回调
     */
	@Event onLeftClick: () => void = () => {}
	/**
	 * 右侧点击回调
     */
	@Event onRightClick: () => void = () => {}
	/**
	 * 标题点击回调
     */
	@Event onTitleClick: () => void = () => {}

	@Local leftWidth: number = 0
	@Local rightWidth: number = 0

	getWidth(pos: "left" | "right"){
		let maxWidth = Math.max(this.leftWidth, this.rightWidth)
		if(GlobalStore.isApp){
			if(pos == 'left'){
				return this.titleBuilder || this.titleTextAlign == "left" ? this.leftWidth : maxWidth
			}else {
				return this.titleBuilder ? this.rightWidth : maxWidth
			}

		}else{
			let maxPadding = Math.max(maxWidth, 100)
			if(pos == 'left'){
				return this.titleBuilder || this.titleTextAlign == "left" ? this.leftWidth : maxPadding
			}else {
				return maxPadding
			}
		}
	}

	build() {
		Column(){
			if(this.isShowStatusBar){
				Row()
					.width(CONTAINER_SIZE.FULL)
					.height(this.topAvoidHeight.value)
					.backgroundColor(this.isKeepBgColorSame ? this.navBarBgColor : this.statusBarBgColor)
			}
			Row(){
				if(this.isShowLeft){
					Row({space: this.baseStyle.spaceBase}){
						if(this.leftBuilder){
							this.leftBuilder()
						}else {
							if(this.leftIcon){
								IBestIcon({
									name: this.leftIcon,
									color: this.leftIconColor,
									iconSize: this.leftIconSize,
									iconRadius: this.leftIconRadius
								})
							}
							if(this.leftLabel){
								Text(this.leftLabel)
									.fontSize(getSizeByUnit(this.leftLabelFontSize, true))
									.fontColor(this.leftLabelColor)
									.lineHeight(this.baseStyle.lineHeightMd)
							}
						}
					}
					.height(CONTAINER_SIZE.FULL)
					.position({left: 0})
					.zIndex(10)
					.padding({left: getSizeByUnit(this.leftRightPadding), right: this.baseStyle.spaceXs})
					.onAreaChange((_: Area, newVal: Area) => {
						this.leftWidth = newVal.width as number
					})
					.onClick(() => {
						this.onLeftClick()
					})
				}
				Column(){
					if(this.titleBuilder){
						this.titleBuilder()
					}else{
						Column({space: this.baseStyle.spaceMini}){
							Row({space: this.baseStyle.spaceXs}){
								if(this.titleIcon){
									IBestIcon({
										name: this.titleIcon,
										color: this.titleIconColor,
										iconSize: this.titleIconSize,
										iconRadius: this.titleIconRadius
									})
								}
								if(this.title){
									Text(this.title)
										.fontColor(this.titleColor)
										.fontSize(getSizeByUnit(this.titleFontSize, true))
										.textAlign(TextAlign.Center)
										.maxLines(1)
										.textOverflow({overflow: TextOverflow.Ellipsis})
										.fontWeight(this.titleFontWeight)
								}
							}
							.onClick(() => {
								this.onTitleClick()
							})
							if(this.subTitle){
								Text(this.subTitle)
									.fontSize(getSizeByUnit(this.subTitleFontSize, true))
									.fontColor(this.subTitleColor)
									.textAlign(TextAlign.Center)
									.maxLines(1)
									.textOverflow({overflow: TextOverflow.Ellipsis})
							}
						}
						.width(CONTAINER_SIZE.FULL)
						.height(CONTAINER_SIZE.FULL)
						.justifyContent(FlexAlign.Center)
						.alignItems(this.titleTextAlign == "center" ? HorizontalAlign.Center : HorizontalAlign.Start)
					}
				}
				.width(CONTAINER_SIZE.FULL)
				.height(CONTAINER_SIZE.FULL)
				.justifyContent(FlexAlign.Center)
				.alignItems(this.titleBuilder ? HorizontalAlign.Start : HorizontalAlign.Center)
				.padding({left: this.getWidth('left'), right: this.getWidth('right')})
				if(this.isShowRight){
					Row({space: this.baseStyle.spaceBase}){
						if(this.rightBuilder){
							this.rightBuilder()
						}else{
							if(this.rightLabel){
								Text(this.rightLabel)
									.fontSize(getSizeByUnit(this.rightLabelFontSize, true))
									.fontColor(this.rightLabelColor)
									.lineHeight(this.baseStyle.lineHeightMd)
							}
							if(this.rightIcon){
								IBestIcon({
									name: this.rightIcon,
									color: this.rightIconColor,
									iconSize: this.rightIconSize
								})
							}
						}
					}
					.height(CONTAINER_SIZE.FULL)
					.position({right: 0})
					.zIndex(10)
					.padding({left: this.baseStyle.spaceXs, right: getSizeByUnit(this.leftRightPadding)})
					.onAreaChange((_: Area, newVal: Area) => {
						this.rightWidth = newVal.width as number
					})
					.onClick(() => {
						this.onRightClick()
					})
				}
			}
			.width(CONTAINER_SIZE.FULL)
			.height(getSizeByUnit(this.navBarHeight))
			.justifyContent(FlexAlign.Center)
			.linearGradient(this.bgLinearGradient)
			.border({width:{bottom: this.isShowBorder ? 1 : 0}, color: IBestNavbarColor.borderColor})
		}
		.backgroundColor(this.navBarBgColor)
		.expandSafeArea(this.expandSafeAreaType, [SafeAreaEdge.TOP])
	}
}