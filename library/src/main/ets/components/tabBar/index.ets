import { IBestAwaitable, IBestBaseDataType, IBestStorageKey, IBestStringNumber } from "../../model/Global.type"
import { CONTAINER_SIZE } from "../../theme-chalk/src/container"
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from "../../theme-chalk/src/index.type"
import ibestEmitter from "../../utils/eventEmitter"
import { convertDimensionsWidthUnit, getEventName, getSizeByUnit, handleBeforeFunction, mergeObject } from "../../utils/utils"
import { IBestBadge } from "../badge"
import { IBestIcon } from "../icon"
import { IBestTabBarColor } from "./color"
import { COMPONENT_NAME, IBestTabBarItemInfo, TABBAR_EVENT_NAME } from "./index.type"
import { AppStorageV2, PathShape } from "@kit.ArkUI"
import { IBestDivider } from "../divider"

@ComponentV2
export struct IBestTabBar{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Local bottomBarHeight: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.BOTTOM_BAR_HEIGHT)!
    /**
     * 分组id
     */
    @Param @Require groupId: IBestStringNumber
    /**
     * 当前选中标签的名称或索引值
     */
    @Param @Require active: IBestStringNumber
    /**
     * 宽度
     */
    @Param tabBarWidth: IBestStringNumber = CONTAINER_SIZE.FULL
    /**
     * 高度
     */
    @Param tabBarHeight: IBestStringNumber = convertDimensionsWidthUnit(50)
    /**
     * 定位
     */
    @Param tabBarPosition?: Position | Edges | LocalizedEdges = undefined
    /**
     * 圆角
     */
    @Param radius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0
    /**
     * 背景色, 与背景材质模糊相斥
     */
    @Param bgColor: ResourceColor = IBestTabBarColor.bgColor
    /**
     * 背景材质模糊, 与背景色相斥, isConvex为true时无效
     */
    @Param bgBlurStyle?: BlurStyle = undefined
    /**
     * 阴影
     */
    @Param tabBarShadow?: ShadowOptions | ShadowStyle = undefined
    /**
     * 是否显示边框线
     */
    @Param showBorder: boolean = false
    /**
     * 上边框线颜色
     */
    @Param bdColor: ResourceColor = IBestTabBarColor.bdColor
    /**
     * 高亮类型
     */
    @Param highlightType: 'color' | 'bgColor' = 'color'
    /**
     * 高亮背景时是否凸起，仅highlightType为bgColor时有效
     */
    @Param isConvex: boolean = false
    /**
     * 选中的颜色
     */
    @Param activeColor: ResourceColor = ''
    /**
     * 未选中的颜色
     */
    @Param inactiveColor: ResourceColor = IBestTabBarColor.textColor
    /**
     * 图标大小
     */
    @Param iconSize: IBestStringNumber = 22
    /**
     * 文字大小
     */
    @Param fontSize: IBestStringNumber = this.baseStyle.fontSizeSm as string
    /**
     * 图标文字间距
     */
    @Param space: IBestStringNumber = this.baseStyle.spaceBase as string
    /**
     * 切换动画时长，单位ms
     */
    @Param duration: number = this.baseStyle.animationDuration as number
    /**
     * 是否开启底部安全区适配
     */
    @Param safeAreaInsetBottom: boolean = false
    /**
     * 默认插槽
     */
    @BuilderParam defaultBuilder: CustomBuilder
    /**
     * 切换标签前的回调函数
     */
    @Event beforeChange?: (name: IBestStringNumber) => IBestAwaitable = undefined
    /**
     * 切换事件
     */
    @Event onChange: (active: IBestStringNumber) => void = () => {}
    @Event $active: (active: IBestStringNumber) => void = () => {}

    @Local uniId: number = 0
    @Local tabBarList: IBestTabBarItemInfo[] = []
    @Local contentWidth: number = 0
    @Local contentHeight: number = 0
    @Provider() highlightDiameter: number = 0
    @Local chamferXY: number[] = [0, 0]
    @Local chamferR: number = 30
    private uiContext = this.getUIContext()

    aboutToAppear() {
        this.uniId = this.getUniqueId()
        ibestEmitter.on(getEventName(COMPONENT_NAME, TABBAR_EVENT_NAME.SEND_TABBAR_ITEM, this.groupId), this.uniId, (info: IBestTabBarItemInfo): void => this.getTabBarItem(info))
        ibestEmitter.on(getEventName(COMPONENT_NAME, TABBAR_EVENT_NAME.TABBAR_ITEM_CHANGE, this.groupId), this.uniId, (info: IBestTabBarItemInfo): void => this.updateTabBarItem(info))
    }
    aboutToDisappear() {
        ibestEmitter.off(getEventName(COMPONENT_NAME, TABBAR_EVENT_NAME.SEND_TABBAR_ITEM, this.groupId), this.uniId)
        ibestEmitter.off(getEventName(COMPONENT_NAME, TABBAR_EVENT_NAME.TABBAR_ITEM_CHANGE, this.groupId), this.uniId)
    }
    init(val: Area){
        this.contentWidth = val.width as number
        this.contentHeight = val.height as number
        this.highlightDiameter = Math.min(this.contentWidth / this.tabBarList.length, val.height as number)
        this.chamferXY = this.getChamferXY(this.highlightDiameter, this.chamferR)
    }
    getChamferXY(diameter: number, r: number = 30): [number, number] {
        let radius = diameter / 2
        let topH = radius - diameter/3
        let chamferX = Math.sqrt(Math.pow(r + radius, 2) - Math.pow(r + topH, 2))
        return [chamferX, r + topH]
    }
    getTabBarItem(info: IBestTabBarItemInfo){
        this.tabBarList.push(new IBestTabBarItemInfo(info))
    }
    @Computed
    get activeIndex(){
        return typeof this.active === 'number' ? this.active : this.tabBarList.findIndex(item => item.name === this.active)
    }
    updateTabBarItem(info: Partial<IBestTabBarItemInfo>){
        const item = this.tabBarList.find(item => item.uniId === info.uniId)
        if(item){
            mergeObject(item, info)
        }
    }
    async onItemClick(item: IBestTabBarItemInfo, index: number){
        const status = await handleBeforeFunction(this.beforeChange, item.name || index)
        if(status){
            const active = item.name || index
            this.$active(active)
            this.onChange(active)
        }
    }
    build() {
        Column(){
            if(this.showBorder){
                IBestDivider({ color: this.bdColor })
            }
            Stack(){
                if(this.highlightDiameter && this.highlightType == 'bgColor'){
                    Stack(){
                        if(this.isConvex){
                            RelativeContainer() {
                                Column()
                                    .width(this.highlightDiameter)
                                    .aspectRatio(1)
                                    .borderRadius(this.highlightDiameter)
                                    .backgroundColor(this.bgColor)
                                    .alignRules({
                                        'middle': { 'anchor': "__container__", 'align': HorizontalAlign.Center }
                                    })
                                Column()
                                    .width(this.chamferXY[0])
                                    .height(this.chamferXY[1])
                                    .radialGradient({
                                        center: [0, 0],
                                        radius: this.chamferR,
                                        colors: [[Color.Transparent, 0.0], [Color.Transparent, 1], [this.bgColor, 1]]
                                    })
                                    .clipShape(new PathShape({
                                        commands: `M0 0 L0 ${this.uiContext.vp2px(this.chamferXY[1])}   L${this.uiContext.vp2px(this.chamferXY[0])} ${this.uiContext.vp2px(this.chamferXY[1])} Z`
                                    }))
                                    .zIndex(-1)
                                    .alignRules({
                                        'right': { 'anchor': "__container__", 'align': HorizontalAlign.Center },
                                        "bottom": { 'anchor': "__container__", 'align': VerticalAlign.Center }
                                    })
                                    .visibility(this.radius && this.active == 0 ? Visibility.None : Visibility.Visible)
                                Column()
                                    .width(this.chamferXY[0])
                                    .height(this.chamferXY[1])
                                    .radialGradient({
                                        center: [this.chamferXY[0], 0],
                                        radius: this.chamferR,
                                        colors: [[Color.Transparent, 0.0], [Color.Transparent, 1], [this.bgColor, 1]]
                                    })
                                    .clipShape(new PathShape({
                                        commands: `M0 ${this.uiContext.vp2px(this.chamferXY[1])}  L${this.uiContext.vp2px(this.chamferXY[0])} 0 L${this.uiContext.vp2px(this.chamferXY[0])} ${this.uiContext.vp2px(this.chamferXY[1])} Z`
                                    }))
                                    .zIndex(-1)
                                    .alignRules({
                                        'left': { 'anchor': "__container__", 'align': HorizontalAlign.Center },
                                        "bottom": { 'anchor': "__container__", 'align': VerticalAlign.Center }
                                    })
                                    .visibility(this.radius && this.active == this.tabBarList.length - 1 ? Visibility.None : Visibility.Visible)
                            }
                            .width(CONTAINER_SIZE.FULL)
                            .height("auto")
                        }
                        if(this.highlightType == 'bgColor'){
                            Row()
                                .width(this.highlightDiameter - 10)
                                .aspectRatio(1)
                                .backgroundColor(this.baseStyle.primary)
                                .borderRadius(this.baseStyle.borderRadiusMax)
                        }
                    }
                    .clip(false)
                    .width(this.contentWidth / this.tabBarList.length)
                    .position({
                        x: this.activeIndex * this.contentWidth / this.tabBarList.length,
                        y: this.highlightType == 'bgColor' && this.isConvex ? -this.highlightDiameter / 3 : -(this.contentHeight - this.highlightDiameter - 10) / 2
                    })
                    .animation({ duration: this.duration })
                }
                Row(){
                    ForEach(this.tabBarList, (item: IBestTabBarItemInfo, index: number) => {
                        IBestTabBarBox({
                            item: item,
                            index,
                            active: this.active,
                            highlightType: this.highlightType,
                            isConvex: this.isConvex,
                            activeColor: this.activeColor,
                            inactiveColor: this.inactiveColor,
                            iconSize: this.iconSize,
                            fontSize: this.fontSize,
                            space: this.space,
                            duration: this.duration,
                            defaultBuilder: item.defaultBuilder,
                            activeBuilder: item.activeBuilder,
                            onItemClick: () => {
                                this.onItemClick(item, index)
                            }
                        })
                    })
                }
                .width(CONTAINER_SIZE.FULL)
                .height(CONTAINER_SIZE.FULL)
            }
            .height(getSizeByUnit(this.tabBarHeight))
            .onAreaChange((_: Area, newVal: Area) => {
                this.init(newVal)
            })
            if(this.defaultBuilder){
                this.defaultBuilder()
            }
        }
        .width(getSizeByUnit(this.tabBarWidth))
        .padding({ bottom: this.safeAreaInsetBottom ? this.bottomBarHeight.value as number : 0 })
        .position(this.tabBarPosition)
        .backgroundColor(this.bgBlurStyle !== undefined && !this.isConvex ? Color.Transparent : this.bgColor)
        .backgroundBlurStyle(this.isConvex ? undefined : this.bgBlurStyle)
        .borderRadius(getSizeByUnit(this.radius))
        .shadow(this.tabBarShadow)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
}
@ComponentV2
struct IBestTabBarBox{
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Param @Require item: IBestTabBarItemInfo
    @Param @Require index: number
    @Param @Require active: IBestStringNumber
    @Param @Require highlightType: 'color' | 'bgColor'
    @Param @Require isConvex: boolean
    @Param @Require activeColor: ResourceColor
    @Param @Require inactiveColor: ResourceColor
    @Param @Require iconSize: IBestStringNumber
    @Param @Require fontSize: IBestStringNumber
    @Param @Require space: IBestStringNumber
    @Param @Require duration: number
    @Consumer() highlightDiameter: number = 0
    @BuilderParam defaultBuilder: CustomBuilder
    @BuilderParam activeBuilder: CustomBuilder
    @Event onItemClick: () => void = () => {}

