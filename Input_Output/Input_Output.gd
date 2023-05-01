extends CharacterBody2D


var offset = Vector2(0,0)
var type
@onready var Blank = get_node("Blank")
var direction = Vector2(0,0)
var heldCalls = 0
var lastMousePos = Vector2(0,0)
var gateName
var inAndOutPINListDictionary = {"OUT" : [], "IN" : []}
var inTextEntryField = false



func _ready():
	$Area2D.connect("input_event",Callable(get_node("/root/Node2D"),"InstancedCircuitObjectInput").bind(self))
	if type == "IN":
		$BodyX.self_modulate = Color(0.0, 1.0, 1.0, 1.0)
	elif type == "OUT":
		$BodyX.self_modulate = Color(0.9, 0.4, 0.2, 1.0)
	
	
	$Input_Output_Label.pivot_offset = Vector2($Input_Output_Label.size / 2)
	$Area2D.position = Vector2($Input_Output_Label.size / 2)
	$BodyX.position = Vector2($Input_Output_Label.size / 2)
	$Blank.position =  Vector2($Input_Output_Label.size / 2)
	$CollisionShape2D.position = $BodyX.position
	get_node("TextEntryDetection/CollisionShape2D").shape.size = $Input_Output_Label.size
	get_node("TextEntryDetection/ColorRect").size = get_node("TextEntryDetection/CollisionShape2D").shape.size
	get_node("TextEntryDetection/ColorRect").position = (get_node("TextEntryDetection").position * -1)
	
	
	
	self.set_physics_process(false)
	set_in_out(type)
	
	if(type == "IN"):
		var outPIN = load("res://GatePIN/OutPIN.tscn").instantiate() #set a single time
		inAndOutPINListDictionary["OUT"].append(outPIN)
		outPIN.visible = false
		self.add_child(outPIN)
	elif (type == "OUT"):
		var inPIN = load("res://GatePIN/InPIN.tscn").instantiate() #set a single time
		inAndOutPINListDictionary["IN"].append(inPIN)
		inPIN.visible = false
		self.add_child(inPIN)

func _on_line_edit_text_changed(new_text):
	$Input_Output_Label.text = $Input_Output_Label.text.to_upper()
	








func set_in_out(type):
	# adds corresponding gate texture to instanced gate
	self.type = type
	#script switching and whatnot will happen here when i've worked on the functionality of the gates later


func _on_Area2D_input_event(viewport, event, shape_idx): #disconnect until full fix is complete in root node script
	
	if event.is_action_pressed("click]") and Input.is_key_pressed(KEY_CTRL):
		if type == "IN":
			get_node("/root/Node2D").CreatePINConnection(inAndOutPINListDictionary["OUT"][0])
		elif type == "OUT":
			get_node("/root/Node2D").CreatePINConnection(inAndOutPINListDictionary["IN"][0])
	
	if !inTextEntryField:
		if event is InputEventMouseButton:
			lastMousePos = get_global_mouse_position()
		# detect drag only based on current location vs last
		if !Input.is_key_pressed(KEY_CTRL):
			if Input.is_mouse_button_pressed(1): #check if you clicked and then moved mouse w/o letting go of mouse 1 (for drag initiation) since last input event
				if lastMousePos != get_global_mouse_position():
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
					offset = lastMousePos - self.position
					#when dropped, set mouse_mode to invisible, set correct location (according to offset) and then set as visible again
	else:
		if !Input.is_mouse_button_pressed(1):
			inTextEntryField = false



func _on_text_entry_detection_mouse_entered():
	inTextEntryField = true
	$Area2D.disconnect("input_event",Callable(self,"_on_Area2D_input_event"))


func _on_text_entry_detection_mouse_exited():
	$Area2D.connect("input_event",Callable(self,"_on_Area2D_input_event"))
