extends TileMapLayer

enum WireOrientation {HORIZONTAL, VERTICAL}

var grid_position_coordinates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_cell(grid_position_coordinates, 1, Vector2i(0,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func DrawWire(original_position, current_position) -> void:
	var x_difference = current_position.x - original_position.x  # change to vector2i soon
	var y_difference = current_position.y - original_position.y 
	#Check orientation
	#Take Delta
	# Draw based on delta
	match DetermineOrientation(original_position, current_position):
		WireOrientation.HORIZONTAL:
			if x_difference > 0:
				self.clear()
				for i in range(x_difference + 1):
					set_cell(original_position + Vector2i(i,0), 1, Vector2i(0,0))
			elif x_difference < 0:
				self.clear()
				for i in range(0, x_difference, -1):
					set_cell(original_position + Vector2i(i,0), 1, Vector2i(0,0))
		WireOrientation.VERTICAL:
			if y_difference > 0:
				self.clear()
				for i in range(y_difference + 1):
					set_cell(original_position + Vector2i(0,i), 2, Vector2i(0,0))
			elif y_difference < 0:
				self.clear()
				for i in range(0, y_difference, -1):
					set_cell(original_position + Vector2i(0,i), 2, Vector2i(0,0))
	

func DetermineOrientation(original_position, current_position) -> WireOrientation:
	var x_delta = abs(original_position.x - current_position.x)
	var y_delta = abs(original_position.y - current_position.y)
	if x_delta > y_delta:
		return WireOrientation.HORIZONTAL
	elif x_delta < y_delta:
		return WireOrientation.VERTICAL
	else:
		return WireOrientation.HORIZONTAL
