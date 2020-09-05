tool
class_name CosPowGradient
extends "res://addons/transitionAnimation/transitionGradient.gd"


func get_gradient(p_time:float) -> float:
	return 1.0 - cos(p_time * 20.0) * pow(2, -10.0 * p_time)
