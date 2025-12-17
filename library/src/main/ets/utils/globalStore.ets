import window from '@ohos.window'
import { mergeObject, saveAppStorage } from './utils'
import { bundleManager, common } from '@kit.AbilityKit'
import { IBestStorageKey } from '../model/Global.type'
import { setIBestUIBaseStyle } from '../theme-chalk/src'
import { AppStorageV2, display } from '@kit.ArkUI'
import { IBestGlobalConfig, IBestGlobalConfigType } from '../model/GlobalConfig'

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
		// 获取屏幕尺寸 顶部和底部规避尺寸
		GlobalStore.getScreenAndAvoidSize()
		// 获取是否是应用
		GlobalStore.getBundleType()
		// 设置旋转监听
		GlobalStore.screenRotateListener()
		// 监听颜色模式变化
		GlobalStore.setColorModeListener()
		// 注册字体
		windowStage.getMainWindowSync().getUIContext().getFont().registerFont({
			familyName: 'ibestFont',
			familySrc: $rawfile('ibest_font.woff')
		})
	}
	/**
	 * 获取规避尺寸
     */
	private static getScreenAndAvoidSize(){
		try {
			const mainWindow: window.Window = GlobalStore.getMainWindow()
			const screenInfo: window.WindowProperties = mainWindow.getWindowProperties()
			const avoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
			const systemDht = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
			const topSize = GlobalStore.px2vp(avoidArea.topRect.height)
			const navigationSize = GlobalStore.px2vp(systemDht.bottomRect.height)
			const o = display.getDefaultDisplaySync().orientation
			GlobalStore.screenWidth = GlobalStore.px2vp(screenInfo.windowRect.width)
			GlobalStore.screenHeight = GlobalStore.px2vp(screenInfo.windowRect.height)
			saveAppStorage(IBestStorageKey.IS_LANDSCAPE, o == 1 || o == 3)
			saveAppStorage(IBestStorageKey.TOP_AVOID_HEIGHT, topSize)
			saveAppStorage(IBestStorageKey.BOTTOM_BAR_HEIGHT, navigationSize)
			mainWindow.on("avoidAreaChange", data => {
				if (data.type == window.AvoidAreaType.TYPE_KEYBOARD) {
					saveAppStorage(IBestStorageKey.KEYBOARD_HEIGHT, GlobalStore.px2vp(data.area.bottomRect.height))
				}
			})
		}catch (e) {
			console.error(e.code, e.message)
		}
	}
	/**
	 * 监听屏幕旋转
	 */
	private static screenRotateListener() {
		display.on("change", () => {
			setTimeout(() => {
				GlobalStore.getScreenAndAvoidSize()
			}, 300)
		})
	}
	/**
	 * 监听配置变化
     */
	private static setColorModeListener(){
		let appContext = GlobalStore.context.getApplicationContext()
		saveAppStorage(IBestStorageKey.COLOR_MODE, GlobalStore.context.config.colorMode as number)
		saveAppStorage(IBestStorageKey.LANGUAGE, GlobalStore.context.config.language as string)
		appContext.on('environment', {
			onConfigurationUpdated(config) {
				saveAppStorage(IBestStorageKey.COLOR_MODE, config.colorMode)
				saveAppStorage(IBestStorageKey.LANGUAGE, config.language)
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
	public static setGlobalConfig(option?: Partial<IBestGlobalConfigType>){
		let config = AppStorageV2.connect(IBestGlobalConfig, IBestStorageKey.GLOBAL_CONFIG, () => new IBestGlobalConfig(option))
		if(config){
			mergeObject(config, option)
		}else {
			AppStorageV2.connect(IBestGlobalConfig, IBestStorageKey.GLOBAL_CONFIG, () => new IBestGlobalConfig(option))
		}
		setIBestUIBaseStyle()
	}
	/**
	 * 获取mainWindow
	 */
	public static getMainWindow(){
		return GlobalStore.windowStage.getMainWindowSync()
	}
	/**
	 * 尺寸转换
	 */
	public static px2vp(value: number){
		return GlobalStore.getMainWindow().getUIContext().px2vp(value)
	}
	public static vp2px(value: number){
		return GlobalStore.getMainWindow().getUIContext().vp2px(value)
	}
}