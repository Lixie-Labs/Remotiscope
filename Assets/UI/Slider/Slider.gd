extends Panel

var config_value_smooth = 0.0
var follow_speed = 0.75

var state = 0.0
var state_smooth = 0.0

var scroll_lock_pos = -1.0

var last_drag     = Vector2.ZERO
var drag_distance = Vector2.ZERO

var track_length = 0.0

func _ready():
	pass

func _process(delta):
	track_length = self.rect_size.y-120
	
	if abs(get_parent().config_value - config_value_smooth) > 0.01:
		config_value_smooth = config_value_smooth * (1.0-follow_speed) + get_parent().config_value * follow_speed
	else:
		config_value_smooth = get_parent().config_value
	
	if abs(state - state_smooth) > 0.01:
		state_smooth = state_smooth * 0.75 + state * 0.25
	else:
		state_smooth = state

	$Knob.margin_top = (1.0-config_value_smooth) * (self.rect_size.y-$Knob.rect_size.y)
	
	self.self_modulate = Color.from_hsv(0.0, 0.0, config_value_smooth*0.75+0.25)

	$Knob/GripLight.modulate.a = state_smooth
	$Knob/GripHole.modulate.a  = 1.0-state_smooth
	
	if scroll_lock_pos != -1.0:
		get_parent().get_parent().get_parent().scroll_horizontal = scroll_lock_pos

func _on_Slider_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		if event.pressed:
			get_tree().root.get_child(0).touch_active = true
			print("Pointer Down: "+get_parent().config_pretty_name)
			last_drag = event.position
			state = 1.0
			
		else:
			print("Pointer Up: "+get_parent().config_pretty_name)
			get_tree().root.get_child(0).touch_active = false
			state = 0.0
			scroll_lock_pos = -1.0
			
			
	elif event is InputEventScreenDrag:
		get_tree().root.get_child(0).touch_active = true
		var current_pos = event.position
		drag_distance = current_pos - last_drag
		last_drag = current_pos

		drag_distance *= Vector2(-1.0, -1.0)
		
		var shifted_value = get_parent().config_value + (drag_distance.y / track_length)

		if shifted_value > 1.0:
			shifted_value = 1.0
		elif shifted_value < 0.0:
			shifted_value = 0.0
			
		get_parent().config_value = shifted_value
		
		get_tree().root.get_node("EmotiscopeApp/Screen").wstx("EMO~set_config|"+get_parent().name+"|"+str(shifted_value))

		scroll_lock_pos = -1.0
		if abs(drag_distance.y) > 4.0:
			scroll_lock_pos = get_parent().get_parent().get_parent().scroll_horizontal
