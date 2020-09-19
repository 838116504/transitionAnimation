tool
extends EditorResourcePreviewGenerator

const HANDLE_TYPE = preload("transitionGradient.gd")
const SCALE = 3.0


func generate(p_from:Resource, p_size:Vector2) -> Texture:
	if not p_from is HANDLE_TYPE:
		return Object()
	
	return _draw_preview(p_from, p_size)

func _draw_preview(p_gradient:Resource, p_size:Vector2) -> Texture:
	p_size = p_size * SCALE
	var pixelW = 1.0 / p_size.x
	var maxY
	var minY
	var values = []
	values.resize(p_size.x)
	for i in p_size.x:
		values[i] = p_gradient.interpolate(i * pixelW)
		if !minY || values[i] < minY:
			minY = values[i]
		if !maxY || values[i] > maxY:
			maxY = values[i]
	
	var pixelH = float(maxY - minY) / p_size.y
	var img = Image.new()
	img.create(p_size.x, p_size.y, false, Image.FORMAT_RGB8)
	img.fill(Color(1.0, 1.0, 1.0))
	var lineColor = Color(0.0, 0.0, 0.0)
	if pixelH > 0.0:
		img.lock()
		var temp
		for i in values.size():
			temp = round((maxY - values[i]) / pixelH)
			if temp >= 1.0:
				img.set_pixel(i, temp - 1, lineColor)
			if temp >= 0.0 && temp < p_size.y:
				img.set_pixel(i, temp, lineColor)
			if temp < p_size.y - 1.0:
				img.set_pixel(i, temp + 1, lineColor)
		img.unlock()
	
	img.resize(p_size.x / SCALE, p_size.y / SCALE, Image.INTERPOLATE_LANCZOS)
	
	var ret = ImageTexture.new()
	ret.create_from_image(img)
	
	return ret

func handles(p_type) -> bool:
	if p_type == "Resource":
		return true
	return false
