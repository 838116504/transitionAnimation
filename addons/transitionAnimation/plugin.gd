tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("TransitionAnimation", "Control", preload("transitionAnimation.gd"), get_editor_interface().get_base_control().get_icon("Control", "EditorIcons"))


func _exit_tree():
	remove_custom_type("TransitionAnimation")
