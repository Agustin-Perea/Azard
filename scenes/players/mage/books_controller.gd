extends Node3D
class_name BooksController

#@onready var book_case : Node3D = $case_book
@onready var book_roulette : Node3D = $Book
#@onready var book_map : Node3D = $MapBook

@onready var audio_stream : AudioStreamPlayer = $"../Sounds/AudioStreamPlayer"
var sonidos = {
	"book_open": preload("res://resources/sounds/open_book.wav"),
	"book_close": preload("res://resources/sounds/kodack__closing-a-book.wav")
}

var pages_dictionary : Dictionary 
var actual_page : Node3D

func _ready() -> void:
	actual_page = book_roulette
	pages_dictionary = {
	Constants.BOOK_PAGE.ROULETTE : book_roulette,
	#Constants.BOOK_PAGE.MAP : book_map,
	#Constants.BOOK_PAGE.CASE : book_case,
	Constants.BOOK_PAGE.NONE : null
	}
	UiEventBus.change_book_page.connect(change_book)

	

#deberia iniciar la animacion
func change_book(book_page : Constants.BOOK_PAGE)->void:
	var next_page : Node3D = pages_dictionary[book_page]

	if actual_page && actual_page != next_page:
		var animation_player : AnimationPlayer = actual_page.get_node_or_null("AnimationPlayer")
		
		UiEventBus.deactivate_descriptions.emit()
		UiEventBus.changeToState.emit(Constants.COMBAT_STATE_NAMES.StandBy)
		
		animation_player.play("book_close")
		audio_stream.stream = sonidos["book_close"]
		audio_stream.play()
		
		EventManager.add_event(EventManager.QueueType.GAME, 
		GameEvent.new({
			"paralel": false,
			"action": func():
				return !animation_player.is_playing()
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
				#actual_page.global_position.y = 200
				actual_page.visible = false
				return true
		}))	


	EventManager.add_event(EventManager.QueueType.GAME, 
	GameEvent.new({
		"paralel": false,
		"action": func():
			if next_page && actual_page != next_page:
				next_page.visible = true
				#if actual_page:
					#actual_page.global_position.y = 200
					
				#next_page.global_position = self.global_position
				
				var animation_player : AnimationPlayer = next_page.get_node_or_null("AnimationPlayer")
				animation_player.play("book_open")
				
				audio_stream.stream = sonidos["book_open"]
				audio_stream.play()
				
			actual_page = next_page
			return true
	}))


		#await next_page.active_tween.finished

	
	
	
