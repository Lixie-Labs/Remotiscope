extends TextureRect

export var graph_items = []

var DebugGraphImage : Image
var DebugGraphTexture : ImageTexture
var texture_rect : TextureRect

func update_graph():
	var graph_line_width = 256 / len(graph_items)

	var clear_col = Color8(0,0,0)
	DebugGraphImage.fill_rect(Rect2(
		Vector2(0,0),
		Vector2(256,150)
	), clear_col)
	
	for i in range(len(graph_items)):
		var rect = Rect2(
			Vector2(
				graph_line_width * i,
				150 - (graph_items[i] * 150)
			),
			Vector2(
				graph_line_width,
				150
			) 
		)
		
		#print(rect)
		
		var col = Color8(255, 0, 0)
		DebugGraphImage.fill_rect(rect, col)
	
	DebugGraphTexture.set_data(DebugGraphImage)

func set_graph_length(new_length):
	graph_items = []
	for i in range(new_length):
		graph_items.append(0)

func _ready():
	set_graph_length( 128 )
	
	# Create the image
	DebugGraphImage = Image.new()
	DebugGraphImage.create(256, 150, false, Image.FORMAT_RGB8)

	# Create a texture from the image
	DebugGraphTexture = ImageTexture.new()
	DebugGraphTexture.create_from_image(DebugGraphImage)

	self.texture = DebugGraphTexture

func _process(delta):
	pass
