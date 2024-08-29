extends AcceptDialog

func show_error(window_title, error):
	self.window_title = "ERROR: "+window_title
	self.dialog_text = error
	show()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
