import { IBestStringNumber } from "../../model/Global.type"

/**
 * 组件名称
 */
export const COMPONENT_NAME = "TABBAR"
/**
 * Table事件名称
 */

export enum TABBAR_EVENT_NAME {
    /**
     * 获取所有列信息
     */
    SEND_TABBAR_ITEM = "SEND_TABBAR_ITEM",
    /**
     * 列属性变化
     */
    TABBAR_ITEM_CHANGE = "TABBAR_ITEM_CHANGE"
}
@ObservedV2
export class IBestTabBarItemType {
    uniId: IBestStringNumber = 0
    icon: ResourceStr = ''
    activeIcon: ResourceStr = ''
    @Trace text: ResourceStr = ''
    name: string = ''
    @Trace show: boolean = true
    @Trace badgeContent: IBestStringNumber = ''
    badgeColor: ResourceColor = ''
    @Trace dot: boolean = false
    max: number = -1
    showZero: boolean = true
    @Trace disabled: boolean = false
    defaultBuilder?: CustomBuilder
    activeBuilder?: CustomBuilder
}
export class IBestTabBarItemInfo extends IBestTabBarItemType{
    constructor(value: IBestTabBarItemType) {
        super()
        this.uniId = value.uniId
        this.icon = value.icon
        this.activeIcon = value.activeIcon
        this.text = value.text
        this.name = value.name
        this.show = value.show
        this.badgeContent = value.badgeContent
        this.badgeColor = value.badgeColor
        this.dot = value.dot
        this.max = value.max
        this.showZero = value.showZero
        this.disabled = value.disabled
        this.defaultBuilder = value.defaultBuilder
        this.activeBuilder = value.activeBuilder
    }
}