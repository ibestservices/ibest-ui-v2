import { image } from '@kit.ImageKit';
/**
 * IBestImageCropper 控制器
 */
export class IBestImageCropperController{
	/**
	 * 设置比例
	 * @since 1.0.3
	 */
	setScale: (scale: number) => void = () => {}
	/**
	 * 设置角度
	 * @since 1.0.3
	 */
	setAngle: (angle: number) => void = () => {}
	/**
	 * 重置
	 * @since 1.0.3
	 */
	reset: () => void = () => {}
	/**
	 * 获取截取结果
     */
	getResult: (callBack?: (result: PixelMap) => void) => Promise<PixelMap> = () => Promise.resolve(image.createImageSource("").createPixelMap())
}