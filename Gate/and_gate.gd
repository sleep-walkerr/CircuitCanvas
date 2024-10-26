# this is a test gate for the new grid system
extends Node2D
var pattern
var type 
var tiles = []
var position_in_grid # this is the tile that the mouse was over when user clicks
var pattern_indicies = {'AND' : 0, 'OR' : 1, 'NOT' : 2, 'NAND' : 3, 'NOR' : 4, 'XOR' : 5, 'XNOR' : 6}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_parent().tile_set.get_patterns_count())
	pattern = get_parent().tile_set.get_pattern(pattern_indicies[type])
	# Draw tiles
	if pattern != null:
		get_parent().set_pattern(position_in_grid, pattern) 
		# Store tiles
		var tile_mask = pattern.get_used_cells()
		for x_y in tile_mask: # Store tiles for drag, drop, delete
			tiles.append(get_parent().map_pattern(position_in_grid, x_y, pattern)) 
		# Add reference to managing node within each tile, this allows for detecting which gate you are over at all times
		for tile in tiles:
			get_parent().get_cell_tile_data(tile).set_custom_data("managing_node_references", self) # Embed a reference to self into each tile
	else:
		print("Pattern not found, Freeing...")
		get_parent().remove_child(self)
		self.queue_free()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
