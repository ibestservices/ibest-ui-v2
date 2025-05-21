import { IBestButton, IBestCheckbox,
    IBestDialogUtil,
    IBestField,
    IBestFloatBubble,
    IBestIcon,
    IBestRadio,
    IBestRadioGroup,
    IBestSwitch,
    IBestTabItemType,
    IBestTabs,
    IBestToast
} from '@ibestservices/ibest-ui-v2'
import { CONTAINER_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import CustomNavBar from '../../components/CustomNavBar'

@Builder
export function FloatBubbleBuilder(_: string, title: string) {
    FloatBubblePage({ title })
}

@Entry
@ComponentV2
struct FloatBubblePage {
    @Param title: string = ''
    @Local curTabName: string = "1"
    @Local tabsList: IBestTabItemType[] = [
        {
            label: $r("app.string.basic_usage"),
            name: "1"
        },
        {
            label: "自由拖拽和磁吸",
            name: "2"
        },
        {
            label: "自定颜色和内容",
            name: "3"
        }
    ]
    @Local bubbleShow: boolean = false
    @Local bubbleShow1: boolean = false
    @Local bubbleShow2: boolean = false

    @Local group: string = "bubbleGroup"
    @Local active: string = "1"
    @Local switchValue: boolean = true
    @Local value: string = ''
    @Builder customBubble(){
        Column({space: 6}){
            IBestIcon({
                name: "replay",
                iconSize: 16,
                color: "#fff"
            })
            Text("刷新").fontSize(12).fontColor("#fff")
        }
    }

    @Builder example() {
        Column() {
            ComponentShowContainer({ title: $r("app.string.component_button") }) {
                IBestButton({
                    type: 'primary',
                    text: $r("app.string.button"),
                    onBtnClick: () => {
                        IBestDialogUtil.open({
                            title: "提示",
                            message: "如果解决方法是丑陋的，那就肯定还有更好的解决方法，只是还没有发现而已。",
                            confirmButtonFontWeight: FontWeight.Bold,
                            dialogWidth: "90%"
                        })
                    }
                })
            }
            ComponentShowContainer({ title: $r("app.string.component_checkbox") }) {
                IBestCheckbox({
                    value: true,
                    name: '1',
                    label: $r("app.string.content")
                })
            }
            ComponentShowContainer({ title: $r("app.string.component_radio") }) {
                IBestRadioGroup({ group: this.group, active: this.active!! }) {
                    IBestRadio({ group: this.group, label: $r("app.string.content"), name: '1' })
                    IBestRadio({ group: this.group, label: $r("app.string.content"), name: '2' })
                }
            }
            ComponentShowContainer({ title: $r("app.string.component_switch") }) {
                Row() {
                    IBestSwitch({
                        value: this.switchValue!!
                    })
                }
            }
            ComponentShowContainer({ title: '文本输入框' }) {
                IBestField({
                    value: this.value!!,
                    label: "文本",
                    placeholder: "请输入文本",
                    hasBorder: false
                })
            }
        }
        .width(CONTAINER_SIZE.FULL)
        .layoutWeight(1)
        .padding({ left: SPACE.SM, right: SPACE.SM, bottom: SPACE.SM })
        .margin({ top: SPACE.SM })
    }
    onTabChange(){
        this.bubbleShow = false
        this.bubbleShow1 = false
        this.bubbleShow2 = false
        switch (this.curTabName){
            case "1":
                this.bubbleShow = true
                break
            case "2":
                this.bubbleShow1 = true
                break
            case "3":
                this.bubbleShow2 = true
                break
        }
    }
    build() {
        NavDestination() {
            CustomNavBar({ title: this.title })
            IBestTabs({
				tabsList: this.tabsList,
                currentName: this.curTabName!!,
                onChange: () => {
                    this.onTabChange()
                }
            })
            this.example()
            IBestFloatBubble({
                show: this.bubbleShow,
                icon: "chat",
                onBubbleClick: () => {
                    IBestToast.show("点击了气泡")
                }
            })
            IBestFloatBubble({
                show: this.bubbleShow1,
                icon: "chat",
                dragAxis: "xy",
                autoHide: true,
                onBubbleClick: () => {
                    IBestToast.show("点击了气泡")
                }
            })
            IBestFloatBubble({
                show: this.bubbleShow2,
                bubbleSize: 54,
                bgColor: "#ed4040",
                pos: {right: 0, bottom: 100},
                bubbleShadow: {
                    radius: 14,
                    color: "#333"
                },
                onBubbleClick: () => {
                    IBestToast.show("点击了气泡")
                }
            }){
                this.customBubble()
            }
        }
        .hideTitleBar(true)
        .backgroundColor(modeColor.bg)
        .onShown(() => {
            this.bubbleShow = true
        })
		.onWillHide(() => {
			this.bubbleShow = false
			this.bubbleShow1 = false
			this.bubbleShow2 = false
		})
    }
}