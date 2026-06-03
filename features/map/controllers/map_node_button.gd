extends Button
class_name MapNodeButton
signal selected(map_node : MapNode)

const ICONS := {
	MapNode.Type.NOT_ASSIGNED: [null,Vector2.ONE/2],
	MapNode.Type.ENEMY: [preload("res://resources/map/map_icons/button_themes/enemy_button_theme.tres"),Vector2.ONE],
	MapNode.Type.REWARD: [preload("res://resources/map/map_icons/button_themes/reward_button_theme.tres"),Vector2.ONE],
	MapNode.Type.EVENT: [preload("res://resources/map/map_icons/button_themes/event_button_theme.tres"),Vector2.ONE],
	MapNode.Type.MINIBOSS: [preload("res://resources/map/map_icons/button_themes/miniboss_button_theme.tres"),Vector2.ONE *1.5],
	MapNode.Type.SHOP: [preload("res://resources/map/map_icons/button_themes/shop_button_theme.tres"),Vector2.ONE*1.25],
	MapNode.Type.BOSS: [preload("res://resources/map/map_icons/button_themes/boss_button_theme.tres"),Vector2.ONE * 2],	
}

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var available := false : set = set_available#no lo usamos para nada
var node : MapNode : set = set_map_node


func _ready() -> void:
	if not available:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

		
func set_available(new_value : bool)->void:
	available = new_value

	if available:
		disabled = false
		animation_player.play("map_button_animations/Sprite_HighLight")
		mouse_filter = Control.MOUSE_FILTER_STOP
		
	elif not node.selected:
		animation_player.play("RESET")
		deactivate()

		
func set_map_node(new_value : MapNode)->void:
	node = new_value
	position = node.position
	
	# Centrar el pivote automáticamente según el tamaño del botón
	pivot_offset = size / 2 
	# Desfasar la posición a la mitad de su tamaño para que el centro coincida con el punto
	position -= (size * scale) / 2
	
	theme = ICONS[node.type][0]
	scale = ICONS[node.type][1]
	
	#disabled = node.disabled
	if node.selected:
		animation_player.play("map_button_animations/select")

	
	
func show_selected()->void:
	#line_2d.modulate = Color.WHITE
	#animation_player.play("select")
	pass

func _on_map_node_selected()->void:
	selected.emit(node)

func _on_button_up() -> void:
	if not available:
		return
	node.selected = true
	animation_player.play("map_button_animations/select") #al finalizar llamar on map node selected
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_on_map_node_selected()

	#TransitionLayer._change_scene_to(node.node_scene.get_battle_scene())
	UiEventBus.change_scene_to.emit(node.node_scene.battle_scene_path)
	GameState.temp_scene_changed_value += 1

	

func deactivate():
	if animation_tween:
		animation_tween.kill()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	disabled = true
	

var animation_tween : Tween
func shake_animation(duration_frames: int):
	var original_pos = position # Guardamos el "home"
	var shake_intensity = 20.0  # Píxeles de fuerza
	
	if animation_tween:
		animation_tween.kill()
	animation_tween = create_tween()
	
	# Calculamos el tiempo en segundos (Godot usa segundos, no frames)
	var duration_sec = float(duration_frames) / 60.0 
	var steps = 5 # Cuántas veces va a saltar antes de volver
	
	for i in range(steps):
		var target_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		# Reducimos la intensidad en cada paso para que suavice al final
		shake_intensity *= 0.7 
		
		animation_tween.tween_property(self, "position", original_pos + target_offset, duration_sec / steps)
	
	# EL PASO FINAL: Aseguramos que vuelva al centro exacto
	animation_tween.tween_property(self, "position", original_pos, 0.05)

func scale_animation(duration: float, scale_multiplier: float = 1.2):
	# Si ya hay una animación, la matamos para no duplicar procesos
	if animation_tween:
		animation_tween.kill()
	
	animation_tween = create_tween().set_loops() # .set_loops() lo hace infinito
	
	# Guardamos la escala actual como base (por si no es Vector2(1,1))
	var base_scale = scale
	var target_scale = base_scale * scale_multiplier
	
	# Configuramos una transición suave tipo Senoidal
	animation_tween.set_trans(Tween.TRANS_SINE)
	animation_tween.set_ease(Tween.EASE_IN_OUT)
	
	# PASO 1: Crecer hasta la escala objetivo
	animation_tween.tween_property(self, "scale", target_scale, duration)
	
	# PASO 2: Volver a la escala original
	animation_tween.tween_property(self, "scale", base_scale, duration)
