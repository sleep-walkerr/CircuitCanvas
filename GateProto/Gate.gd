extends KinematicBody2D

var offset = Vector2(0,0)
var frame = 0
var type = "OR"
var gateSprite = Sprite.new()
onready var Blank = get_node("Blank")
var direction = Vector2(0,0)
var heldCalls = 0
var lastMousePos




func _on_Area2D_input_event(viewport, event, shape_idx):
	#time/frame based system
	#if Input.is_action_just_pressed("click]"):
		#offset = get_global_mouse_position() - self.position
		#if clicked add to reference list of currently selected gates
	if Input.is_action_just_pressed("click]"):
		lastMousePos = get_global_mouse_position()
	# detect drag only based on current location vs last
	if Input.is_mouse_button_pressed(1): #check if you clicked and then moved mouse w/o letting go of mouse 1 (for drag initiation) since last input event
		if lastMousePos != get_global_mouse_position():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			offset = lastMousePos - self.position
			#when dropped, set mouse_mode to invisible, set correct location (according to offset) and then set as visible again
		
		
		

# PROBLEM IN THIS FUNCTION - this doesn't just run when being held on selected gate, it runs on all gates when conditions are met
func _physics_process(delta): # should be used when querying the state of an input (in this case, to query whether left click is still pressed)
	#if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		#if Input.is_mouse_button_pressed(1):
			#heldCalls+=1 #counts number of frames where mouse is held (on all objects if not careful) on this object
			#if(heldCalls > 4):
				#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#else:
			#heldCalls = 0
				
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_mouse_button_pressed(1): 
		#print(heldCalls)
		#global_position = lerp(global_position, get_global_mouse_position() - offset, 25 * delta)
		#var direction = (get_global_mouse_position() - position) - offset
		move_and_collide(direction)
		direction = Vector2(0,0)
	elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		Input.warp_mouse_position(self.position + offset)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#heldCalls = 0
		
		
		
		
func set_Gate_Type(type):
	gateSprite.texture = load("res://GateProto/" + type + ".png")
	self.add_child(gateSprite)
	#script switching and whatnot will happen here when i've worked on the functionality of the gates later

func _ready():
	self.set_physics_process(false)
	set_Gate_Type(type)
	$Area2D.connect("mouse_entered", get_parent(), "OverSelectableScene", [self])
	$Area2D.connect("mouse_exited", get_parent(), "LeftSelectableScene", [null])

