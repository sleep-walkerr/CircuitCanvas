extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var selectedGate = "bruh"
var hovering_instanced_scene = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func EnteredInstancedScene():
	print("Entered instanced scene...")
	hovering_instanced_scene = true
	
func ExitedInstancedScene():
	hovering_instanced_scene = false
	
func SelectedGate(scenePath):
	selectedGate = scenePath

func _input(event):
	if event.is_action_pressed("click]") and hovering_instanced_scene == false:
		var gate_instance = load("res://Gate/Gate.tscn").instance()
		gate_instance.position = get_local_mouse_position()
		self.add_child(gate_instance)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


