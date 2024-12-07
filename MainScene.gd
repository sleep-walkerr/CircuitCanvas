extends Node2D
 
enum Mode {GATE, DELETE, WIRE, INPUT_OUTPUT, RENAME}

var object_being_dragged
var object_drag_offset
var object_predragging_pos
var selected_mode # will indicate one of 3 modes that can be selected
var over_gui
var camera = Camera2D.new() # Not used yet but will be used for zooming and panning
var gate_grid_data = {} # Provides a way to directly access tile data by coordinates
var selected_operation 
var current_wire
var wire_previous_tiles # 1st, move this to inside of wire objects, 2nd, this needs to not only hold wire tiles, but each tiles ID, a bug is caused by not storing the ID :/

# Called when the node enters the scene tree for the first time.
func _ready():
	#Set background to transparent
	get_tree().get_root().transparent_bg = true
	#Set mode to gate mode
	$MainControls/GeneralSelection/CenterContainer/VBoxContainer/HBoxContainer/select_button.emit_signal("pressed")
	$MainControls/GeneralSelection/CenterContainer/VBoxContainer/HBoxContainer/select_button.button_pressed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): #combined old physics_process with process, need to reorganize contents	
	pass
	
func _input(event):
	if !over_gui:
		var tile_currently_over = $GateGrid.local_to_map(get_global_mouse_position())
		# DELETE ME
		if event.is_action_pressed("click]"):
			print(tile_currently_over)
		# D
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
					var new_position = tile_currently_over - object_drag_offset # Calculate new position to draw from
					# Redraw pattern using offset from the tile currently over
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
					if GetInputOutputByTile(tile_currently_over) != null:
						GetInputOutputByTile(tile_currently_over).Delete()
			Mode.WIRE: # needs to be reorganized to stop repetition of conditionals
				if event.is_action_pressed("click]") and not IsWireTile(tile_currently_over): # If click and over nothing, create a wire
					object_predragging_pos = tile_currently_over # capture original position to draw wire from
					current_wire = load("res://Wire/Wire.tscn").instantiate() # Instantiate wire object
					current_wire.grid_position_coordinates = tile_currently_over # Set original position of wire
					$WireContainer.add_child(current_wire) # Add to wire container
				if Input.is_mouse_button_pressed(1) and current_wire != null: # if a wire is currently being modified, keep drawing it
					current_wire.DrawWire(object_predragging_pos, tile_currently_over)
					current_wire.DrawPins()
				if !Input.is_mouse_button_pressed(1) and current_wire != null and object_predragging_pos != null: # Deselect wire for modification if mouse not held anymore
					# if wire is only one tile, delete it
					if current_wire.get_used_cells().size() < 2:
						current_wire.Delete()
					object_predragging_pos = null # Set wire modification variables to null for next use
					current_wire = null
				if event.is_action_pressed("click]") and IsWireTile(tile_currently_over) and GetWireByTile(tile_currently_over).get_cell_source_id(tile_currently_over) == 2: # Resizing of wires, source id 3 = wire pin tile
					# if user clicks, is over a wire tile and that wire tile is a wire pin tile, then start resizing wire
					current_wire = GetWireByTile(tile_currently_over)
					for pin_tile in current_wire.get_used_cells_by_id(2):
						if pin_tile != tile_currently_over: # the pin tile that is not the pin currently over will be the pin that is static during the resizing
							object_predragging_pos = pin_tile
							
				if event.is_action_pressed("click]") and IsWireTile(tile_currently_over) and GetWireByTile(tile_currently_over).get_cell_source_id(tile_currently_over) != 2: # Moving of wires
					object_being_dragged = GetWireByTile(tile_currently_over) # Since wire is being dragged, use different variable
					# add offset later
					object_predragging_pos = tile_currently_over
					wire_previous_tiles = object_being_dragged.get_used_cells()
				if Input.is_mouse_button_pressed(1) and object_being_dragged != null:	# if left click is still held, keep dragging wire
					# Move this to MoveWire() function in wire later
					var position_change = tile_currently_over - object_predragging_pos	
					object_being_dragged.clear()
					for wire_tile in wire_previous_tiles:
						object_being_dragged.set_cell(wire_tile + position_change, object_being_dragged.orientation, Vector2i(0,0))
					object_being_dragged.DrawPins()
						
				if !Input.is_mouse_button_pressed(1) and object_being_dragged != null: # if left click is released and there is still an assigned wire, reset and stop dragging
					object_being_dragged = null
					object_predragging_pos = null
			Mode.INPUT_OUTPUT:
				# creates a new input or output depending on if left or right click is pressed
				if event.is_action_pressed("click]") and !IsInputOutputTile(tile_currently_over):
					var new_input_output = load("res://Input_Output/InputOutput.tscn").instantiate()
					new_input_output.grid_position_coordinates = tile_currently_over
					new_input_output.type = 0
					$InputOutputContainer.add_child(new_input_output)
				elif event.is_action_pressed("right_click"):
					var new_input_output = load("res://Input_Output/InputOutput.tscn").instantiate()
					new_input_output.grid_position_coordinates = tile_currently_over
					new_input_output.type = 1
					$InputOutputContainer.add_child(new_input_output)
				# start dragging operation
				if event.is_action_pressed("click]") and IsInputOutputTile(tile_currently_over):
					object_being_dragged = GetInputOutputByTile(tile_currently_over) # IsInputOutputTile and GetWireByTile have the same functionality, rename and use for this case as well
				if Input.is_mouse_button_pressed(1) and object_being_dragged != null:
					object_being_dragged.clear()
					# Draw pattern at tile currently over
					object_being_dragged.grid_position_coordinates = tile_currently_over
					object_being_dragged.RedrawPattern() # need to integrate offset to make dragging start less jarring
				# continue or exit dragging operation
				if !Input.is_mouse_button_pressed(1) and object_being_dragged != null: # if left click is released and there is still an assigned wire, reset and stop dragging
					object_being_dragged = null
					object_predragging_pos = null
			Mode.RENAME:
				if event.is_action_pressed("click]"):
					if IsInputOutputTile(tile_currently_over):
						object_being_dragged = GetInputOutputByTile(tile_currently_over)
					if isTileOccupied(tile_currently_over):
						object_being_dragged = GetManagingNode(tile_currently_over)
					if object_being_dragged != null:
						$MainControls/GeneralSelection/CenterContainer/VBoxContainer/HBoxContainer2/NameEntryElements/RenameEntrySection/VBoxContainer/LineEdit.text = object_being_dragged.name
					
			_:
				pass


