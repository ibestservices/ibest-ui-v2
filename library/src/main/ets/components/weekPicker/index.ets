import { IBestPicker } from '../picker'
import { IBestPickerOption } from '../picker/index.type'
import { convertDimensionsWidthUnit } from '../../utils/utils'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct IBestWeekPicker {
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 已选择的值
     */
    @Param @Require value: IBestStringNumber
    /**
     * 选项列表
     */
    @Param options: IBestPickerOption[] = [
        { text: $r("app.string.ibest_monday"), value: 1 },
        { text: $r("app.string.ibest_tuesday"), value: 2 },
        { text: $r("app.string.ibest_wednesday"), value: 3 },
        { text: $r("app.string.ibest_thursday"), value: 4 },
        { text: $r("app.string.ibest_friday"), value: 5},
        { text: $r("app.string.ibest_saturday"), value: 6 },
        { text: $r("app.string.ibest_sunday"), value: 0 }
    ]
    /**
     * 标题
     */
    @Param title: ResourceStr = ""
    /**
     * 单项高度
     */
    @Param itemHeight: IBestStringNumber = convertDimensionsWidthUnit(44)
    /**
     * 确认按钮文字
     */
    @Param confirmText: ResourceStr = $r("app.string.ibest_text_confirm")
    /**
     * 取消按钮文字
     */
    @Param cancelText: ResourceStr = $r("app.string.ibest_text_cancel")
    /**
     * 是否显示顶部栏
     */
    @Param showToolBar: boolean = true
    /**
     * 可见选项数量
     */
    @Param visibleItemCount: number = 6
    /**
     * 是否横向
     */
    @Param horizontal: boolean = false
    /**
     * 单项宽度, 仅横向时生效
     */
    @Param itemWidth: IBestStringNumber = convertDimensionsWidthUnit(44)
    /**
     * 高度, 仅横向时生效
     */
    @Param contentHeight: IBestStringNumber = convertDimensionsWidthUnit(44)
    /**
     * 选项字体大小
     */
    @Param optionFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
    /**
     * 外部圆角
     */
    @Param radius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0
    /**
     * 未选中字体颜色
     */
    @Param fontColor: ResourceColor = ''
    /**
     * 未选中字体字重
     */
    @Param fontWeight: FontWeight = FontWeight.Normal
    /**
     * 选中字体大小
     */
    @Param selectedFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
    /**
     * 选中文字颜色
     */
    @Param selectedFontColor: ResourceColor = ''
    /**
     * 选项文字字重
     */
    @Param selectedFontWeight: FontWeight = FontWeight.Normal
    /**
     * 确认按钮点击事件
     */
    @Event onConfirm: (value: IBestStringNumber, text: string) => void = () => {}
    /**
     * 取消按钮点击事件
     */
    @Event onCancel: () => void = () => {}
    /**
     * 选中项改变事件
     */
    @Event onChange: (value: IBestStringNumber, text: string) => void = () => {}
    @Event $value: (value: IBestStringNumber) => void = () => {}

    @Local modelValue: IBestStringNumber[] = [this.value]

    @Monitor("value")
    valueChange(){
        this.modelValue = [this.value]
    }
    @Monitor("modelValue")
    modelValueChange(){
        if(this.modelValue.length) {
            this.$value(this.modelValue[0])
        }
    }

    build() {
        IBestPicker({
            value: this.modelValue!!,
            title: this.title,
            options: this.options,
            showToolBar: this.showToolBar,
            visibleItemCount: this.visibleItemCount,
            itemHeight: this.itemHeight,
            confirmText: this.confirmText,
            cancelText: this.cancelText,
            horizontal: this.horizontal,
            itemWidth: this.itemWidth,
            contentHeight: this.contentHeight,
            optionFontSize: this.optionFontSize,
            radius: this.radius,
            fontColor: this.fontColor,
            fontWeight: this.fontWeight,
            selectedFontSize: this.selectedFontSize,
            selectedFontColor: this.selectedFontColor,
            selectedFontWeight: this.selectedFontWeight,
            onConfirm: (selectedValues, selectTexts) => {
                this.onConfirm(selectedValues[0], selectTexts[0])
            },
            onCancel: () => {
                this.onCancel()
            },
            onChange: (selectedValues, selectTexts): void => this.onChange(selectedValues[0], selectTexts[0])
        })
    }
}