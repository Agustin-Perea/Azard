extends Node3D
class_name RouletteControl

signal spin_initialized
signal spin_finished

@export var roulette: Node3D
@export var ball: Node3D  # Ya no necesita ser RigidBody3D

@export var ball_origin_transform: Node3D

# === FASE 1: VELOCIDAD INICIAL ===
@export var angular_speed_deg: float = 500.0

# === FASE 2: DESACELERACIÓN ===
@export var deceleration_time: float = 6.0
@export var final_speed_deg: float = 60.0

# === FASE 3: ENCAJE ===
@export var drop_duration: float = 2.5
@export var inner_radius: float = 0.35
@export var finish_radius: float = 0.30
@export var choosed_field: int = 0

# === CONFIGURACIÓN ===
@export var lock_height: bool = true

# === CONSTANTES DE CAMPOS ===
const FIELD_COUNT := 37
const FIELD_ANGLE := TAU / FIELD_COUNT
const BASE_OFFSET := FIELD_ANGLE / 2.5

# === ESTADOS ===
enum Phase {
	INITIAL_SPEED,
	DECELERATION,
	DROPPING,
	ADJUST,
	FINISHED
}

var _current_phase: Phase = Phase.FINISHED
var _time := 0.0
var _phase_time := 0.0

var _center: Vector3
var _initial_radius: float
var _current_radius: float
var _height: float

var _omega_initial: float
var _omega_final: float
var _omega_current: float
var _omega_decay_rate: float

var _target_angle_local: float
var _roulette_initial_rotation: float

var angle_diff: float = 0.0
var _angle_rad: float = 0.0

@export var finish_y_level: float = -0.09


var _original_parent: Node

func _ready() -> void:

	assert(roulette, "Falta asignar la ruleta")
	assert(ball, "Falta asignar la bola")

	_original_parent = ball.get_parent()  # ← guardar hermano de roulette

	_initialize_geometry()
	_initialize_physics()
	_calculate_target()
	spin()


func spin() -> void:
	if choosed_field >= 0 and choosed_field < FIELD_COUNT:
		set_target_field(choosed_field)
	reset_simulation()


func _initialize_geometry() -> void:
	_center = roulette.global_transform.origin
	var rel := ball.global_transform.origin - _center
	_height = ball.global_transform.origin.y
	_initial_radius = Vector2(rel.x, rel.z).length()
	_current_radius = _initial_radius
	_angle_rad = atan2(rel.z, rel.x)


func _initialize_physics() -> void:
	_omega_initial = deg_to_rad(angular_speed_deg)
	_omega_final = deg_to_rad(final_speed_deg)
	_omega_current = _omega_initial
	_omega_decay_rate = (_omega_initial - _omega_final) / deceleration_time
	# Sin RigidBody: no hay gravity_scale, damp, freeze, etc.


func _calculate_target() -> void:
	_target_angle_local = (FIELD_ANGLE * choosed_field) + BASE_OFFSET
	_roulette_initial_rotation = roulette.global_rotation.y


func _physics_process(delta: float) -> void:
	_time += delta
	_phase_time += delta

	match _current_phase:
		Phase.INITIAL_SPEED:
			_process_initial_speed(delta)
		Phase.DECELERATION:
			_process_deceleration(delta)
		Phase.DROPPING:
			_process_dropping(delta)
		Phase.ADJUST:
			_process_adjust(delta)
		Phase.FINISHED:
			pass
			# Fijar la bola en la posición final
			#var spot_angle = -roulette.global_rotation.y + (choosed_field * FIELD_ANGLE) + BASE_OFFSET
			#var spot_pos_global = roulette.global_transform.origin + Vector3(sin(spot_angle), 0, cos(spot_angle)) * finish_radius
			#var target_ball_angle = atan2(spot_pos_global.x - _center.x, spot_pos_global.z - _center.z) - 1.5708
			#var finishPos = get_position_from_angle(target_ball_angle, finish_radius, roulette.global_position)
			#ball.global_position.x = finishPos.x
			#ball.global_position.z = finishPos.z


func _process_initial_speed(delta: float) -> void:
	_angle_rad += _omega_current * delta
	_move_ball_orbit(_current_radius)
	_transition_to(Phase.DECELERATION)


func _process_deceleration(delta: float) -> void:
	_omega_current = max(_omega_final, _omega_initial - _omega_decay_rate * _phase_time)
	_angle_rad += _omega_current * delta
	_move_ball_orbit(_current_radius)

	if _phase_time >= deceleration_time:
		_transition_to(Phase.DROPPING)


func get_relative_ball_angle(roulette_node: Node3D, ball_node: Node3D) -> float:
	var local_pos = ball_node.to_local(roulette_node.global_transform.origin)
	var angle = atan2(local_pos.x, local_pos.z)
	angle = fmod(angle + TAU, TAU)
	return angle


