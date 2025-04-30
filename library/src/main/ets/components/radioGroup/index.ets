import { emitter } from '../../utils/EventEmitter'
import { COMPONENT_NAME, RADIO_GROUP_EVENT_NAME } from './index.type'
import { convertDimensionsWidthUnit, getEventName, getSizeByUnit, sleep } from '../../utils/utils'
import { IBestStringNumber } from '../../model/Global.type'

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
	@Event beforeChange?: (name: IBestStringNumber | boolean) => Promise<boolean> | boolean = undefined
	@Event $active: (name: IBestStringNumber | boolean) => void = () => {}

	@Local uniId: number = 0

	aboutToAppear() {
		this.uniId = this.getUniqueId()
		if(this.group){
			emitter.on(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.ITEM_CHANGE, this.group), this.uniId, (name: IBestStringNumber | boolean): Promise<void> => this.onItemChange(name))
			sleep(50).then(() => {
				this.initRadio()
			})
		}
	}
	aboutToDisappear() {
		if(this.group){
			emitter.off(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.ITEM_CHANGE, this.group), this.uniId)
		}
	}
	@Monitor("active", "disabled")
	initRadio() {
		emitter.emit(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.INIT_CHILDREN, this.group), this.active, this.disabled)
	}
	async handleBeforeClose(name: IBestStringNumber | boolean) {
		let status = true
		try {
			if (this.beforeChange) {
				status = await this.beforeChange(name)
			}
		} catch (e) {
			status = false
		}
		return status
	}
	async onItemChange(name: IBestStringNumber | boolean) {
		let status = await this.handleBeforeClose(name)
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