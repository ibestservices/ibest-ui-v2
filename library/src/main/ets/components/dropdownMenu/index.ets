import { CONTAINER_SIZE } from "../../theme-chalk/src/container"
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from "../../theme-chalk/src/index.type"
import ibestEmitter from "../../utils/eventEmitter"
import { convertDimensionsWidthUnit, getComponentsInfo, getEventName, getSizeByUnit, handleBeforeFunction } from "../../utils/utils"
import { IBestDropdownMenuColor } from "./color"
import { COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME, IBestDropdownMenuContentParams,
    IBestDropdownMenuContentType,
    IBestDropdownMenuOption,
    MenuContentController,
    IBestDropdownMenuController
} from "./index.type"
import { AppStorageV2 } from "@kit.ArkUI"
import { IBestAwaitable, IBestBaseDataType, IBestStorageKey, IBestStringNumber } from "../../model/Global.type"
import GlobalStore from "../../utils/globalStore"
import { IBestIcon } from "../icon"
import { IBestCell } from "../cell"

const popupDuration = 150
const hideDuration = 180

@ComponentV2
export struct IBestDropdownMenu{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Local topAvoidHeight: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.TOP_AVOID_HEIGHT)!
    /**
     * 分组id
     */
    @Param @Require groupId: IBestStringNumber
    /**
     * 菜单高度
     */
    @Param menuHeight: IBestStringNumber = convertDimensionsWidthUnit(48)
    /**
     * 背景色
     */
    @Param bgColor: ResourceColor = IBestDropdownMenuColor.bgColor
    /**
     * 菜单阴影
     */
    @Param menuShadow: ShadowOptions | ShadowStyle = {radius: 0}
    /**
     * 是否在点击遮罩层后关闭下拉菜单
     */
    @Param closeOnClickOverlay: boolean = true
    /**
     * 菜单项宽度类型
     */
    @Param menuWidthType: 'auto' | 'flex' = 'flex'
    /**
     * 菜单项图标
     */
    @Param menuIcon: ResourceStr = 'arrow-down'
    /**
     * 菜单项图标大小
     */
    @Param menuIconSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 菜单项字体大小
     */
    @Param menuFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
	 * 菜单项字体色
     */
	@Param menuFontColor: ResourceColor = IBestDropdownMenuColor.textColor
	/**
	 * 菜单标题和下拉选项的选中态颜色
	 */
	@Param activeColor: ResourceColor = this.baseStyle.primary
    /**
     * 下拉选项文字大小
     */
    @Param dropDownFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 下拉选项图标大小
     * @since 1.0.3
     */
    @Param dropDownIconSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
	/**
     * 下拉选项选中图标
     */
    @Param selectedIcon: ResourceStr = 'success'
    /**
     * 下拉菜单圆角
     */
    @Param radius: IBestStringNumber = 0
    /**
     * 默认内容
     */
    @BuilderParam defaultBuilder: CustomBuilder
    /**
     * 菜单控制器
     */
    @Param controller: IBestDropdownMenuController = new IBestDropdownMenuController()

    @Local uniId: number = 0
    @Local menuList: IBestDropdownMenuContentParams[] = []
    @Provider() activeIndex: IBestStringNumber = ''
    private uiContext = this.getUIContext()
    private promptAction = this.uiContext.getPromptAction()
    private baseController: MenuContentController = new MenuContentController()
    private isOpening: boolean = false

    @Builder optionListBuilder(){
        ForEach(this.menuList, (option: IBestDropdownMenuContentParams, index: number) => {
            IBestDropdownMenuOptionItem({
                option: option,
                index: index,
                menuFontColor: this.menuFontColor,
                activeColor: this.activeColor,
                menuWidthType: this.menuWidthType,
                menuIcon: this.menuIcon,
                menuIconSize: this.menuIconSize,
                menuFontSize: this.menuFontSize
            })
                .layoutWeight(this.menuWidthType == 'flex' ? 1 : 0)
                .enabled(!option.disabled)
                .onClick(() => {
                    this.openMenu(index)
                })
        }, (_: IBestDropdownMenuContentParams, index: number) => index.toString())
        if (this.defaultBuilder) {
            this.defaultBuilder()
        }
    }
    @Styles optionListStyle(){
        .width(CONTAINER_SIZE.FULL)
        .height(getSizeByUnit(this.menuHeight))
        .backgroundColor(this.bgColor)
        .shadow(this.menuShadow)
        .id(`ibest_dropdown_menu_${this.uniId}`)
    }
    @Builder menuContentBuilder(maxHeight: number) {
        IBestDropdownMenuContent({
            groupId: this.groupId,
            maxHeight,
            option: this.getOption(),
            bgColor: this.bgColor,
            activeColor: this.activeColor,
            dropDownFontSize: this.dropDownFontSize,
            dropDownIconSize: this.dropDownIconSize,
            selectedIcon: this.selectedIcon,
            controller: this.baseController
        })
    }
    aboutToAppear() {
        this.uniId = this.getUniqueId()
        this.controller.close = (): void => this.manualClose()
        ibestEmitter.on(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), this.uniId, (type: string, option: IBestDropdownMenuContentType, callBack?: (index: number) => void): void => this.updateOption(type, option, callBack))
    }
    aboutToDisappear() {
        ibestEmitter.off(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), this.uniId)
        this.manualClose()
    }
    updateOption(type: string, option: IBestDropdownMenuContentType, callBack?: (index: number) => void) {
        switch (type) {
            case 'init':
                this.menuList.push(new IBestDropdownMenuContentParams(option))
                if(callBack){
                    callBack(this.menuList.length-1)
                }
                break
            case 'value':
                this.menuList[option.index!].value = option.value
                let dialogId = this.menuList[option.index!].dialogId
                if(dialogId !== ''){
                    this.close(option.index!)
                }
                break
            case 'options':
                this.menuList[option.index!].options = option.options
                break
            case 'disabled':
                this.menuList[option.index!].disabled = option.disabled
                break
        }
    }
    getMaskTop() {
        let info = getComponentsInfo(this.uiContext, `ibest_dropdown_menu_${this.uniId}`)
        return info.screenTop + info.height
    }
    getOpenIndex() {
        return this.menuList.findIndex(item => item.dialogId !== '')
    }
    getOption(): IBestDropdownMenuContentParams{
        return this.activeIndex !=='' ? this.menuList[this.activeIndex] : new IBestDropdownMenuContentParams()
    }
    async openMenu(index: number) {
        if(this.isOpening){
            return
        }
        let i = this.getOpenIndex()
        if (i > -1) {
            await this.close(i)
            if (i == index) {
                return
            }
        }
        this.isOpening = true
        let status = await handleBeforeFunction(this.menuList[index].beforeOpen)
        if (!status) {
            return
        }
        let y = this.getMaskTop()
        let maskHeight = GlobalStore.screenHeight - y
        this.activeIndex = index
        this.promptAction.openCustomDialog({
            builder: () => this.menuContentBuilder(maskHeight),
            width: CONTAINER_SIZE.FULL,
            backgroundBlurStyle: BlurStyle.NONE,
            alignment: DialogAlignment.Top,
            cornerRadius: {
                topLeft: 0,
                topRight: 0,
                bottomLeft: getSizeByUnit(this.radius),
                bottomRight: getSizeByUnit(this.radius)
            },
            maskRect: {
                x: 0,
                y: y,
                width: CONTAINER_SIZE.FULL,
                height: maskHeight
            },
            offset: { dx: 0, dy: y - (this.topAvoidHeight.value as number) },
            transition: TransitionEffect.OPACITY.animation({
                duration: hideDuration
            }),
            onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                let reason = dismissDialogAction.reason
                if (reason == DismissReason.TOUCH_OUTSIDE && !this.closeOnClickOverlay) {
                    return
                }
                this.close(index)
            }
        }).then((id: number) => {
            this.menuList[index].dialogId = id
            this.menuList[index].onOpen!()
            this.isOpening = false
        })
    }
    close(index: number) {
        return new Promise<void>((resolve) => {
            this.baseController.hide()
            setTimeout(() => {
                try {
                    this.promptAction.closeCustomDialog(this.menuList[index].dialogId as number)
                    this.menuList[index].dialogId = ''
                    this.menuList[index].onClose!()
                    this.activeIndex = ''
                    resolve()
                }catch (e) {}
            }, hideDuration)
        })
    }
    manualClose(){
        let i = this.getOpenIndex()
        if (i > -1) {
            this.close(i)
        }
    }
    build() {
        if(this.menuWidthType == 'flex'){
            Row() {
                this.optionListBuilder()
            }
            .optionListStyle()
        }else {
            Scroll(){
                Row(){
                    this.optionListBuilder()
                }
                .padding({left: this.baseStyle.spaceBase as string, right: this.baseStyle.spaceXs as string})
            }
            .optionListStyle()
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .align(Alignment.Start)
        }
    }
}

