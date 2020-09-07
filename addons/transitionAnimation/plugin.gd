tool
extends EditorPlugin

var previewGen
func _enter_tree():
	add_custom_type("TransitionAnimation", "Control", preload("transitionAnimation.gd"), get_editor_interface().get_base_control().get_icon("Control", "EditorIcons"))
	previewGen = preload("previewGenerator.gd").new()
	get_editor_interface().get_resource_previewer().add_preview_generator(previewGen)


func _exit_tree():
	remove_custom_type("TransitionAnimation")
	get_editor_interface().get_resource_previewer().remove_preview_generator(previewGen)
