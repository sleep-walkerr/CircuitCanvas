# this is a test gate for the new grid system
extends Node2D
var pattern
var type 
var tiles = []
var data_tiles = []
var tile_mask
var position_in_grid # this is the tile that the mouse was over when user clicks
var pattern_indicies = {'AND' : 0, 'OR' : 1, 'NOT' : 2, 'NAND' : 3, 'NOR' : 4, 'XOR' : 5, 'XNOR' : 6}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pattern = get_parent().tile_set.get_pattern(pattern_indicies[type])
	# Draw tiles
	if pattern != null:
		get_parent().set_pattern(position_in_grid, pattern) 
		# Store tiles
		tile_mask = pattern.get_used_cells()
		for x_y in tile_mask: # Store tiles for drag, drop, delete
			tiles.append(get_parent().map_pattern(position_in_grid, x_y, pattern)) 
		# Add reference to managing node for the group of tiles that are managed
		
		# NEW Add data layer to add tiles to for gate 
		for tile in tiles:
			get_node("/root/Node2D/DataGateGrid").set_cell(tile, 0, Vector2i(0,0), 1)
			get_node("/root/Node2D/DataGateGrid").update_internals() # this line is crucial as it allows for the tile scenes to enter the tree and therefore run their _ready
			get_node("/root/Node2D").gate_grid_data[tile].managing_node_ref = self
	else: # If the pattern is not found, this object is deleted as no gate can be drawn
		get_parent().remove_child(self)
		self.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func RedrawPattern() -> void: # Redraws pattern every frame for drag and drop movement (might replace section in ready fxn)
	# Needs to have position_in_grid set to new position before calling
	# Clear corresponding datatiles from Data TileMap, dictionary, and finally from memory ( and scene tree )
	for tile in tiles: # for each current tile
		# Erase from dictionary and from grid
		get_node("/root/Node2D").gate_grid_data.erase(tile)
		get_node("/root/Node2D/DataGateGrid").erase_cell(tile)
	# Delete previously stored coordinates
	tiles.clear()
	get_parent().set_pattern(position_in_grid, pattern) 
	for x_y in tile_mask: # Store tiles for drag, drop, delete
		tiles.append(get_parent().map_pattern(position_in_grid, x_y, pattern)) 
	# Add reference to managing node within each tile, this allows for detecting which gate you are over at all times
	for tile in tiles:
		get_node("/root/Node2D/DataGateGrid").set_cell(tile, 0, Vector2i(0,0), 1)
		get_node("/root/Node2D/DataGateGrid").update_internals() # this line is crucial as it allows for the tile scenes to enter the tree and therefore run their _ready
		get_node("/root/Node2D").gate_grid_data[tile].managing_node_ref = self
	
