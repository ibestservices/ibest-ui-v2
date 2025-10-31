import { emitter } from '../../utils/eventEmitter'
import { COMPONENT_NAME, RADIO_GROUP_EVENT_NAME } from './index.type'
import { convertDimensionsWidthUnit, getEventName, getSizeByUnit, handleBeforeFunction, sleep } from '../../utils/utils'
import { IBestAwaitable, IBestStringNumber } from '../../model/Global.type'

@ComponentV2
export struct IBestRadioGroup {
	/**
	 * 分组标识
	 */
	@Param @Require @Once group: IBestStringNumber
	/**
	 * 激活的标识
	 */
	@Param @Require active: IBestStringNumber | boolean
	/**
	 * 排列方向
	 */
	@Param placeDirection: Axis = Axis.Vertical
	/**
	 * 排列间距
	 */
	@Param space: IBestStringNumber = convertDimensionsWidthUnit(12)
	/**
	 * 是否禁用
	 * @since 0.0.5
	 */
	@Param disabled: boolean = false
	/**
	 * 默认内容
	 */
	@BuilderParam defaultBuilder: CustomBuilder
	/**
	 * 选中变化的回调
	 */
	@Event onChange: (name: IBestStringNumber | boolean) => void = () => {}
	/**
	 * 改变前的回调
	 */
	@Event beforeChange?: (name: IBestStringNumber | boolean) => IBestAwaitable = undefined
	@Event $active: (name: IBestStringNumber | boolean) => void = () => {}

	@Local uniId: number = 0

	aboutToAppear() {
		this.uniId = this.getUniqueId()
		emitter.on(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.ITEM_CHANGE, this.group), this.uniId, (name: IBestStringNumber | boolean): Promise<void> => this.onItemChange(name))
		sleep(50).then(() => {
			this.initRadio()
		})
	}
	aboutToDisappear() {
		emitter.off(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.ITEM_CHANGE, this.group), this.uniId)
	}
	@Monitor("active", "disabled")
	initRadio() {
		emitter.emit(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.INIT_CHILDREN, this.group), this.active, this.disabled)
	}
	async onItemChange(name: IBestStringNumber | boolean) {
		let status = await handleBeforeFunction(this.beforeChange, name)
		if(!status){
			return
		}
		this.$active(name)
		this.onChange(name)
	}
	build() {
		if (this.placeDirection == Axis.Horizontal) {
			Row({ space: getSizeByUnit(this.space) }) {
				if (this.defaultBuilder) {
					this.defaultBuilder()
				}
			}
		} else {
			Column({ space: getSizeByUnit(this.space) }) {
				if (this.defaultBuilder) {
					this.defaultBuilder()
				}
			}
			.alignItems(HorizontalAlign.Start)
		}
	}
}