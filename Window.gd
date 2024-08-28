extends Panel

var window_visible = false
var window_opacity = 0.0
var window_opacity_target = 0.0

func _ready():
	pass # Replace with function body.

var iter = 0
func _process(delta):
	if window_visible == true:
		window_opacity_target = 1.0
	else:
		if window_opacity_target != 0.0:
			window_opacity_target = 0.0
			for child in get_children():
				child.hide()
	
	if window_opacity < 0.01:
		self.hide()
	else:
		self.show()
		
	window_opacity = window_opacity_target*0.3 + window_opacity*0.7
	
	self.modulate.a = window_opacity
	get_node("../Screen/Header").modulate.a = 1.0-window_opacity
	
	iter += 1
	if iter >= 100:
		iter = 0
		#window_visible = !window_visible


func _on_CloseButton_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		print("CLOSE")
		window_visible = false
