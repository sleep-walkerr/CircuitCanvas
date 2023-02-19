extends KinematicBody2D

var selected = false
var offset
var frame = 0

func _on_Area2D_input_event(viewport, event, shape_idx):
		if Input.is_action_just_pressed("click]"):
			selected = true
			offset = get_global_mouse_position() - global_position
			
			
			
			
			
func _physics_process(delta):
	if selected:
		#for non-collision slide through
		#global_position = lerp(global_position, get_global_mouse_position() - offset, 25 * delta) 
		
		#for collision based interaction with gates 
		var direction = (get_global_mouse_position() - position) - offset
		move_and_collide(direction)
		

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			selected = false


func _on_BufferTest_ready():
	$Area2D.connect("mouse_entered", get_parent(), "EnteredInstancedScene")
	$Area2D.connect("mouse_exited", get_parent(), "ExitedInstancedScene")
