extends Sprite3D

var listens : StatsComponent
var Life_bar : Sprite3D
@onready var info : Label3D = $LifeText
@onready var progress_bar : ProgressBar = $"../SubViewport/ProgressBar"

func _ready() -> void:
	Life_bar = self
	listens = GameState.player_stats
	if listens:
		listens.health_changed.connect(update_canvas)
		update_canvas()

func update_canvas()->void:
	info.text = str(listens.current_healt) + "/" + str(listens.max_healt)
	progress_bar.value = listens.current_healt
