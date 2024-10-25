#this needs to be done from main gui panel using $ selector
extends Panel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScrollContainer/GateSelectContainer/and_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind("AND"))
	$ScrollContainer/GateSelectContainer/or_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind("OR")) 
	$ScrollContainer/GateSelectContainer/not_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind("NOT"))
	$ScrollContainer/GateSelectContainer/nand_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind("NAND"))
	$ScrollContainer/GateSelectContainer/nor_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind("NOR"))
	$ScrollContainer/GateSelectContainer/xor_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind("XOR"))
	$ScrollContainer/GateSelectContainer/xnor_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind("XNOR"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
