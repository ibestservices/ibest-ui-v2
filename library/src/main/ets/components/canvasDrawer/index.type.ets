import { IBestStringNumber } from '../../model/Global.type'

@ObservedV2
export class IBestCanvasContent {
	/**
	 * 内容类型
     */
	@Trace type?: "" | "image" | "text" = ""
	/**
	 * 图片地址
     */
	@Trace url?: ResourceStr = ""
	/**
	 * 文字
     */
	@Trace text?: ResourceStr = ""
	/**
	 * 内容宽度
	 */
	@Trace width?: number = 0
	/**
	 * 图片高度, 文字无效
	 */
	@Trace height?: number = 0
	/**
	 * 内容左上角距离画布顶部距离
	 */
	@Trace top?: number = 0
	/**
	 * 图片左上角距离画布底部距离, 文字无效
	 */
	@Trace bottom?: number = 0
	/**
	 * 内容左上角距离画布左侧距离
	 */
	@Trace left?: number = 0
	/**
	 * 内容右上角距离画布右侧距离, 优先级大于left
	 */
	@Trace right?: number = 0
	/**
	 * 文字最大行数
	 */
	@Trace maxLineNumber?: number = 1
	/**
	 * 文字字体大小
	 */
	@Trace fontSize?: number = 0
	/**
	 * 文字行高
	 */
	@Trace lineHeight?: number = 0
	/**
	 * 文字颜色
	 */
	@Trace fontColor?: IBestStringNumber | CanvasGradient | CanvasPattern = ""
	/**
	 * 文字字重 可选 'normal', 'bold', 'bolder', 'lighter', 100, 200, 300, 400, 500, 600, 700, 800, 900
	 */
	@Trace fontWeight?: string = "normal"
	/**
	 * 文字 下划线，删除线
	 */
	@Trace textDecoration?: '' | 'underline' | 'lineThrough' = ''
	/**
	 * 文字对齐方式
     */
	@Trace textAlign?: CanvasTextAlign = 'left'
	/**
	 * 图片圆角
	 */
	@Trace borderRadius?: number = 0
	/**
	 * 图片旋转角度
     */
	@Trace deg?: number = 0
}
