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
            label: "自定颜色和内容",
            name: "2"
        }
    ]
    @Local bubbleShow: boolean = false
    @Local bubbleShow1: boolean = false

    @Local isMagnetic: boolean = true
    @Local autoHide: boolean = false
    @Local group: string = "bubbleGroup"
    @Local active: string = "1"
    @Local value: string = ''
    @Local isOpen: boolean = false
    @Builder customBubble(){
        Stack({alignContent: Alignment.Bottom}){
            Column()
                .width("100%")
                .height(this.isOpen ? 150 : 60)
                .animation({duration: 200})
                .borderRadius(60)
                .backgroundColor("red")
            Column({space: 6}){
                IBestIcon({
                    name: "replay",
                    iconSize: 16,
                    color: "#fff"
                })
                Text("刷新").fontSize(12).fontColor("#fff")
            }
            .width("100%")
            .height("100%")
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
                this.isOpen = !this.isOpen
            })
        }
        .width(60)
        .height(60)
        .backgroundColor("red")
        .borderRadius(60)
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
            ComponentShowContainer({ title: "自动隐藏" }) {
                IBestCheckbox({
                    value: this.autoHide!!,
                    label: this.autoHide ? "开启" : "关闭"
                })
            }
            ComponentShowContainer({ title: $r("app.string.component_radio") }) {
                IBestRadioGroup({ group: this.group, active: this.active!! }) {
                    IBestRadio({ group: this.group, label: $r("app.string.content"), name: '1' })
                    IBestRadio({ group: this.group, label: $r("app.string.content"), name: '2' })
                }
            }
            ComponentShowContainer({ title: "是否开启磁吸" }) {
                Row() {
                    IBestSwitch({
                        value: this.isMagnetic!!,
                        activeText: "开",
                        inactiveText: "关"
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
        switch (this.curTabName){
            case "1":
                this.bubbleShow = true
                break
            case "2":
                this.bubbleShow1 = true
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
                dragAxis: "xy",
                isMagnetic: this.isMagnetic,
                autoHide: this.autoHide,
                onBubbleClick: () => {
                    IBestToast.show("点击了气泡")
                }
            })
            IBestFloatBubble({
                show: this.bubbleShow1,
                dragAxis: "xy",
                bgColor: Color.Transparent,
                pos: {right: 0, bottom: 100}
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
		})
    }
}