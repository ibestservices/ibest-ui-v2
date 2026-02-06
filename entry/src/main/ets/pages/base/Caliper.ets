import { IBestCaliper } from '@ibestservices/ibest-ui-v2';
import { modeColor, SPACE } from '../../assets/styles/BaseStyle';
import ComponentShowContainer from '../../components/ComponentShowContainer';
import CustomNavBar from '../../components/CustomNavBar';

@Builder
export function CaliperBuilder(_: string, title: string){
    CaliperPage({title})
}

@Entry
@ComponentV2
struct CaliperPage {
    @Param title: string = ''
    @Local value: number = 6
    @Local value1: number = 50
    @Local value2: number = 0
    @Local value3: number = 0
    @Local value4: number = 0.5
    @Local value5: number = 0
    @Local value6: number = 0

    build() {
        NavDestination() {
            CustomNavBar({title: this.title})
            List() {
                ListItem() {
                    ComponentShowContainer({ title: '基础用法', space: SPACE.BASE }){
                        Text(this.value.toString())
                        IBestCaliper({
                            value: this.value!!
                        })
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: '设置开始结尾数', space: SPACE.BASE }){
                        Text(this.value1.toString())
                        IBestCaliper({
                            value: this.value1!!,
                            startNum: 50,
                            endNum: 200
                        })
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: '自定义刻度', space: SPACE.MD }){
                        Text(this.value2.toString())
                        IBestCaliper({
                            value: this.value2!!,
                            scaleSize: 2
                        })
                        Text(this.value3.toString())
                        IBestCaliper({
                            value: this.value3!!,
                            scales: 5,
                            scaleSize: 2
                        })
                        Text(this.value4.toString())
                        IBestCaliper({
                            value: this.value4!!,
                            scaleSize: 0.1
                        })
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: '自定义样式', space: SPACE.BASE }){
                        Text(this.value5.toString())
                        IBestCaliper({
                            value: this.value5!!,
                            bgColor: "#d8e9f6",
                            fontColor: "#038cfd",
                            bigScaleHeight: 50,
                            smallScaleHeight: 40,
                            activeScaleColor: "red",
                            activeFontWeight: FontWeight.Bold
                        })
                    }
                }
                ListItem() {
                    ComponentShowContainer({ title: '刻度对齐方式', space: SPACE.SM }){
                        Text(this.value6.toString())
                        IBestCaliper({
                            value: this.value6!!,
                            scaleAlign: "center"
                        })
                        IBestCaliper({
                            value: this.value6!!,
                            scaleAlign: "bottom"
                        })
                    }
                }
                ListItem().height(50)
            }
            .layoutWeight(1)
            .padding({ left: SPACE.SM, right: SPACE.SM })
        }
        .hideTitleBar(true)
        .backgroundColor(modeColor.bg2)
    }
}