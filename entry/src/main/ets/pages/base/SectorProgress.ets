import { IBestSectorProgress, IBestSlider } from '@ibestservices/ibest-ui-v2'
import { modeColor, SPACE } from '../../assets/styles/BaseStyle'
import ComponentShowContainer from '../../components/ComponentShowContainer'
import CustomNavBar from '../../components/CustomNavBar'
import { LengthMetrics } from '@kit.ArkUI'

@Builder
export function SectorProgressBuilder(_: string, title: string){
    SectorProgressPage({title})
}

@Entry
@ComponentV2
struct SectorProgressPage {
    @Param title: string = ''
    @Local value: number = 30

    build() {
        NavDestination() {
            CustomNavBar({title: this.title})
            List() {
                ListItem() {
                    ComponentShowContainer({ title: '基础用法' }) {
                        IBestSectorProgress({
                            value: this.value!!,
                            text: `${this.value}%`
                        })
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: '样式定制' }) {
                        Column(){
                            Flex({wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center, space: { main: LengthMetrics.vp(20), cross: LengthMetrics.vp(20) }}){
                                IBestSectorProgress({
                                    value: this.value!!,
                                    diameter: 80,
                                    text: "宽度定制"
                                })
                                IBestSectorProgress({
                                    value: this.value!!,
                                    bgColor: "#ebedf0",
                                    sectorBgColor: "#ee0a24",
                                    text: "颜色定制"
                                })
                                IBestSectorProgress({
                                    value: this.value!!,
                                    clockwise: false,
                                    text: "逆时针"
                                })
                                IBestSectorProgress({
                                    value: this.value!!,
                                    text: "边框",
                                    outerBorder: {width: 1, color: Color.Green}
                                })
                                IBestSectorProgress({
                                    value: this.value!!,
                                    text: "过渡动画",
                                    enableAnimation: true
                                })
                            }
                            Row({space: SPACE.SM}){
                                IBestSlider({
                                    value: this.value!!
                                })
                            }
                        }
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: '起始位置' }) {
                        Flex({wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(20), cross: LengthMetrics.vp(20) }}){
                            IBestSectorProgress({
                                value: this.value!!,
                                startPosition: "left",
                                text: "左侧"
                            })
                            IBestSectorProgress({
                                value: this.value!!,
                                startPosition: "right",
                                text: "右侧"
                            })
                            IBestSectorProgress({
                                value: this.value!!,
                                startPosition: "bottom",
                                text: "底部"
                            })
                            IBestSectorProgress({
                                value: this.value!!,
                                startPosition: "left",
                                clockwise: false,
                                text: "左侧逆时针"
                            })
                            IBestSectorProgress({
                                value: this.value!!,
                                startPosition: "right",
                                clockwise: false,
                                text: "右侧逆时针"
                            })
                            IBestSectorProgress({
                                value: this.value!!,
                                startPosition: "bottom",
                                clockwise: false,
                                text: "底部逆时针"
                            })
                        }
                    }
                }

                ListItem().height(50)
            }
            .padding({left: SPACE.MD, right: SPACE.MD})
            .layoutWeight(1)
        }
        .hideTitleBar(true)
        .backgroundColor(modeColor.bg)
    }
}