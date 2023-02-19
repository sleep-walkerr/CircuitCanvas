extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var selectedGate = null
var scene_currently_over
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func OverSelectableScene(currently_over): #sets scene_currently_over to a reference of the instanced scene currently being hovered over
	scene_currently_over = currently_over
	
func LeftSelectableScene(currently_over): #sets scene_currently_over to null, bc now you aren't over anything...
	scene_currently_over = currently_over
	
func SelectedGate(scenePath):
	selectedGate = scenePath

func _input(event):
	if event.is_action_pressed("click]") and scene_currently_over == null:
		var gate_instance = load("res://Gate/Gate.tscn").instance()
		gate_instance.position = get_local_mouse_position()
		gate_instance.type = selectedGate
		self.add_child(gate_instance)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


