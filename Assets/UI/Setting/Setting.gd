extends Panel

export var config_pretty_name = "Setting"
export var config_type = "f32"
export var config_ui_type = "s"
export var config_value = 0.0

var value = 0

func set_setting_name(new_name):
	$Label.text = "  " + str(new_name).to_upper() + "  "

func set_slider_value(new_value):
	value = new_value
	
	var setting_width = self.rect_size.x
	var min_x = 6
	var max_x = setting_width - 130
	var span = max_x - min_x
	
	$Slider/Knob.rect_position.x = min_x + span*value
	$Toggle/Knob.rect_position.x = min_x + span*value
	
	$Slider/Knob.text = str(round(new_value*100))+"%"
	
	if round(new_value) == 1.0:
		$Toggle/Knob.text = "ON"
	else:
		$Toggle/Knob.text = "OFF"

	$Slider/Backdrop.modulate.a = new_value
	$Toggle/Backdrop.modulate.a = new_value
	
	var color_shift = 0.75 + new_value*0.25
	#$Slider/Knob.modulate = Color(color_shift, color_shift, color_shift)
	$Toggle/Knob.modulate = Color(color_shift, color_shift, color_shift)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Slider.hide()
	$Toggle.hide()

	if config_ui_type == "s":
		$Slider.show()
		$Toggle.hide()
	elif config_ui_type == "t":
		$Slider.hide()
		$Toggle.show()


var value_set = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value_set += 0.025
	set_slider_value(config_value)
