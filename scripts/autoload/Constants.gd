extends Node

const COMBAT_STATE_NAMES: Dictionary = {
	"EnemySelection" : "SelectionState",
	"BookState" : "BookState",
	"RoulleteSpin" : "RouletteState",
	"BetResolve" : "BetResolve",
	"Victory" : "Victory",
	"Defeat" : "Defeat",
	"StandBy" : "StandBy",
}

const RARITY_ID: Dictionary = {
	"COMMON" : 1,
	"RARE" : 2,
	"EPIC" : 3,
	"LEGENDARY" : 4,
}

enum ATTACK_TYPE {
	SINGLE,
	HALF,
	ALL
}

enum BALL_RARITY {
	RARITY_COMMON = 1,
	RARITY_UNCOMMON = 2,
	RARITY_RARE = 3,
	RARITY_EPIC = 4,
	RARITY_LEGENDARY = 5,
}

enum BALL_TARGET {
	TARGET_SINGLE = 1,
	TARGET_HALF = 2,
	TARGET_ALL = 3,
}

enum BALL_ATTACK_PROFILE {
	PROFILE_UNI_TARGET,
	PROFILE_MULTI_TARGET,
	PROFILE_CLEAVE,
	PROFILE_DOT,
	PROFILE_SUPPORT,
	PROFILE_UTILITY,
	PROFILE_CONTROL,
	PROFILE_ECONOMY,
	PROFILE_JACKPOT,
	PROFILE_RANDOM,
	PROFILE_COPY,
	PROFILE_COMBO,
	PROFILE_EXECUTE,
	PROFILE_FINISHER,
	PROFILE_SYNERGY,
}

enum BALL_CATEGORY {
	CATEGORY_DAMAGE,
	CATEGORY_SUPPORT,
	CATEGORY_SUSTAIN,
	CATEGORY_DEFENSE,
	CATEGORY_ECONOMY,
	CATEGORY_CONTROL,
	CATEGORY_DOT,
	CATEGORY_AOE,
	CATEGORY_MULTIPLIER,
	CATEGORY_COPY,
	CATEGORY_JACKPOT,
	CATEGORY_RISK_REWARD,
	CATEGORY_DEBUFF,
	CATEGORY_EXECUTE,
	CATEGORY_FINISHER,
	CATEGORY_SYNERGY,
	CATEGORY_RANDOM,
	CATEGORY_CHAIN,
	CATEGORY_PIERCE,
	CATEGORY_BURST,
}

enum PASSIVE_ITEM_RARITY {
	RARITY_COMMON = 1,
	RARITY_UNCOMMON = 2,
	RARITY_RARE = 3,
	RARITY_EPIC = 4,
	RARITY_LEGENDARY = 5,
}

enum PASSIVE_ITEM_TRIGGER {
	TRIGGER_COMBAT_START,
	TRIGGER_PRE_RESOLVE,
	TRIGGER_REROLL,
	TRIGGER_BET_RESOLVED,
	TRIGGER_POST_RESOLVED,
	TRIGGER_COMBAT_END,
	TRIGGER_COMBAT_KILL,
	TRIGGER_ENEMY_KILLED,
	TRIGGER_LOADOUT,
	TRIGGER_REWARD_GENERATED,
	TRIGGER_SHOP_GENERATED,
	TRIGGER_CHEST_OPENED,
	TRIGGER_EVENT_REWARD_GENERATED,
	TRIGGER_STATUS_TICK,
}

enum PASSIVE_ITEM_STATUS {
	STATUS_CONCEPT,
	STATUS_IN_GAME,
}

enum TRINKET_RARITY {
	RARITY_COMMON = 1,
	RARITY_UNCOMMON = 2,
	RARITY_RARE = 3,
	RARITY_EPIC = 4,
	RARITY_LEGENDARY = 5,
}

