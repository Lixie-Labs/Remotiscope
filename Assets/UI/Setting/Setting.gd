extends Panel

export var config_pretty_name = "Setting"
export var config_type = "f32"
export var config_ui_type = "s"
export var config_value = 0.0

var last_drag     = Vector2.ZERO
var drag_distance = Vector2.ZERO

func set_setting_name(new_name):
	$Label.text = "  " + str(new_name).to_upper() + "  "

func set_slider_value(new_value):
	config_value = new_value
		
	var setting_width = self.rect_size.x
	var min_x = 6
	var max_x = setting_width - 130
	var span = max_x - min_x
	
	$Slider/Knob.rect_position.x = min_x + span*config_value
	
	$Slider/Knob.text = str(round(new_value*100))+"%"
	
	if new_value < 0.5:
		$Toggle/Knob.text = "OFF"
	else:
		$Toggle/Knob.text = "ON"


	$Slider/Backdrop.modulate.a = new_value
	$Toggle/Backdrop.modulate.a = new_value
	
	var color_shift = 0.75 + new_value*0.25
	#$Slider/Knob.modulate = Color(color_shift, color_shift, color_shift)
	$Toggle/Knob.modulate = Color(color_shift, color_shift, color_shift)


func _on_Setting_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		if event.pressed == true:
			print("Pointer Down: "+config_pretty_name)
			get_tree().root.get_child(0).touch_active = true
			last_drag = event.position
			
		elif event.pressed == false:
			print("Pointer Up: "+config_pretty_name)
			get_tree().root.get_child(0).touch_active = false
		
		else:
			print("UNKNOWN EVENT!")


	elif event is InputEventScreenDrag:
		var current_pos = event.position
		drag_distance = current_pos - last_drag
		last_drag = current_pos

		#drag_distance *= Vector2(-1.0, -1.0)
		
		var setting_width = self.rect_size.x
		var min_x = 6
		var max_x = setting_width - 130
		var track_length = max_x - min_x
		
		var shifted_value = config_value + (drag_distance.x / track_length)

		if shifted_value > 1.0:
			shifted_value = 1.0
		elif shifted_value < 0.0:
			shifted_value = 0.0
			
		config_value = shifted_value
		
		if config_ui_type == "t":
			if shifted_value > 0.5:
				shifted_value = 1.0
			else:
				shifted_value = 0.0
		
		get_tree().root.get_node("EmotiscopeApp/Screen").wstx("EMO~set_config|"+name+"|"+str(shifted_value))
		get_tree().root.get_node("EmotiscopeApp/Screen/Contents/ScreenPreview").update_preview()

		#if abs(drag_distance.y) > 4.0:
		#	scroll_lock_pos = get_parent().get_parent().get_parent().scroll_horizontal

var value_smooth = 0
func run_graphics():
	var setting_width = self.rect_size.x
	var min_x = 6
	var max_x = setting_width - 130
	var span = max_x - min_x
	
	value_smooth = value_smooth * 0.7 + current_value * 0.3
	$Toggle/Knob.rect_position.x = min_x + span*value_smooth
	
	set_slider_value(config_value)

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
	
	set_slider_value(0.0)

var current_value = 0
func _process(delta):
	if config_value != current_value:
		set_slider_value(config_value)
		current_value = config_value
	
	run_graphics()

var cancel_toggle = false
var toggle_pressed = false
func _on_ToggleKnob_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		if event.pressed == true:
			toggle_pressed = true
		if event.pressed == false:
			if toggle_pressed == true:
				toggle_pressed = false
				print("Pointer Up: "+config_pretty_name)
				get_tree().root.get_child(0).touch_active = false
				
				if cancel_toggle == true:
					cancel_toggle = false
				else:
					if config_value == 0.0:
						config_value = 1.0
					elif config_value == 1.0:
						config_value = 0.0
					
					get_tree().root.get_node("EmotiscopeApp/Screen").wstx("EMO~set_config|"+name+"|"+str(config_value))
	
	elif event is InputEventScreenDrag:
		cancel_toggle = true
