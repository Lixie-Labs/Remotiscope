extends Panel

var spinner_enabled = true
var touch_active = false

var user_fps      = 60
var reference_fps = 60
var time_scale = 1.0
var current_frame = 0

func _ready():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Spinner.enabled = spinner_enabled
	
	# Calculate time scale
	user_fps = 1.0 / delta
	time_scale = reference_fps / user_fps
	current_frame = Engine.get_frames_drawn()
