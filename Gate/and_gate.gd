# this is a test gate for the new grid system
extends Node2D
var pattern
var type
var tiles = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#sample settings
	pattern = get_parent().tile_set.get_pattern(0) # parent should always be the TileMapLayer GateGrid
	type = "AND"
	var position = Vector2i(40,20) # this will be the tile that the mouse was over when user clicks
	# Draw tiles
	get_parent().set_pattern(position, pattern) 
	# Store tiles
	var tile_mask = pattern.get_used_cells()
	for x_y in tile_mask:
		tiles.append(get_parent().map_pattern(position, x_y, pattern))
	print(tiles)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
