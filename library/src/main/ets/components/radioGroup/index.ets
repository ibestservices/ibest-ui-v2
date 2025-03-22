import { emitter } from '../../utils/EventEmitter'
import { COMPONENT_NAME, RADIO_GROUP_EVENT_NAME } from './index.type'
import { convertDimensionsWidthUnit, getEventName, getSizeByUnit, sleep } from '../../utils/utils'
import { IBestStringNumber } from '../../model/Global.type'

@ComponentV2
export struct IBestRadioGroup {
	/**
	 * 分组标识
	 */
	@Param @Require @Once group: string
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
	 * 默认内容
	 */
	@BuilderParam defaultBuilder: CustomBuilder
	/**
	 * 选中变化的回调
	 */
	@Event onChange: (name: IBestStringNumber | boolean) => void = () => {}
	@Event $active: (name: IBestStringNumber | boolean) => void = () => {}

	@Local uniId: number = 0

	aboutToAppear() {
		this.uniId = this.getUniqueId()
		if(this.group){
			emitter.on(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.ITEM_CHANGE, this.group), this.uniId, (name: IBestStringNumber | boolean): void => this.onItemChange(name))
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
	@Monitor("active")
	initRadio() {
		emitter.emit(getEventName(COMPONENT_NAME, RADIO_GROUP_EVENT_NAME.INIT_CHILDREN, this.group), this.active)
	}
	onItemChange(name: IBestStringNumber | boolean) {
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