extends Panel

var nickname = "emotiscope"
var ip_address = "0.0.0.0"
var firmware_version = "0.0.0"
var last_check_in = "never"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Rows/DeviceName.text = nickname
	$Rows/Columns/IPAddress.text = ip_address
	$Rows/Columns/FirmwareVersion.text = firmware_version
	$Rows/Columns/LastCheckIn.text = last_check_in


func _on_Device_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		if event.pressed == true:
			get_tree().root.get_child(0).get_child(0).current_device_ip = ip_address
			get_tree().root.get_child(0).get_child(0).current_device_nickname = nickname
			print("NEW DEVICE IP: "+ip_address)
			
			get_tree().root.get_child(0).get_child(0).ws_client_connected = false
			get_tree().root.get_child(0).get_child(0).ws_client.disconnect_from_host()
			get_tree().root.get_child(0).get_child(0).connect_to_websocket()
			get_tree().root.get_child(0).get_node("Window").window_visible = false
