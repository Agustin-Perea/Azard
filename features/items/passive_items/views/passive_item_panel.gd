extends Panel
class_name PassiveItemPanel

signal tooltip_requested(panel: PassiveItemPanel, data_model: PassiveItemDefinition)
signal tooltip_closed(panel: PassiveItemPanel)

@onready var sprite : Sprite2D = $PassiveItemSprite
@onready var cant : Label = $Label
var dataModel : PassiveItemDefinition #esto va a ser agregado por el tableState
var quantity := 1

var active_tween : Tween
@export var animate_time : float = 0.5
@export var default_sprite_scale : float = 0.5
@export var default_sprite_alpha : float = 0.7

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	if dataModel:
		#dataModel.animate.connect(_animate) quiza agregarlo en el runtime
		sprite.texture = dataModel.image_texture
	_update_quantity_label()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tooltip_requested.emit(self, dataModel)

func set_quantity(value: int) -> void:
	quantity = max(1, value)
	_update_quantity_label()

func _update_quantity_label() -> void:
	if cant == null:
		return
	cant.visible = quantity > 1
	cant.text = "x" + str(quantity)

func _on_mouse_entered() -> void:
	tooltip_requested.emit(self, dataModel)

func _on_mouse_exited() -> void:
	tooltip_closed.emit(self)

func _animate() -> void:
	#al no esperar que termine la animacion se agregan n eventos bloqueados por el siguiente evento al llamar este metodo
	#por eso es bueno asegurar que el siguiente evento sea el bloqueante o sino se reescribiria el tween
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
			"action": func():
			_update_quantity_label()
			if active_tween:
				active_tween.kill()

			active_tween = create_tween()

			active_tween.set_parallel(true)
			sprite.scale *= 1.5
			active_tween.tween_property(sprite, "modulate:a", 1.0, animate_time/2).set_trans(Tween.TRANS_CUBIC)
			active_tween.tween_property(sprite, "scale", Vector2.ONE * default_sprite_scale, animate_time/2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			
			#active_tween.chain().tween_property(sprite, "scale", last_scale, animate_time/2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			active_tween.chain().tween_property(sprite, "modulate:a", default_sprite_alpha, animate_time*2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			
			return true
	}))
