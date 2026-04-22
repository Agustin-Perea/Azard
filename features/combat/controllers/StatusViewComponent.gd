extends Node
class_name StatusViewComponent

@onready var damage_viewport : Sprite3D = $"../ModelVisualComponent/StatsView/DamageView"
@onready var damage_text : RichTextLabel = $"../ModelVisualComponent/StatsView/DamageSubViewport/RichTextLabel"


#en realidad deberia crearlos a traves de un prefab
@onready var health_sprite_viewport : Sprite3D = $"../ModelVisualComponent/StatsView/LifeView"
@onready var health_progress_bar : ProgressBar = $"../ModelVisualComponent/StatsView/SubViewport/ProgressBar"
@onready var health_label_text : Label3D = $"../ModelVisualComponent/StatsView/LifeText"

@onready var stats : StatsComponent = $"../StatsComponent"


func _ready() -> void:
	stats.health_changed.connect(_update_health)
	_update_health()

func _show_health() -> void:
	health_sprite_viewport.visible = true
	
func _update_health() -> void:
	health_progress_bar.max_value = stats.max_healt
	health_progress_bar.value = stats.current_healt
	health_label_text.text = str(stats.current_healt)

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
