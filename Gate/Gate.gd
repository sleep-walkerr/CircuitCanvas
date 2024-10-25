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

func set_Gate_Type(type):
	# adds corresponding gate texture to instanced gate
	gateSprite.texture = load("res://Icons/" + type + "Instanced.png")
	self.add_child(gateSprite)
	#script switching and whatnot will happen here when i've worked on the functionality of the gates later
	
	
func calculate_Output_PIN_Index(newPINNumber):
	#find new index of output pin
	inAndOutPINListDictionary["OUT"][0].set_meta("PINNo", newPINNumber+1)


func _ready():
	$Area2D.connect("input_event",Callable(get_node("/root/Node2D"),"InstancedCircuitObjectInput").bind(self))
	self.set_physics_process(false)
	set_Gate_Type(type)
	#configure output pin and add
	"""
	var outPIN = load("res://GatePIN/OutPIN.tscn").instantiate() #set a single time
	inAndOutPINListDictionary["OUT"].append(outPIN)
	self.add_child(outPIN)
	outPIN.position = Vector2(56, 0)
	"""
	
	#configure input pins
	"""
	if type != "Buffer" and type != "NOT":
		set_Input_PIN_Number(2)
	else:
		set_Input_PIN_Number(1)
	"""
		
func PINInputEvent(viewport, event, shape_idx, fromPIN):
	if event.is_action_pressed("click]") and Input.is_key_pressed(KEY_CTRL):
		get_node("/root/Node2D").CreatePINConnection(fromPIN)
		
func set_Input_PIN_Number(newPINNumber):	
	configureSpacerPoints(newPINNumber)
	InstancePinsAndPosition(newPINNumber)
	
	
	
	
func InstancePinsAndPosition(newPINNumber):	
	for i in range(newPINNumber):
		# i+2 because of the initial 2 points already on the line (points are in order of addition)
		var newGatePIN = load("res://GatePIN/InPIN.tscn").instantiate()
		newGatePIN.set_meta("PINNo", i+1)
		newGatePIN.show_behind_parent = true
		inAndOutPINListDictionary["IN"].append(newGatePIN)
		self.add_child(newGatePIN)
		newGatePIN.position = Vector2($PINSpacer.points[i+2] - Vector2(24, 0))
		calculate_Output_PIN_Index(newPINNumber)
	
func configureSpacerPoints(newPINNumber):
	var distance = abs($PINSpacer.points[0].y) + abs($PINSpacer.points[1].y)
	var increment = (distance / newPINNumber) / 2
	var currentPosition = $PINSpacer.points[0].y# will keep track of how many segments have been added for setting points
	var points = 2+newPINNumber
	for i in range(newPINNumber):
		currentPosition += increment
		$PINSpacer.add_point(Vector2($PINSpacer.points[0].x, currentPosition))
		currentPosition += increment
	

	
func AddPIN():
	if !(type == "NOT" or type == "Buffer"):
		$PINSpacer.clear_points()
		$PINSpacer.add_point(Vector2(-37, -40))
		$PINSpacer.add_point(Vector2(37,40))
		var newPINNumber = inAndOutPINListDictionary["OUT"][0].get_meta("PINNo")
		configureSpacerPoints(inAndOutPINListDictionary["OUT"][0].get_meta("PINNo"))
		print($PINSpacer.points)
		for inPIN in inAndOutPINListDictionary["IN"]:
			self.remove_child(inPIN)
		var newGatePIN = load("res://GatePIN/InPIN.tscn").instantiate()
		newGatePIN.set_meta("PINNo", newPINNumber)
		newGatePIN.show_behind_parent = true
		inAndOutPINListDictionary["IN"].append(newGatePIN)
		var index = 2
		for inPIN in inAndOutPINListDictionary["IN"]:
			add_child(inPIN)
			inPIN.position = Vector2($PINSpacer.points[index] - Vector2(24, 0))
			print(Vector2($PINSpacer.points[index] - Vector2(70, 0)))
			index += 1
		calculate_Output_PIN_Index(newPINNumber)
	
	
	
	
	
