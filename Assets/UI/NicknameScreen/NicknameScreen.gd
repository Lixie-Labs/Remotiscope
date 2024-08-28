extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SaveButton_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		if event.pressed == true:
			print("SAVE")
			var new_nickname = $Contents/NicknameEntry/NicknameBox.text
			
			if len(new_nickname) > 60:
				new_nickname = str(new_nickname).substr(0,60)
				new_nickname = new_nickname.replace("|","")
				new_nickname = new_nickname.replace("~","")
			
			get_tree().root.get_node("EmotiscopeApp/Screen").current_device_nickname = new_nickname
			get_tree().root.get_node("EmotiscopeApp/Screen").wstx("EMO~set_nickname|"+new_nickname)
			
			get_tree().root.get_node("EmotiscopeApp/Window").window_visible = false


func _on_CloseButton_pressed():
	get_tree().root.get_node("EmotiscopeApp/Window").window_visible = false
