import { IBestCell, IBestIcon, IBestStringNumber } from "../../../../../Index"
import { CONTAINER_SIZE } from "../../theme-chalk/src/container"
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from "../../theme-chalk/src/index.type"
import { emitter } from "../../utils/EventEmitter"
import { convertDimensionsWidthUnit, getComponentsInfo, getEventName, getSizeByUnit } from "../../utils/utils"
import { IBestDropdownMenuColor } from "./color"
import { COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME, IBestDropdownMenuContentParams,
    IBestDropdownMenuContentType,
    IBestDropdownMenuOption,
    MenuContentController,
    IBestDropdownMenuController
} from "./index.type"
import { AppStorageV2 } from "@kit.ArkUI"
import { IBestBaseDataType, IBestStorageKey } from "../../model/Global.type"
import GlobalStore from "../../utils/GlobalStore"

const popupDuration = 150
const hideDuration = 170

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
	@Param activeColor: ResourceColor = IBestDropdownMenuColor.activeColor
    /**
     * 下拉选项文字大小
     */
    @Param dropDownFontSize: IBestStringNumber = ""
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
                .id(`ibest_dropdown_menu_${this.uniId}`)
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
    }
    @Builder menuContentBuilder(maxHeight: number) {
        IBestDropdownMenuContent({
            groupId: this.groupId,
            maxHeight: maxHeight,
            option: this.getOption(),
            bgColor: this.bgColor,
            activeColor: this.activeColor,
            dropDownFontSize: this.dropDownFontSize,
            selectedIcon: this.selectedIcon,
            controller: this.baseController
        })
    }
    aboutToAppear() {
        this.uniId = this.getUniqueId()
        this.controller.close = (): void => this.manualClose()
        emitter.on(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), this.uniId, (type: string, option: IBestDropdownMenuContentType, callBack?: (index: number) => void): void => this.updateOption(type, option, callBack))
    }
    aboutToDisappear() {
        emitter.off(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), this.uniId)
        this.manualClose()
    }
    // 更新选项
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
    // 获取遮罩层顶部距离
    getMaskTop() {
        let info = getComponentsInfo(this.uiContext, `ibest_dropdown_menu_${this.uniId}`)
        return info.screenTop + info.height
    }
    // 是否有打开的选项
    getOpenIndex() {
        return this.menuList.findIndex(item => item.dialogId !== '')
    }
    // 获取当前选项信息
    getOption(): IBestDropdownMenuContentParams{
        return this.activeIndex !=='' ? this.menuList[this.activeIndex] : new IBestDropdownMenuContentParams()
    }
    // 打开筛选
    async openMenu(index: number) {
        let i = this.getOpenIndex()
        if (i > -1) {
            await this.close(i)
            if (i == index) {
                return
            }
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
        })
    }
    // 关闭
    close(index: number) {
        return new Promise<void>((resolve) => {
            this.baseController.hide()
            setTimeout(() => {
                this.promptAction.closeCustomDialog(this.menuList[index].dialogId as number)
                this.menuList[index].dialogId = ''
                this.menuList[index].onClose!()
                this.activeIndex = ''
                resolve()
            }, hideDuration)
        })
    }
    // 手动关闭
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
            let option = this.option.options?.find(item => item.value == value)
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
                color: this.option.disabled ? IBestDropdownMenuColor.disabledColor : this.isOpen() ? this.activeColor : IBestDropdownMenuColor.textColor
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
    @Param @Require selectedIcon: ResourceStr
    @Param controller: MenuContentController = new MenuContentController()
    @BuilderParam defaultBuilder: CustomBuilder

    @Local transY: IBestStringNumber = "-100%"
    aboutToAppear(): void {
        this.controller.hide = (): void => this.init()
        this.init()
    }
    // 初始化
    init(){
        this.transY = "-100%"
        this.defaultBuilder = this.option.defaultBuilder
    }
    build(){
        Scroll(){
            Column(){
                if(this.defaultBuilder){
                    this.defaultBuilder()
                }else {
                    ForEach(this.option.options, (option: IBestDropdownMenuOption, index: number) => {
                        IBestCell({
                            leftIcon: option.icon,
                            leftIconColor: this.option.value == option.value ? this.activeColor : IBestDropdownMenuColor.textColor,
                            title: option.text,
                            titleFontSize: this.dropDownFontSize,
                            titleColor: this.option.value == option.value ? this.activeColor : IBestDropdownMenuColor.textColor,
                            rightIcon: this.option.value == option.value ? this.selectedIcon : "",
                            rightIconColor: this.activeColor,
                            disabled: option.disabled,
                            clickable: true,
                            hasBorder: index < this.option.options!.length - 1,
                            onCellClick: () => {
                                this.option.onChange!(option.value)
                            }
                        })
                    }, (_: IBestDropdownMenuOption, index: number) => index.toString())
                }
            }
            .width(CONTAINER_SIZE.FULL)
        }
        .width(CONTAINER_SIZE.FULL)
        .backgroundColor(this.baseStyle.default)
        .constraintSize({ maxHeight: this.maxHeight * 0.8 })
        .translate({ y: this.transY })
        .border({ width:{ top:1 }, color: IBestDropdownMenuColor.borderColor })
        .animation({ duration: popupDuration, curve: Curve.EaseInOut })
        .onAppear(() => {
            setTimeout(() => {
                this.transY = 0
            }, 100)
        })
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
    @Event $value: (value: IBestStringNumber) => void = () => {}

    @Local uniId: number = 0
    @Local index: number = 0

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
        this.init()
    }
    aboutToDisappear(): void {
        emitter.off(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CLICK, this.groupId), this.uniId)
    }
    init(){
        emitter.emit(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), 'init', {
            options: this.options,
            value: this.value,
            title: this.title,
            disabled: this.disabled,
            defaultBuilder: this.defaultBuilder,
            onOpen: this.onOpen,
            onClose: this.onClose,
            onChange: (value: IBestStringNumber): void => this.onValueChange(value)
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
        console.log("valueChange")
        emitter.emit(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), 'value', {
            index: this.index,
            value: this.value
        })
    }
    @Monitor("disabled")
    disabledChange(){
        emitter.emit(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), 'disabled', {
            index: this.index,
            disabled: this.disabled
        })
    }
    @Monitor("options", "options.length")
    optionsChange(){
        emitter.emit(getEventName(COMPONENT_NAME, DROPDOWN_MENU_EVENT_NAME.OPTION_CHANGE, this.groupId), 'options', {
            index: this.index,
            options: this.options
        })
    }
    build(){}
}