enum TRINKET_TRIGGER {
	TRIGGER_COMBAT_START,
	TRIGGER_PRE_RESOLVE,
	TRIGGER_REROLL_USED,
	TRIGGER_BET_RESOLVED,
	TRIGGER_POST_RESOLVED,
	TRIGGER_COMBAT_END,
	TRIGGER_COMBAT_KILL,
	TRIGGER_ENEMY_KILLED,
}

enum TRINKET_STATUS {
	STATUS_CONCEPT,
	STATUS_IN_GAME,
}

enum BOARD_UPGRADE_RARITY {
	RARITY_COMMON = 1,
	RARITY_UNCOMMON = 2,
	RARITY_RARE = 3,
	RARITY_EPIC = 4,
	RARITY_LEGENDARY = 5,
}

enum BOARD_UPGRADE_TYPE {
	TYPE_POINT_MODIFICATION,
	TYPE_COLOR_REINFORCEMENT,
	TYPE_PARITY_REINFORCEMENT,
	TYPE_SECTOR_UPGRADE,
	TYPE_HYBRID_UPGRADE,
	TYPE_POINT_ECONOMY,
	TYPE_PRECISION,
	TYPE_SOFT_REPLACEMENT,
	TYPE_JACKPOT,
	TYPE_MIRROR,
	TYPE_STRUCTURAL_MODIFICATION,
	TYPE_GLOBAL_GOLD,
	TYPE_GLOBAL_COLOR,
	TYPE_EXTREME_CONVERGENCE,
}

enum BOARD_UPGRADE_STATUS {
	STATUS_CONCEPT,
	STATUS_IN_GAME,
}

const BALL_RARITY_BY_NAME: Dictionary = {
	"common": BALL_RARITY.RARITY_COMMON,
	"uncommon": BALL_RARITY.RARITY_UNCOMMON,
	"rare": BALL_RARITY.RARITY_RARE,
	"epic": BALL_RARITY.RARITY_EPIC,
	"legendary": BALL_RARITY.RARITY_LEGENDARY,
}

const BALL_CATEGORY_BY_NAME: Dictionary = {
	"damage": BALL_CATEGORY.CATEGORY_DAMAGE,
	"base_damage": BALL_CATEGORY.CATEGORY_DAMAGE,
	"support": BALL_CATEGORY.CATEGORY_SUPPORT,
	"sustain": BALL_CATEGORY.CATEGORY_SUSTAIN,
	"defense": BALL_CATEGORY.CATEGORY_DEFENSE,
	"economy": BALL_CATEGORY.CATEGORY_ECONOMY,
	"control": BALL_CATEGORY.CATEGORY_CONTROL,
	"roulette_control": BALL_CATEGORY.CATEGORY_CONTROL,
	"dot": BALL_CATEGORY.CATEGORY_DOT,
	"aoe": BALL_CATEGORY.CATEGORY_AOE,
	"final_multiplier": BALL_CATEGORY.CATEGORY_MULTIPLIER,
	"copy": BALL_CATEGORY.CATEGORY_COPY,
	"combo_copy": BALL_CATEGORY.CATEGORY_COPY,
	"jackpot": BALL_CATEGORY.CATEGORY_JACKPOT,
	"jackpot_aoe": BALL_CATEGORY.CATEGORY_JACKPOT,
	"risk_reward": BALL_CATEGORY.CATEGORY_RISK_REWARD,
	"debuff": BALL_CATEGORY.CATEGORY_DEBUFF,
	"execute": BALL_CATEGORY.CATEGORY_EXECUTE,
	"finisher": BALL_CATEGORY.CATEGORY_FINISHER,
	"gold_synergy": BALL_CATEGORY.CATEGORY_SYNERGY,
	"prime_condition": BALL_CATEGORY.CATEGORY_SYNERGY,
	"color_condition": BALL_CATEGORY.CATEGORY_SYNERGY,
	"convergence": BALL_CATEGORY.CATEGORY_SYNERGY,
	"random": BALL_CATEGORY.CATEGORY_RANDOM,
	"chain": BALL_CATEGORY.CATEGORY_CHAIN,
	"pierce": BALL_CATEGORY.CATEGORY_PIERCE,
	"shield_conversion": BALL_CATEGORY.CATEGORY_BURST,
}

