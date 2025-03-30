import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { emitter } from '../../utils/EventEmitter'
import { convertDimensionsWidthUnit, getEventName, getSizeByUnit } from '../../utils/utils'
import { IBestSidebarColor } from './color'
import { COMPONENT_NAME, LeftBarSize, SIDEBAR_EVENT_NAME } from './index.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestSideBar{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 分组id
     */
	@Param @Require groupId: IBestStringNumber
	/**
	 * 当前导航项的索引
	 */
	@Param @Require active: number
	/**
	 * 宽度
     */
	@Param sideWidth: IBestStringNumber = convertDimensionsWidthUnit(80)
	/**
	 * 最大高度
     */
	@Param maxHeight: IBestStringNumber = 0
	/**
	 * 背景色
     */
	@Param bgColor: ResourceColor = IBestSidebarColor.bgColor
	/**
	 * 文字颜色
	 */
	@Param titleColor: ResourceColor = IBestSidebarColor.textColor
	/**
	 * 文字大小
	 */
	@Param titleFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
	 * 激活背景色
     */
	@Param activeBgColor: ResourceColor = IBestSidebarColor.activeBg
	/**
	 * 是否显示左侧颜色条
     */
	@Param showLeftBar: boolean = true
	/**
	 * 左侧颜色条尺寸
     */
	@Param leftBarSize: LeftBarSize = { width: convertDimensionsWidthUnit(4), height: convertDimensionsWidthUnit(16) }
	/**
	 * 左侧颜色条颜色
     */
	@Param leftBarColor: ResourceColor = this.baseStyle.primary
	/**
	 * 激活态文字颜色
     */
	@Param activeFontColor: ResourceColor = IBestSidebarColor.textColor
	/**
	 * 激活态字重
	 */
	@Param activeFontWeight: FontWeight = FontWeight.Medium
	/**
	 * 默认内容
     */
	@BuilderParam defaultBuilder?: CustomBuilder
	/**
	 * 切换事件回调
     */
	@Event onChange: (index: number) => void = () => {}
	@Event $active: (index: number) => void = () => {}

	@Local uniId: number = 0

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		if(this.groupId){
			emitter.on(getEventName(COMPONENT_NAME, SIDEBAR_EVENT_NAME.CHANGE_ACTIVE, this.groupId), this.uniId, (active: number): void => this.changeActive(active))
			setTimeout(() => {
				this.initItems()
			}, 0)
		}
	}
	aboutToDisappear(): void {
		if(this.groupId){
			emitter.off(getEventName(COMPONENT_NAME, SIDEBAR_EVENT_NAME.CHANGE_ACTIVE, this.groupId), this.uniId)
		}
	}
	@Monitor("active")
	initItems(){
		emitter.emit(getEventName(COMPONENT_NAME, SIDEBAR_EVENT_NAME.INIT_ITEM, this.groupId), this.active, {
			titleColor: this.titleColor,
			titleFontSize: this.titleFontSize,
			activeBgColor: this.activeBgColor,
			showLeftBar: this.showLeftBar,
			leftBarSize: this.leftBarSize,
			leftBarColor: this.leftBarColor,
			activeFontColor: this.activeFontColor,
			activeFontWeight: this.activeFontWeight
		})
	}
	changeActive(active: number){
		this.$active(active)
		this.onChange(active)
	}
	build() {
		Scroll(){
			Column(){
				if(this.defaultBuilder){
					this.defaultBuilder()
				}
			}
			.backgroundColor(this.bgColor)
		}
		.width(getSizeByUnit(this.sideWidth))
		.scrollBar(BarState.Off)
		.edgeEffect(EdgeEffect.None)
		.align(Alignment.Start)
	}
}