func IsInputOutputTile(tile) -> bool: # Checks if an input/output exists at a given tile, this is a repeat of IsWireTile, remove later
	for input_output in $InputOutputContainer.get_children():
		for used_tile in input_output.get_used_cells():
			if input_output.get_cell_source_id(tile) != -1:
				if tile == used_tile:
					return true
	return false
	
func GetInputOutputByTile(tile) -> TileMapLayer: # Gets the input_output at the given tile
	for input_output in $InputOutputContainer.get_children():
		for used_tile in input_output.get_used_cells():
			if input_output.get_cell_source_id(tile) != -1:
				if tile == used_tile:
					return input_output
	return null
			
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
	
func RenameObject() -> void:
	object_being_dragged.name = $MainControls/GeneralSelection/CenterContainer/VBoxContainer/HBoxContainer2/NameEntryElements/RenameEntrySection/VBoxContainer/LineEdit.text
	
func ExportToSDL() -> void:
	var export_interface = load("res://Export/ExportToSDL.tscn").instantiate()
	export_interface.GatesContainer = $GateGrid
	export_interface.InputsOutputsContainer = $InputOutputContainer
	export_interface.WiresContainer = $WireContainer
	export_interface.DataGateGridRef = $DataGateGrid
	export_interface.gate_grid_data_ref = gate_grid_data
	
	export_interface.CollectWireConnections()
	export_interface.SimplifyWireConnections()
	export_interface.PrintCircuit()
	export_interface.ExportToSDL()
	

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
