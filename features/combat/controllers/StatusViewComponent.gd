extends Node
class_name StatusViewComponent

@export var show_next_attack_icon : bool = true

@onready var damage_viewport : Sprite3D = $"../ModelVisualComponent/StatsView/DamageView"
@onready var damage_text : RichTextLabel = $"../ModelVisualComponent/StatsView/DamageSubViewport/RichTextLabel"


#en realidad deberia crearlos a traves de un prefab
@onready var health_sprite_viewport : Control = $"../ModelVisualComponent/StatsView/LifeHudControl"
@onready var health_progress_bar : ProgressBar = $"../ModelVisualComponent/StatsView/LifeHudControl/ProgressBar" #$"../ModelVisualComponent/StatsView/SubViewport/ProgressBar"
@onready var health_label_text : Label = $"../ModelVisualComponent/StatsView/LifeHudControl/Label" #$"../ModelVisualComponent/StatsView/LifeText"

@onready var shield_icon : TextureRect = $"../ModelVisualComponent/StatsView/LifeHudControl/ShieldTextureRect"
@onready var shield_bar : ColorRect = $"../ModelVisualComponent/StatsView/LifeHudControl/ColorRect"
@onready var shield_label : Label = $"../ModelVisualComponent/StatsView/LifeHudControl/ShieldLabel"

#deberia haber distintos tipos de iconos para cada siguiente ataque y es dado en atkInfo
@onready var action_icon : TextureRect = $"../ModelVisualComponent/StatsView/LifeHudControl/AttackTextureRect"
@onready var action_label : Label = $"../ModelVisualComponent/StatsView/LifeHudControl/AttackLabel"

var stats : StatsComponent

var health_tween : Tween
var displayed_health : float = 0.0
var displayed_shield : float = 0.0

@onready var action_controller : ActionController = $"../ActionController"


func set_up(view_stats : StatsComponent)->void:
	stats = view_stats
	
	displayed_health = stats.current_healt
	displayed_shield = stats.shield
	shield_label.text = str(int(round(displayed_shield)))
	
	stats.health_changed.connect(_update_health)


	UiEventBus.deactivate_status_view_component.connect(deactivate)
	UiEventBus.activate_status_view_component.connect(activate)

	health_progress_bar.max_value = stats.max_healt
	health_progress_bar.value = stats.current_healt
	health_label_text.text = str(int(round(stats.current_healt)))
	shield_label.text = str(int(round(stats.shield)))
	update_action()

func _show_health() -> void:
	health_sprite_viewport.visible = true
	
func _update_health() -> void:
	health_progress_bar.max_value = stats.max_healt
	
	show_life_drop_animation()
	

func _show_damaged(damage: float) -> void:
	damage_viewport.visible = true
	
	damage_text.bbcode_enabled = true
	damage_text.text = "[center][wave amp=50 freq=5]" + str(int(damage)) + "[/wave][/center]"
	
	# Reset transformaciones iniciales
	damage_viewport.scale = Vector3.ZERO
	damage_viewport.modulate.a = 1.0
	
	# Posicion inicial
	var initial_pos = damage_viewport.position 
		
	# Animacion de escala, secuancial, se necesitan 2 pasos
	var scale_tween = create_tween()
	scale_tween.tween_property(damage_viewport, "scale", Vector3(1, 1, 1), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(damage_viewport, "scale", Vector3(0.3, 0.3, 0.3), 0.9)
	
	# tween de movimiento, paralelo a posicion y transparencia
	var tween = create_tween().set_parallel(true)	
	# Animacion movimiento hacia arriba
	tween.tween_property(damage_viewport, "position:y", initial_pos.y + 1.5, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Desvanecimiento
	tween.tween_property(damage_viewport, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_LINEAR)
	
	# 4. Limpieza
	tween.finished.connect(func(): 
		damage_viewport.position = initial_pos # Reset para la próxima vez
		damage_viewport.visible = false #desactivar la visual de los nodos ahorra gpu, nodo.process_mode = Node.PROCESS_MODE_DISABLED ahorra cpu
		# queue_free() # esto borra la instancia del nodo	
	)

func activate()->void:
	health_label_text.visible = true
	health_sprite_viewport.visible = true
	
	if displayed_shield > 0:
		activate_shield_hud()
	else:
		deactivate_shield_hud()
		
	if show_next_attack_icon:
		action_icon.visible = true
		action_label.visible = true
	else:
		action_icon.visible = false
		action_label.visible = false
	

func deactivate()->void:
	health_label_text.visible = false
	health_sprite_viewport.visible = false

	deactivate_shield_hud()
		
	action_icon.visible = false
	action_label.visible = false

func deactivate_shield_hud()->void:
	shield_icon.visible = false
	shield_bar.visible = false
	shield_label.visible = false
	
func activate_shield_hud()->void:
	shield_icon.visible = true
	shield_bar.visible = true
	shield_label.visible = true
	
func show_life_drop_animation() -> void:
	activate()

	if health_tween:
		health_tween.kill()

	var target_health = stats.current_healt
	var target_shield = stats.shield

	health_progress_bar.max_value = stats.max_healt

	health_tween = create_tween()

	# 1. Escudo (solo si hay o hubo cambio relevante)
	if displayed_shield != target_shield:
		if target_shield > 0:
			activate_shield_hud()

		health_tween.tween_method(
			func(value):
				displayed_shield = value
				shield_label.text = str(int(round(value))),
			displayed_shield,
			target_shield,
			0.25
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		# después del escudo, decidir si se apaga HUD
		health_tween.tween_callback(func():
			if target_shield <= 0:
				deactivate_shield_hud()
		)

	health_tween.chain().set_parallel(true)
	# 2. Vida (siempre después del escudo)
	health_tween.tween_property(
		health_progress_bar,
		"value",
		target_health,
		0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	health_tween.tween_method(
		func(value):
			displayed_health = value
			health_label_text.text = str(int(round(value))),
		displayed_health,
		target_health,
		0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	

#debe elegir la representacion visual del siguiente ataque
func update_action() ->void:
	if action_controller.next_attacK_Info:
		action_icon.visible = true
		action_label.text = str(action_controller.next_attacK_Info.damage)
	