@ComponentV2
struct IBestDropdownMenuOptionItem{
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Consumer() activeIndex: number = 0
    @Param @Require option: IBestDropdownMenuContentParams
    @Param @Require index: number
	@Param @Require menuFontColor: ResourceColor
    @Param @Require activeColor: ResourceColor
    @Param @Require menuWidthType: 'auto' | 'flex'
    @Param @Require menuIcon: ResourceStr
    @Param @Require menuIconSize: IBestStringNumber
    @Param @Require menuFontSize: IBestStringNumber
    isOpen(){
        return this.index == this.activeIndex && this.option.dialogId !== ''
    }
    @Monitor("option", "options.length")
    getShowText(){
        if(this.option.options?.length){
            let value = this.option.value
            let option = this.option.options?.find(item => item.value === value)
            return option?.text || this.option.title
        }else {
            return this.option.title
        }
    }
    build() {
        Row({space: this.baseStyle.spaceBase as string}){
            Text(this.getShowText())
                .fontColor(this.option.disabled ? IBestDropdownMenuColor.disabledColor : this.isOpen() ? this.activeColor : this.menuFontColor)
                .fontSize(this.menuFontSize)
                .constraintSize({maxWidth: "80%"})
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({overflow: TextOverflow.Ellipsis})
            IBestIcon({
                name: this.menuIcon,
                iconSize: this.menuIconSize,
                color: this.option.disabled ? IBestDropdownMenuColor.disabledColor : this.isOpen() ? this.activeColor : this.menuFontColor
            })
                .rotate({ z: 1, angle: this.isOpen() ? 180 : 0 })
                .animation({duration: 200})
        }
        .width(this.menuWidthType == 'flex' ? CONTAINER_SIZE.FULL : "")
        .height(CONTAINER_SIZE.FULL)
        .justifyContent(FlexAlign.Center)
        .padding({left: this.baseStyle.spaceXs, right: this.baseStyle.spaceXs})
    }
}

