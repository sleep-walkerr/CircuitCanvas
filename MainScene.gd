extends Node2D
 
var object_being_dragged
var object_drag_offset
var over_gui

var newConnection
var selected_scenes
var mouseDelta = Vector2(0,0)
var selectedGate 
var isMousePositioned = true #had to add this because of timing issues. Might be engine bug :/

# Node reference Lists/Matricies for gates, connections, and input/output nodes
var gateReferencesByCategory = {}
var connectionsList = []
var inputsAndOutputsList = {"IN" : [], "OUT" : []}
var mouseOverAndSelectionCast = ShapeCast2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#Set background to transparent
	get_tree().get_root().transparent_bg = true
	#Create dictionary containing arrays that will hold references to all gates for every gate type
	gateReferencesByCategory['AND'] = []
	gateReferencesByCategory['Buffer'] = []
	gateReferencesByCategory['NAND'] = []
	gateReferencesByCategory['NOR'] = []
	gateReferencesByCategory['NOT'] = []
	gateReferencesByCategory['OR'] = []
	gateReferencesByCategory['XNOR'] = []
	gateReferencesByCategory['XOR'] = []
	
	#configure mouse detection and selection shapecast
	mouseOverAndSelectionCast.exclude_parent = false
	mouseOverAndSelectionCast.shape = RectangleShape2D.new()
	mouseOverAndSelectionCast.shape.size = Vector2(0,0)
	mouseOverAndSelectionCast.target_position = Vector2(0,0)
	mouseOverAndSelectionCast.collide_with_areas = true
	self.add_child(mouseOverAndSelectionCast)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): #combined old physics_process with process, need to reorganize contents
	# New Code
	
	
	#Get node currently over every frame using raycast
	mouseOverAndSelectionCast.position = get_global_mouse_position()
	
func _input(event):
	if !over_gui:
		var tile_currently_over = $GateGrid.local_to_map(get_global_mouse_position())
		# New Test Code
		if event.is_action_pressed("click]"):
			if selectedGate != null and !isTileOccupied(tile_currently_over): # For the creation of gate patterns
				# This is a good start, needs to eventually check if any resulting tiles will overwrite occupied tiles, if they will, block action
				var new_gate_position = tile_currently_over	
				# Test gate creation with sample and gate
				# Instance in and gate
				var new_gate = load("res://Gate/AND_GATE.tscn").instantiate()
				new_gate.position_in_grid = new_gate_position
				new_gate.type = selectedGate
				# Add to Grid
				$GateGrid.add_child(new_gate)
			elif Input.is_mouse_button_pressed(1) and isTileOccupied(tile_currently_over): # If left mouse held and over a gate, start dragging functionality
				object_being_dragged = $GateGrid.get_cell_tile_data(tile_currently_over).get_custom_data("managing_node_references")
				# Store offset
				object_drag_offset = $GateGrid.get_cell_atlas_coords(tile_currently_over) - Vector2i(1,0) # Use atlas
				#--Calculate offset using atlas
		if object_being_dragged != null and Input.is_mouse_button_pressed(1): # If still pressed, keep dragging

			# Delete previous pattern tiles
			for tile in object_being_dragged.tiles:
				$GateGrid.erase_cell(tile)
			# Redraw pattern using offset from the tile currently over
		
			object_being_dragged.position_in_grid = tile_currently_over - object_drag_offset
			object_being_dragged.RedrawPattern()
		elif !Input.is_mouse_button_pressed(1):
			object_being_dragged = null
			
					
					
			
			
			
		# End New Test Code
			
func SelectedGate(scenePath):
	selectedGate = scenePath
	
func SetSelectedGate(gate_selection):
#	for currentSelectionContainer in gateSelectionContainer.get_parent().get_children():
#		if currentSelectionContainer.get_meta("type") == selectedGate:
#			currentSelectionContainer.get_node("GateButtonPanel/GateSelectionButton").texture_normal = load("res://Icons/" + currentSelectionContainer.get_meta("type") + ".png")
#	gateSelectionContainer.get_node("GateButtonPanel/GateSelectionButton").texture_normal = load("res://Icons/" + gateSelectionContainer.get_meta("type") + "Pressed.png")
#	selectedGate = gateSelectionContainer.get_meta("type")
	selectedGate = gate_selection
	
	
func DragTiles() -> void:
	pass
	
func isTileOccupied(tile) -> bool:
	if $GateGrid.get_cell_source_id($GateGrid.local_to_map(get_global_mouse_position())) == -1:
		return false
	else:
		return true
	
	

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
	
