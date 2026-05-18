extends Control


@onready var button : Button = $Button
@onready var panel : Panel = $Panel
@onready var text : RichTextLabel = $RichTextLabel

func _ready() -> void:
	button.button_down.connect(_on_button_button_down)
	UiEventBus.scene_changed.connect(set_up)
	BookEventBus.defeat.connect(_on_defeat)
	set_up()

func set_up()->void:
	self.visible = false
	

func _on_button_button_down() -> void:
	GameState.end_run()
	UiEventBus.change_scene_to.emit(GameState.MAIN_MENU_SCENE_PATH)

func _on_defeat()->void:
	self.visible = true
	
	panel.modulate.a = 0
	text.modulate.a = 0
	button.modulate.a = 0
	button.scale = Vector2.ZERO 
	button.pivot_offset = button.size / 2 


	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(panel, "modulate:a", 1.0, 2).set_trans(Tween.TRANS_EXPO)
	

	tween.tween_property(text, "modulate:a", 1.0, 1)
	

	tween.parallel().tween_property(button, "modulate:a", 1.0, .5)
	tween.tween_property(button, "scale", Vector2.ONE, 1)
	
