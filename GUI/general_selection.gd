extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CenterContainer/HBoxContainer/delete_button.connect("pressed",Callable(get_node("/root/Node2D"),"SetSelectedGate").bind("Delete"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
