tool
extends EditorPlugin

var previewGen
var moveFromInspectorPlugin

func _enter_tree():
	add_custom_type("TransitionAnimation", "Control", preload("transitionAnimation.gd"), get_editor_interface().get_base_control().get_icon("Control", "EditorIcons"))
	previewGen = preload("previewGenerator.gd").new()
	get_editor_interface().get_resource_previewer().add_preview_generator(previewGen)
	moveFromInspectorPlugin = preload("moveFromInspectorPlugin.gd").new()
	add_inspector_plugin(moveFromInspectorPlugin)


func _exit_tree():
	remove_custom_type("TransitionAnimation")
	get_editor_interface().get_resource_previewer().remove_preview_generator(previewGen)
	remove_inspector_plugin(moveFromInspectorPlugin)
