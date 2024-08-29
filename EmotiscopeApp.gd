#
#	EMOTISCOPE APP
#	developed by @lixielabs in Godot 3.5.3
#

extends VBoxContainer

# Load children
var setting_scene = load("res://Assets/UI/Setting/Setting.tscn")
var device_scene = load("res://Assets/UI/Device/Device.tscn")
var mode_button_scene = load("res://Assets/UI/ModeButton/ModeButton.tscn")

# Current device IP
var current_device_ip = "192.168.86.224"
var current_device_nickname = "emotiscope"

# Websocket client
var STATE_REQUEST_FRAME_INTERVAL = 5
var next_state_request_wait_counter = 0
var ws_client
var ws_client_connected = false
var state_request_active = false
var state_request_wait_frames = 0

var device_list = []

var http_request;

# --------------------------------------------------------
# NETWORKING
# --------------------------------------------------------
func connect_to_websocket():
	$Header/HeaderText.text = current_device_nickname
	#get_node("../Window/NicknameScreen/Contents/NicknameEntry/NicknameBox").text = current_device_nickname
	
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
		#print("WSTX while not connected")
		pass

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

func decode_screen_pixel(code):
	var charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	for i in range(len(charset)):
		if charset[i] == code:
			return i

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
			
			if len(get_node("../Window/ModeScreen").mode_list) >= int(config_value)+1:
				if config_name == "Current Mode":
					var mode_name_string = get_node("../Window/ModeScreen").mode_list[int(config_value)]
					$Contents/CurrentMode.text = str(mode_name_string).to_upper()
			
			if config_ui_type == "s" or config_ui_type == "t":
				update_config_item_by_name(config_name, config_type, config_ui_type, config_value)
			
			#print(config_name + ": " + config_value)
	
	elif section_header == "modes":
		for i in range(num_items/2):
			var mode_name = packet[1 + (i*2 + 0)]
			var mode_type = packet[1 + (i*2 + 1)]
			
			add_mode_to_list(mode_name, mode_type, i)
	
	elif section_header == "nickname":
		var device_nickname = packet[1]
		current_device_nickname = device_nickname
		$Header/HeaderText.text = current_device_nickname
	
	elif section_header == "screen":
		num_items = int(packet[1])
		
		if num_items != len($Contents/ScreenPreview.graph_items):
			$Contents/ScreenPreview.set_graph_length(num_items)
			print("RESIZING SCREEN PREVIEW")
		#
		var graph_contents = packet[2]
		for i in range(num_items):
			var pixel_data_r = decode_screen_pixel(graph_contents[i*3 + 0])
			var pixel_data_g = decode_screen_pixel(graph_contents[i*3 + 1])
			var pixel_data_b = decode_screen_pixel(graph_contents[i*3 + 2])
			
			$Contents/ScreenPreview.graph_items[i] = [pixel_data_r, pixel_data_g, pixel_data_b]
			
		$Contents/ScreenPreview.update_preview()
		
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
			
		$Contents/ScreenPreview.update_preview()

func add_mode_to_list(mode_name, mode_type, mode_index):
	if mode_type == "0":
		mode_type = "Active"
	elif mode_type == "1":
		mode_type = "Inactive"
		
	if not get_node("../Window/ModeScreen/Contents/Modes/"+mode_type+"/ScrollContainer/ModeList/"+mode_name):
		print(mode_name + " not yet in "+mode_type+" modes!")
		
		var new_button = mode_button_scene.instance()
		new_button.set_mode_button_name(mode_name)
		new_button.mode_index = mode_index
		
		get_node("../Window/ModeScreen/Contents/Modes/"+mode_type+"/ScrollContainer/ModeList/").add_child(new_button)
		
		get_node("../Window/ModeScreen").mode_list.append(mode_name)
		

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
				device_list = response_data.result
		
				print("Devices: ")
				print(device_list)
				
				var device_list_node = get_node("../Window/NicknameScreen/Contents/DeviceListContainer/ScrollContainer/DeviceList")
				for child in device_list_node.get_children():
					device_list_node.remove_child(child)
				
				for device in device_list:
					var device_id = str(device["local_ip"]).replace(".","")
					if not get_node("../Window/NicknameScreen/Contents/DeviceListContainer/ScrollContainer/DeviceList/"+device_id):
						var check_in_age_minutes = 0
						var current_time = OS.get_unix_time()
						var last_check_in_time = int(device["timestamp"])
						check_in_age_minutes = int((current_time - last_check_in_time) / 60.0)
						
						var new_device = device_scene.instance()
						new_device.ip_address = device["local_ip"]
						new_device.firmware_version = device["version"]
						new_device.last_check_in = "seen "+str(check_in_age_minutes)+" min ago"
						new_device.nickname = device["nickname"]
						
						get_node("../Window/NicknameScreen/Contents/DeviceListContainer/ScrollContainer/DeviceList").add_child(new_device)
				
				current_device_ip = device_list[0]["local_ip"]
				current_device_nickname = device_list[0]["nickname"]
				print("NEW DEVICE IP: |"+current_device_ip+"|")
				
				remove_child(http_request)
				
				connect_to_websocket()
			else:
				print("JSON RESPONSE PARSING ERROR")
	else:
		print("Request failed with code: ", response_code)

func fetch_devices_from_discovery_server():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_request_completed")
	
	var url = "http://r.emotiscope.rocks/discovery"
	var response = http_request.request(url)
	
	if response != OK:
		print("Failed to make request: ", response)
		
func main_loop(delta):
	iter += 1
	
	if iter % 2 == 0:
		run_websocket()
		request_emotiscope_graph()
		
	run_graphics(delta)
	run_debug()

# ------------------------------------------------------------------------------------------
# RUNTIME
# ------------------------------------------------------------------------------------------

func _ready():
	fetch_devices_from_discovery_server()
	connect_to_websocket()
	
	$Contents/SettingGallery.get_h_scrollbar().modulate.a = 0.5

var iter = 0
func _process(delta):
	main_loop(delta)

func _on_HeaderText_gui_input(event):
	if event is InputEventMouseButton or event in InputEventScreenTouch:
		if event.pressed == true:
			var device_list_node = get_node("../Window/NicknameScreen/Contents/DeviceListContainer/ScrollContainer/DeviceList")
			for child in device_list_node.get_children():
					device_list_node.remove_child(child)
			fetch_devices_from_discovery_server()
			get_node("../Window/NicknameScreen/Contents/NicknameEntry/NicknameBox").text = current_device_nickname
			get_node("../Window/NicknameScreen").show()
			get_node("../Window").window_visible = true
