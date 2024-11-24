extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CenterContainer/VBoxContainer/HBoxContainer/select_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedMode").bind(0)) # This will change to gate mode instead of select
	$CenterContainer/VBoxContainer/HBoxContainer/delete_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedMode").bind(1))
	$CenterContainer/VBoxContainer/HBoxContainer/wire_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedMode").bind(2))
	$CenterContainer/VBoxContainer/HBoxContainer2/input_output_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedMode").bind(3))
	$CenterContainer/VBoxContainer/HBoxContainer2/NameEntryElements/rename_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedMode").bind(4))
	$CenterContainer/VBoxContainer/HBoxContainer2/NameEntryElements/RenameEntrySection/VBoxContainer/enter_button.connect("pressed",Callable(get_node("/root/Node2D"),"RenameObject"))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
