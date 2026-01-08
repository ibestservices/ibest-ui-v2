import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import ibestEmitter from '../../utils/eventEmitter'
import { convertDimensionsWidthUnit, getEventName, getSizeByUnit } from '../../utils/utils'
import { IBestCollapseColor } from '../collapse/color'
import { COLLAPSE_EVENT_NAME, COMPONENT_NAME } from '../collapse/index.type'
import { IBestIcon } from '../icon'
import { AppStorageV2 } from '@kit.ArkUI'
@ComponentV2
export struct IBestCollapseItem {
    /**
     * 全局公共样式
     */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 分组id
     */
    @Param @Require groupId: IBestStringNumber
    /**
     * 唯一标识符
     */
    @Param @Require name: IBestStringNumber
    /**
     * 索引
     */
    @Param @Require index: number
    /**
     * 标题栏左侧图标
     */
    @Param icon: ResourceStr = ""
    /**
     * 标题栏左侧图标颜色
     */
    @Param iconColor: ResourceColor = IBestCollapseColor.iconColor
    /**
     * 标题栏左侧图标大小
     */
    @Param iconSize: IBestStringNumber = convertDimensionsWidthUnit(16)
    /**
     * 标题
     */
    @Param title: ResourceStr = ""
    /**
     * 标题文字颜色
     */
    @Param titleColor: ResourceColor = IBestCollapseColor.titleColor
    /**
     * 标题文字大小
     */
    @Param titleFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 标题栏右侧内容
     */
    @Param value: ResourceStr = ""
    /**
     * 标题右侧文字颜色
     */
    @Param valueColor: ResourceColor = IBestCollapseColor.valueColor
    /**
     * 标题右侧文字大小
     */
    @Param valueFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 是否显示内边框
     */
    @Param isShowBorder: boolean = true
    /**
     * 是否禁用
     */
    @Param disabled: boolean = false
    /**
     * 是否只读
     */
    @Param readOnly: boolean = false
    /**
     * 默认内容
     */
    @BuilderParam defaultBuilder: CustomBuilder

    @Local isExpand: boolean = false
    @Local uniId: number = 0
    @Local isReady: boolean = false

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
        setTimeout(() => {
            this.isReady = true
        }, 220)
        ibestEmitter.emit(getEventName(COMPONENT_NAME, COLLAPSE_EVENT_NAME.GET_ALL_ITEM_NAME, this.groupId), this.name, this.disabled || this.readOnly)
        ibestEmitter.on(getEventName(COMPONENT_NAME, COLLAPSE_EVENT_NAME.INIT_ITEM, this.groupId), this.uniId, (activeNames: IBestStringNumber | IBestStringNumber[]): void => this.changeState(activeNames))
    }
    aboutToDisappear(): void {
        ibestEmitter.off(getEventName(COMPONENT_NAME, COLLAPSE_EVENT_NAME.INIT_ITEM, this.groupId), this.uniId)
    }
    getIsDisabled(){
        return this.disabled || this.readOnly
    }
    changeState(activeNames: IBestStringNumber | IBestStringNumber[]){
        if(typeof activeNames == 'number'){
            activeNames = activeNames.toString()
        }
        this.isExpand = typeof activeNames == "string" ? activeNames == this.name : activeNames.includes(this.name)
    }
    toggle(){
        this.isExpand = !this.isExpand
        ibestEmitter.emit(getEventName(COMPONENT_NAME, COLLAPSE_EVENT_NAME.ITEM_STATE_CHANGE, this.groupId), this.name, this.isExpand)
    }

    build() {
        Column(){
            Row({space: this.baseStyle.spaceBase}){
                if(this.icon){
                    IBestIcon({
                        name: this.icon,
                        iconSize: this.iconSize,
                        color: this.iconColor
                    })
                }
                Text(this.title)
                    .layoutWeight(1)
                    .fontSize(getSizeByUnit(this.titleFontSize, true))
                    .fontColor(this.titleColor)
                if(this.value){
                    Text(this.value)
                        .layoutWeight(1)
                        .textAlign(TextAlign.End)
                        .fontColor(this.valueColor)
                        .fontSize(getSizeByUnit(this.valueFontSize, true))
                }
                IBestIcon({
                    name: "arrow-down",
                    iconSize: this.baseStyle.fontSizeMd as string,
                    color: IBestCollapseColor.rightIconColor
                })
                    .rotate({ z:1, angle: this.isExpand ? -180 : 0 })
                    .animation({ duration: 300 })
                    .visibility(this.readOnly ? Visibility.Hidden : Visibility.Visible)
            }
            .padding({left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd, top: this.baseStyle.spaceSm, bottom: this.baseStyle.spaceSm})
            .stateStyles({
                pressed:{
                    .backgroundColor(IBestCollapseColor.activeBg)
                },
                normal:{
                    .backgroundColor(IBestCollapseColor.bgColor)
                }
            })
            .enabled(!this.getIsDisabled())
            .opacity(this.disabled ? 0.4 : 1)
            .onClick(() => {
                this.toggle()
            })
            Column(){
                if(this.isShowBorder) {
                    Divider()
                        .height(1)
                        .color(IBestCollapseColor.borderColor)
                        .position({ left: 0, top: "-" + this.baseStyle.spaceSm as Dimension })
                }
                if(this.defaultBuilder){
                    this.defaultBuilder()
                }
            }
            .width(CONTAINER_SIZE.FULL)
            .padding({left: this.baseStyle.spaceMd, right: this.baseStyle.spaceMd, top: this.baseStyle.spaceSm, bottom: this.baseStyle.spaceSm})
            .visibility(this.isExpand ? Visibility.Visible : Visibility.None)
            .animation({ duration: this.isReady ? 200 : 0 })
            if(this.isShowBorder && this.index > 0){
                Divider()
                    .width(`calc(100% - ${this.baseStyle.spaceMd} - ${this.baseStyle.spaceMd})`)
                    .height(1)
                    .color(IBestCollapseColor.borderColor)
                    .position({left: this.baseStyle.spaceMd as Dimension, top: 0})
            }
        }
        .backgroundColor(IBestCollapseColor.bgColor)
    }
}