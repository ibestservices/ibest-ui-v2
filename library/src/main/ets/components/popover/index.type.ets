/**
 * popover 选项类型
 */
export interface IBestPopoverAction{
    /**
     * 选项文字
     */
    text: string
    /**
     * 选项标识
     */
    value?: string
    /**
     * 文字左侧自定义图标
     */
    icon?: ResourceStr
    /**
     * 选项文字颜色
     */
    color?: string
    /**
     * 是否禁用
     */
    disabled?: boolean
}
/**
 * 遮罩颜色
 */
export interface PopoverMask{
    color: ResourceColor
}
/**
 * 分割线尺寸
 */
export type BorderSizeType = 'full' | 'center' | 'right'
/**
 * 气泡框 controller
 */
export class IBestPopoverController{
    /**
     * 打开
     */
    open: () => void = () => {}
    /**
     * 关闭
     */
    close: () => void = () => {}
}