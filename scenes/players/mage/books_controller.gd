extends Node3D
class_name BooksController

@onready var book_none : Node3D = $"../ModelVisualComponent/mage/bro_rig/Skeleton3D/stats_left_cover_001"
@onready var book_case : Node3D = $CaseBook
@onready var book_roulette : Node3D = $Book
#@onready var book_map : Node3D = $MapBook

@onready var audio_stream : AudioStreamPlayer = $"../Sounds/AudioStreamPlayer"
var sonidos = {
	"book_open": preload("res://resources/sounds/open_book.wav"),
	"book_close": preload("res://resources/sounds/kodack__closing-a-book.wav")
}

var pages_dictionary : Dictionary 
var actual_page : Node3D

var last_position : Vector3

func _ready() -> void:
	actual_page = book_roulette
	pages_dictionary = {
	Constants.BOOK_PAGE.ROULETTE : book_roulette,
	#Constants.BOOK_PAGE.MAP : book_map,
	Constants.BOOK_PAGE.CASE : book_case,
	Constants.BOOK_PAGE.NONE : book_none
	}
	UiEventBus.change_book_page.connect(change_book)

	

#deberia iniciar la animacion
func change_book(book_page : Constants.BOOK_PAGE)->void:
	var next_page : Node3D = pages_dictionary[book_page]

	if actual_page != book_none && actual_page && actual_page != next_page:
		var actual_animation_player : AnimationPlayer = actual_page.get_node_or_null("AnimationPlayer")

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
				actual_page.global_position.y += 200
				actual_page.visible = false
				return true
		}))	


	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			if next_page == book_none:
				next_page.visible = true
				actual_page.visible = false
				
				
			elif next_page && actual_page != next_page:
				actual_page.visible = false
				next_page.visible = true
				next_page.global_position.y -= 200

				var animation_player : AnimationPlayer = next_page.get_node_or_null("AnimationPlayer")
				animation_player.play("book_animations/book_open")
				
				audio_stream.stream = sonidos["book_open"]
				audio_stream.play()
				
			actual_page = next_page
			return true
	}))


		#await next_page.active_tween.finished

	
	
	
