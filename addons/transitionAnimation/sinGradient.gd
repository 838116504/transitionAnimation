tool
class_name SinGradient
extends "res://addons/transitionAnimation/transitionGradient.gd"

func get_gradient(p_time:float) -> float:
	return sin(p_time * PI - PI/2)
