interface IBestCollapseColorType {
    bgColor: ResourceColor
    titleColor: ResourceColor
    iconColor: ResourceColor
    valueColor: ResourceColor
    rightIconColor: ResourceColor
    activeBg: ResourceColor
    borderColor: ResourceColor
}

export const IBestCollapseColor: IBestCollapseColorType = {
    bgColor: $r("app.color.ibest_collapse_background"),
    titleColor: $r("app.color.ibest_collapse_title_color"),
    iconColor: $r("app.color.ibest_collapse_icon_color"),
    valueColor: $r("app.color.ibest_collapse_value_color"),
    rightIconColor: $r("app.color.ibest_gray_6"),
    activeBg: $r("app.color.ibest_active_color"),
    borderColor: $r("app.color.ibest_collapse_border_color")
}