extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var selectedGate = "OR"
var scene_currently_over
var selected_scenes
var overCanvas = true

var mouseDelta = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func OverSelectionGUI(): #pause everything except for selectionGUI when inside of it
	get_tree().paused = true
func LeftSelectionGUI():
	get_tree().paused = false
	print("exited..")

#change to raycast system later to see if it is better
func OverSelectableScene(currently_over): #sets scene_currently_over to a reference of the instanced scene currently being hovered over
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if scene_currently_over != null:
			# remove hover effect on last instance
			scene_currently_over.Blank.visible = false
			scene_currently_over.set_physics_process(false)
		#set currently_over to current instance hovered over and add hover effect
		scene_currently_over = currently_over
		scene_currently_over.set_physics_process(true)
		scene_currently_over.Blank.visible = true
	
func LeftSelectableScene(currently_over): #sets scene_currently_over to null, bc now you aren't over anything...
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if scene_currently_over != null:
			scene_currently_over.Blank.visible = false
			scene_currently_over.set_physics_process(false)
			
		scene_currently_over = currently_over
		
		
		
		
		
		
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
	if event.is_action_pressed("click]") and selectedGate != null and scene_currently_over == null and overCanvas == true:
		var gate_instance = load("res://GateProto/Gate.tscn").instance()
		gate_instance.type = selectedGate
		gate_instance.position = get_local_mouse_position()
		self.add_child(gate_instance)
		
	#just some tests here to see how i can make this functional
	elif event is InputEventMouseMotion and scene_currently_over is KinematicBody2D:
		mouseDelta = event.relative#Input.get_last_mouse_speed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(Performance.get_monitor(Performance.TIME_FPS))
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		scene_currently_over.direction += mouseDelta * 1000 * delta#Input.get_last_mouse_speed()
		mouseDelta = Vector2(0,0)
	
	
	





func OverCanvas():
	print("over canvas")
	overCanvas = true


func LeftCanvas():
	print("left canvas")
	overCanvas = false
