extends KinematicBody2D

var offset
var frame = 0
var type = "OR"
var gateSprite = Sprite.new()



func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click]"):
		offset = get_global_mouse_position() - global_position

func _physics_process(delta): # should be used when querying the state of an input (in this case, to query whether left click is still pressed)
	if Input.is_mouse_button_pressed(1):
		#global_position = lerp(global_position, get_global_mouse_position() - offset, 25 * delta)
		var direction = (get_global_mouse_position() - position) - offset
		move_and_collide(direction)
		
func set_Gate_Type(type):
	gateSprite.texture = load("res://Gate/" + type + ".png")
	self.add_child(gateSprite)

func _ready():
	set_Gate_Type(type)
	$Area2D.connect("mouse_entered", get_parent(), "OverSelectableScene", [self])
	$Area2D.connect("mouse_exited", get_parent(), "LeftSelectableScene", [null])
