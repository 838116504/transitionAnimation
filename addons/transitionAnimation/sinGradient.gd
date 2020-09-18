tool
class_name SinGradient
extends "res://addons/transitionAnimation/transitionGradient.gd"

func interpolate(p_time:float) -> float:
	return (sin(p_time * PI - PI/2) + 1.0) / 2.0
