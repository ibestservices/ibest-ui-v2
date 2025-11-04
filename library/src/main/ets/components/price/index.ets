import { IBestStorageKey, IBestStringNumber } from "../../model/Global.type"
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from "../../theme-chalk/src/index.type"
import { getSizeByUnit } from "../../utils/utils"
import { AppStorageV2 } from "@kit.ArkUI"

@ComponentV2
export struct IBestPrice{
    /**
     * 全局公共样式
     */
    @Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 显示值
     */
    @Param value: IBestStringNumber = 0
    /**
     * 符号
     */
    @Param symbol: ResourceStr = '￥'
    /**
     * 符号位置
     */
    @Param symbolPosition: 'left' | 'right' = 'left'
    /**
     * 小数位位数
     */
    @Param decimal: number = 2
    /**
     * 是否按照千分位显示
     */
    @Param thousand: boolean = false
    /**
     * 文本装饰线
     */
    @Param strikeThrough: boolean = false
    /**
     * 符号字体大小
     */
    @Param symbolFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 整数部分字体大小
     */
    @Param integerFontSize: IBestStringNumber = this.baseStyle.fontSizeLg as string
    /**
     * 小数点字体大小
     */
    @Param decimalPointFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 小数部分字体大小
     */
    @Param decimalFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 字体颜色
     */
    @Param color: ResourceColor = this.baseStyle.danger

    @Builder symbolBuilder(){
        Span(this.symbol)
            .fontSize(getSizeByUnit(this.symbolFontSize, true))
    }
    isHasPoint(){
        return this.value.toString().indexOf('.') > -1
    }
    // 格式化整数部分
    formatInteger() {
        let value = this.value
        if(isNaN(Number(value)) || Number(value) == 0) {
            value = 0
        }
        if(this.isHasPoint()) {
            value = Number(value).toFixed(this.decimal)
            value = value.split('.')[0]
        }else {
            value = value.toString()
        }
        if(this.thousand) {
            return (value || 0).toString().replace(/(\d)(?=(?:\d{3})+$)/g, '$1,')
        }else {
            return value
        }
    }
    // 格式化小数部分
    formatDecimal() {
        let value = this.value
        if(isNaN(Number(value)) || Number(value) == 0) {
            value = 0
        }
        if(this.isHasPoint()) {
            value = Number(value).toFixed(this.decimal)
            value = value.split('.')[1]
        }else {
            value = 0
        }
        const resultFixed = Number('0.' + value).toFixed(this.decimal)
        return String(resultFixed).substring(2, resultFixed.length)
    }

    build() {
        Text(){
            if(this.symbolPosition == 'left'){
                this.symbolBuilder()
            }
            Span(this.formatInteger()).fontSize(getSizeByUnit(this.integerFontSize, true))
            if(this.decimal > 0){
                Span(".").fontSize(getSizeByUnit(this.decimalPointFontSize, true))
            }
            Span(this.formatDecimal()).fontSize(getSizeByUnit(this.decimalFontSize, true))
            if(this.symbolPosition == 'right'){
                this.symbolBuilder()
            }
        }
        .fontColor(this.color)
        .decoration({ type: this.strikeThrough ? TextDecorationType.LineThrough : TextDecorationType.None, color: Color.Transparent })
    }
}