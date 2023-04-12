extends CharacterBody2D

var offset = Vector2(0,0)
var frame = 0
var type = "NOT"
var gateSprite = Sprite2D.new()
@onready var Blank = get_node("Blank")
var direction = Vector2(0,0)
var heldCalls = 0
var lastMousePos
var gateName #this will hold the identifier of the gate that will be used in the SDL file
var inAndOutPINListDictionary = {"OUT" : [], "IN" : []} #hold references to all instanced PIN nodes


func _on_Area2D_input_event(viewport, event, shape_idx):
	#time/frame based system
	#if Input.is_action_just_pressed("click]"):
		#offset = get_global_mouse_position() - self.position
		#if clicked add to reference list of currently selected gates
	if Input.is_action_just_pressed("click]"):
		lastMousePos = get_global_mouse_position()
	# detect drag only based on current location vs last
	if !Input.is_key_pressed(KEY_CTRL):
		if Input.is_mouse_button_pressed(1): #check if you clicked and then moved mouse w/o letting go of mouse 1 (for drag initiation) since last input event
			if lastMousePos != get_global_mouse_position():
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				offset = lastMousePos - self.position
				#when dropped, set mouse_mode to invisible, set correct location (according to offset) and then set as visible again
		
		
func set_Gate_Type(type):
	# adds corresponding gate texture to instanced gate
	gateSprite.texture = load("res://Gate/" + type + "Instanced.png")
	self.add_child(gateSprite)
	#script switching and whatnot will happen here when i've worked on the functionality of the gates later
	
func calculate_Output_PIN_Index(newPINNumber):
	#find new index of output pin
	inAndOutPINListDictionary["OUT"][0].set_meta("PINNo", newPINNumber+1)

func set_Input_PIN_Number(newPINNumber):
	# instances pins into instanced gate
	
	#set up points on Line2D first
	#first get the distance btw points
	var distance = abs($PINSpacer.points[0].y) + abs($PINSpacer.points[1].y)
	var increment = (distance / newPINNumber) / 2
	var currentPosition = $PINSpacer.points[0].y# will keep track of how many segments have been added for setting points
	var points = 2+newPINNumber
	for i in range(newPINNumber):
		currentPosition += increment
		$PINSpacer.add_point(Vector2($PINSpacer.points[0].x, currentPosition))
		currentPosition += increment
		
	for i in range(newPINNumber):
		# i+2 because of the initial 2 points already on the line (points are in order of addition)
		var newGatePIN = load("res://GatePIN/InPIN.tscn").instantiate()
		newGatePIN.set_meta("PINNo", i+1)

		newGatePIN.show_behind_parent = true
		inAndOutPINListDictionary["IN"].append(newGatePIN)
		self.add_child(newGatePIN)
		newGatePIN.position = Vector2($PINSpacer.points[i+2] - Vector2(24, 0))
		
	#anytime a new input pin number is set, total input pins will be counted and then the index of the output pin will be known
	calculate_Output_PIN_Index(newPINNumber)
	

	



func _ready():
	self.set_physics_process(false)
	set_Gate_Type(type)
	#configure output pin and add
	var outPIN = load("res://GatePIN/OutPIN.tscn").instantiate() #set a single time
	inAndOutPINListDictionary["OUT"].append(outPIN)
	self.add_child(outPIN)
	outPIN.position = Vector2(76, 0)
	
	#configure input pins
	if type != "Buffer" and type != "NOT":
		set_Input_PIN_Number(2)
	else:
		set_Input_PIN_Number(1)
		
	


func PINInputEvent(viewport, event, shape_idx, fromPIN):
	if event.is_action_pressed("click]") and Input.is_key_pressed(KEY_CTRL):
		get_node("/root/Node2D").CreatePINConnection(fromPIN)
