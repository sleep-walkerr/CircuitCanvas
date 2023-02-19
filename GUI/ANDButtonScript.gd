extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("mouse_entered", get_parent().get_parent().get_parent(), "EnteredInstancedScene")
	self.connect("mouse_exited", get_parent().get_parent().get_parent(), "ExitedInstancedScene")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ANDButton_pressed():
	get_parent().get_parent().get_parent().SelectedGate("AND")
