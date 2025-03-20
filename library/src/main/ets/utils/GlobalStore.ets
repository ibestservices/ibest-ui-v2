import window from '@ohos.window';
import font from '@ohos.font';
import { getWindowAvoidSize } from './utils';
import { bundleManager, common } from '@kit.AbilityKit';
import { IBestBaseDataType, IBestGlobalConfig, IBestGlobalConfigType, IBestStorageKey } from '../model/Global.type';
import { setIBestUIBaseStyle } from '../theme-chalk/src';
import { AppStorageV2, display } from '@kit.ArkUI';

// 全局存储中心
export default class GlobalStore {
	// windowStage
	public static windowStage: window.WindowStage
	// context
	public static context: common.UIAbilityContext
	// 屏幕信息
	public static screenWidth: number = 0
	public static screenHeight: number = 0
	public static isApp: boolean = false
	/**
	 * 初始化
	 */
	public static init(windowStage: window.WindowStage, context: common.UIAbilityContext){
		GlobalStore.windowStage = windowStage
		GlobalStore.context = context
		// 获取顶部和底部规避尺寸
		GlobalStore.getAvoidSize()
		// 获取屏幕尺寸
		GlobalStore.getScreenSize()
		// 获取是否是应用
		GlobalStore.getBundleType()
		// 设置旋转监听
		GlobalStore.screenRotateListener()
		// 监听颜色模式变化
		GlobalStore.setColorModeListener()
		// 注册字体
		font.registerFont({
			familyName: 'ibestFont',
			familySrc: $rawfile('vant_font.woff')
		})
	}
	/**
	 * 获取规避尺寸
     */
	private static getAvoidSize(){
		let res = getWindowAvoidSize()
		let top = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.TOP_AVOID_HEIGHT)
		let bottom = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.BOTTOM_BAR_HEIGHT)
		if(top){
			top.value = res.topSize
		}else{
			AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.TOP_AVOID_HEIGHT, () => new IBestBaseDataType(res.topSize))
		}
		if(bottom){
			bottom.value = res.navigationSize
		}else {
			AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.BOTTOM_BAR_HEIGHT, () => new IBestBaseDataType(res.navigationSize))
		}
	}
	/**
	 * 获取屏幕尺寸
     */
	private static getScreenSize(){
		let mainWindow = GlobalStore.windowStage.getMainWindowSync()
		let screenInfo: window.WindowProperties = mainWindow.getWindowProperties()
		let o = display.getDefaultDisplaySync().orientation
		let screenWidth = o == 1 || o == 3 ? screenInfo.windowRect.height : screenInfo.windowRect.width
		let screenHeight = o == 1 || o == 3 ? screenInfo.windowRect.width : screenInfo.windowRect.height
		let isLandscape = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.IS_LANDSCAPE)
		GlobalStore.screenWidth = screenWidth
		GlobalStore.screenHeight = screenHeight
		if(isLandscape){
			isLandscape.value = o == 1 || o == 3
		}else{
			AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.IS_LANDSCAPE, () => new IBestBaseDataType(o == 1 || o == 3))
		}
		mainWindow.on("avoidAreaChange", data => {
			if (data.type == window.AvoidAreaType.TYPE_KEYBOARD) {
				let keyHeight = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.KEYBOARD_HEIGHT)
				if(keyHeight){
					keyHeight.value = px2vp(data.area.bottomRect.height)
				}else{
					AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.KEYBOARD_HEIGHT, () => new IBestBaseDataType(px2vp(data.area.bottomRect.height)))
				}
			}
		})
	}
	/**
	 * 监听屏幕旋转
	 */
	private static screenRotateListener() {
		display.on("change", () => {
			setTimeout(() => {
				GlobalStore.getScreenSize()
				GlobalStore.getAvoidSize()
			}, 300)
		})
	}
	/**
	 * 监听配置变化
     */
	private static setColorModeListener(){
		let appContext = GlobalStore.context.getApplicationContext()
		AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.COLOR_MODE, () => new IBestBaseDataType(GlobalStore.context.config.colorMode as number))
		appContext.on('environment', {
			onConfigurationUpdated(config) {
				let colorMode = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.COLOR_MODE) as IBestBaseDataType
				let language = AppStorageV2.connect(IBestBaseDataType, IBestStorageKey.LANGUAGE) as IBestBaseDataType
				colorMode.value = config.colorMode
				language.value = config.language
			},
			onMemoryLevel() {}
		})
	}
	/**
	 * 获取是否是元服务
	 */
	private static getBundleType(){
		GlobalStore.isApp = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).appInfo.bundleType == bundleManager.BundleType.APP
	}
	/**
	 * 设置全局配置
	 */
	public static setGlobalConfig(option?: IBestGlobalConfigType){
		AppStorageV2.connect(IBestGlobalConfig, IBestStorageKey.GLOBAL_CONFIG, () => new IBestGlobalConfig(option))
		setIBestUIBaseStyle()
	}
}