const PASSIVE_ITEM_RARITY_BY_NAME: Dictionary = {
	"common": PASSIVE_ITEM_RARITY.RARITY_COMMON,
	"uncommon": PASSIVE_ITEM_RARITY.RARITY_UNCOMMON,
	"rare": PASSIVE_ITEM_RARITY.RARITY_RARE,
	"epic": PASSIVE_ITEM_RARITY.RARITY_EPIC,
	"legendary": PASSIVE_ITEM_RARITY.RARITY_LEGENDARY,
}

const PASSIVE_ITEM_TRIGGER_BY_NAME: Dictionary = {
	"combat_start": PASSIVE_ITEM_TRIGGER.TRIGGER_COMBAT_START,
	"pre_resolve": PASSIVE_ITEM_TRIGGER.TRIGGER_PRE_RESOLVE,
	"reroll": PASSIVE_ITEM_TRIGGER.TRIGGER_REROLL,
	"bet_resolved": PASSIVE_ITEM_TRIGGER.TRIGGER_BET_RESOLVED,
	"post_resolved": PASSIVE_ITEM_TRIGGER.TRIGGER_POST_RESOLVED,
	"combat_end": PASSIVE_ITEM_TRIGGER.TRIGGER_COMBAT_END,
	"combat_kill": PASSIVE_ITEM_TRIGGER.TRIGGER_COMBAT_KILL,
	"enemy_killed": PASSIVE_ITEM_TRIGGER.TRIGGER_ENEMY_KILLED,
	"loadout": PASSIVE_ITEM_TRIGGER.TRIGGER_LOADOUT,
	"reward_generated": PASSIVE_ITEM_TRIGGER.TRIGGER_REWARD_GENERATED,
	"shop_generated": PASSIVE_ITEM_TRIGGER.TRIGGER_SHOP_GENERATED,
	"chest_opened": PASSIVE_ITEM_TRIGGER.TRIGGER_CHEST_OPENED,
	"event_reward_generated": PASSIVE_ITEM_TRIGGER.TRIGGER_EVENT_REWARD_GENERATED,
	"status_tick": PASSIVE_ITEM_TRIGGER.TRIGGER_STATUS_TICK,
}

const PASSIVE_ITEM_EFFECT_KEY: Dictionary = {
	"SPARE_WHEEL": "spare_wheel",
	"COPPER_LENS": "copper_lens",
	"RED_RIBBON": "red_ribbon",
	"BLACK_RIBBON": "black_ribbon",
	"PRIME_CHALK": "prime_chalk",
	"QUIET_PURSE": "quiet_purse",
	"FIRST_AID_TAPE": "first_aid_tape",
	"FELT_GLOVES": "felt_gloves",
	"LUCKY_CHARM": "lucky_charm",
	"BALL_POUCH": "ball_pouch",
	"SAFETY_NET": "safety_net",
	"GOLDEN_DUST": "golden_dust",
	"ECHO_PIN": "echo_pin",
	"TOXIC_INK": "toxic_ink",
	"CHAIN_COIL": "chain_coil",
	"TABLE_SIGIL": "table_sigil",
	"VITAL_THREAD": "vital_thread",
	"VISION": "vision",
	"LUCKY_THREAD": "lucky_thread",
	"LUCKY_CLOVER": "lucky_clover",
	"OMEGA_ROLL": "omega_roll",
	"TRINKET_STRAP": "trinket_strap",
	"IRON_SHELL": "iron_shell",
	"ROULETTE_CHALK": "roulette_chalk",
	"HIGH_ROLLER_BADGE": "high_roller_badge",
	"BLOOD_CONTRACT": "blood_contract",
	"DEALER_GLOVES": "dealer_gloves",
	"GOLD_POCKET": "gold_pocket",
	"GRAVE_WAX": "grave_wax",
	"SPLIT_LEDGER": "split_ledger",
	"LOADED_DICE": "loaded_dice",
	"THIRD_CHIP": "third_chip",
	"GOLDEN_LEDGER": "golden_ledger",
	"WEIGHTED_WHEEL": "weighted_wheel",
	"TWIN_FUSE": "twin_fuse",
	"DEADMANS_SWITCH": "deadmans_switch",
	"LOADED_MARK": "loaded_mark",
	"HOUSE_KEY": "house_key",
	"CROWN_OF_ODDS": "crown_of_odds",
	"ROYAL_TREASURY": "royal_treasury",
	"FINAL_BET_SEAL": "final_bet_seal",
	"FORTUNE_IDOL": "fortune_idol",
	"EYE_OF_FORTUNE": "eye_of_fortune",
	"ROBA_ALMAS": "roba_almas",
	"MITOSIS": "mitosis",
	"HOUSE_WIN": "house_win",
}

