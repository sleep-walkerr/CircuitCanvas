extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", get_parent(), "OverSelectionGUI")
	connect("mouse_exited", get_parent(), "LeftSelectionGUI")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass





