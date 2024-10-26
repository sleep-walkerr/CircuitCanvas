extends Panel
var dragging = false
var dragging_start_position = Vector2()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragging:
		get_window().position = Vector2(get_window().position) + get_global_mouse_position() - dragging_start_position
		
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			dragging = !dragging
			dragging_start_position = get_global_mouse_position()
	


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_minimize_button_button_down() -> void:
	get_tree().root.mode = Window.MODE_MINIMIZED
