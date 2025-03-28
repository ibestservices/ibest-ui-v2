import { IBestButton, IBestCircleProgress } from '@ibestservices/ibest-ui-v2';
import { modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import { LengthMetrics } from '@kit.ArkUI';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function CircleProgressBuilder(_: string, title: string){
	CircleProgressPage({title})
}

@Entry
@ComponentV2
struct CircleProgressPage {
    @Param title: string = ''
    @Local value: number = 10

    build() {
		NavDestination() {
			CustomNavBar({title: this.title})
            List() {
                ListItem() {
                    ComponentShowContainer({ title: '基础用法' }) {
                        IBestCircleProgress({
                            value: this.value!!,
                            text: `${this.value}%`
                        })
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: '样式定制' }) {
                        Column(){
                            Flex({wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(20), cross: LengthMetrics.vp(20) }}){
                                IBestCircleProgress({
                                    value: this.value!!,
                                    strokeWidth: 6,
                                    text: "宽度定制"
                                })
                                IBestCircleProgress({
                                    value: this.value!!,
                                    color: "#ee0a24",
                                    bgColor: "#ebedf0",
                                    text: "颜色定制"
                                })
                                IBestCircleProgress({
                                    value: this.value!!,
                                    clockwise: false,
                                    text: "逆时针",
                                    color: "#07c160"
                                })
                                IBestCircleProgress({
                                    value: this.value!!,
                                    diameter: 120,
                                    clockwise: false,
                                    text: "大小定制",
                                    color: "#7232dd"
                                })
                            }
                            Row({space: SPACE.SM}){
                                IBestButton({
                                    text: "增加",
                                    type: "primary",
                                    buttonSize: "small",
                                    onBtnClick: () => {
                                        this.value += 10
                                    }
                                })
                                IBestButton({
                                    text: "减少",
                                    type: "danger",
                                    buttonSize: "small",
                                    onBtnClick: () => {
                                        this.value -= 10
                                    }
                                })
                            }
                        }
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: '起始位置' }) {
                        Flex({wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(20), cross: LengthMetrics.vp(20) }}){
                            IBestCircleProgress({
                                value: this.value!!,
                                startPosition: "left",
                                text: "左侧"
                            })
                            IBestCircleProgress({
                                value: this.value!!,
                                startPosition: "right",
                                text: "右侧"
                            })
                            IBestCircleProgress({
                                value: this.value!!,
                                startPosition: "bottom",
                                text: "底部"
                            })
                            IBestCircleProgress({
                                value: this.value!!,
                                startPosition: "left",
                                clockwise: false,
                                text: "左侧逆时针"
                            })
                            IBestCircleProgress({
                                value: this.value!!,
                                startPosition: "right",
                                clockwise: false,
                                text: "右侧逆时针"
                            })
                            IBestCircleProgress({
                                value: this.value!!,
                                startPosition: "bottom",
                                clockwise: false,
                                text: "底部逆时针"
                            })
                        }
                    }
                }
            }
            .padding({left: SPACE.MD, right: SPACE.MD})
            .layoutWeight(1)
        }
        .hideTitleBar(true)
        .backgroundColor(modeColor.bg)
    }
}