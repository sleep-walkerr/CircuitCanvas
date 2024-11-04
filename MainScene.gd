extends Node2D
 
enum Mode {GATE, DELETE, WIRE}

var object_being_dragged
var object_drag_offset
var object_predragging_pos
var selected_mode # will indicate one of 3 modes that can be selected
var over_gui
var camera = Camera2D.new() # Not used yet but will be used for zooming and panning
var gate_grid_data = {} # Provides a way to directly access tile data by coordinates
var wire_tiles = {}
var selected_operation 
var current_wire

# Called when the node enters the scene tree for the first time.
func _ready():
	#Set background to transparent
	get_tree().get_root().transparent_bg = true
	#Set mode to gate mode
	$MainControls/GeneralSelection/CenterContainer/HBoxContainer/select_button.emit_signal("pressed")
	$MainControls/GeneralSelection/CenterContainer/HBoxContainer/select_button.button_pressed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): #combined old physics_process with process, need to reorganize contents	
	pass
	
func _input(event): # Need to change all of this to a case statement, faster
	if !over_gui:
		var tile_currently_over = $GateGrid.local_to_map(get_global_mouse_position())
		match selected_mode: # Eventually change this back to select, delete, wire, gate, and make select for moving wires and gates around. Less confusing
			Mode.GATE: 
				if event.is_action_pressed("click]") and object_being_dragged == null:
					if selected_operation != null: # If selected gate is != null
						if !isTileOccupied(tile_currently_over): # For the creation of gate patterns
							var new_gate_position = tile_currently_over	
							# Instance in gate
							var new_gate = load("res://Gate/AND_GATE.tscn").instantiate()
							new_gate.position_in_grid = new_gate_position
							new_gate.type = selected_operation
							# Add to Grid
							$ChangeBuffer.add_child(new_gate) # Gates check if they are overwriting other gates when added to the tree, see _ready()
					if Input.is_mouse_button_pressed(1) and isTileOccupied(tile_currently_over): # If left mouse held and over a gate, start dragging functionality
						object_being_dragged = GetManagingNode(tile_currently_over)
						# Store offset
						object_drag_offset = $GateGrid.get_cell_atlas_coords(tile_currently_over) - Vector2i(1,0) # Offset needs to be fixed
						#--Move to buffer
						MoveToBuffer(object_being_dragged)
				if object_being_dragged != null and Input.is_mouse_button_pressed(1): # If still pressed, keep dragging
					#print("inside dragging")
					var new_position = tile_currently_over - object_drag_offset # Calculate new position to draw from
					# Redraw pattern using offset from the tile currently over
					#object_being_dragged.position_in_grid = new_position
					object_being_dragged.MovePattern(new_position)
				elif !Input.is_mouse_button_pressed(1) and object_being_dragged != null: # Release after object dragged
					MoveToGrid(object_being_dragged)
					object_being_dragged = null
			Mode.DELETE: 
				if event.is_action_pressed("click]"):
					if isTileOccupied(tile_currently_over):
						GetManagingNode(tile_currently_over).Delete()
					if GetWireByTile(tile_currently_over) != null:
						GetWireByTile(tile_currently_over).Delete()
			Mode.WIRE: 
				if event.is_action_pressed("click]") and not IsWireTile(tile_currently_over): # If click and over nothing, create a wire
					object_predragging_pos = tile_currently_over # capture original position to draw wire from
					current_wire = load("res://Wire/Wire.tscn").instantiate() # Instantiate wire object
					current_wire.grid_position_coordinates = tile_currently_over # Set original position of wire
					$WireContainer.add_child(current_wire) # Add to wire container
				if Input.is_mouse_button_pressed(1) and current_wire != null: # if a wire is currently being modified, keep drawing it
					current_wire.DrawWire(object_predragging_pos, tile_currently_over)
				if !Input.is_mouse_button_pressed(1) and object_predragging_pos != null: # Deselect wire for modification if mouse not held anymore
					# if wire is only one tile, delete it
					if current_wire.get_used_cells().size() < 2:
						current_wire.Delete()
					object_predragging_pos = null
					current_wire = null
					
				# if click and IsWireTile and is wire pin tile, set current_wire to wire over and set object_predragging_pos to other wire pin
				if event.is_action_pressed("click]") and IsWireTile(tile_currently_over) and GetWireByTile(tile_currently_over).get_cell_source_id(tile_currently_over) == 3:
					current_wire = GetWireByTile(tile_currently_over)
					for pin_tile in current_wire.get_used_cells_by_id(3):
						if pin_tile != tile_currently_over:
							object_predragging_pos = pin_tile
			_:
				pass

			
func SetSelectedMode(mode):
	if mode != Mode.GATE:
		for button in $MainControls/gate_selection_interface/ScrollContainer/GateSelectContainer.get_children():
			button.disabled = true
	else:
		for button in $MainControls/gate_selection_interface/ScrollContainer/GateSelectContainer.get_children():
			button.disabled = false
	selected_mode = mode
	
func SetSelectedGate(gate_selection):
	selected_operation = gate_selection
	
func DragTiles() -> void:
	pass
	
func isTileOccupied(tile) -> bool:
	if $GateGrid.get_cell_source_id($GateGrid.local_to_map(get_global_mouse_position())) == -1:
		return false
	else:
		return true

func IsWireTile(tile) -> bool: # Checks if a wire exists at the given tile
	for wire in $WireContainer.get_children():
		for used_tile in wire.get_used_cells():
			if wire.get_cell_source_id(tile) != -1:
				if tile == used_tile:
					return true
	return false
	
func GetWireByTile(tile) -> TileMapLayer: # Gets the wire at the given tile
	for wire in $WireContainer.get_children():
		for used_tile in wire.get_used_cells():
			if wire.get_cell_source_id(tile) != -1:
				if tile == used_tile:
					return wire
	return null
	
func GetManagingNode(tile) -> Node2D: # This needs to be updated
	if gate_grid_data.has(tile):
		return gate_grid_data.get(tile).managing_node_ref
	else: return null

func MoveToBuffer(gate) -> void:
	for tile in gate.tiles:
		$GateGrid.erase_cell(tile)
	$GateGrid.remove_child(gate)
	$ChangeBuffer.add_child(gate)
	gate.MovePattern(gate.position_in_grid)
	
func MoveToGrid(gate) -> void:
	for tile in gate.tiles:
		$ChangeBuffer.erase_cell(tile)
	$ChangeBuffer.remove_child(gate)
	$GateGrid.add_child(gate)
	gate.MovePattern(gate.position_in_grid)

func _on_gd_example_position_changed(node, new_pos):
	print("The position of " + node.get_class() + " is now " + str(new_pos))
	pass

func _on_gd_example_cpp_print_signal(node, print_string):
	print("CPP Print: " + print_string)
	pass

func EnteredGUI() -> void:
	over_gui = true
	
func ExitedGUI() -> void:
	over_gui = false
