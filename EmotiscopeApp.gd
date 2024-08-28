#
#	EMOTISCOPE APP
#	developed by @lixielabs in Godot 3.5.3
#

extends VBoxContainer

# Load children
var setting_scene = load("res://Assets/UI/Setting/Setting.tscn")
var slider_scene  = load("res://Assets/UI/Slider/Slider.tscn")

# Current device IP
var current_device_ip = "0.0.0.0"

# Websocket client
var STATE_REQUEST_FRAME_INTERVAL = 5
var next_state_request_wait_counter = 0
var ws_client
var ws_client_connected = false
var state_request_active = false
var state_request_wait_frames = 0

var http_request;

# --------------------------------------------------------
# NETWORKING
# --------------------------------------------------------
func connect_to_websocket():
	print("connect to websocket")
	if ws_client_connected == false:
		get_parent().spinner_enabled = true
		# Start client
		ws_client = WebSocketClient.new()
		
		# Connect callbacks
		ws_client.connect("connection_closed", self, "ws_closed")
		ws_client.connect("connection_error", self, "ws_error")
		ws_client.connect("connection_established", self, "ws_connected")
		ws_client.connect("data_received", self, "wsrx")
		
		# Initiate connection to an Emotiscope
		var result = ws_client.connect_to_url("ws://"+current_device_ip+"/ws")
		if result != OK:
			print("Unable to connect")
	else:
		print("Tried to connect to WS while ws_client_connected already marked true")

func ws_connected(proto = ""):
	print("Connected with protocol: ", proto)
	ws_client_connected = true
	ws_client.get_peer(1).set_write_mode ( ws_client.get_peer(1).WRITE_MODE_TEXT )
	state_request_active = false
	state_request_wait_frames = 0

func ws_closed(was_clean = false):
	# was_clean tells if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	connect_to_websocket();
	#restart_app()

func wstx(message):
	#print("TX: "+message)
	if ws_client_connected == true:
		#$Screen/Contents/DebugOutput.text = "TX: "+ message + "\n"
		ws_client.get_peer(1).put_packet(message.to_utf8())
	else:
		print("WSTX while not connected")

func wsrx():
	var message = ws_client.get_peer(1).get_packet().get_string_from_utf8()
	#print("RX: "+message)
	
	#$Contents/DebugText.text = "RX: " + message + "\n"
	parse_emotiscope_packet(message)

func restart_app():
	print("####### SOFTWARE RESTART #######")
	var main_scene = get_tree().get_root().get_child(0)
	get_tree().reload_current_scene()

func request_emotiscope_graph():
	wstx("EMO~get_graph|1")

func request_emotiscope_state():
	wstx("EMO~get_state|1")
	state_request_active = true
	state_request_wait_frames = 0

func kill_websocket():
	ws_client_connected = false
	ws_client.disconnect_from_host()
	state_request_active = false
	state_request_wait_frames = 0

func run_websocket():
	ws_client.poll()
	
	# If we haven't yet recieved a response
	if state_request_active == true:
		state_request_wait_frames += 1
		# Restart app if no response in 4 seconds (on 60Hz screen)
		if state_request_wait_frames >= 240:
			kill_websocket()
			connect_to_websocket()
	
	# Check if it's time to request Emotiscope's system state again
	if next_state_request_wait_counter > 0:
		next_state_request_wait_counter -= 1
	else:
		# Reset counter
		next_state_request_wait_counter = STATE_REQUEST_FRAME_INTERVAL

		if state_request_active == false:
			if ws_client_connected == true and get_parent().touch_active == false:
				request_emotiscope_state()

# ----------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------

