extends VBoxContainer

func close_window():
	get_parent().window_visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CloseButton_button_up():
	close_window()
	pass # Replace with function body.
