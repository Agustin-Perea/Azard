extends Node3D
class_name BooksController

const HELP_BOOK_SCRIPT := preload("res://features/book/views/help_book_controller.gd")
const HELP_LEFT_COVER_MESH := preload("res://resources/map/models/map_left_case.res")
const HELP_RIGHT_COVER_MESH := preload("res://resources/map/models/map_right_case.res")
const HELP_BOTTOM_COVER_MESH := preload("res://resources/map/models/map_bottom_case.res")
const HELP_BOOK_MATERIAL := preload("res://resources/book/materials/book_material.tres")
const BOOK_ANIMATIONS := preload("res://resources/book/animations/book_animations.res")

@onready var book_none : Node3D = $"../ModelVisualComponent/mage/bro_rig/Skeleton3D/stats_left_cover_001"
@onready var book_case : Node3D = $CaseBook
@onready var book_roulette : Node3D = $Book
@onready var book_map : Node3D = $MapBook
var book_help : Node3D

@onready var audio_stream : AudioStreamPlayer = $"../Sounds/AudioStreamPlayer"
var sonidos = {
	"book_open": preload("res://resources/sounds/open_book.wav"),
	"book_close": preload("res://resources/sounds/kodack__closing-a-book.wav")
}

var pages_dictionary : Dictionary 
var actual_page : Node3D

var last_position : Vector3
var book_transitioning := false
var queued_book_page := -1
var transition_animation_player : AnimationPlayer

func _ready() -> void:
	book_help = _create_help_book()
	actual_page = book_roulette
	pages_dictionary = {
	Constants.BOOK_PAGE.ROULETTE : book_roulette,
	Constants.BOOK_PAGE.MAP : book_map,
	Constants.BOOK_PAGE.CASE : book_case,
	Constants.BOOK_PAGE.NONE : book_none,
	Constants.BOOK_PAGE.HELP : book_help
	}
	UiEventBus.change_book_page.connect(change_book)

	

#deberia iniciar la animacion
func change_book(book_page : Constants.BOOK_PAGE)->void:
	if not pages_dictionary.has(book_page):
		return
	var next_page : Node3D = pages_dictionary[book_page]
	if book_transitioning:
		queued_book_page = book_page
		return
	if next_page == actual_page:
		UiEventBus.book_page_change_finished.emit(book_page)
		return

	book_transitioning = true
	queued_book_page = -1
	transition_animation_player = null
	UiEventBus.book_page_change_started.emit(book_page)

	var closing_page := actual_page
	var opening_page := next_page

	if closing_page != book_none && closing_page && closing_page != opening_page:
		var actual_animation_player : AnimationPlayer = closing_page.get_node_or_null("AnimationPlayer")

		UiEventBus.deactivate_descriptions.emit()
		UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.StandBy)
		
		actual_animation_player.play("book_animations/book_close")
		audio_stream.stream = sonidos["book_close"]
		audio_stream.play()
		
		EventManager.add_event(EventManager.QueueType.GAME, 
		GameEvent.new({
			"paralel": false,
			"action": func():
				return !actual_animation_player.is_playing()
		}))	

		EventManager.add_event(EventManager.QueueType.GAME, 
		GameEvent.new({
			"paralel": false,
			"action": func():
				UiEventBus.apply_camera_shake.emit(.05, .2, 15)
				return true
		}))	
		EventManager.add_event(EventManager.QueueType.GAME, 
		GameEvent.new({
			"paralel": false,
			"delay" : 0.2,
			"action": func():
				closing_page.global_position.y += 200
				closing_page.visible = false
				return true
		}))	


	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			if opening_page == book_none && actual_page != opening_page:
				actual_page.visible = false
				opening_page.visible = true
				
			elif opening_page && actual_page != opening_page:
				actual_page.visible = false
				opening_page.visible = true
				opening_page.global_position.y -= 200

				var animation_player : AnimationPlayer = opening_page.get_node_or_null("AnimationPlayer")
				animation_player.play("book_animations/book_open")
				transition_animation_player = animation_player
				
				audio_stream.stream = sonidos["book_open"]
				audio_stream.play()
				
			actual_page = opening_page
			return true
	}))

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			return transition_animation_player == null || !transition_animation_player.is_playing()
	}))

	EventManager.add_event(EventManager.QueueType.GAME,
	GameEvent.new({
		"paralel": false,
		"action": func():
			_finish_book_transition(book_page)
			return true
	}))


		#await next_page.active_tween.finished


	
func _finish_book_transition(book_page : Constants.BOOK_PAGE) -> void:
	book_transitioning = false
	transition_animation_player = null
	UiEventBus.book_page_change_finished.emit(book_page)
	if queued_book_page != -1 && queued_book_page != book_page:
		var page_to_open := queued_book_page
		queued_book_page = -1
		change_book.call_deferred(page_to_open)
	else:
		queued_book_page = -1

func _create_help_book() -> Node3D:
	var help_book: Node3D = HELP_BOOK_SCRIPT.new()
	help_book.name = "HelpBook"
	help_book.transform = book_case.transform
	help_book.visible = false

	_add_help_book_mesh(help_book, "bottom_cover", HELP_BOTTOM_COVER_MESH, Transform3D.IDENTITY, HELP_BOOK_MATERIAL)
	_add_help_book_mesh(help_book, "left_cover", HELP_LEFT_COVER_MESH, Transform3D.IDENTITY, HELP_BOOK_MATERIAL)
	_add_help_book_mesh(help_book, "right_cover", HELP_RIGHT_COVER_MESH, Transform3D.IDENTITY, HELP_BOOK_MATERIAL)

	var animation_player := AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	animation_player.add_animation_library("book_animations", BOOK_ANIMATIONS)
	help_book.add_child(animation_player)

	add_child(help_book)
	help_book.setup()
	return help_book

func _add_help_book_mesh(parent: Node3D, mesh_name: String, mesh_resource: ArrayMesh, mesh_transform: Transform3D, material: Material = null) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = mesh_name
	mesh_instance.mesh = mesh_resource
	mesh_instance.transform = mesh_transform
	if material:
		mesh_instance.material_override = material
	parent.add_child(mesh_instance)
	return mesh_instance
	
