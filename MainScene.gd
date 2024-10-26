extends Node2D
 
var scene_currently_over
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
	#Get node currently over every frame using raycast
	mouseOverAndSelectionCast.position = get_global_mouse_position()
	
func _input(event):
	# New Test Code
	if event.is_action_pressed("click]") and selectedGate != null:
		print($GateGrid.local_to_map(get_global_mouse_position()))
		var new_gate_position = $GateGrid.local_to_map(get_global_mouse_position())
		# Test gate creation with sample and gate
		# Instance in and gate
		var new_gate = load("res://Gate/AND_GATE.tscn").instantiate()
		new_gate.position_in_grid = new_gate_position
		new_gate.type = selectedGate
		# Add to Grid
		$GateGrid.add_child(new_gate)
		
		
		
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
	

func _on_gd_example_position_changed(node, new_pos):
	print("The position of " + node.get_class() + " is now " + str(new_pos))
	pass

func _on_gd_example_cpp_print_signal(node, print_string):
	print("CPP Print: " + print_string)
	pass
