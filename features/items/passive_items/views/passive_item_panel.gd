extends Button
extends Button
class_name PassiveItemPanel
@onready var sprite : Sprite2D = $PassiveItemSprite
@onready var cant : Label = $Label

#debe ser un runtime
var dataModel : PassiveItemRuntimeState #esto va a ser agregado por el tableState

#debe ser un runtime
var dataModel : PassiveItemRuntimeState #esto va a ser agregado por el tableState

var active_tween : Tween
@export var animate_time : float = 0.5
@export var default_sprite_scale : float = 0.5
@export var default_sprite_alpha : float = 0.7

func _ready() -> void:
	if dataModel:
		#dataModel.animate.connect(_animate) quiza agregarlo en el runtime
		sprite.texture = dataModel.passive_item_definition.image_texture
		sprite.texture = dataModel.passive_item_definition.image_texture

func _animate() -> void:
	#al no esperar que termine la animacion se agregan n eventos bloqueados por el siguiente evento al llamar este metodo
	#por eso es bueno asegurar que el siguiente evento sea el bloqueante o sino se reescribiria el tween
	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			if dataModel.quantity > 1:
				cant.text = "x" + str(dataModel.quantity)
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

func update_view():
	if dataModel.quantity > 1:
		cant.visible = true
		cant.text = "x" + str(dataModel.quantity)
	else:
		cant.visible = false
		
