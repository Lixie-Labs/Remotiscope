extends VBoxContainer

export var config_pretty_name = "Setting"
export var config_name = "setting"
export var config_value = 1.0
export var config_type = "slider"

func _ready():
	$Label.text = config_pretty_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
