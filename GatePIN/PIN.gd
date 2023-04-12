extends Node2D

#$Area2D.connect("mouse_entered",Callable(get_parent(),"OverSelectableScene").bind(self))
#$Area2D.connect("input_event",Callable(get_parent(),"OverSelectableScene").bind(self))
var connectionParticipatingIn

func _ready():
		$Area2D.connect("input_event",Callable(get_parent(),"PINInputEvent").bind(self))
