extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("mouse_entered", get_node("/root/Node2D"), "OverSelectableScene", [self])
	self.connect("mouse_exited", get_node("/root/Node2D"), "LeftSelectableScene", [null])





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
