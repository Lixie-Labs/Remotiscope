extends Label

func spawn_mode_screen():
	get_node("../../../Window/ModeScreen").show()
	get_node("../../../Window").window_visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CurrentMode_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		if event.pressed == true:
			spawn_mode_screen()
	pass # Replace with function body.
