extends TileMapLayer

enum IOType {INPUT, OUTPUT}
var type = null # input or output, should be set before entering the tree
var grid_position_coordinates
var pattern

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == IOType.INPUT:
		pattern = tile_set.get_pattern(0)
		set_pattern(grid_position_coordinates, pattern)
	elif type == IOType.OUTPUT:
		pattern = tile_set.get_pattern(1)
		set_pattern(grid_position_coordinates, pattern)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func RedrawPattern() -> void:
	set_pattern(grid_position_coordinates,pattern)

func Delete() -> void:
		get_parent().remove_child(self)
		queue_free()
