class_name PlayerUnit extends Unit



func _ready() -> void:
	stats = GameState.player_stats
	
	status_view_component.set_up(stats)
	stats.set_up()
	#movement_manager.base_damage = ataque
	animation_state_machine = animation_tree.get("parameters/playback")
	#camera_state_machine = camera_animation_tree.get("parameters/playback")
	#if not attack_camera:
		#attack_camera = get_node_or_null("CameraAttack/Camera-camera")
	#movement_manager.attacker = self
	stats.death.connect(_death)
	
	@warning_ignore("unused_parameter")
	animation_tree.animation_finished.connect(func(anim_name: StringName): anim_finished = true)