    @Local realIconSize: number = 0

    @Computed
    get isActive(){
        return this.item.name ? this.item.name === this.active : this.index === this.active
    }
    @Computed
    get iconColor(){
        return this.isActive ? this.highlightType == 'bgColor' ? this.baseStyle.default : this.activeColor || this.baseStyle.primary : this.inactiveColor
    }
    @Computed
    get textColor(){
        return this.isActive ? this.highlightType == 'bgColor' && !this.isConvex ? this.baseStyle.default : this.activeColor || this.baseStyle.primary : this.inactiveColor
    }
    @Computed
    get offsetY(){
        return -((this.highlightDiameter - 10 - this.realIconSize) / 2 - 2)
    }
    build() {
        Column({space: getSizeByUnit(this.space)}){
            if(this.isActive && this.activeBuilder){
                this.activeBuilder()
            }else {
                if(this.defaultBuilder){
                    this.defaultBuilder()
                }
                if(this.item.icon){
                    Row(){
                        IBestBadge({
                            content: this.item.badgeContent,
                            color: this.item.badgeColor,
                            dot: this.item.dot,
                            max: this.item.max,
                            showZero: this.item.showZero,
                            yOffset: 5
                        }){
                            IBestIcon({
                                name: this.isActive && this.item.activeIcon ? this.item.activeIcon : this.item.icon,
                                iconSize: this.iconSize,
                                color: this.iconColor
                            })
                                .onAreaChange((_: Area, newVal: Area) => {
                                    this.realIconSize = newVal.width as number
                                })
                        }
                    }
                    .offset({y: this.isConvex && this.isActive ? this.offsetY : 0})
                    .animation({ duration: this.duration })
                }
                if(this.item.text){
                    Text(this.item.text)
                        .width(CONTAINER_SIZE.FULL)
                        .fontSize(getSizeByUnit(this.fontSize, true))
                        .fontColor(this.textColor)
                        .textAlign(TextAlign.Center)
                        .maxLines(1)
                        .textOverflow({overflow: TextOverflow.Ellipsis})
                }
            }
        }
        .height(CONTAINER_SIZE.FULL)
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .enabled(!this.item.disabled)
        .opacity(this.item.disabled ? 0.6 : 1)
        .visibility(this.item.show ? Visibility.Visible : Visibility.None)
        .onClick(() => {
            !this.defaultBuilder && this.onItemClick()
        })
    }
}

