import { IBestStringNumber } from '../../model/Global.type'
import { emitter } from '../../utils/EventEmitter'
import { getEventName } from '../../utils/utils'
import { IBestCollapseColor } from './color'
import { COLLAPSE_EVENT_NAME, IBestCollapseItemData, COMPONENT_NAME, IBestCollapseController, ToggleOption } from './index.type'

@ComponentV2
export struct IBestCollapse {
    /**
     * 分组id
     */
    @Param @Require groupId: IBestStringNumber
    /**
     * 当前展开面板的name
     */
    @Param @Require activeName: IBestStringNumber | IBestStringNumber[]
    /**
     * 是否开启手风琴模式
     */
    @Param accordion: boolean = false
    /**
     * 是否显示外边框
     */
    @Param isShowBorder: boolean = true
	/**
	 * 组件实例
	 */
	@Param controller: IBestCollapseController = new IBestCollapseController()
    /**
     * 默认内容
     */
    @BuilderParam defaultBuilder: CustomBuilder
    /**
     * 监听面板状态变化
     */
    @Event onChange: (name: IBestStringNumber | IBestStringNumber[]) => void = () => {}
	@Event $activeName: (name: IBestStringNumber | IBestStringNumber[]) => void = () => {}

	@Local uniId: number = 0
    @Local allCollapseItem: IBestCollapseItemData[] = []

    aboutToAppear(): void {
        this.uniId = this.getUniqueId()
        this.controller.toggleAll = (option?: boolean | ToggleOption): void => this.toggleAll(option)
        emitter.on(getEventName(COMPONENT_NAME, COLLAPSE_EVENT_NAME.GET_ALL_ITEM_NAME, this.groupId), this.uniId, (name: IBestStringNumber, disabled: boolean): void => this.getAllNames(name, disabled))
        emitter.on(getEventName(COMPONENT_NAME, COLLAPSE_EVENT_NAME.ITEM_STATE_CHANGE, this.groupId), this.uniId, (name: IBestStringNumber, isExpand: boolean): void => this.setName(name, isExpand))
    }
    onDidBuild(): void {
        setTimeout(() => {
            this.initItem()
        }, 0)
    }
    aboutToDisappear(): void {
        emitter.off(getEventName(COMPONENT_NAME, COLLAPSE_EVENT_NAME.GET_ALL_ITEM_NAME, this.groupId), this.uniId)
        emitter.off(getEventName(COMPONENT_NAME, COLLAPSE_EVENT_NAME.ITEM_STATE_CHANGE, this.groupId), this.uniId)
    }

    initItem(name?: IBestStringNumber | IBestStringNumber[]){
		name = name ?? this.activeName
        emitter.emit(getEventName(COMPONENT_NAME, COLLAPSE_EVENT_NAME.INIT_ITEM, this.groupId), name)
    }

    getAllNames(name: IBestStringNumber, disabled: boolean){
        if(!this.allCollapseItem.some(e => e.name == name)){
            this.allCollapseItem.push({name, disabled})
        }
    }

    setName(name: IBestStringNumber, isExpand: boolean){
        if(this.accordion){ // 手风琴模式
			let activeName = this.activeName != undefined && !isExpand ? "" : name
			console.log("手风琴模式", activeName)
            this.$activeName(activeName)
            this.initItem(activeName)
			this.onChange(activeName)
        }else{
			let arr: IBestStringNumber[] = []
            if(typeof this.activeName == 'string'){
				arr = this.activeName.split(" ")
            }else if(typeof this.activeName == 'number'){
				arr = [this.activeName]
            }
            let index: number = arr.indexOf(name)
            if(index > -1){
				arr.splice(index, 1)
            }else{
				arr.push(name)
            }
			this.$activeName(arr)
			this.onChange(arr)
        }
    }

    toggleAll(option?: boolean | ToggleOption){
        if(this.accordion){
            return
        }
        let actives = Array.isArray(this.activeName) ? this.activeName : [this.activeName]
		let activeName: IBestStringNumber[] = []
        if(option == undefined){    // 切换
			console.log("切换", JSON.stringify(actives))
			activeName = this.allCollapseItem.filter((e: IBestCollapseItemData) => !actives.includes(e.name)).map((e: IBestCollapseItemData) => e.name)
        }else if(typeof option == 'boolean'){
			activeName = option ? this.allCollapseItem.map((e: IBestCollapseItemData) => e.name) : []
        }else{
            let disabledArr = this.allCollapseItem.filter(e => actives.includes(e.name) && e.disabled)
            let arr: IBestCollapseItemData[] = []
            if(option.skipDisabled){
                arr = this.allCollapseItem.filter((e: IBestCollapseItemData) => !e.disabled)
            }
            arr = option.expanded == undefined ? arr.filter((e: IBestCollapseItemData) => !actives.includes(e.name)) : option.expanded ? arr : []
            if(option.skipDisabled){
                arr = arr.concat(disabledArr)
            }
			activeName = arr.map((e: IBestCollapseItemData) => e.name)
        }
		this.$activeName(activeName)
        this.onChange(activeName)
        this.initItem(activeName)
    }
    build() {
        Column(){
            if(this.defaultBuilder){
                this.defaultBuilder()
            }
        }
        .border(this.isShowBorder ? { width:{top: 1, bottom: 1}, color: IBestCollapseColor.borderColor } : {})
    }
}