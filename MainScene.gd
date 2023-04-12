extends Node2D

# for now just focus on getting the "simulate circuit" logic to work. Use the button as a placeholder trigger
# For 3 input ORs and the like, instance in pins and split space evenly

var scene_currently_over
var newConnection
var selected_scenes
var mouseDelta = Vector2(0,0)
var selectedGate = "NOT"
var isMousePositioned = true #had to add this because of timing issues. Might be engine bug :/

# Node reference Lists/Matricies for gates, connections, and input/output nodes
var gateReferencesByCategory = {}
var connectionsList = []
var inputsAndOutputsList = []

var mouseOverAndSelectionCast = ShapeCast2D.new()



# Called when the node enters the scene tree for the first time.
func _ready():
	#Create dictionary containing arrays that will hold references to all gates for every gate type
	#Figure out a better way to set up all of the lists
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
	
	#detect is mouse if over last node after drag and drop
	if mouseOverAndSelectionCast.get_collision_count() > 0 and mouseOverAndSelectionCast.get_collider(0) == scene_currently_over:
		isMousePositioned = true
	
	if !Input.is_key_pressed(KEY_CTRL):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_mouse_button_pressed(1): 
			isMousePositioned = false
			UpdateConnectionCoordinates(scene_currently_over)
			scene_currently_over.move_and_collide(scene_currently_over.direction)
			scene_currently_over.direction = Vector2(0,0)
			
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			Input.warp_mouse(scene_currently_over.position + scene_currently_over.offset)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		scene_currently_over.direction += mouseDelta* (Performance.get_monitor(Performance.TIME_FPS)) * delta # current position of mouse relative to last * current fps * time since last frame. This allows for consistent movement reguardless of framerate
		mouseDelta = Vector2(0,0)
	elif isMousePositioned:
		if mouseOverAndSelectionCast.get_collision_count() > 0 and mouseOverAndSelectionCast.get_collider(0) is CharacterBody2D: #change to check if any then check type
			if scene_currently_over != mouseOverAndSelectionCast.get_collider(0) and scene_currently_over != null:
				LeftSelectableScene()
			OverSelectableScene(mouseOverAndSelectionCast.get_collider(0))
		if mouseOverAndSelectionCast.get_collision_count() == 0 and scene_currently_over != null:
			LeftSelectableScene()
		
		if !Input.is_key_pressed(KEY_CTRL): #adding another not ctrl section to make it more obvious
			newConnection = null
	
	

func UpdateConnectionCoordinates(sceneToUpdate): # updates coordinates of and redraws connection as participating gate is moved
	var connectionPointIndex = 0
	for pinType in sceneToUpdate.inAndOutPINListDictionary:
		for gatePIN in sceneToUpdate.inAndOutPINListDictionary[pinType]:
			if gatePIN.connectionParticipatingIn != null:
				#find matching pin reference from list
				for connectedPIN in gatePIN.connectionParticipatingIn.get_meta("nodesConnected"):
					if gatePIN == connectedPIN:
						#update coords and redraw
						gatePIN.connectionParticipatingIn.get_node("Line2D").set_point_position(connectionPointIndex, sceneToUpdate.position + gatePIN.position + gatePIN.get_node("Area2D/CollisionShape2D").position)
						gatePIN.connectionParticipatingIn.queue_redraw ()
					connectionPointIndex += 1
				connectionPointIndex = 0
	
	
	

func OverSelectionGUI(): #pause everything except for selectionGUI when inside of it
	get_tree().paused = true
func LeftSelectionGUI():
	get_tree().paused = false
	

func OverSelectableScene(currently_over): #sets scene_currently_over to a reference of the instanced scene currently being hovered over
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		#set currently_over to current instance hovered over and add hover effect
		scene_currently_over = currently_over
		scene_currently_over.set_physics_process(true)
		if currently_over == scene_currently_over:
			scene_currently_over.Blank.visible = true
		
		