const PASSIVE_ITEM_EFFECT_FLAG: Dictionary = {
	"POISON_TICK_BONUS": "passive_poison_tick_bonus",
	"EXTRA_CHAIN_TARGETS": "passive_extra_chain_targets",
	"COPY_EFFECTIVENESS_BONUS": "passive_copy_effectiveness_bonus",
	"HEALING_BONUS": "passive_healing_bonus",
}

const TRINKET_RARITY_BY_NAME: Dictionary = {
	"common": TRINKET_RARITY.RARITY_COMMON,
	"uncommon": TRINKET_RARITY.RARITY_UNCOMMON,
	"rare": TRINKET_RARITY.RARITY_RARE,
	"epic": TRINKET_RARITY.RARITY_EPIC,
	"legendary": TRINKET_RARITY.RARITY_LEGENDARY,
}

const TRINKET_TRIGGER_BY_NAME: Dictionary = {
	"combat_start": TRINKET_TRIGGER.TRIGGER_COMBAT_START,
	"pre_resolve": TRINKET_TRIGGER.TRIGGER_PRE_RESOLVE,
	"reroll_used": TRINKET_TRIGGER.TRIGGER_REROLL_USED,
	"bet_resolved": TRINKET_TRIGGER.TRIGGER_BET_RESOLVED,
	"post_resolved": TRINKET_TRIGGER.TRIGGER_POST_RESOLVED,
	"combat_end": TRINKET_TRIGGER.TRIGGER_COMBAT_END,
	"combat_kill": TRINKET_TRIGGER.TRIGGER_COMBAT_KILL,
	"enemy_killed": TRINKET_TRIGGER.TRIGGER_ENEMY_KILLED,
}

const TRINKET_EFFECT_KEY: Dictionary = {
	"RED_THREAD": "red_thread",
	"BLACK_THREAD": "black_thread",
	"PRIME_LENS": "prime_lens",
	"EVEN_TOKEN": "even_token",
	"ODD_TOKEN": "odd_token",
	"MULLIGAN_PEBBLE": "mulligan_pebble",
	"OPENING_BELL": "opening_bell",
	"GOLDEN_NEEDLE": "golden_needle",
	"COMBO_RIBBON": "combo_ribbon",
	"MARKERS_CHALK": "markers_chalk",
	"SECOND_BELL": "second_bell",
	"CHAIN_HOOK": "chain_hook",
	"SAFE_LOOP": "safe_loop",
	"SPLIT_NEEDLE": "split_needle",
	"HOUSE_EMBLEM": "house_emblem",
	"ZERO_SEAL": "zero_seal",
	"DEALERS_MARK": "dealers_mark",
	"EXECUTION_WIRE": "execution_wire",
	"TREASURY_FANG": "treasury_fang",
	"PRISM_RING": "prism_ring",
	"LAST_LAUGH": "last_laugh",
	"RIGGED_WATCH": "rigged_watch",
	"MIRROR_CREST": "mirror_crest",
	"HIGH_ROLLER_CREST": "high_roller_crest",
	"BLOOD_RUBY": "blood_ruby",
	"GILDED_ENGINE": "gilded_engine",
	"TRIPLE_KNOT": "triple_knot",
	"ECLIPSE_CROWN": "eclipse_crown",
	"FATE_LOOP": "fate_loop",
	"ROYAL_TREASURY": "royal_treasury",
	"FINAL_BET_SEAL": "final_bet_seal",
	"CONVERGENCE_HEART": "convergence_heart",
}

