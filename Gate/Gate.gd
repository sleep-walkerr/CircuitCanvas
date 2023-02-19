extends KinematicBody2D

var selected = false
var offset
var frame = 0
var type = null
var gateSprite = Sprite.new()



func _on_Area2D_input_event(viewport, event, shape_idx):
		if Input.is_action_just_pressed("click]"):
			selected = true
			offset = get_global_mouse_position() - global_position
			
			
			
			
func _physics_process(delta): #consider using *_input (not the same as _input)
	if selected:
		#global_position = lerp(global_position, get_global_mouse_position() - offset, 25 * delta)
		var direction = (get_global_mouse_position() - position) - offset
		move_and_collide(direction)
		

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			selected = false
	
func set_Gate_Type(type):
	gateSprite.texture = load("res://Gate/" + type + ".png")
	self.add_child(gateSprite)


func _ready():
	set_Gate_Type(type)
	$Area2D.connect("mouse_entered", get_parent(), "OverSelectableScene", [self])
	$Area2D.connect("mouse_exited", get_parent(), "LeftSelectableScene", [null])
	
