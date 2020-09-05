tool
class_name PowGradient
extends "res://addons/transitionAnimation/transitionGradient.gd"


func get_gradient(p_time:float) -> float:
	return pow(2, -10.0 * p_time)