@ComponentV2
struct IBestDropdownMenuContent{
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    @Param @Require groupId: IBestStringNumber
    @Param @Require maxHeight: number
    @Param @Require option: IBestDropdownMenuContentParams
    @Param @Require bgColor: ResourceColor
    @Param @Require activeColor: ResourceColor
    @Param @Require dropDownFontSize: IBestStringNumber
    @Param @Require dropDownIconSize: IBestStringNumber
    @Param @Require selectedIcon: ResourceStr
    @Param controller: MenuContentController = new MenuContentController()
    @BuilderParam defaultBuilder: CustomBuilder

    @Local transY: IBestStringNumber = "-100%"
    @Local initialIndex: number = -1

    @Builder cellTitleBuilder(option: IBestDropdownMenuOption){
        Row({space: this.baseStyle.spaceBase}){
            if(option.icon && (!option.iconPosition || option.iconPosition == 'left')){
                IBestIcon({
                    name: option.icon,
                    color: this.option.value == option.value ? this.activeColor : IBestDropdownMenuColor.textColor,
                    iconSize: this.dropDownIconSize
                })
            }
            Text(option.text)
                .fontSize(getSizeByUnit(this.dropDownFontSize, true))
                .fontColor(this.option.value == option.value ? this.activeColor : IBestDropdownMenuColor.textColor)
            if(option.icon && option.iconPosition == 'right'){
                IBestIcon({
                    name: option.icon,
                    color: this.option.value == option.value ? this.activeColor : IBestDropdownMenuColor.textColor,
                    iconSize: this.dropDownIconSize
                })
            }
        }.alignItems(VerticalAlign.Center)
    }

