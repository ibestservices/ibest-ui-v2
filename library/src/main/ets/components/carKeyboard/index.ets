import { getDefaultBaseStyle } from '../../theme-chalk/src'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { IBestCarKeyboardKey } from './index.type'
import { IBestPopup } from '../popup'
import { convertDimensionsWidthUnit, getComponentsInfo, getResourceStr, getSizeByUnit } from '../../utils/utils'
import { IBestCarKeyboardColor } from './color'
import { IBestBaseDataType, IBestStorageKey, IBestStringNumber } from '../../model/Global.type'
import { AppStorageV2 } from '@kit.ArkUI'
const keyWidth = 0.09

@Extend(Row) function ibestCarKeyboardKeyBoxStyle(){
    .borderRadius(getDefaultBaseStyle().borderRadiusMd)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .stateStyles({
        normal: {
            .backgroundColor(IBestCarKeyboardColor.keyBg)
        },
        pressed: {
            .backgroundColor(IBestCarKeyboardColor.activeBg)
        }
    })
}
@Extend(Text) function ibestCarKeyboardKeyTextStyle(){
    .fontSize(getDefaultBaseStyle().fontSizeLg)
    .fontColor(IBestCarKeyboardColor.textColor)
}

@ComponentV2
export struct IBestCarKeyboardContent{
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
	@Local bottomBarHeight: IBestBaseDataType = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.BOTTOM_BAR_HEIGHT)!
    @Param @Require value: string
	@Param maxLength: number = 8
    @Param title: ResourceStr = ''
    @Param confirmBtnText: ResourceStr = ''
	@Param keyHeight: IBestStringNumber = ''
    @Event onInput: (value: string) => void = () => {}
	@Event onDelete: () => void = () => {}
	@Event onClose: () => void = () => {}
	@Event onConfirm: () => void = () => {}
	@Event $value: (value: string) => void = () => {}

	@Local uniId: number = 0
    private provinceKeys: string[][] = [
		['京', '津', '沪', '渝', '冀', '豫', '云', '辽', '黑'],
		['湘', '皖', '鲁', '新', '苏', '浙', '赣', '鄂', '桂'],
		['甘', '晋', '蒙', '陕', '吉', '闽', '贵', '粤', '青'],
		['藏', '川', '宁', '琼', '使', '领', '临']
	]
	private numKeys: string[][] = [
		['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
		['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
		['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
		['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
		['港', '澳', '学', '警', '挂']
	]
	@Local provinceKeysList: IBestCarKeyboardKey[][] = []
	@Local numKeysList: IBestCarKeyboardKey[][] = []
	@Local space: number = 0
	@Local space1: number = 0
	private uiContext = this.getUIContext()

	@Builder keyButton(item: IBestCarKeyboardKey, full: boolean = false){
		Row(){
			Text(item.text)
				.ibestCarKeyboardKeyTextStyle()
		}
		.width(keyWidth * 100 + '%')
		.height(getSizeByUnit(this.keyHeight || convertDimensionsWidthUnit(42)))
		.layoutWeight(full ? 1 : 0)
		.ibestCarKeyboardKeyBoxStyle()
		.enabled(!item.disabled)
		.opacity(item.disabled ? 0.6 : 1)
		.onClick(() => {
			this.selectKey(item)
		})
	}
	@Builder deleteButton(){
		Row(){
			Image($r("app.media.ibest_delete"))
				.width(convertDimensionsWidthUnit(20))
				.fillColor(IBestCarKeyboardColor.textColor)
		}
		.layoutWeight(1)
		.height(getSizeByUnit(this.keyHeight || convertDimensionsWidthUnit(42)))
		.ibestCarKeyboardKeyBoxStyle()
		.onClick(() => {
			this.selectKey(new IBestCarKeyboardKey("delete"))
		})
	}

    aboutToAppear(): void {
		this.init()
    }
	init(){
		this.uniId = this.getUniqueId()
		this.provinceKeysList = this.provinceKeys.map(e => {
			return e.map(f => new IBestCarKeyboardKey("text", f))
		})
		this.numKeysList = this.numKeys.map(e => {
			return e.map(f =>  new IBestCarKeyboardKey("text", f))
		})
		if(this.value){
			this.switchDisabled()
		}
		setTimeout(() => {
			let width = getComponentsInfo(this.uiContext, `ibest_car_keyboard_${this.uniId}`).width
			this.space = (width - width * keyWidth * 9 ) / 8
			this.space1 = (width - width * keyWidth * 10) / 9
		}, 100)
	}
    // 按键点击
    selectKey(key: IBestCarKeyboardKey): void {
        switch (key.type){
            case "delete":
                this.$value(this.value.slice(0, -1))
				this.onDelete()
                break
            default:
				if(this.value.length < this.maxLength){
					this.$value(this.value + key.text)
					this.onInput(getResourceStr(key.text!))
				}
                break
        }
    }
	// 切换禁用
	@Monitor("value")
	switchDisabled(){
		const valueLength = this.value.length
		if(valueLength == 1) {
			const keys = this.numKeys[0]
			this.numKeysList.forEach(e => {
				e.forEach(f => {
					f.disabled = keys.includes(f.text)
				})
			})
		} else if(valueLength == this.maxLength - 2) {
			this.numKeysList.forEach(e => {
				e.forEach(f => {
					f.disabled = f.text === 'I' || f.text === 'O'
				})
			})
		} else {
			const keys = this.numKeys[this.numKeysList.length - 1].concat(['I', 'O'])
			this.numKeysList.forEach(e => {
				e.forEach(f => {
					f.disabled = keys.includes(f.text)
				})
			})
		}
	}
	getConfirmButtonText(){
		return this.confirmBtnText || $r("app.string.ibest_text_complete")
	}

    build() {
        Column(){
			Stack({ alignContent: Alignment.End }){
				if(this.title){
					Row(){
						Text(this.title)
						.fontSize(this.baseStyle.fontSizeLg)
						.fontColor(IBestCarKeyboardColor.textColor)
					}
					.width(CONTAINER_SIZE.FULL)
					.justifyContent(FlexAlign.Center)
				}
				Text(this.getConfirmButtonText())
					.padding({ left: this.baseStyle.spaceMd, right: this.baseStyle.spaceSm })
					.fontSize(this.baseStyle.fontSizeMd)
					.fontColor(this.baseStyle.primary)
					.onClick(() => {
						this.onClose()
						this.onConfirm()
					})
			}
			.width(CONTAINER_SIZE.FULL)
			.height(convertDimensionsWidthUnit(40))
			Column(){
				Column({ space: this.baseStyle.spaceXs }){
					ForEach(this.provinceKeysList, (item: IBestCarKeyboardKey[], index: number) => {
						Row({space: this.space}){
							ForEach(item, (e: IBestCarKeyboardKey) => {
								this.keyButton(e)
							}, (_: IBestCarKeyboardKey, i: number) => i.toString())
							if(index == this.provinceKeysList.length - 1){
								this.deleteButton()
							}
						}
						.width(CONTAINER_SIZE.FULL)
						.justifyContent(FlexAlign.SpaceBetween)
					})
				}
				.width(CONTAINER_SIZE.FULL)
				.visibility(this.value.length ? Visibility.None : Visibility.Visible)
				Column({ space: this.baseStyle.spaceXs as string }){
					ForEach(this.numKeysList, (item: IBestCarKeyboardKey[], index: number) => {
						Row({space: this.space1}){
							ForEach(item, (e: IBestCarKeyboardKey) => {
								this.keyButton(e, index == this.numKeysList.length - 1)
								// .layoutWeight(index == this.numKeysList.length - 1 ? 1 : 0)
							}, (_: IBestCarKeyboardKey, i: number) => i.toString())
							if(index == this.numKeysList.length - 2){
								this.deleteButton()
							}
						}
						.width(CONTAINER_SIZE.FULL)
						.justifyContent(index == 2 ? FlexAlign.Center : index == 3 ? FlexAlign.Start : FlexAlign.SpaceBetween)
					}, (_: IBestCarKeyboardKey[], i: number) => i.toString())
				}
				.width(CONTAINER_SIZE.FULL)
				.visibility(this.value.length ? Visibility.Visible : Visibility.None)
			}
			.id(`ibest_car_keyboard_${this.uniId}`)
        }
        .width(CONTAINER_SIZE.FULL)
        .backgroundColor(IBestCarKeyboardColor.bg)
		.padding({
			left: this.baseStyle.spaceBase as string,
			right: this.baseStyle.spaceBase as string,
			bottom: this.bottomBarHeight.value as number
		})
    }
}

@ComponentV2
export struct IBestCarKeyboard{
    /**
     * 弹框展示状态
     */
    @Param @Require visible: boolean
    /**
     * 值
     */
    @Param @Require value: string
	/**
	 * 最大长度
     */
	@Param maxLength: number = 8
    /**
     * 标题
     */
    @Param title: ResourceStr = ''
	/**
	 * 确认按钮文字
	 */
	@Param confirmBtnText: ResourceStr = ''
	/**
	 * 按键高度
     */
	@Param keyHeight: IBestStringNumber = convertDimensionsWidthUnit(42)
    /**
     * 输入回调
     */
	@Event onInput: (value: string) => void = () => {}
    /**
     * 删除回调
     */
	@Event onDelete: () => void = () => {}
    /**
     * 关闭回调
     */
	@Event onClose: () => void = () => {}
	/**
	 * 完成回调
     */
	onConfirm: (value: string) => void = () => {}
	@Event $value: (value: string) => void = () => {}
	@Event $visible: (value: boolean) => void = () => {}

    @Builder baseBuilder() {
		IBestCarKeyboardContent({
            value: this.value,
			maxLength: this.maxLength,
			title: this.title,
			confirmBtnText: this.confirmBtnText,
			keyHeight: this.keyHeight,
            onInput: (value: string): void => this.onInput(value),
            onDelete: (): void => this.onDelete(),
            onClose: (): void => this.close(),
			onConfirm: (): void => this.onConfirm(this.value),
			$value: (value: string): void => this.$value(value),
        })
    }

    // 关闭
    close(){
        this.$visible(false)
        this.onClose()
    }

    build() {
        IBestPopup({
            visible: this.visible,
            popupAlign: "bottom",
            popupHeight: "auto",
            bgColor: IBestCarKeyboardColor.bg,
            maskColor: "transparent",
            closeOnBackPress: true,
            safeAreaInsetBottom: false,
            contentBuilder: (): void => this.baseBuilder(),
			$visible: (value: boolean): void => this.$visible(value)
        })
    }
}