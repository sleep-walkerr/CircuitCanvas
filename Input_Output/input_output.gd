extends TileMapLayer

enum IOType {INPUT, OUTPUT}
var type = null # input or output, should be set before entering the tree
var grid_position_coordinates
var pattern
var alias

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var number_inputs = 0
	var number_outputs = 0
	for IOObject in get_node("/root/Node2D/InputOutputContainer").get_children():
		if IOObject.type == 0:
			number_inputs = number_inputs + 1
		elif IOObject.type == 1:
			number_outputs = number_outputs + 1
	
	if type == IOType.INPUT:
		pattern = tile_set.get_pattern(0)
		set_pattern(grid_position_coordinates, pattern)
		alias = str("IN#",number_inputs)
	elif type == IOType.OUTPUT:
		pattern = tile_set.get_pattern(1)
		set_pattern(grid_position_coordinates, pattern)
		alias = str("OUT#",number_outputs)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func RedrawPattern() -> void:
	set_pattern(grid_position_coordinates,pattern)

func Delete() -> void:
		get_parent().remove_child(self)
		queue_free()