const TRINKET_EFFECT_FLAG: Dictionary = {
	"CHAIN_SECONDARY_DAMAGE_BONUS": "trinket_chain_secondary_damage_bonus",
	"COPY_EFFECTIVENESS_BONUS": "trinket_copy_effectiveness_bonus",
	"REROLL_SAVED_MULT": "trinket_reroll_saved_mult",
	"EXECUTION_NEXT_MULT": "trinket_execution_next_mult",
	"GILDED_ENGINE_MULT": "trinket_gilded_engine_mult",
	"RIGGED_WATCH_AVAILABLE": "trinket_rigged_watch_available",
	"FATE_LOOP_AVAILABLE": "trinket_fate_loop_available",
	"CONVERGENCE_DUPLICATES_FIELD_BONUS": "trinket_convergence_duplicates_field_bonus",
}

const BOARD_UPGRADE_RARITY_BY_NAME: Dictionary = {
	"common": BOARD_UPGRADE_RARITY.RARITY_COMMON,
	"uncommon": BOARD_UPGRADE_RARITY.RARITY_UNCOMMON,
	"rare": BOARD_UPGRADE_RARITY.RARITY_RARE,
	"epic": BOARD_UPGRADE_RARITY.RARITY_EPIC,
	"legendary": BOARD_UPGRADE_RARITY.RARITY_LEGENDARY,
}

const BOARD_UPGRADE_TYPE_BY_NAME: Dictionary = {
	"point_modification": BOARD_UPGRADE_TYPE.TYPE_POINT_MODIFICATION,
	"color_reinforcement": BOARD_UPGRADE_TYPE.TYPE_COLOR_REINFORCEMENT,
	"parity_reinforcement": BOARD_UPGRADE_TYPE.TYPE_PARITY_REINFORCEMENT,
	"sector_upgrade": BOARD_UPGRADE_TYPE.TYPE_SECTOR_UPGRADE,
	"hybrid_upgrade": BOARD_UPGRADE_TYPE.TYPE_HYBRID_UPGRADE,
	"point_economy": BOARD_UPGRADE_TYPE.TYPE_POINT_ECONOMY,
	"precision": BOARD_UPGRADE_TYPE.TYPE_PRECISION,
	"soft_replacement": BOARD_UPGRADE_TYPE.TYPE_SOFT_REPLACEMENT,
	"jackpot": BOARD_UPGRADE_TYPE.TYPE_JACKPOT,
	"mirror": BOARD_UPGRADE_TYPE.TYPE_MIRROR,
	"structural_modification": BOARD_UPGRADE_TYPE.TYPE_STRUCTURAL_MODIFICATION,
	"global_gold": BOARD_UPGRADE_TYPE.TYPE_GLOBAL_GOLD,
	"global_color": BOARD_UPGRADE_TYPE.TYPE_GLOBAL_COLOR,
	"extreme_convergence": BOARD_UPGRADE_TYPE.TYPE_EXTREME_CONVERGENCE,
}

