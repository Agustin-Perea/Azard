extends Control

@onready var continue_button : Button = $Button
@onready var stadisitcs : FinishStadisticsControl = $"../Finish_Stadistics"
func _ready() -> void:
	MusicManager.play_music(Constants.MUSIC_FINISH)
	continue_button.pressed.connect(on_button_pressed)
	
func on_button_pressed() -> void:
	continue_button.visible = false
	stadisitcs.aparecer()
