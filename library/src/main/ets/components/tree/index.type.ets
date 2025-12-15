import { IBestStringNumber } from "@ibestservices/ibest-ui-v2"

export class IBestTreeData{
    $treeNodeId?: number
    label: ResourceStr = ''
    value?: IBestStringNumber
    isLeaf?: boolean
    disabled?: boolean
    children?: IBestTreeData[]
}

@ObservedV2
export class IBestTreeNodeData extends IBestTreeData{
    groupId: string = ''
    firstLevelId: number = 0
    $treeNodeId: number
    level: number = 0
    @Trace selected: boolean = false
    @Trace isIndeterminate: boolean = false
    @Trace children: IBestTreeNodeData[]
    switchExpand: (val: boolean) => void = () => {}
    append: (data: IBestTreeData) => void = () => {}
    remove: () => void = () => {}
    constructor(data: IBestTreeData) {
        super()
        this.label = data.label
        this.$treeNodeId = data.$treeNodeId ?? 0
        this.value = data.value ?? ''
        this.disabled = data.disabled ?? false
        this.isLeaf = data.isLeaf ?? false
        this.selected = false
        this.isIndeterminate = false
        this.children = data.children ? data.children.map(item => new IBestTreeNodeData(item)) : []
    }
}

export class IBestTreeController{
    /**
     * 设置选中节点，仅selectType不为空时可用
     */
    setCheckedNodes: (keys: IBestStringNumber[]) => void = () => {}
    /**
     * 获取选中节点，仅selectType不为空时可用
     */
    getCheckedNodes: () => IBestTreeData[] = () => []
    /**
     * 重置选中，仅selectType不为空时可用
     */
    reset: () => void = () => {}
    /**
     * 添加节点
     */
    append: (data: IBestTreeData, parentNode: IBestTreeNodeData) => void = () => {}
    /**
     * 移除节点
     */
    remove: (node: IBestTreeNodeData) => void = () => {}
}