# 版本记录

## 0.0.9 - 5.0.3(15)
#### 新增:
1. 新增 IBestContactAddress 联系人地址组件;
2. IBestCell 新增 arrowSize arrowColor cellPadding 属性;
3. IBestCalendar 新增 showOtherMonthDate 属性;
4. IBestCountDown 新增 onFinish 事件;
5. IBestCountTo 新增 onFinish 事件;
6. IBestDatePicker 新增 lunar 属性, 支持显示农历;
7. IBestNavbar 新增 expandSafeAreaType 属性;
8. IBestUpload 新增 imageSelectOption fileSelectOption beforeRemove 属性, onRemove onFileClick 事件; IBestUploaderFile 类型新增 uploadUrl 属性;
9. IBestTextEllipsis 新增 textFontWeight actionFontWeight 属性;
10. IBestHighLight keywords 新增 IBestHighlightKeywords 类型, 支持设置不同颜色、字体大小的高亮词;
11. IBestSteps 新增 bgColor 属性.

#### 优化:
1. IBestCell 传入rightIcon时保留箭头, 左右图标支持内置图标名;
2. 部分组件 radius 支持自定义设置位置.

#### Bug修复:
1. IBestTable 自定义表格内容时，边框线高度不一致问题;
2. IBestButton btnBorderRadius 0未生效问题;
3. IBestProgress 进度条宽度较宽时文字错位问题;
4. IBestHighlight text动态修改时，文字未同步变化问题;
5. IBestField autosize 为true时 inputAlign不生效问题.

## 0.0.7
#### 新增:
1. IBestDropdownMenu 下拉菜单组件;
2. IBestGuide 引导组件;
3. IBestToast 增加 onClosed 事件;
4. IBestCellGroup 增加 titlePadding;
5. IBestCell 增加 titleFontSize labelFontSize 属性;
6. IBestSlider 增加 customSecondButton 属性.

#### 优化:
1. IBestCascader 选项支持动态传入;
2. IBestCell 使用valueBuilder时保留箭头;
3. IBestCollapse 支持activeName切换;
4. IBestCollapseItem 优化高度获取;
5. IBestPopup 优化居中时关闭的延迟.

#### Bug修复:
1. IBestNoticeBar 在文字未超出宽度时也会自动滚动问题;
2. IBestFloatBubble 点击穿透问题.

## 0.0.6
#### 新增:
1. IBestFloatBubble 悬浮球 组件;
2. IBestCarKeyboard 车牌键盘 组件;
3. IBestCarInput 车牌输入框 组件;
4. IBestPasswordInput 增加 autoFocus showCursor highlightType 属性;
5. IBestWatermark 增加 contentInteractive 属性.

#### 优化:
1. 日历农历初一日显示为月份.

#### Bug修复:
1. IBestImagePreview 侧滑关闭后无法打开问题;
2. 修复 IBestDialog buttonSpace 不生效问题.

## 0.0.5
#### 新增:
1. IBestCountTo 数字滚动 组件;
2. IBestSkeleton 骨架屏 组件;
3. IBestSteps 步骤条 组件;
4. IBestPopup  增加  keyboardAvoidMode keyboardAvoidDistance levelMode levelUniqueId 参数;
5. IBestDialog 增加 keyboardAvoidMode 参数;
6. IBestCheckGroup、IBestRadioGroup 增加 disabled 参数.

#### Bug修复:
1. IBestActionSheet IBestDialogUtil 优化多窗口关闭;
2. IBestPasswordInput 最后一位输入问题;
3. IBestCheckBox 禁用状态在分组中失效问题;
4. IBestStepper 输入时无法限制大小问题.

## 0.0.4
#### Bug修复:
1. 部分组件报错问题。