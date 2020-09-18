tool
#class_name TransitionAnimation
extends Control

signal completed


export var animTime := 0.5
export var showDeferr := 0.0
export var hideDeferr := 0.0
export var useChildMinSize := false

enum { MODE_MOVE = 0, MODE_SCALE, MODE_MODULATE, MODE_ROTATE }
var mode := MODE_MOVE setget set_mode
var nextMode = null
enum { DIR_LEFT_TOP = 0, DIR_TOP, DIR_RIGHT_TOP, 
		DIR_LEFT, DIR_CENTER, DIR_RIGHT,
		DIR_LEFT_BOTTOM, DIR_BOTTOM, DIR_RIGHT_BOTTOM, 
		DIR_TOP_ONLY, DIR_BOTTOM_ONLY, DIR_LEFT_ONLY, DIR_RIGHT_ONLY }
var moveDir := DIR_BOTTOM_ONLY
var scaleMin := Vector2(1.0, 1.0)
var scaleMax := Vector2(0.0, 0.0)
var modulateMin := 1.0
var modulateMax := 0.0
var rotateMin := 0.0
var rotateMax := 360.0
var gradient = Object()
enum { STATE_NORMAL = 0, STATE_SHOWING, STATE_HIDING }
var state := STATE_NORMAL setget set_state
var childTemp := {}
var animCurTime := animTime
var animCurTargetValue = Vector2.ZERO
var animCurStartValue = Vector2.ZERO
var animCurDeferr := 0.0
var needHide := false
var lastVisibale := true

func _init():
	mouse_filter = MOUSE_FILTER_IGNORE

func _process(p_delta):
	if state == STATE_NORMAL:
		set_process(false)
		return
	
	if animCurTime >= animTime:
		if state == STATE_HIDING:
			hide()
		self.state = STATE_NORMAL
		return
	
	if animCurDeferr > p_delta:
		animCurDeferr -= p_delta
		return
	elif animCurDeferr > 0.0:
		p_delta -= animCurDeferr
		animCurDeferr == 0.0

	animCurTime += p_delta
	if gradient == null:
		return
	
	var value
	var ratio = clamp(animCurTime / animTime, 0.0, 1.0)
	if state == STATE_HIDING:
		value = gradient.interpolate(ratio)
	else:
		value = gradient.interpolate(1.0 - ratio)
	
	for i in get_children():
		match mode:
			MODE_MOVE:
				var move = animCurStartValue + animCurTargetValue * value
				if i is Control:
					if not childTemp.has(i.get_instance_id()):
						childTemp[i.get_instance_id()] = Vector2.ZERO
					i.set_position(i.rect_position - childTemp[i.get_instance_id()] + move)
					childTemp[i.get_instance_id()] = move
				elif i is Node2D:
					if not childTemp.has(i.get_instance_id()):
						childTemp[i.get_instance_id()] = Vector2.ZERO
					i.position = i.position - childTemp[i.get_instance_id()] + move
					childTemp[i.get_instance_id()] = move
				minimum_size_changed()
			MODE_SCALE:
				if !childTemp.has(get_instance_id()):
					childTemp[get_instance_id()] = rect_scale
				rect_scale = animCurStartValue + animCurTargetValue * value
			MODE_MODULATE:
				if !childTemp.has(get_instance_id()):
					childTemp[get_instance_id()] = modulate.a
				modulate.a = animCurStartValue + animCurTargetValue * value
			MODE_ROTATE:
				if !childTemp.has(get_instance_id()):
					childTemp[get_instance_id()] = rect_rotation
				rect_rotation = childTemp[get_instance_id()] + animCurStartValue + animCurTargetValue * value

func set_mode(p_value:int):
	if mode == p_value:
		return
	
	if state != STATE_NORMAL:
		nextMode = p_value
	else:
		mode = p_value
	property_list_changed_notify()

