import { IBestStringNumber } from '../../model/Global.type'

/**
 * tab宽度类型
 */
export interface TabWidthType{
    boxWidth: number
    boxLocalLeft: number
    textWidth: number
}

/**
 * tabItem类型
 */
@ObservedV2
export class IBestTabItemType{
    /**
     * 选项文字
     */
    @Trace label: ResourceStr = ""
    /**
     * 选项标识
     */
    name: IBestStringNumber = ""
    /**
     * 选项数量
     */
    @Trace number?: number
    /**
     * 选项图标
     */
    icon?: ResourceStr = ""
    /**
     * 是否禁用
     */
    @Trace isDisable?: boolean = false
}
export class IBestTabItem extends IBestTabItemType{
    constructor(value: IBestTabItemType) {
        super()
        this.label = value.label
        this.name = value.name
        this.number = value.number ?? undefined
        this.icon = value.icon ?? undefined
        this.isDisable = value.isDisable ?? false
    }
}