extends Node2D
var managing_node_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var position_in_grid = get_parent().local_to_map(position)
	get_parent().get_parent().gate_grid_data[position_in_grid] = self
	#print(get_parent().get_parent().gate_grid_data)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
