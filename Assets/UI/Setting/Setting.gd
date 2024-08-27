tool
extends Panel

export var setting_type = 0

func set_slider_value(new_value):	
	var full_width = self.rect_size.x;
	print(full_width)
	var new_width = full_width*new_value
	$Slider/Value.rect_size.x = new_width

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_slider_value(0.1)
	pass
