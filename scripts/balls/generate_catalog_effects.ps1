$effects = @(
    @{ id = 1; slug = 'base_ball'; rarity = 'common'; class = 'BaseBallCatalogEffect'; body = @('pass') },
    @{ id = 2; slug = 'duball'; rarity = 'common'; class = 'DuballCatalogEffect'; body = @('_multiply_mult(roulette_controller, _scale_float(2.0, 2.25, 2.5))') },
    @{ id = 3; slug = 'healt_ball'; rarity = 'common'; class = 'HealtBallCatalogEffect'; body = @('_heal(_scale_int(10, 14, 18))') },
    @{ id = 4; slug = 'fire_ball'; rarity = 'common'; class = 'FireBallCatalogEffect'; body = @('_set_flag("fire_ball_splash_pct", _scale_float(0.5, 0.75, 1.0))') },
    @{ id = 5; slug = 'poison_ball'; rarity = 'common'; class = 'PoisonBallCatalogEffect'; body = @('_set_flag("poison_ball_damage", _scale_int(3, 4, 5))', '_set_flag("poison_ball_turns", _scale_int(2, 2, 3))') },
    @{ id = 6; slug = 'shield_ball'; rarity = 'common'; class = 'ShieldBallCatalogEffect'; body = @('_shield(_scale_int(6, 9, 12))') },
    @{ id = 7; slug = 'red_ball'; rarity = 'common'; class = 'RedBallCatalogEffect'; body = @('if _is_red(roulette_controller):', '    _add_mult(roulette_controller, _scale_float(0.5, 0.75, 1.0))') },
    @{ id = 8; slug = 'black_ball'; rarity = 'common'; class = 'BlackBallCatalogEffect'; body = @('if _is_black(roulette_controller):', '    _shield(_scale_int(6, 8, 10))') },
    @{ id = 9; slug = 'bounce_ball'; rarity = 'uncommon'; class = 'BounceBallCatalogEffect'; body = @('_set_flag("bounce_ball_hits", _scale_int(3, 4, 5))') },
    @{ id = 10; slug = 'mirror_ball'; rarity = 'uncommon'; class = 'MirrorBallCatalogEffect'; body = @('_set_flag("mirror_ball_copy_power", _scale_float(0.70, 1.0, 1.30))') },
    @{ id = 11; slug = 'leech_ball'; rarity = 'uncommon'; class = 'LeechBallCatalogEffect'; body = @('var steal := _scale_float(0.30, 0.40, 0.50)', 'var heal_amount := int(round(roulette_controller.base * steal))', '_heal(max(heal_amount, 0))') },
    @{ id = 12; slug = 'prime_ball'; rarity = 'uncommon'; class = 'PrimeBallCatalogEffect'; body = @('if _is_prime(roulette_controller):', '    _multiply_mult(roulette_controller, _scale_float(1.75, 2.0, 2.5))') },
    @{ id = 13; slug = 'random_ball'; rarity = 'uncommon'; class = 'RandomBallCatalogEffect'; body = @('var value := _scale_int(8, 12, 16)', 'var rng := roulette_controller.rng', 'var roll := rng.randi_range(0, 3)', 'if roll == 0:', '    _add_base(roulette_controller, value)', 'elif roll == 1:', '    _heal(value)', 'elif roll == 2:', '    _shield(value)', 'else:', '    _add_mult(roulette_controller, _scale_float(0.75, 1.0, 1.25))') },
    @{ id = 14; slug = 'bank_ball'; rarity = 'uncommon'; class = 'BankBallCatalogEffect'; body = @('_gold(_scale_int(6, 9, 12))') },
    @{ id = 15; slug = 'mute_ball'; rarity = 'rare'; class = 'MuteBallCatalogEffect'; body = @('_set_flag("mute_ball_turns", _scale_int(1, 1, 2))', '_set_flag("mute_ball_enemy_damage_reduction", _scale_float(0.0, 0.20, 0.20))') },
    @{ id = 16; slug = 'gold_ball'; rarity = 'rare'; class = 'GoldBallCatalogEffect'; body = @('var winner := _winner(roulette_controller)', 'if winner != null and bool(winner.get_meta("board_tag_golden", false)):', '    _add_mult(roulette_controller, float(_scale_int(1, 2, 3)))') },
    @{ id = 17; slug = 'risk_ball'; rarity = 'rare'; class = 'RiskBallCatalogEffect'; body = @('_self_damage(_scale_int(3, 4, 5))') },
    @{ id = 18; slug = 'crystal_ball'; rarity = 'rare'; class = 'CrystalBallCatalogEffect'; body = @('_set_flag("crystal_ball_correction_range", _scale_int(1, 2, 2))') },
    @{ id = 19; slug = 'curse_ball'; rarity = 'rare'; class = 'CurseBallCatalogEffect'; body = @('_set_flag("curse_ball_vulnerable_pct", _scale_float(0.25, 0.35, 0.50))', '_set_flag("curse_ball_vulnerable_turns", _scale_int(2, 2, 3))') },
    @{ id = 20; slug = 'storm_ball'; rarity = 'rare'; class = 'StormBallCatalogEffect'; body = @('_set_flag("storm_ball_chain_targets", _scale_int(4, 5, 99))') },
    @{ id = 21; slug = 'zero_ball'; rarity = 'epic'; class = 'ZeroBallCatalogEffect'; body = @('if _is_zero_family(roulette_controller):', '    _multiply_mult(roulette_controller, _scale_float(6.0, 8.0, 10.0))', '    if _level() >= 3:', '        _gold(10)') },
    @{ id = 22; slug = 'rig_ball'; rarity = 'epic'; class = 'RigBallCatalogEffect'; body = @('_set_flag("rig_ball_correction_range", _scale_int(1, 2, 3))') },
    @{ id = 23; slug = 'echo_ball'; rarity = 'epic'; class = 'EchoBallCatalogEffect'; body = @('_set_flag("echo_ball_repeat_power", _scale_float(0.50, 0.75, 1.0))') },
    @{ id = 24; slug = 'void_ball'; rarity = 'epic'; class = 'VoidBallCatalogEffect'; body = @('_set_flag("void_ball_ignore_shield", true)', 'if bool(_get_flag("combat_any_target_debuffed", false)) and _level() >= 3:', '    _add_mult(roulette_controller, 0.35)') },
    @{ id = 25; slug = 'fortune_ball'; rarity = 'epic'; class = 'FortuneBallCatalogEffect'; body = @('var step := _scale_int(20, 15, 10)', 'var max_bonus := _scale_int(10, 15, 20)', 'var bonus := int(floor(float(GameState.run_gold) / float(step)))', '_add_base(roulette_controller, min(bonus, max_bonus))') },
    @{ id = 26; slug = 'grave_ball'; rarity = 'epic'; class = 'GraveBallCatalogEffect'; body = @('_set_flag("grave_ball_execute_threshold", _scale_float(0.15, 0.20, 0.25))') },
    @{ id = 27; slug = 'ascend_ball'; rarity = 'legendary'; class = 'AscendBallCatalogEffect'; body = @('var used_types: Array = _get_flag("combat_used_ball_types", [])', 'var count := used_types.size()', 'var scale := _scale_float(0.20, 0.25, 0.30)', '_add_mult(roulette_controller, float(count) * scale)') },
    @{ id = 28; slug = 'jackpot_ball'; rarity = 'legendary'; class = 'JackpotBallCatalogEffect'; body = @('if _is_zero_family(roulette_controller):', '    _set_flag("jackpot_ball_aoe_damage", _scale_int(60, 90, 130))', '    _multiply_mult(roulette_controller, 2.0)', '    if _level() >= 2:', '        _gold(_scale_int(0, 10, 15))', '    if _level() >= 3:', '        _heal(15)') },
    @{ id = 29; slug = 'cataclysm_ball'; rarity = 'legendary'; class = 'CataclysmBallCatalogEffect'; body = @('var ratio := _scale_float(1.0, 1.25, 1.5)', 'var bonus := int(round(float(GameState.run_shield) * ratio))', '_add_base(roulette_controller, bonus)', 'GameState.run_shield = 0') },
    @{ id = 30; slug = 'fate_ball'; rarity = 'legendary'; class = 'FateBallCatalogEffect'; body = @('_set_flag("fate_ball_rolls", _scale_int(3, 4, 5))') },
    @{ id = 31; slug = 'chrono_ball'; rarity = 'legendary'; class = 'ChronoBallCatalogEffect'; body = @('_set_flag("chrono_ball_repeat_count", _scale_int(2, 2, 3))', '_set_flag("chrono_ball_repeat_power", _scale_float(0.60, 0.80, 1.0))') },
    @{ id = 32; slug = 'eclipse_ball'; rarity = 'legendary'; class = 'EclipseBallCatalogEffect'; body = @('var winner := _winner(roulette_controller)', 'if winner != null:', '    winner.set_meta("board_tag_both_colors", true)', 'if _level() >= 2 and (_is_prime(roulette_controller) or bool(winner.get_meta("board_tag_golden", false))):', '    _add_mult(roulette_controller, _scale_float(0.0, 1.0, 2.0))', 'if _level() >= 3:', '    _add_mult(roulette_controller, 1.0)') }
)

$root = "features/balls/effects/catalog"

foreach ($item in $effects) {
    $id = '{0:D2}' -f [int]$item.id
    $path = Join-Path $root "$($item.rarity)/ball_${id}_$($item.slug)_effect.gd"

    $lines = @(
        'extends BaseCatalogBallEffect',
        "class_name $($item.class)",
        '',
        'func on_post_resolved(roulette_controller: RouletteController) -> void:'
    )

    foreach ($line in $item.body) {
        $normalized = $line.Replace('    ', "`t")
        $lines += "`t$normalized"
    }

    Set-Content -Path $path -Value ($lines -join "`r`n") -Encoding UTF8
}

Write-Host "Generated $($effects.Count) catalog effect scripts."