@ComponentV2
export struct IBestTabBarItem{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 分组id
     */
    @Param @Require groupId: IBestStringNumber
    /**
     * 图标
     */
    @Param icon: ResourceStr = ''
    /**
     * 激活图标
     */
    @Param activeIcon: ResourceStr = ''
    /**
     * 标签文字
     */
    @Param text: ResourceStr = ''
    /**
     * 标签标识
     */
    @Param name: IBestStringNumber = ''
    /**
     * 是否显示
     */
    @Param show: boolean = true
    /**
     * 徽标内容
     */
    @Param badgeContent: IBestStringNumber = ''
    /**
     * 徽标背景色
     */
    @Param badgeColor: ResourceColor = ''
    /**
     * 是否展示为小红点
     */
    @Param dot: boolean = false
    /**
     * 最大值,超过最大值会显示 {max}+,仅当 content 为数字时有效
     */
    @Param max: number = -1
    /**
     * 值为0时是否显示徽标
     */
    @Param showZero: boolean = true
    /**
     * 是否禁用
     */
    @Param disabled: boolean = false
    /**
     * 自定义内容
     */
    @BuilderParam defaultBuilder: CustomBuilder
    /**
     * 自定义激活内容
     */
    @BuilderParam activeBuilder: CustomBuilder

