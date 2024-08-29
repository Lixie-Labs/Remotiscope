extends Panel

var nickname = "null"
var ip_address = "null"
var firmware_version = "0.0.0"
var last_check_in = "needs update"
var supported = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var iter = 0
func _process(delta):
	if get_tree().root.get_child(0).get_child(0).ws_client_connected == true:
		$Rows/DeviceName.text = nickname
		$Rows/Columns/IPAddress.text = ip_address
		$Rows/Columns/FirmwareVersion.text = firmware_version
		$Rows/Columns/LastCheckIn.text = last_check_in
		
		var major_version = int(firmware_version.split(".")[0])
		
		if major_version >= 2:
			# Get the existing StyleBoxFlat assigned to the panel's custom style
			var original_stylebox = get_stylebox("panel")
			
			# Ensure it is a StyleBoxFlat before modifying
			if original_stylebox and original_stylebox is StyleBoxFlat:
				# Make a unique copy to avoid modifying all instances
				var stylebox = original_stylebox.duplicate()
				
				# Modify only the border color
				stylebox.border_color = Color(1.00, 0.64, 0.37)
				
				# Apply the new unique StyleBoxFlat to this panel instance
				add_stylebox_override("panel", stylebox)
				
				self.modulate.a = 1.0
			else:
				print("No StyleBoxFlat found or is not the correct type.")
		else:
			supported = false
			last_check_in = "needs update"
			self.modulate.a = 0.5

func _on_Device_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		if event.pressed == true:
			if supported == true:
				get_tree().root.get_child(0).get_child(0).current_device_ip = ip_address
				get_tree().root.get_child(0).get_child(0).current_device_nickname = nickname
				print("NEW DEVICE IP: "+ip_address)
				
				get_tree().root.get_child(0).get_child(0).ws_client_connected = false
				get_tree().root.get_child(0).get_child(0).ws_client.disconnect_from_host()
				get_tree().root.get_child(0).get_child(0).connect_to_websocket()
				get_tree().root.get_child(0).get_node("Window").window_visible = false
			else:
				get_tree().root.get_child(0).get_node("Dialog").show_error("Unsupported Device", "This Emotiscope doesn't have new enough software to use this app, please update it!\n\nAt least 2.0.0 is required.")
