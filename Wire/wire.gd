extends TileMapLayer

enum WireOrientation {HORIZONTAL, VERTICAL} # change this to tile types

var grid_position_coordinates
var orientation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_cell(grid_position_coordinates, 1, Vector2i(0,0))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func DrawWire(original_position, current_position) -> void:
	var x_difference = current_position.x - original_position.x 
	var y_difference = current_position.y - original_position.y 
	match DetermineOrientation(original_position, current_position):
		WireOrientation.HORIZONTAL: # If wire should be horizontal
			if x_difference > 0: # if mouse is in front of original point
				self.clear() # clear tiles
				for i in range(x_difference + 1):
					set_cell(original_position + Vector2i(i,0), 0, Vector2i(0,0)) # set horizontal wire tile at each tile until point that mouse is at from origin
			elif x_difference < 0: # if mouse is in behind of original point
				self.clear()
				for i in range(0, x_difference, -1):
					set_cell(original_position + Vector2i(i,0), 0, Vector2i(0,0))
			orientation = WireOrientation.HORIZONTAL
		WireOrientation.VERTICAL: # If wire should be vertical
			if y_difference > 0:
				self.clear()
				for i in range(y_difference + 1):
					set_cell(original_position + Vector2i(0,i), WireOrientation.VERTICAL, Vector2i(0,0))
			elif y_difference < 0:
				self.clear()
				for i in range(0, y_difference, -1):
					set_cell(original_position + Vector2i(0,i), WireOrientation.VERTICAL, Vector2i(0,0))
			orientation = WireOrientation.VERTICAL

func DrawPins() -> void:
		set_cell(get_used_cells().front(), 2, Vector2i(0,0)) # Set front and back of wire to wire pin tile
		set_cell(get_used_cells().back(), 2, Vector2i(0,0))

func DetermineOrientation(original_position, current_position) -> WireOrientation:
	var x_delta = abs(original_position.x - current_position.x)
	var y_delta = abs(original_position.y - current_position.y)
	if x_delta > y_delta:
		return WireOrientation.HORIZONTAL
	elif x_delta < y_delta:
		return WireOrientation.VERTICAL
	else:
		return WireOrientation.HORIZONTAL
		
func Delete() -> void:
		get_parent().remove_child(self)
		queue_free()