func parse_emotiscope_packet(packet):
	state_request_active = false
	
	packet = packet.split("~")[1].split("|")
	var section_header = packet[0]
	var num_items = len(packet) - 1
	
	if section_header == "stats":
		$Contents/DebugText.text = ""
		
		for i in range(num_items/2):
			var stat_name = packet[1 + (i*2 + 0)]
			var stat_value = packet[1 + (i*2 + 1)]

			$Contents/DebugText.text += (stat_name + ": " + stat_value) + " "
			
	elif section_header == "config":
		for i in range(num_items/4):
			var config_name    = packet[1 + (i*4 + 0)]
			var config_type    = packet[1 + (i*4 + 1)]
			var config_ui_type = packet[1 + (i*4 + 2)]
			var config_value   = packet[1 + (i*4 + 3)]
			
			if config_ui_type == "s" or config_ui_type == "t":
				update_config_item_by_name(config_name, config_type, config_ui_type, config_value)
			
			#print(config_name + ": " + config_value)
	
	elif section_header == "modes":
		for i in range(num_items/2):
			var mode_name = packet[1 + (i*2 + 0)]
			var mode_type = packet[1 + (i*2 + 1)]
			
			#print(mode_name + ": " + mode_type)
	
	elif section_header == "graph":
		num_items = int(packet[1])
		if num_items != len($Contents/DebugGraph.graph_items):
			$Contents/DebugGraph.set_graph_length(num_items)
			print("RESIZING GRAPH")
		
		var graph_contents = packet[2].split(",")
		for i in range(num_items):
			var new_value = float(graph_contents[i]) / 255.0
			$Contents/DebugGraph.graph_items[i] = new_value
		
		$Contents/DebugGraph.update_graph()
		
	if get_parent().spinner_enabled == true:
		get_parent().spinner_enabled = false

func update_config_item_by_name(name, type, ui_type, value):
	if not $Contents/SettingGallery/Settings.get_node(name):
		#print("NO CONFIG FOUND for "+name)
		
		var setting = setting_scene.instance()
		setting.name = name
		
		setting.config_pretty_name = name
		setting.config_type = type
		setting.config_ui_type = ui_type
		setting.config_value = float(value)
		
		setting.set_setting_name(name)	
		if ui_type == "s" or ui_type == "t":
			#setting.set_slider_value(float(value))
			$Contents/SettingGallery/Settings.add_child(setting)
	else:
		#print("CONFIG FOUND")
		if ui_type == "s" or ui_type == "t":
			$Contents/SettingGallery/Settings.get_node(name).config_value = float(value)
			
		$Contents/ColorPreview.update_color_preview()

# -----------------------------------------------------------
# Graphics
# -----------------------------------------------------------

func resize_settings():
	var window_width = get_viewport().get_visible_rect().size.x
	
	for child in $Contents/SettingGallery/Settings.get_children():
		child.rect_min_size.x = (window_width-50) / 3.0

func run_graphics(delta):
	resize_settings()

func run_debug():
	# Check if the F12 key is pressed
	if Input.is_key_pressed(KEY_F12):
		# Disable V-Sync
		OS.vsync_enabled = false
	else:
		# Enable V-Sync
		OS.vsync_enabled = true

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var response_string = body.get_string_from_utf8()
		if "error" in response_string:
			if "No devices checked in" in response_string:
				print("NO DEVICES CHECKED IN")
			else:
				print("UNSUPPORTED ERROR: "+response_string)
		else:
			var response_data = JSON.parse(response_string)
			
			if response_data.error == OK:
				var device_list = response_data.result
		
				print("Devices: ")
				print(device_list)
				
				for device in device_list:
					print(device["local_ip"])
				
				current_device_ip = device_list[0]["local_ip"]
				print("NEW DEVICE IP: |"+current_device_ip+"|")
				
				remove_child(http_request)
				
				connect_to_websocket()
			else:
				print("JSON RESPONSE PARSING ERROR")
	else:
		print("Request failed with code: ", response_code)

# ------------------------------------------------------------------------------------------
# RUNTIME
# ------------------------------------------------------------------------------------------

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_request_completed")
	
	var url = "https://app.emotiscope.rocks/discovery"
	var response = http_request.request(url)
	
	if response != OK:
		print("Failed to make request: ", response)
	
	connect_to_websocket()
	
	$Contents/SettingGallery.get_h_scrollbar().modulate.a = 0.5

var iter = 0
func _process(delta):
	iter += 1
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	run_websocket()
	run_graphics(delta)
	run_debug()

	request_emotiscope_graph()
