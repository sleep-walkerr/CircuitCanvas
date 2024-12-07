# The data gate grid might be able to be replaced if the tilemap resource is made unique (recursive)
extends Node2D
var pattern
var type 
var tiles = []
var data_tiles = [] # Holds data tiles for THIS gate, only required for prevention of writing over other gates
var tile_mask
var position_in_grid # this is the tile that the mouse was over when user clicks
var gate_inputs = {}
var pattern_indicies = {'AND' : 0, 'OR' : 1, 'NOT' : 2, 'NAND' : 3, 'NOR' : 4, 'XOR' : 5, 'XNOR' : 6} # Change this to enum


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = str(type, get_instance_id())
	pattern = get_parent().tile_set.get_pattern(pattern_indicies[type])
	# Draw tiles
	if pattern != null:
		tile_mask = pattern.get_used_cells() # Get mask to use to determine relative positions of tiles after pattern is drawn
		RedrawPattern() # Draws pattern for first time and stores tiles drawn into tiles
		if !OverwritingTiles():
			RedrawData() # Adds a reference to self in corresponding tiles in data grid
			get_parent().get_parent().MoveToGrid(self)
		else:
			ClearTiles()
			get_parent().remove_child(self)
			self.queue_free()
	else: # If the pattern is not found, this object is deleted as no gate can be drawn
		get_parent().remove_child(self)
		self.queue_free()

func MovePattern(new_position) -> void: # Redraws pattern every frame for drag and drop movement (might replace section in ready fxn)
	# Needs to have position_in_grid set to new position before calling
	var previous_position = position_in_grid
	position_in_grid = new_position
	ClearTiles()
	# Delete previously stored coordinates
	tiles.clear()
	RedrawPattern()
	if !OverwritingTiles():
		ClearDataTiles()
		RedrawData()
		SetInputPins()
	else: 
		position_in_grid = previous_position
		ClearTiles()
		tiles.clear()
		RedrawPattern()
		ClearDataTiles()
		RedrawData()
		SetInputPins()
func RedrawPattern() -> void:
	get_parent().set_pattern(position_in_grid, pattern) # Physical Redraw of pattern on grid
	for x_y in tile_mask: # Store drawn tile coordinates for drag, drop, delete
		tiles.append(get_parent().map_pattern(position_in_grid, x_y, pattern)) 
	get_parent().update_internals()

func ClearTiles() -> void:
	for tile in tiles:
		get_parent().erase_cell(tile)
	
func RedrawData() -> void:
	# Add reference to managing node within each tile, this allows for detecting which gate you are over at all times
	data_tiles.clear()
	for tile in tiles: # CHANGE THIS: This should only occurr once after drag and drop has completed, needs to be used to determine if drag & drop can occurr at all.
		get_node("/root/Node2D/DataGateGrid").set_cell(tile, 0, Vector2i(0,0), 1)
		get_node("/root/Node2D/DataGateGrid").update_internals() # this line is crucial as it allows for the tile scenes to enter the tree and therefore run their _ready
		get_node("/root/Node2D").gate_grid_data[tile].managing_node_ref = self # Adds data tile to main dictionary
		data_tiles.append(tile) # Adds data tile to list here
	get_node("/root/Node2D/DataGateGrid").update_internals()
	
func ClearDataTiles():
	# Clear corresponding datatiles from Data TileMap, dictionary, and finally from memory ( and scene tree )
	for data_tile in data_tiles: # for each current tile
		# Erase from dictionary and from grid
		get_node("/root/Node2D").gate_grid_data.erase(data_tile)
		get_node("/root/Node2D/DataGateGrid").erase_cell(data_tile)
	get_node("/root/Node2D/DataGateGrid").update_internals()
	
func OverwritingTiles() -> bool: # Should only be called when tiles are in buffer
	var is_overwriting_tiles = true
	# What to remember
	#--At this point, tiles will always be updated to the current position, even if mid drag drop bc of buffer
	for tile in tiles: # Tiles is current location of tiles
		if get_node("/root/Node2D").gate_grid_data.has(tile): # if data tiles has an entry for a corresponding tile in buffer
			if data_tiles.has(tile) and get_node("/root/Node2D").gate_grid_data[tile].managing_node_ref == self: # check reference for that tile and see if it is me
				is_overwriting_tiles = false
			else: 
				is_overwriting_tiles = true
				break
		else: is_overwriting_tiles = false
			
	return is_overwriting_tiles
	
func Delete() -> void: # Primarily for delete mode, called to make gate remove all traces of itself
	ClearDataTiles()
	ClearTiles()
	get_parent().remove_child(self)
	self.queue_free()

func SetInputPins():
	var index = 1
	gate_inputs.clear()
	for tile in tiles:
		if get_parent().get_cell_source_id(tile) == 7:
			gate_inputs[tile] = index
			index = index + 1
			
			