func set_state(p_value:int):
	if state == p_value:
		return
	
	if p_value != STATE_NORMAL:
		var needFind = get_children()
		while needFind.size() > 0:
			var child = needFind.back()
			needFind.pop_back()
			if child is get_script():
				child.state = p_value
			for i in child.get_children():
				needFind.append(i)
	
	if state == STATE_NORMAL:
		animCurTime = 0.0
		if p_value == STATE_HIDING:
			animCurDeferr = hideDeferr
		else:
			animCurDeferr = showDeferr
	elif p_value != STATE_NORMAL:
		if animCurDeferr <= 0.0:
			animCurTime = animTime - animCurTime
		else:
			animCurTime = 0.0
			if state == STATE_HIDING:
				animCurDeferr = clamp(showDeferr - (hideDeferr - animCurDeferr), 0.0, showDeferr)
			else:
				animCurDeferr = clamp(hideDeferr - (showDeferr - animCurDeferr), 0.0, hideDeferr)
	
	
	match p_value:
		STATE_NORMAL:
			var child
			match mode:
				MODE_MOVE:
					for i in childTemp.keys():
						child = instance_from_id(i)
						if child is Control:
							child.set_position(child.rect_position - childTemp[i])
						elif child is Node2D:
							child.position -= childTemp[i]
				MODE_SCALE:
					if childTemp.has(get_instance_id()):
						rect_scale = childTemp[get_instance_id()]
				MODE_MODULATE:
					if childTemp.has(get_instance_id()):
						modulate.a = childTemp[get_instance_id()]
				MODE_ROTATE:
					if childTemp.has(get_instance_id()):
						rect_rotation = childTemp[get_instance_id()]
			childTemp.clear()
			set_process(false)
			if nextMode != null:
				self.mode = nextMode
				nextMode = null
			if needHide:
				hide_without_anim()
			emit_signal("completed")
		STATE_HIDING, STATE_SHOWING:
			match mode:
				MODE_MOVE:
					animCurStartValue = Vector2.ZERO
					match moveDir:
						DIR_LEFT_TOP:
							animCurTargetValue = rect_pivot_offset
						DIR_TOP:
							animCurTargetValue = rect_pivot_offset - Vector2(rect_size.x / 2.0, 0.0)
						DIR_RIGHT_TOP:
							animCurTargetValue = rect_pivot_offset - Vector2(rect_size.x, 0.0)
						DIR_LEFT:
							animCurTargetValue = rect_pivot_offset - Vector2(0.0, rect_size.y / 2.0)
						DIR_CENTER:
							animCurTargetValue = rect_pivot_offset - Vector2(rect_size.x / 2.0, rect_size.y / 2.0)
						DIR_RIGHT:
							animCurTargetValue = rect_pivot_offset - Vector2(rect_size.x, rect_size.y / 2.0)
						DIR_LEFT_BOTTOM:
							animCurTargetValue = rect_pivot_offset - Vector2(0.0, rect_size.y)
						DIR_BOTTOM:
							animCurTargetValue = rect_pivot_offset - Vector2(rect_size.x / 2.0, rect_size.y)
						DIR_RIGHT_BOTTOM:
							animCurTargetValue = rect_pivot_offset - Vector2(rect_size.x, rect_size.y)
						DIR_TOP_ONLY:
							animCurTargetValue = Vector2(0.0, rect_pivot_offset.y)
						DIR_BOTTOM_ONLY:
							animCurTargetValue = Vector2(0.0, rect_pivot_offset.y - rect_size.y)
						DIR_LEFT_ONLY:
							animCurTargetValue = Vector2(rect_pivot_offset.x, 0.0)
						DIR_RIGHT_ONLY:
							animCurTargetValue = Vector2(rect_pivot_offset.x - rect_size.x, 0.0)
				MODE_SCALE:
					animCurStartValue = scaleMin
					animCurTargetValue = scaleMax - scaleMin
				MODE_MODULATE:
					animCurStartValue = modulateMin
					animCurTargetValue = modulateMax - modulateMin
				MODE_ROTATE:
					animCurStartValue = rotateMin
					animCurTargetValue = rotateMax - rotateMin
			set_process(true)
	state = p_value

