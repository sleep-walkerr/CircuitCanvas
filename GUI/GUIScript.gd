extends Panel
var typeList = ['AND', 'NAND', 'NOR', 'NOT', 'OR', 'XNOR', 'XOR', 'IN', 'OUT', 'Delete']

# currentOtherTextureButton.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind(currentOtherTextureButton))


# Called when the node enters the scene tree for the first time.
func _ready():
	for type in typeList:
		var newGateSelectionContainer = load("res://GUI/GateSelectionContainer.tscn").instantiate()
		newGateSelectionContainer.get_node("LabelPanel/GateSelectionLabel").text = type
		newGateSelectionContainer.get_node("GateButtonPanel/GateSelectionButton").texture_normal = load("res://Icons/" + type + ".png")
		newGateSelectionContainer.get_node("GateButtonPanel/GateSelectionButton").texture_pressed = load("res://Icons/" + type + "Pressed.png")
		newGateSelectionContainer.get_node("GateButtonPanel/GateSelectionButton").connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind(newGateSelectionContainer))
		newGateSelectionContainer.name = type + "SelectionContainer"
		newGateSelectionContainer.set_meta("type", type)
		$SelectionButtonsContainer.add_child(newGateSelectionContainer)
