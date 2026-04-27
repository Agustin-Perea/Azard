extends BaseState


@export var change_camera : bool = true
@export var camera : Camera3D
#estrategia de comportamiento
@export var fixed_time : float = .5
@export var disable_book_inputs : bool = true
@export var ui_book_button : bool = false
@export var ui_selection_button : bool = false



##en una clase especifica puedes escribir las callbacks de game loop(process,inputs etc)
func start():
	#activar funciones en base a los booleanos
	if change_camera:
		UiEventBus.changeCamera.emit(camera,fixed_time)
	UiEventBus.book_button_visible.emit(ui_book_button)
	UiEventBus.selection_button_visible.emit(ui_selection_button)
	UiEventBus.book_inputs_enabled.emit(disable_book_inputs)
	UiEventBus.change_collision_detection.emit(disable_book_inputs)
	
func end():
	pass
