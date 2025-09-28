import { IBestDialogUtil, IBestReadMore } from '@ibestservices/ibest-ui-v2';
import { FONT_SIZE, modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function ReadMoreBuilder(_: string, title: string){
    ReadMorePage({title})
}

@Entry
@ComponentV2
struct ReadMorePage {
    @Param title: string = ''
    @Local isExpand: boolean = false
    @Local isExpand1: boolean = false
    @Local isExpand2: boolean = false
    @Local isVip: boolean = false
    @Local isExpand3: boolean = false

    @Builder textBuilder(){
        Text("莫听穿林打叶声，何妨吟啸且徐行。竹杖芒鞋轻胜马，谁怕？一蓑烟雨任平生。料峭春风吹酒醒，微冷，山头斜照却相迎。回首向来萧瑟处，归去，也无风雨也无晴。")
            .fontSize(FONT_SIZE.MD)
            .lineHeight(24)
    }
    @Builder imgBuilder(){
        Column({space: SPACE.SM}){
            this.textBuilder()
            Image("https://pic.rmb.bdstatic.com/bjh/3f1f471fd58/240608/84792afec007f0da44ea981f73196434.jpeg")
                .height(200)
        }
    }

    build() {
        NavDestination() {
            CustomNavBar({title: this.title})
            List() {
                ListItem() {
                    ComponentShowContainer({ title: "基本用法" }) {
                        IBestReadMore({
                            value: this.isExpand!!
                        }){
                            this.textBuilder()
                        }
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: "自定义高度" }) {
                        IBestReadMore({
                            value: this.isExpand1!!,
                            collapseHeight: 150
                        }){
                            this.imgBuilder()
                        }
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: "一次性展开" }) {
                        IBestReadMore({
                            value: this.isExpand2!!,
                            once: true
                        }){
                            this.textBuilder()
                        }
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: "异步展开" }) {
                        IBestReadMore({
                            value: this.isExpand3!!,
                            inactive: !this.isVip,
                            expandText: this.isVip ? "展开" : "付费解锁",
                            expandIcon: this.isVip ? "arrow-down" : "lock",
                            beforeExpand: () => {
                                if(this.isVip){
                                    return true
                                }
                                return new Promise((resolve, reject) => {
                                    IBestDialogUtil.open({
                                        title: "提示",
                                        message: "需开通VIP才能解锁全部内容，是否继续？",
                                        showCancelButton: true,
                                        onConfirm: () => {
                                            this.isVip = true
                                            resolve(true)
                                        },
                                        onCancel: () => {
                                            reject(false)
                                        }
                                    })
                                })
                            }
                        }){
                            this.textBuilder()
                        }
                    }
                }
                ListItem().height(50)
            }
            .layoutWeight(1)
            .padding({ left: SPACE.SM, right: SPACE.SM })
        }
        .hideTitleBar(true)
        .backgroundColor(modeColor.bg)
    }
}