const BOARD_UPGRADE_EFFECT_KEY: Dictionary = {
	"GOLD_PAINT": "gold_paint",
	"COLOR_SHIFT": "color_shift",
	"LUCKY_MARK": "lucky_mark",
	"PRIME_MARK": "prime_mark",
	"SAFE_NUMBER": "safe_number",
	"RED_SEAL": "red_seal",
	"BLACK_SEAL": "black_seal",
	"PAIR_BLESSING": "pair_blessing",
	"DOUBLE_GOLD_PAINT": "double_gold_paint",
	"SECTOR_POLISH": "sector_polish",
	"PRIME_CLUSTER": "prime_cluster",
	"COLOR_LINK": "color_link",
	"GILDED_EDGE": "gilded_edge",
	"WEALTH_SLOT": "wealth_slot",
	"PRECISION_INK": "precision_ink",
	"SOFT_REPLACEMENT": "soft_replacement",
	"GOLDEN_PAIR": "golden_pair",
	"JACKPOT_SEED": "jackpot_seed",
	"EXACT_MIRROR": "exact_mirror",
	"TRIPLE_COLOR_WASH": "triple_color_wash",
	"ROYAL_PRIME": "royal_prime",
	"WEIGHTED_SECTOR": "weighted_sector",
	"TREASURY_NUMBER": "treasury_number",
	"SOFT_37_ECHO": "soft_37_echo",
	"ADD_37": "add_37",
	"CROWNED_NUMBER": "crowned_number",
	"ROYAL_SECTOR": "royal_sector",
	"HOUSE_BIAS": "house_bias",
	"SPLIT_JACKPOT": "split_jackpot",
	"RICH_VEIN": "rich_vein",
	"CRIMSON_SWEEP": "crimson_sweep",
	"GOLDEN_CROWN": "golden_crown",
	"FATE_SECTOR": "fate_sector",
	"ROYAL_37": "royal_37",
	"HOUSE_OF_GOLD": "house_of_gold",
	"ECLIPSE_WHEEL": "eclipse_wheel",
}

const BALL_ATTACK_PROFILE_BY_NAME: Dictionary = {
	"uni-target": BALL_ATTACK_PROFILE.PROFILE_UNI_TARGET,
	"single": BALL_ATTACK_PROFILE.PROFILE_UNI_TARGET,
	"multi-target": BALL_ATTACK_PROFILE.PROFILE_MULTI_TARGET,
	"multi_target": BALL_ATTACK_PROFILE.PROFILE_MULTI_TARGET,
	"cleave": BALL_ATTACK_PROFILE.PROFILE_CLEAVE,
	"dot": BALL_ATTACK_PROFILE.PROFILE_DOT,
	"support": BALL_ATTACK_PROFILE.PROFILE_SUPPORT,
	"utility": BALL_ATTACK_PROFILE.PROFILE_UTILITY,
	"control": BALL_ATTACK_PROFILE.PROFILE_CONTROL,
	"economy": BALL_ATTACK_PROFILE.PROFILE_ECONOMY,
	"jackpot": BALL_ATTACK_PROFILE.PROFILE_JACKPOT,
	"random": BALL_ATTACK_PROFILE.PROFILE_RANDOM,
	"copy": BALL_ATTACK_PROFILE.PROFILE_COPY,
	"combo": BALL_ATTACK_PROFILE.PROFILE_COMBO,
	"execute": BALL_ATTACK_PROFILE.PROFILE_EXECUTE,
	"finisher": BALL_ATTACK_PROFILE.PROFILE_FINISHER,
	"synergy": BALL_ATTACK_PROFILE.PROFILE_SYNERGY,
}

