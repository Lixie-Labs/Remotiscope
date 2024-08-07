extends Node2D

var enabled = true
var opacity = 1.0

func _ready():
	pass

func _process(delta):
	# Center it
	position = get_viewport().get_visible_rect().size / Vector2(2.0, 2.0);

	# Spin it
	$Sprite.rotation += 0.1

	# Fade it
	if enabled == true:
		show()
		if opacity < 1.0:
			opacity += 0.1
	else:
		if opacity > 0.0:
			opacity -= 0.1
		else:
			hide()

	# technologic
	modulate.a = opacity
