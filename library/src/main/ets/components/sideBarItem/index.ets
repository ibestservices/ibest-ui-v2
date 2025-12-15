import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { emitter } from '../../utils/eventEmitter'
import { convertDimensionsWidthUnit, getEventName, getSizeByUnit } from '../../utils/utils'
import { COMPONENT_NAME, SIDEBAR_EVENT_NAME, SideBarConfig } from '../sideBar/index.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestSideBarItem{
	/**
	 * 全局公共样式
	 */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	/**
	 * 分组id
	 */
	@Param @Require groupId: IBestStringNumber
	/**
	 * 索引
     */
	@Param @Require index: number
	/**
	 * 选项文字
     */
	@Param title: ResourceStr = ""
	/**
	 * 是否禁用该项
     */
	@Param disabled: boolean = false
	/**
	 * 内边距
	 * @since 1.0.5
	 */
	@Param contentPadding: Length | Padding | LocalizedPadding = {
		top: convertDimensionsWidthUnit(20),
		bottom: convertDimensionsWidthUnit(20),
		right: this.baseStyle.spaceSm
	}
	/**
	 * 自定义内容
     */
	@BuilderParam defaultBuilder: CustomBuilder
	/**
	 * 点击事件
     */
	@Event onItemClick: (index: number) => void = () => {}

	@Local uniId: number = 0
	@Local config: SideBarConfig = {} as SideBarConfig
	@Local isActive: boolean = false

	aboutToAppear(): void {
		this.uniId = this.getUniqueId()
		if(this.groupId){
			emitter.on(getEventName(COMPONENT_NAME, SIDEBAR_EVENT_NAME.INIT_ITEM, this.groupId), this.uniId, (active: number, config?: SideBarConfig): void => this.init(active, config))
		}
	}

	aboutToDisappear(): void {
		if(this.groupId) {
			emitter.off(getEventName(COMPONENT_NAME, SIDEBAR_EVENT_NAME.INIT_ITEM, this.groupId), this.uniId)
		}
	}

	init(active: number, config?: SideBarConfig){
		this.isActive = active == this.index
		if(config){
			this.config = config
		}
	}
	changeActive(){
		emitter.emit(getEventName(COMPONENT_NAME, SIDEBAR_EVENT_NAME.CHANGE_ACTIVE, this.groupId), this.index)
		this.onItemClick(this.index)
	}
	build() {
		Row(){
			if(this.defaultBuilder){
				this.defaultBuilder()
			}else{
				if(this.config.showLeftBar){
					Divider()
						.vertical(true)
						.width(getSizeByUnit(this.config.leftBarSize.width))
						.height(getSizeByUnit(this.config.leftBarSize.height))
						.backgroundColor(this.config.leftBarColor || this.baseStyle.primary)
						.margin({right: this.baseStyle.spaceSm})
						.visibility(this.isActive ? Visibility.Visible : Visibility.Hidden)
				}
				Text(this.title)
					.fontColor(this.isActive ? this.config.activeFontColor : this.config.titleColor)
					.fontSize(getSizeByUnit(this.config.titleFontSize))
					.wordBreak(WordBreak.BREAK_ALL)
					.fontWeight(this.isActive ? this.config.activeFontWeight : FontWeight.Normal)
					.lineHeight(convertDimensionsWidthUnit(20))
			}
		}
		.width(CONTAINER_SIZE.FULL)
		.padding(getSizeByUnit(this.contentPadding))
		.justifyContent(FlexAlign.Start)
		.alignItems(VerticalAlign.Center)
		.backgroundColor(this.isActive ? this.config.activeBgColor : "")
		.enabled(!this.disabled)
		.opacity(this.disabled ? 0.6 : 1)
		.onClick(() => {
			this.changeActive()
		})
	}
}