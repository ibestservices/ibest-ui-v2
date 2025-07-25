import { emitter } from '../../utils/EventEmitter';
import { convertDimensionsWidthUnit, getEventName, getSizeByUnit, sleep } from '../../utils/utils';
import { CHECKBOX_GROUP_EVENT_NAME, COMPONENT_NAME, IBestCheckboxGroupController } from './index.type';
import { IBestAwaitable, IBestStringNumber } from '../../model/Global.type';

@ComponentV2
export struct IBestCheckboxGroup {
	/**
	 * 分组id
	 */
	@Param @Require group: IBestStringNumber
	/**
	 * 最大可选数量 默认0是都可选
	 */
	@Param max: number = 0
	/**
	 * 激活的标识列表
	 */
	@Param @Require activeList: IBestStringNumber[]
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
	 * 实例控制器
	 */
	@Param controller: IBestCheckboxGroupController = new IBestCheckboxGroupController()
	/**
	 * 选中变化的回调
	 */
	@Event onChange: (checkedItemNames: IBestStringNumber[]) => void = () => {}
	/**
	 * 改变前回调
     */
	@Event beforeChange?: (checkedItemNames: IBestStringNumber[]) => IBestAwaitable = undefined
	@Event $activeList: (actives: IBestStringNumber[]) => void = () => {}

	@Local uniId: number = 0
	@Local allCheckNames: IBestStringNumber[] = []
	
	aboutToAppear() {
		this.uniId = this.getUniqueId()
		this.controller.toggleAll = (isSelectAll?: boolean): void => this.toggleAll(isSelectAll)
		if (this.group) {
			emitter.on(getEventName(COMPONENT_NAME, CHECKBOX_GROUP_EVENT_NAME.GET_ALL_NAME, this.group), this.uniId, (name: IBestStringNumber): void => this.getAllNames(name))
			emitter.on(getEventName(COMPONENT_NAME, CHECKBOX_GROUP_EVENT_NAME.ITEM_CHANGE, this.group), this.uniId, (name: IBestStringNumber, checked: boolean): Promise<void> => this.onItemChange(name, checked))
			sleep(50).then(() => {
				this.initChildren()
				this.handleMaxChange()
			})
		}
	}
	aboutToDisappear() {
		if(this.group){
			emitter.off(getEventName(COMPONENT_NAME, CHECKBOX_GROUP_EVENT_NAME.GET_ALL_NAME, this.group), this.uniId)
			emitter.off(getEventName(COMPONENT_NAME, CHECKBOX_GROUP_EVENT_NAME.ITEM_CHANGE, this.group), this.uniId)
		}
	}
	getAllNames(name: IBestStringNumber){
		if(!this.allCheckNames.includes(name)){
			this.allCheckNames.push(name)
		}
	}
	@Monitor("disabled")
	initChildren() {
		emitter.emit(getEventName(COMPONENT_NAME, CHECKBOX_GROUP_EVENT_NAME.INIT_CHILDREN, this.group), this.activeList, this.disabled)
	}
	@Monitor("activeList", "activeList.length")
	activeChange(){
		this.initChildren()
		this.handleMaxChange()
	}
	async handleBeforeClose(checkedNames: IBestStringNumber[]) {
		let status = true
		try {
			if (this.beforeChange) {
				status = await this.beforeChange(checkedNames)
			}
		} catch (e) {
			status = false
		}
		return status
	}
	// 选项变化
	async onItemChange(name: IBestStringNumber, checked: boolean) {
		let checkedNames: IBestStringNumber[] = [...this.activeList]
		if(checked){
			let index = this.activeList.indexOf(name)
			if(index == -1){
				checkedNames.push(name)
			}
		}else {
			checkedNames = checkedNames.filter(item => item !== name)
		}
		let status = await this.handleBeforeClose(checkedNames)
		if(!status){
			this.$activeList([...this.activeList])
			return
		}
		this.$activeList(checkedNames)
		this.onChange(checkedNames)
		this.handleMaxChange()
	}
	// 当最大数量变化时
	@Monitor("max")
	handleMaxChange() {
		this.max > 0 &&
		emitter.emit(getEventName(COMPONENT_NAME, CHECKBOX_GROUP_EVENT_NAME.ON_MAX_CHANGE, this.group), {
			max: this.max,
			checkedList: this.activeList
		})
	}
	// 全选与反选
	toggleAll(isSelectAll?: boolean) {
		let arr: IBestStringNumber[] = []
		if(typeof isSelectAll == 'boolean'){
			if(isSelectAll){
				arr = this.allCheckNames
				this.$activeList(arr)
			}else {
				this.$activeList([])
			}
		}else{
			arr = this.allCheckNames.filter(item => !this.activeList.includes(item))
			this.$activeList(arr)
		}
		this.onChange(arr)
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