const BOARD_TAG: Dictionary = {
	"GOLDEN": "board_tag_golden",
	"BOTH_COLORS": "board_tag_both_colors",
	"LUCKY": "board_tag_lucky",
	"PRIME_OVERRIDE": "board_tag_prime_override",
	"SAFE": "board_tag_safe",
	"JACKPOT": "board_tag_jackpot",
	"JACKPOT_SECONDARY": "board_tag_jackpot_secondary",
	"SOFT_37": "board_tag_soft_37",
	"FAVORABLE": "board_tag_favorable",
	"ROYAL_37": "board_tag_royal_37",
	"SOFT_REPLACEMENT_NUMBER": "board_tag_soft_replacement_number",
	"OPPOSITE_COPY_SOURCE": "board_tag_opposite_copy_source",
	"HOUSE_BIAS": "board_tag_house_bias",
	"LUCKY_MULT": "board_bonus_lucky_mult",
	"SAFE_SHIELD": "board_bonus_safe_shield",
	"RED_SEAL_BASE": "board_bonus_red_seal_base",
	"BLACK_SEAL_MULT": "board_bonus_black_seal_mult",
	"PAIR_BASE": "board_bonus_pair_base",
	"SECTOR_MULT": "board_bonus_sector_mult",
	"WEALTH_GOLD": "board_bonus_wealth_gold",
	"PRECISION_MULT": "board_bonus_precision_mult",
	"GOLDEN_PAIR_MULT": "board_bonus_golden_pair_mult",
	"WEIGHTED_SECTOR_MULT": "board_bonus_weighted_sector_mult",
	"TREASURY_GOLD_PER_CONDITION": "board_bonus_treasury_gold_per_condition",
	"GOLDEN_GOLD_BONUS": "board_bonus_golden_gold",
	"COLOR_GLOBAL_MULT": "board_bonus_color_global_mult",
	"GOLDEN_CROWN_MULT": "board_bonus_golden_crown_mult",
}

const BALL_EFFECT_FLAG: Dictionary = {
	"BOUNCE_HITS": "bounce_ball_hits",
	"MIRROR_COPY_POWER": "mirror_ball_copy_power",
	"POISON_DAMAGE": "poison_ball_damage",
	"POISON_TURNS": "poison_ball_turns",
	"FIRE_SPLASH_PCT": "fire_ball_splash_pct",
	"MUTE_TURNS": "mute_ball_turns",
	"MUTE_ENEMY_DAMAGE_REDUCTION": "mute_ball_enemy_damage_reduction",
	"CRYSTAL_CORRECTION_RANGE": "crystal_ball_correction_range",
	"CURSE_VULNERABLE_PCT": "curse_ball_vulnerable_pct",
	"CURSE_VULNERABLE_TURNS": "curse_ball_vulnerable_turns",
	"STORM_CHAIN_TARGETS": "storm_ball_chain_targets",
	"RIG_CORRECTION_RANGE": "rig_ball_correction_range",
	"ECHO_REPEAT_POWER": "echo_ball_repeat_power",
	"VOID_IGNORE_SHIELD": "void_ball_ignore_shield",
	"GRAVE_EXECUTE_THRESHOLD": "grave_ball_execute_threshold",
	"COMBAT_ANY_TARGET_DEBUFFED": "combat_any_target_debuffed",
	"COMBAT_USED_BALL_TYPES": "combat_used_ball_types",
	"JACKPOT_AOE_DAMAGE": "jackpot_ball_aoe_damage",
	"FATE_ROLLS": "fate_ball_rolls",
	"CHRONO_REPEAT_COUNT": "chrono_ball_repeat_count",
	"CHRONO_REPEAT_POWER": "chrono_ball_repeat_power",
}

enum BOOK_PAGE {
	ROULETTE,
	CASE,
	MAP,
	NONE
}

#betfields colors
enum BET_FIELD_COLOR {
	GREEN,
	RED,
	BLACK,
}
enum BET_FIELD_PARITY {
	EVEN,
	ODD,
	NONE
}
enum BET_FIELD_HALF_TABLE {
	LESS_18,
	GREATER_19,
	NONE
}
enum BET_FIELD_COLUMN {
	COLUMN_1ST,
	COLUMN_2ND,
	COLUMN_3RD,
	NONE
}
enum BET_FIELD_ROW {
	ROW_1ST,
	ROW_2ND,
	ROW_3RD,
	NONE
}
#scene routes
const TEST_SCENE = "res://RouletteCombat.tscn"
const MAP_SCENE = "res://MapGeneration/map_scene.tscn"