func LeftSelectableScene():
	scene_currently_over.Blank.visible = false
	scene_currently_over.set_physics_process(false)
	scene_currently_over = null
		
		
		
# add, remove, and clear selected gates
# selection list should be cleared when blank canvas is clicked or gate is clicked
# when gate is clicked, add to selection list
func SelectGates():#Add list of gates (most of the time its just going to be one) to list of currently selected gates
	pass
	
func DeselectGate(): #Remove gate from list of selected gates (bc selection can only remove one at a time. use windows desktop for reference)
	pass
		
func SelectedGate(scenePath):
	selectedGate = scenePath

func _input(event):
	if event.is_action_pressed("click]") and selectedGate != null and mouseOverAndSelectionCast.get_collision_count() == 0 and !Input.is_key_pressed(KEY_CTRL):
		var gate_instance = load("res://Gate/Gate.tscn").instantiate()
		gate_instance.type = selectedGate
		gate_instance.position = get_local_mouse_position()
		$GateContainer.add_child(gate_instance)
		
		#naming of Gates upon creation
		#need to add a way to change the name later, but changing requires enforcement of naming conventions (why im skipping it for now)
		gate_instance.gateName = gate_instance.type.to_lower() + str(CountExistingGatesOfType(gate_instance.type)+1)
		gateReferencesByCategory[gate_instance.type].append(gate_instance)
	
		
		
	#just some tests here to see how i can make this functional
	elif event is InputEventMouseMotion and scene_currently_over is CharacterBody2D:
		mouseDelta = event.relative#Input.get_last_mouse_velocity()
			

			
func CreatePINConnection(PIN):
	if Input.is_key_pressed(KEY_CTRL):
		if newConnection == null:
			newConnection = load("res://Connection/Connection.tscn").instantiate()
			newConnection.get_node("Line2D").set_default_color(Color(0,1,1,1))
			newConnection.get_node("Line2D").width = 5
			newConnection.get_node("Line2D").add_point(scene_currently_over.position + PIN.position + PIN.get_node("Area2D/CollisionShape2D").position)
			newConnection.get_meta("nodesConnected")[0] = PIN
		elif newConnection != null:
			newConnection.get_node("Line2D").add_point(scene_currently_over.position + PIN.position + PIN.get_node("Area2D/CollisionShape2D").position)
			newConnection.get_meta("nodesConnected")[1] = PIN
			$GateContainer.add_child(newConnection)
			connectionsList.append(newConnection)
			newConnection.get_meta("nodesConnected")[0].connectionParticipatingIn = newConnection
			newConnection.get_meta("nodesConnected")[1].connectionParticipatingIn = newConnection
			newConnection = null

func SetSelectedGate(gateTypeIn):
	selectedGate = gateTypeIn


func _on_gd_example_position_changed(node, new_pos):
	#print("The position of " + node.get_class() + " is now " + str(new_pos))
	pass


func _on_gd_example_cpp_print_signal(node, print_string):
	#print("CPP Print: " + print_string)
	pass





func _on_simulate_logic_button_pressed():
	#output all elements in canvas to SDL file with proper connections
	var myFile = FileAccess.open("CircuitCanvas.sdl", FileAccess.WRITE)
	
	#myFile.store_string(str("NOT not1 NOT not2 ")) #this is for future reference
	print(connectionsList)
	
	
	myFile.store_line("$This is an SDL comment\n");
	
	myFile.store_line("COMPONENTS\n");
	
	#print all gates to components section grouped by category
	for gateCategory in gateReferencesByCategory:
		myFile.store_line("$" + gateCategory + " Gates:")
		for gateNodeReference in gateReferencesByCategory[gateCategory]:
			myFile.store_line(gateNodeReference.gateName)
		myFile.store_line("")

	myFile.store_line("ALIASES");
	myFile.store_line("CONNECTIONS");
	myFile.store_line("END");

	myFile = null
						
						


func CountExistingGatesOfType(gateType):
	var gateCount = 0
	for gateNode in gateReferencesByCategory[gateType]:
		gateCount+=1
	return gateCount