func _set(p_property, p_value):
	match mode:
		MODE_MOVE:
			if p_property == "moveDir":
				moveDir = p_value
				return true
		MODE_SCALE:
			if p_property == "scaleMin":
				scaleMin = p_value
				return true
			if p_property == "scaleMax":
				scaleMax = p_value
				return true
		MODE_MODULATE:
			if p_property == "modulateMin":
				modulateMin = p_value
				return true
			if p_property == "modulateMax":
				modulateMax = p_value
				return true
		MODE_ROTATE:
			if p_property == "rotateMin":
				rotateMin = p_value
				return true
			if p_property == "rotateMax":
				rotateMax = p_value
				return true
	
	if p_property == "mode":
		self.mode = p_value
	elif p_property == "gratient":
		gradient = p_value
	else:
		return false
	return true

func _get(p_property):
	if p_property == "mode":
		return mode
	match mode:
		MODE_MOVE:
			if p_property == "moveDir":
				return moveDir
		MODE_SCALE:
			if p_property == "scaleMin":
				return scaleMin
			if p_property == "scaleMax":
				return scaleMax
		MODE_MODULATE:
			if p_property == "modulateMin":
				return modulateMin
			if p_property == "modulateMax":
				return modulateMax
		MODE_ROTATE:
			if p_property == "rotateMin":
				return rotateMin
			if p_property == "rotateMax":
				return rotateMax
	if p_property == "gradient":
		return gradient
	return null

func _get_property_list():
	var ret = []
	ret.append({"name":"mode", "type":TYPE_INT, "hint":PROPERTY_HINT_ENUM, "hint_string":"move, scale, modulate, rotate", "usage":PROPERTY_USAGE_DEFAULT})
	match mode:
		MODE_MOVE:
			ret.append({"name":"moveDir", "type":TYPE_INT, "hint":PROPERTY_HINT_ENUM, 
					"hint_string":"DIR_LEFT_TOP,DIR_TOP,DIR_RIGHT_TOP,DIR_LEFT,DIR_CENTER,DIR_RIGHT,DIR_LEFT_BOTTOM, DIR_BOTTOM, DIR_RIGHT_BOTTOM,DIR_TOP_ONLY,DIR_BOTTOM_ONLY,DIR_LEFT_ONLY,DIR_RIGHT_ONLY",
					"usage":PROPERTY_USAGE_DEFAULT})
		MODE_SCALE:
			ret.append({"name":"scaleMin", "type":TYPE_VECTOR2, "usage":PROPERTY_USAGE_DEFAULT})
			ret.append({"name":"scaleMax", "type":TYPE_VECTOR2, "usage":PROPERTY_USAGE_DEFAULT})
		MODE_MODULATE:
			ret.append({"name":"modulateMin", "type":TYPE_REAL, "usage":PROPERTY_USAGE_DEFAULT})
			ret.append({"name":"modulateMax", "type":TYPE_REAL, "usage":PROPERTY_USAGE_DEFAULT})
		MODE_ROTATE:
			ret.append({"name":"rotateMin", "type":TYPE_REAL, "usage":PROPERTY_USAGE_DEFAULT})
			ret.append({"name":"rotateMax", "type":TYPE_REAL, "usage":PROPERTY_USAGE_DEFAULT})
	ret.append({"name":"gradient", "type":TYPE_OBJECT, "hint":PROPERTY_HINT_RESOURCE_TYPE, "hint_string":"TransitionGradient, Curve"})
	return ret

func _notification(what):
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if lastVisibale == visible:
				return
			
			if state != STATE_NORMAL:
				visible = true
				return
			
			self.state = STATE_SHOWING if visible else STATE_HIDING
			lastVisibale = true
			needHide = !visible
			visible = true


func _get_minimum_size():
	if not useChildMinSize:
		return Vector2.ZERO
	
	var ret := Vector2.ZERO
	var end
	for i in get_children():
		end = i.rect_position + i.get_combined_minimum_size()
		if ret.x < end.x:
			ret.x = end.x
		if ret.y < end.y:
			ret.y = end.y
	return ret

func show():
	self.state = STATE_SHOWING
	needHide = false
	lastVisibale = true
	visible = true

func hide():
	self.state = STATE_HIDING
	needHide = true
	lastVisibale = true
	visible = true

func show_without_anim():
	lastVisibale = true
	visible = true
	needHide = false
	state = STATE_NORMAL

func hide_without_anim():
	lastVisibale = false
	visible = false
	needHide = false
	state = STATE_NORMAL