    aboutToAppear(): void {
        this.controller.hide = (): void => this.close()
        this.init()
    }
    init(){
        this.defaultBuilder = this.option.defaultBuilder
        this.initialIndex = this.option.options?.findIndex(item => item.value === this.option.value) || -1
    }
    close(){
        this.transY = "-100%"
    }
    build(){
        if(this.defaultBuilder) {
            this.defaultBuilder()
        }else if (this.option.options.length) {
            List({initialIndex: this.initialIndex}){
                Repeat<IBestDropdownMenuOption>(this.option.options).each((obj: RepeatItem<IBestDropdownMenuOption>) => {
                    ListItem(){
                        IBestCell({
                            titleBuilder: () => this.cellTitleBuilder(obj.item),
                            rightIcon: this.option.value == obj.item.value ? this.selectedIcon : "",
                            rightIconColor: this.activeColor,
                            disabled: obj.item.disabled,
                            clickable: true,
                            hasBorder: obj.index < this.option.options.length - 1,
                            onCellClick: () => {
                                this.option.onChange && this.option.onChange(obj.item.value)
                            }
                        })
                    }
                })
                    .key((item: IBestDropdownMenuOption) => item.value.toString())
                    .virtualScroll({
                        onTotalCount: () => { return this.option.options.length }
                    })
            }
            .width(CONTAINER_SIZE.FULL)
            .backgroundColor(this.baseStyle.default)
            .constraintSize({ maxHeight: this.option.maxHeight ? getSizeByUnit(this.option.maxHeight) : this.maxHeight*0.9 })
            .translate({ y: this.transY })
            .border({ width: { top: 1 }, color: IBestDropdownMenuColor.borderColor })
            .opacity(this.transY == 0 ? 1 : 0)
            .animation({ duration: popupDuration, curve: Curve.EaseInOut })
            .edgeEffect(EdgeEffect.None)
            .onAppear(() => {
                setTimeout(() => {
                    this.transY = 0
                }, 100)
            })
        }
    }
}

@ComponentV2
export struct IBestDropdownItem{
    /**
     * 分组id
     */
    @Param @Require groupId: IBestStringNumber
    /**
     * 菜单项标题
     */
    @Param title: ResourceStr = ''
    /**
     * 选项数组
     */
    @Param options: IBestDropdownMenuOption[] = []
    /**
     * 当前选中项对应的value
     */
    @Param value: IBestStringNumber = ''
    /**
     * 是否禁用菜单
     */
    @Param disabled: boolean = false
    /**
     * 最大高度
     * @since 1.0.3
     */
    @Param maxHeight: IBestStringNumber = ''
    /**
     * 默认内容
     */
    @BuilderParam defaultBuilder: CustomBuilder
    /**
     * 打开时触发
     */
    @Event onOpen: () => void = () => {}
    /**
     * 关闭时触发
     */
    @Event onClose: () => void = () => {}
    /**
     * 点击选项时触发
     */
    @Event onChange: (value: IBestStringNumber) => void = () => {}
    /**
     * 打开前回调
     * @since 1.0.3
     */
    @Event beforeOpen?: () => IBestAwaitable = undefined
    @Event $value: (value: IBestStringNumber) => void = () => {}

    @Local uniId: number = 0
    @Local index: number = 0

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
        this.init()
    }
    aboutToDisappear(): void {
        ibestEmitter.off(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CLICK, this.groupId), this.uniId)
    }
    init(){
        ibestEmitter.emit(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), 'init', {
            value: this.value,
            title: this.title,
            options: this.options,
            maxHeight: this.maxHeight,
            disabled: this.disabled,
            defaultBuilder: this.defaultBuilder,
            onOpen: this.onOpen,
            onClose: this.onClose,
            onChange: (value: IBestStringNumber): void => this.onValueChange(value),
            beforeOpen: this.beforeOpen
        }, (index: number) => {
            this.index = index
        })
    }
    onValueChange(value: IBestStringNumber){
        this.$value(value)
        this.onChange(value)
    }
    @Monitor("value")
    valueChange(){
        ibestEmitter.emit(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), 'value', {
            index: this.index,
            value: this.value
        })
    }
    @Monitor("disabled")
    disabledChange(){
        ibestEmitter.emit(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), 'disabled', {
            index: this.index,
            disabled: this.disabled
        })
    }
    @Monitor("options", "options.length")
    optionsChange(){
        ibestEmitter.emit(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), 'options', {
            index: this.index,
            options: this.options
        })
    }
    build(){}
}