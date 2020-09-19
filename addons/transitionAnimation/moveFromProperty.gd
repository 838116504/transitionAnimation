tool
extends EditorProperty

const icons = [ preload("moveFromLeftTopIcon.png"), preload("moveFromCenterTopIcon.png"), preload("moveFromRightTopIcon.png"), 
		preload("moveFromLeftCenterIcon.png"), preload("moveFromCenterIcon.png"), preload("moveFromRightCenterIcon.png"),
		preload("moveFromLeftBottomIcon.png"), preload("moveFromCenterBottomIcon.png"), preload("moveFromRightBottomIcon.png"),
		preload("moveFromTopIcon.png"), preload("moveFromBottomIcon.png"), preload("moveFromLeftIcon.png"), preload("moveFromRightIcon.png")]
const texts = [ "Left Top", "Center Top", "Right Top", "Left Center", "Center", "Right Center",
		"Left Bottom", "Center Bottom", "Right Bottom", "Top", "Bottom", "Left", "Right"]
var assign := OptionButton.new()
var isUnknow := false
var isUpdate := false

func set_value(p_value):
	if p_value < 0 || p_value >= icons.size():
		if not isUnknow:
			isUnknow = true
			assign.add_item("Unknow")
		isUpdate = true
		assign.select(icons.size())
		isUpdate = false
	else:
		if isUnknow:
			isUnknow = false
			assign.clear()
			for i in icons.size():
				assign.add_icon_item(icons[i], texts[i], i)
		isUpdate = true
		assign.select(p_value)
		isUpdate = false

func _init():
	assign.size_flags_horizontal = SIZE_EXPAND_FILL
	assign.flat = true
	assign.clip_text = true
	for i in icons.size():
		assign.add_icon_item(icons[i], texts[i], i)
	assign.connect("item_selected", self, "_on_assign_item_selected")
	add_child(assign)
	add_focusable(assign)

func _on_assign_item_selected(p_index):
	if isUpdate:
		return
	emit_changed(get_edited_property(), p_index)

func update_property():
	var newValue = get_edited_object()[get_edited_property()]
	set_value(newValue)
