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
	for x_y in tile_mask: # Store tiles for drag, drop, delete
		tiles.append(get_parent().map_pattern(position, x_y, pattern)) 
	# Add reference to managing node within each tile, this allows for detecting which gate you are over at all times
	for tile in tiles:
		get_parent().get_cell_tile_data(tile).set_custom_data("managing_node_references", self) # Embed a reference to self into each tile
		
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
