extends MarginContainer
var typeList = ['AND', 'OR', 'NOR']

# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	for gateType in typeList: #for each listed gateType
		var currentGateSelectionLabel = Label.new()
		currentGateSelectionLabel.text = gateType
		currentGateSelectionLabel.align = Label.ALIGN_CENTER
		currentGateSelectionLabel.add_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0))
		# set color to black or something here
		$VBoxContainer.add_child(currentGateSelectionLabel)
		
		var currentGateTextureButton = TextureButton.new()
		currentGateTextureButton.texture_normal = load("res://Gate/" + gateType + ".png")
		$VBoxContainer.add_child(currentGateTextureButton)

	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass







#func _on_ANDButton_pressed():
	#get_node("/root/Node2D").SelectedGate("AND")
