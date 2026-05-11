extends Node3D


@onready var ball_spot : BallElement = $left_cover/Ball_Spot
@onready var ball_spot_2 : BallElement = $left_cover/Ball_Spot2
@onready var ball_spot_3 : BallElement = $left_cover/Ball_Spot3

@onready var price_chart_ball : Label3D = $left_cover/price_chart_text/Label3D
@onready var price_chart_ball_2 : Label3D = $left_cover/price_chart_text2/Label3D
@onready var price_chart_ball_3 : Label3D = $left_cover/price_chart_text3/Label3D

@onready var bingo_chip_spot : BingoChipElement = $left_cover/Bingo_Chip_Spot
@onready var bingo_chip_spot_2 : BingoChipElement = $left_cover/Bingo_Chip_Spot2
@onready var bingo_chip_spot_3 : BingoChipElement = $left_cover/Bingo_Chip_Spot3

@onready var price_chart_chip : Label3D = $left_cover/price_chart_bet_chip/Label3D
@onready var price_chart_chip_2 : Label3D = $left_cover/price_chart_bet_chip2/Label3D
@onready var price_chart_chip_3 : Label3D = $left_cover/price_chart_bet_chip3/Label3D

@onready var reroll_price_chart : Label3D = $left_cover/price_chart_reroll/Label3D

@onready var reroll_button : SB_Button3D = $left_cover/SB_Button3D
@onready var map_button : SB_Button3D = $left_cover/Next_SB_Button3D

@onready var ball_description_canvas : BallDescription =  $left_cover/BallDescription
#@onready var bingo_chip_info : BingoChipinfo =  $bingo_chip_info




const SHOP_BALL_PRICES := {
	Constants.RARITY_ID.COMMON: 5,
	Constants.RARITY_ID.RARE: 7,
	Constants.RARITY_ID.EPIC: 8,
	Constants.RARITY_ID.LEGENDARY: 10,
}

const SHOP_REROLL_PRICE_BASE := 5
const SHOP_REROLL_PRICE_UPDATE := 1
var Shop_rerolls_count : int = 0 
var actual_reroll_price : int = 5

const SHOP_BASE_CHIP_MOD_PRICE := 4 #si este sale modificado se agrega el precio por modificacion
const SHOP_POTION_PRICE := 5


func _ready() -> void:
	reroll_button.pressed.connect(_on_reroll_pressed)
	map_button.pressed.connect(on_map_button_pressed)
	reroll()
	Shop_rerolls_count = 0
	reroll_price_chart.text = str(SHOP_REROLL_PRICE_BASE + SHOP_REROLL_PRICE_UPDATE * Shop_rerolls_count)

func _on_reroll_pressed()->void:
	actual_reroll_price = SHOP_REROLL_PRICE_BASE + SHOP_REROLL_PRICE_UPDATE * Shop_rerolls_count
	if GameState.economy_component.can_afford(actual_reroll_price):
		GameState.economy_component.spend_run_gold(actual_reroll_price)
		reroll()
	

func reroll() -> void:

	Shop_rerolls_count += 1
	actual_reroll_price = SHOP_REROLL_PRICE_BASE + SHOP_REROLL_PRICE_UPDATE * Shop_rerolls_count
	reroll_price_chart.text = str(actual_reroll_price)
	
	
	var ball_created : BallRuntimeState = GameState.object_pool_database.ball_pool_definition.get_random_ball()
	
	ball_spot._assign_data_model(ball_created)
	price_chart_ball.text = str(ball_created.ball_definition.base_price)
	
	
	ball_created = GameState.object_pool_database.ball_pool_definition.get_random_ball()
	ball_spot_2._assign_data_model(ball_created)
	price_chart_ball_2.text = str(ball_created.ball_definition.base_price)
	
	ball_created = GameState.object_pool_database.ball_pool_definition.get_random_ball()
	ball_spot_3._assign_data_model(ball_created)
	price_chart_ball_3.text = str(ball_created.ball_definition.base_price)
	
	#pool bingo_chips
	var bingo_chip_created : BetFieldModel = GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model()
	bingo_chip_spot.assign_data_model(bingo_chip_created) 
	price_chart_chip.text = str(SHOP_BASE_CHIP_MOD_PRICE)
	
	bingo_chip_created = GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model()
	bingo_chip_spot_2.assign_data_model(bingo_chip_created) 
	price_chart_chip_2.text = str(SHOP_BASE_CHIP_MOD_PRICE)
	
	bingo_chip_created = GameState.object_pool_database.bingo_chips_constructor.get_random_bet_field_model()
	bingo_chip_spot_3.assign_data_model(bingo_chip_created) 
	price_chart_chip_3.text = str(SHOP_BASE_CHIP_MOD_PRICE)
	
	UiEventBus.deactivate_descriptions.emit()



func on_map_button_pressed()->void:
	#PlayerUiEvents.change_book_page.emit(Constants.BOOK_PAGE.MAP)
	#preload()
	GameState.temp_scene_changed_value +=1
	UiEventBus.change_book_page.emit(Constants.BOOK_PAGE.MAP)
	#UiEventBus.change_scene_to.emit("res://scenes/combat/battle_scene_1.tscn")
	
