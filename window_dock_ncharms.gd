extends Panel
var dragging = false
var dragging_start_position = Vector2()
var is_hovering_over_button = false
var is_within_gui = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragging and get_window().has_focus():
		get_window().position = Vector2(get_window().position) + get_global_mouse_position() - dragging_start_position
		
func _ready() -> void:
	$TextureButton.connect("pressed", Callable(get_node("/root/Node2D/"),"ExportToSDL"))
		
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click]") and !dragging:
		dragging = !dragging
		dragging_start_position = get_global_mouse_position()
	elif !Input.is_mouse_button_pressed(1) and dragging:
		dragging = false

func HoveringOverButton() -> void:
	is_hovering_over_button = true
	
func NotHoveringOverButton() -> void:
	is_hovering_over_button = false

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_minimize_button_button_down() -> void:
	get_window().mode = Window.MODE_MINIMIZED

func _on_mouse_entered() -> void:
	is_within_gui = true


func _on_mouse_exited() -> void:
	is_within_gui = false
