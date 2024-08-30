extends TextureRect

export var graph_items = []

var color_path       = "EmotiscopeApp/Screen/Contents/SettingGallery/Settings/Color"
var color_range_path = "EmotiscopeApp/Screen/Contents/SettingGallery/Settings/Color Range"
var saturation_path  = "EmotiscopeApp/Screen/Contents/SettingGallery/Settings/Saturation"
var brightness_path  = "EmotiscopeApp/Screen/Contents/SettingGallery/Settings/Brightness"
var warmth_path      = "EmotiscopeApp/Screen/Contents/SettingGallery/Settings/Warmth"
var mirror_mode_path = "EmotiscopeApp/Screen/Contents/SettingGallery/Settings/Mirror Mode"

var ColorPreviewImage : Image
var ColorPreviewTexture : ImageTexture
var texture_rect : TextureRect

var incandescent_lookup = Color(1.0000, 0.4452, 0.1562)

func wrap_float(input):
	while input > 1.0:
		input -= 1.0
	while input < 0.0:
		input += 1.0
		
	return input

func saw_to_triangle(saw: float) -> float:
	# Convert sawtooth (0.0 to 1.0) to triangle wave (0.0 to 1.0)
	return 1.0 - abs(2.0 * saw - 1.0)

var run = 0
func update_preview():
	var graph_line_width = 256 / len(graph_items)
	
	var hue         = 0.0
	var hue_range   = 0.0
	var saturation  = 0.0
	var brightness  = 0.0
	var warmth      = 0.0
	var mirror_mode = 0.0
	
	if get_tree().root.get_node(color_path):
		hue = get_tree().root.get_node(color_path).config_value
	if get_tree().root.get_node(color_range_path):
		hue_range = get_tree().root.get_node(color_range_path).config_value
	if get_tree().root.get_node(saturation_path):
		saturation = get_tree().root.get_node(saturation_path).config_value
	if get_tree().root.get_node(brightness_path):
		brightness = 0.2 + (get_tree().root.get_node(brightness_path).config_value) * 0.8
	if get_tree().root.get_node(warmth_path):
		warmth = get_tree().root.get_node(warmth_path).config_value
	if get_tree().root.get_node(mirror_mode_path):
		mirror_mode = round(get_tree().root.get_node(mirror_mode_path).config_value)
		
	var clear_col = Color(0,0,0, 0.0)
	ColorPreviewImage.fill_rect(Rect2(
		Vector2(0,0),
		Vector2(256,150)
	), clear_col)
	
	for i in range(64):
		var progress = i / float(64)
		
		var new_red = int(graph_items[i][0])/64.0
		var new_grn = int(graph_items[i][1])/64.0
		var new_blu = int(graph_items[i][2])/64.0
		
		#new_red = sqrt(new_red)
		#new_grn = sqrt(new_grn)
		#new_blu = sqrt(new_blu)

		var new_color = Color(
			new_red,
			new_grn,
			new_blu
		)
		var max_color = 0.0
		max_color = max(max_color, new_red)
		max_color = max(max_color, new_grn)
		max_color = max(max_color, new_blu)
		
		max_color = sqrt(max_color)
		
		var shifted_item = max_color*0.95 + 0.05
		
		var rect = Rect2(
			Vector2(
				graph_line_width * i,
				(150/2) - (150/4)*shifted_item
			),
			Vector2(
				graph_line_width,
				shifted_item*75
			)
		)
		
		ColorPreviewImage.fill_rect(rect, new_color)
			
	ColorPreviewTexture.set_data(ColorPreviewImage)

func set_graph_length(new_length):
	graph_items = []
	for i in range(new_length):
		graph_items.append([0,0,0])

func _ready():
	set_graph_length( 64 )
	
	# Create the image
	ColorPreviewImage = Image.new()
	ColorPreviewImage.create(256, 150, false, Image.FORMAT_RGBAF)

	# Create a texture from the image
	ColorPreviewTexture = ImageTexture.new()
	ColorPreviewTexture.create_from_image(ColorPreviewImage)

	self.texture = ColorPreviewTexture

func _process(delta):
	update_preview()
	pass
