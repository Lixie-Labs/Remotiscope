extends VBoxContainer

var mode_name = "Mode Name"
var mode_index = 0

func set_mode_button_name(new_name):
	mode_name = new_name
	$Name.text = str(new_name).to_upper()
	self.name = new_name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ModeButton_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		if event.pressed == true:
			print("CLICK")
			get_tree().root.get_node("EmotiscopeApp/Screen").wstx("EMO~set_config|Current Mode|"+str(mode_index))
			get_tree().root.get_node("EmotiscopeApp/Window").window_visible = false
