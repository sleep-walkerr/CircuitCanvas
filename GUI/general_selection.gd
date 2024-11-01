extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CenterContainer/HBoxContainer/select_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedMode").bind(0)) # This will change to gate mode instead of select
	$CenterContainer/HBoxContainer/delete_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedMode").bind(1))
	$CenterContainer/HBoxContainer/wire_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedMode").bind(2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
