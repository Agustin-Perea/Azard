extends Control

@onready var color_rect : ColorRect = $ColorRect

var scene_to_load : String
var color_rect_tween : Tween

func _ready() -> void:
	UiEventBus.change_scene_to.connect(_change_scene_to)
	UiEventBus.change_scene_to_packed.connect(_change_scene_to_packed)
	visible = true
	color_rect.modulate.a = 0.0

func _change_scene_to(scene : String)->void:
	if color_rect_tween:
		color_rect_tween.kill()
	
	scene_to_load = scene
	
	color_rect_tween = create_tween().set_trans(Tween.TRANS_SINE)
	color_rect_tween.tween_property(color_rect,"modulate:a", 1.0,0.5).connect("finished",_load_new_scene)
	color_rect_tween.chain().tween_property(color_rect,"modulate:a", 0.0,2)

func _change_scene_to_packed(scene : PackedScene)->void:
	
	if color_rect_tween:
		color_rect_tween.kill()

	color_rect_tween = create_tween().set_trans(Tween.TRANS_SINE)
	color_rect_tween.tween_property(color_rect,"modulate:a", 1.0,0.5).connect("finished",func(): 
		get_tree().call_deferred("change_scene_to_packed",scene)
		UiEventBus.scene_changed.emit())
	color_rect_tween.chain().tween_property(color_rect,"modulate:a", 1.0,0.3)
	color_rect_tween.chain().tween_property(color_rect,"modulate:a", 0.0,2)

func _load_new_scene()->void:
	
	get_tree().call_deferred("change_scene_to_file",scene_to_load)
	UiEventBus.scene_changed.emit()
	


func _change_scente_to_with_texture_transition(scene : String)->void:
	var captura = get_viewport().get_texture().get_image()
	var textura_final = ImageTexture.create_from_image(captura)
	$TextureRect.texture = textura_final
	$TextureRect.show()

	if color_rect_tween:
		color_rect_tween.kill()
	
	scene_to_load = scene
	
	color_rect_tween = create_tween().set_trans(Tween.TRANS_SINE)
	$TextureRect.modulate.a = 1.0
	color_rect_tween.tween_property($TextureRect,"modulate:a", 1.0,0.0).connect("finished",_load_new_scene)

	