    @Local uniId: number = 0

    aboutToAppear() {
        this.uniId = this.getUniqueId()
        ibestEmitter.emit(getEventName(COMPONENT_NAME, TABBAR_EVENT_NAME.SEND_TABBAR_ITEM, this.groupId), {
            uniId: this.uniId,
            icon: this.icon,
            activeIcon: this.activeIcon,
            text: this.text,
            name: this.name,
            show: this.show,
            badgeContent: this.badgeContent,
            badgeColor: this.badgeColor,
            dot: this.dot,
            max: this.max,
            showZero: this.showZero,
            disabled: this.disabled,
            defaultBuilder: this.defaultBuilder,
            activeBuilder: this.activeBuilder
        })
    }
    @Monitor("show")
    showChange(){
        ibestEmitter.emit(getEventName(COMPONENT_NAME, TABBAR_EVENT_NAME.TABBAR_ITEM_CHANGE, this.groupId), {
            uniId: this.uniId,
            show: this.show
        })
    }
    @Monitor("disabled")
    disabledChange(){
        ibestEmitter.emit(getEventName(COMPONENT_NAME, TABBAR_EVENT_NAME.TABBAR_ITEM_CHANGE, this.groupId), {
            uniId: this.uniId,
            disabled: this.disabled
        })
    }
    build() {}
}