func _process_dropping(delta: float) -> void:
	angle_diff = wrapf(
		get_relative_ball_angle(roulette, ball)
		- roulette.global_rotation.y
		+ choosed_field * FIELD_ANGLE
		+ BASE_OFFSET,
		0, TAU
	)

	var radius_speed = (_initial_radius - inner_radius) / drop_duration
	_current_radius = move_toward(_current_radius, inner_radius, radius_speed * delta)

	var adjusted_omega = _omega_final
	var radius_reached = abs(_current_radius - inner_radius) < 0.01

	if radius_reached:
		var distance_factor = clamp(angle_diff / deg_to_rad(90.0), 0.1, 1.0)
		adjusted_omega = _omega_final * distance_factor

	_angle_rad += wrapf(adjusted_omega * delta, 0, TAU)
	_move_ball_smooth(_current_radius, _angle_rad, adjusted_omega)

	var angle_reached = (abs(angle_diff) < deg_to_rad(5) or abs(angle_diff - TAU) < deg_to_rad(5))

	if radius_reached and angle_reached and _phase_time > 0.5:
		_transition_to(Phase.ADJUST)


func _process_adjust(delta: float) -> void:
	var finish_radius_reached = abs(_current_radius - finish_radius) < 0.01

	var radius_speed = (_initial_radius - inner_radius) / drop_duration
	_current_radius = move_toward(_current_radius, finish_radius, radius_speed * delta)

	var spot_angle = -roulette.global_rotation.y + (choosed_field * FIELD_ANGLE) + BASE_OFFSET / 2
	var spot_pos_global = roulette.global_transform.origin + Vector3(sin(spot_angle), 0, cos(spot_angle)) * finish_radius
	var target_ball_angle = atan2(spot_pos_global.x - _center.x, spot_pos_global.z - _center.z) - 1.5708

	_move_ball_smooth(_current_radius, target_ball_angle, _omega_final)

	angle_diff = wrapf(
		get_relative_ball_angle(roulette, ball)
		- roulette.global_rotation.y
		+ choosed_field * FIELD_ANGLE
		+ BASE_OFFSET,
		0, TAU
	)
	var angle_reached = (abs(angle_diff) < deg_to_rad(5) or abs(angle_diff - TAU) < deg_to_rad(5))

	if finish_radius_reached and angle_reached:
		spin_finished.emit()
		print("Han finalizado")
		_transition_to(Phase.FINISHED)

	if _phase_time > 0.5:
		spin_finished.emit()
		var finish_pos = get_position_from_angle(target_ball_angle, finish_radius, roulette.global_position)
		ball.global_position.x = finish_pos.x
		ball.global_position.z = finish_pos.z
		ball.global_position.y = finish_y_level
		print("Han finalizado")
		_transition_to(Phase.FINISHED)


@warning_ignore("shadowed_variable")
func get_position_from_angle(target_ball_angle: float, finish_radius: float, center: Vector3) -> Vector3:
	var x = center.x + finish_radius * cos(target_ball_angle)
	var z = center.z + finish_radius * sin(target_ball_angle)
	return Vector3(x, center.y, z)


func _move_ball_orbit(radius: float) -> void:
	# Posicionamiento directo, sin física
	var x = _center.x + cos(_angle_rad) * radius
	var z = _center.z + sin(_angle_rad) * radius
	var y = _height if lock_height else ball.global_transform.origin.y
	ball.global_position = Vector3(x, y, z)


func _move_ball_smooth(radius: float, angle: float, omega: float) -> void:
	# Interpolación suave de posición XZ; Y desciende linealmente hacia finish_y_level
	var x = _center.x + cos(angle) * radius
	var z = _center.z + sin(angle) * radius

	var lerp_factor = clamp(0.1 + omega / _omega_final * 0.4, 0.1, 0.5)
	ball.global_position.x = lerp(ball.global_position.x, x, lerp_factor)
	ball.global_position.z = lerp(ball.global_position.z, z, lerp_factor)

	# Descenso suave en Y sin gravedad real
	ball.global_position.y = move_toward(ball.global_position.y, finish_y_level, 0.001 * (1.0 - omega / _omega_initial))


func _transition_to(new_phase: Phase) -> void:
	_current_phase = new_phase
	_phase_time = 0.0

	if new_phase == Phase.DROPPING:
		print("Iniciando fase de encaje en campo: ", choosed_field)
	elif new_phase == Phase.FINISHED:
		_finish_movement()


func _finish_movement() -> void:
	set_physics_process(false)

	# Reparentear bola → hija de roulette, manteniendo posición global
	var global_pos = ball.global_position
	ball.get_parent().remove_child(ball)
	roulette.add_child(ball)
	ball.global_position = global_pos  # ← restaurar posición tras reparenteo


func reset_simulation() -> void:
	_time = 0.0
	_phase_time = 0.0
	_current_phase = Phase.INITIAL_SPEED
	_omega_current = _omega_initial
	_current_radius = _initial_radius

	# Reparentear bola → de vuelta al nivel original (hermana de roulette)
	if ball.get_parent() != _original_parent:
		var global_pos = ball.global_position
		ball.get_parent().remove_child(ball)
		_original_parent.add_child(ball)
		ball.global_position = global_pos

	ball.global_position = ball_origin_transform.global_position

	_initialize_physics()
	set_physics_process(true)
	spin_initialized.emit()


func set_target_field(field: int) -> void:
	assert(field >= 0 and field < FIELD_COUNT, "Campo fuera de rango")
	choosed_field = field
	_calculate_target()
