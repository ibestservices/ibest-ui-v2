import { IBestUIBaseStyle, IBestUIBaseStyleObjType } from '../../theme-chalk/src/index.type'
import { convertDimensions, getSizeByUnit } from '../../utils/utils'
import { AppStorageV2, matrix4 } from '@kit.ArkUI'
import { CONTAINER_SIZE } from '../../theme-chalk/src/container'
import { IBestCircleProgressColor } from './color'
import { IBestStorageKey, IBestStringNumber } from '../../model/Global.type'

class Point {
    x: number
    y: number

    constructor(x: number, y: number) {
        this.x = x
        this.y = y
    }
    plus(rhs: Point): Point {
        return new Point(this.x + rhs.x, this.y + rhs.y)
    }
    subtract(rhs: Point): Point {
        return new Point(this.x - rhs.x, this.y - rhs.y)
    }
    multiply(scale: number): Point {
        return new Point(this.x * scale, this.y * scale)
    }
    equals(rhs: Point): boolean {
        return this.x === rhs.x && this.y === rhs.y
    }
}

@AnimatableExtend(Circle) function animatableDashArray(point: Point) {
    .strokeDashArray([point.x, point.y])
}

@ComponentV2
export struct IBestCircleProgress{
    /**
     * 全局公共样式
     */
	@Local baseStyle: IBestUIBaseStyleObjType = AppStorageV2.connect(IBestUIBaseStyle, IBestStorageKey.BASE_STYLE)!
    /**
     * 进度值
     */
    @Param @Require value: number
    /**
     * 进度条直径
     */
    @Param diameter: number = convertDimensions(100)
    /**
     * 目标进度
     */
    @Param target: number = 100
    /**
     * 中间文字
     */
    @Param text: ResourceStr = ''
    /**
     * 文字颜色
     */
    @Param textColor: ResourceColor = IBestCircleProgressColor.textColor
    /**
     * 文字大小
     */
    @Param textFontSize: IBestStringNumber = this.baseStyle.fontSizeMd as string
    /**
     * 字重
     */
    @Param textFontWeight: FontWeight = 600
    /**
     * 进度条颜色
     */
    @Param color: ResourceColor = ""
    /**
     * 进度条背景颜色
     */
    @Param bgColor: ResourceColor = IBestCircleProgressColor.bgColor
    /**
     * 进度条宽度
     */
    @Param strokeWidth: number = 4
    /**
     * 动画时长
     */
    @Param duration: number = 300
    /**
     * 边框端点绘制样式
     */
    @Param strokeLineCap: LineCapStyle = LineCapStyle.Round
    /**
     * 是否顺时针
     */
    @Param clockwise: boolean = true
    /**
     * 起始位置
     */
    @Param startPosition: "left" | "right" | "bottom" | "top" = "top"
	/**
	 * 到达目标值
     */
	@Event onReachTarget: () => void = () => {}
	@Event $value: (value: number) => void = () => {}

    @Local maxPerimeter: number = 0
    @Local isShow: boolean = false
    @Local strokeDashArray: Point = new Point(0,0)

    aboutToAppear() {
        this.maxPerimeter = Math.floor(Math.PI * this.diameter)
        this.isShow = this.value > 0
        this.valueChange()
    }
	@Monitor("value")
    valueChange(){
        if(this.value > 0){
            this.isShow = true
        }
		let value = Math.min(this.target, Math.max(this.value, 0))
        this.$value(value)
        this.strokeDashArray = new Point(value ? (this.maxPerimeter * value) / this.target : 0.01, this.maxPerimeter)
    	if(value == this.target){
			this.onReachTarget()
		}
	}
    getSize(){
        return getSizeByUnit(this.diameter - this.strokeWidth)
    }
    getPosition(){
        let matrix1 = matrix4.identity()
        let matrix2 = matrix4.identity()
        switch (this.startPosition){
            case "top":
                return this.clockwise ? matrix1.rotate({ z: 1, angle: -90 }) : matrix1.rotate({ z: 1, angle: -90 }).combine(matrix2.rotate({ y: 1, angle: 180 }))
            case "bottom":
                return this.clockwise ? matrix1.rotate({ z: 1, angle: 90 }) : matrix1.rotate({ z: 1, angle: 90 }).combine(matrix2.rotate({ y: 1, angle: 180 }))
            case "left":
                return this.clockwise ? matrix1.rotate({ z: 1, angle: 180 }) : matrix1.rotate({ z: 1, angle: 180 }).combine(matrix2.rotate({ x: 1, angle: 180 }))
            case "right":
                return this.clockwise ? matrix1 : matrix1.combine(matrix2.rotate({ x: 1, angle: 180 }))
        }
    }
    getColor(){
        return this.color || this.baseStyle.primary
    }

    build() {
        Row(){
            Circle({width: this.getSize(), height: this.getSize()})
                .fill("transparent")
                .strokeWidth(this.strokeWidth)
                .stroke(this.bgColor)
                .strokeLineCap(LineCapStyle.Round)
                .position({left: this.strokeWidth/2, top: this.strokeWidth/2})
            Circle({width: this.getSize(), height: this.getSize()})
                .fill("transparent")
                .strokeWidth(this.strokeWidth)
                .stroke(this.getColor())
                .strokeLineCap(LineCapStyle.Round)
                .position({left: this.strokeWidth/2, top: this.strokeWidth/2})
                .animatableDashArray(this.strokeDashArray)
                .animation({
                    duration: this.duration,
                    onFinish: () => {
                        this.isShow = this.value > 0
                    }
                })
                .transform(this.getPosition())
                .visibility(this.isShow ? Visibility.Visible : Visibility.Hidden)
            if(this.text){
                Text(this.text)
                    .width(CONTAINER_SIZE.FULL)
                    .textAlign(TextAlign.Center)
                    .fontSize(getSizeByUnit(this.textFontSize, true))
                    .fontColor(this.textColor)
                    .fontWeight(this.textFontWeight)
					.padding({left: this.strokeWidth, right: this.strokeWidth})
					.position({left:0, top: "50%"})
                    .translate({ y: "-50%" })
            }
        }
        .width(getSizeByUnit(this.diameter))
        .aspectRatio(1)
    }
}