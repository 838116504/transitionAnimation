tool
class_name TransitionGradient
extends Resource

func get_class():
	return get_class_static()

func get_class_name():
	return get_class_static()

static func get_class_static():
	return "TransitionGradient"

func get_gradient(p_time:float) -> float:
	return p_time
