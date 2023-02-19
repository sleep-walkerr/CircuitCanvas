extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("mouse_entered", get_parent(), "EnteredInstancedScene")
	self.connect("mouse_exited", get_parent(), "ExitedInstancedScene")





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
