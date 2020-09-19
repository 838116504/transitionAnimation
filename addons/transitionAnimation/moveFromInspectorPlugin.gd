tool
extends EditorInspectorPlugin

const TransitionAnimation = preload("transitionAnimation.gd")

func can_handle(object):
	if object is TransitionAnimation:
		return true
	return false

func parse_property(object, type, path, hint, hint_text, usage):
	if type == TYPE_INT && path == "moveFrom":
		var moveFromProperty = preload("moveFromProperty.gd").new()
		add_property_editor(path, moveFromProperty)
		return true
	return false
