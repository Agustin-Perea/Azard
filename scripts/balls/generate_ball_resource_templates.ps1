$balls = @(
    @{ id=1; slug='base_ball'; rarity='common'; weight=140; name='BaseBall'; attackType=1; damage='6,9,12'; profile='uni-target'; category='base_damage' },
    @{ id=2; slug='duball'; rarity='common'; weight=140; name='Duball'; attackType=1; damage='2,3,4'; profile='uni-target'; category='final_multiplier' },
    @{ id=3; slug='healt_ball'; rarity='common'; weight=135; name='HealtBall'; attackType=1; damage='1,2,3'; profile='uni-target/support'; category='sustain' },
    @{ id=4; slug='fire_ball'; rarity='common'; weight=125; name='FireBall'; attackType=2; damage='3,4,5'; profile='cleave/multi-target'; category='aoe' },
    @{ id=5; slug='poison_ball'; rarity='common'; weight=125; name='PoisonBall'; attackType=1; damage='2,3,4'; profile='uni-target/dot'; category='dot' },
    @{ id=6; slug='shield_ball'; rarity='common'; weight=130; name='ShieldBall'; attackType=1; damage='1,2,3'; profile='uni-target/support'; category='defense' },
    @{ id=7; slug='red_ball'; rarity='common'; weight=125; name='RedBall'; attackType=1; damage='4,5,6'; profile='uni-target'; category='color_condition' },
    @{ id=8; slug='black_ball'; rarity='common'; weight=125; name='BlackBall'; attackType=1; damage='4,5,6'; profile='uni-target/support'; category='color_condition' },
    @{ id=9; slug='bounce_ball'; rarity='uncommon'; weight=90; name='BounceBall'; attackType=2; damage='2,3,4'; profile='multi-target random'; category='multi_target' },
    @{ id=10; slug='mirror_ball'; rarity='uncommon'; weight=85; name='MirrorBall'; attackType=1; damage='0,0,0'; profile='utility/copy'; category='copy' },
    @{ id=11; slug='leech_ball'; rarity='uncommon'; weight=85; name='LeechBall'; attackType=1; damage='3,4,5'; profile='uni-target'; category='lifesteal' },
    @{ id=12; slug='prime_ball'; rarity='uncommon'; weight=80; name='PrimeBall'; attackType=1; damage='2,3,4'; profile='uni-target'; category='prime_condition' },
    @{ id=13; slug='random_ball'; rarity='uncommon'; weight=80; name='RandomBall'; attackType=1; damage='8,12,16'; profile='random/utility'; category='random' },
    @{ id=14; slug='bank_ball'; rarity='uncommon'; weight=80; name='BankBall'; attackType=1; damage='2,3,4'; profile='uni-target/economy'; category='economy' },
    @{ id=15; slug='mute_ball'; rarity='rare'; weight=55; name='MuteBall'; attackType=1; damage='2,3,4'; profile='control/uni-target'; category='control' },
    @{ id=16; slug='gold_ball'; rarity='rare'; weight=50; name='GoldBall'; attackType=1; damage='3,4,5'; profile='uni-target/synergy'; category='gold_synergy' },
    @{ id=17; slug='risk_ball'; rarity='rare'; weight=50; name='RiskBall'; attackType=1; damage='10,14,18'; profile='uni-target/self-cost'; category='risk_reward' },
    @{ id=18; slug='crystal_ball'; rarity='rare'; weight=45; name='CrystalBall'; attackType=1; damage='3,4,5'; profile='utility/consistency'; category='consistency' },
    @{ id=19; slug='curse_ball'; rarity='rare'; weight=45; name='CurseBall'; attackType=1; damage='2,3,4'; profile='debuff/uni-target'; category='debuff' },
    @{ id=20; slug='storm_ball'; rarity='rare'; weight=45; name='StormBall'; attackType=3; damage='2,3,4'; profile='chain/multi-target'; category='chain' },
    @{ id=21; slug='zero_ball'; rarity='epic'; weight=28; name='ZeroBall'; attackType=1; damage='1,2,3'; profile='jackpot/uni-target'; category='jackpot' },
    @{ id=22; slug='rig_ball'; rarity='epic'; weight=24; name='RigBall'; attackType=1; damage='3,4,5'; profile='utility/control'; category='roulette_control' },
    @{ id=23; slug='echo_ball'; rarity='epic'; weight=24; name='EchoBall'; attackType=1; damage='0,0,0'; profile='utility/copy combo'; category='combo_copy' },
    @{ id=24; slug='void_ball'; rarity='epic'; weight=22; name='VoidBall'; attackType=1; damage='6,8,10'; profile='pierce/uni-target'; category='pierce' },
    @{ id=25; slug='fortune_ball'; rarity='epic'; weight=22; name='FortuneBall'; attackType=1; damage='2,3,4'; profile='uni-target/economy scaling'; category='economy_scaling' },
    @{ id=26; slug='grave_ball'; rarity='epic'; weight=20; name='GraveBall'; attackType=1; damage='5,7,9'; profile='execute/uni-target'; category='execute' },
    @{ id=27; slug='ascend_ball'; rarity='legendary'; weight=10; name='AscendBall'; attackType=1; damage='5,7,9'; profile='finisher/scaling'; category='finisher' },
    @{ id=28; slug='jackpot_ball'; rarity='legendary'; weight=8; name='JackpotBall'; attackType=3; damage='8,10,12'; profile='aoe/jackpot'; category='jackpot_aoe' },
    @{ id=29; slug='cataclysm_ball'; rarity='legendary'; weight=8; name='CataclysmBall'; attackType=1; damage='5,7,9'; profile='burst/shield conversion'; category='shield_conversion' },
    @{ id=30; slug='fate_ball'; rarity='legendary'; weight=7; name='FateBall'; attackType=1; damage='0,0,0'; profile='utility/consistency'; category='fate_control' },
    @{ id=31; slug='chrono_ball'; rarity='legendary'; weight=6; name='ChronoBall'; attackType=1; damage='0,0,0'; profile='utility/combo replay'; category='combo_replay' },
    @{ id=32; slug='eclipse_ball'; rarity='legendary'; weight=5; name='EclipseBall'; attackType=1; damage='8,10,12'; profile='uni-target/synergy'; category='convergence' }
)

$definitionOutDir = "features/balls/templates/definitions"
$runtimeOutDir = "features/balls/templates/runtime"

foreach ($ball in $balls) {
    $id = '{0:D2}' -f [int]$ball.id
    $effectPath = "res://features/balls/effects/catalog/$($ball.rarity)/ball_${id}_$($ball.slug)_effect.gd"
    $definitionPath = Join-Path $definitionOutDir "ball_${id}_$($ball.slug)_definition.template.tres"
    $runtimePath = Join-Path $runtimeOutDir "ball_${id}_$($ball.slug).template.tres"

    $levels = $ball.damage.Split(',')

    $definitionTemplate = @"
[gd_resource type="Resource" script_class="BallDefinition" format=3 uid="uid://REPLACE_ME"]

[ext_resource type="Script" uid="uid://REPLACE_ME" path="$effectPath" id="1_effect"]
[ext_resource type="Material" uid="uid://REPLACE_ME" path="res://resources/balls/materials/double_ball_material.tres" id="2_material"]
[ext_resource type="Script" uid="uid://REPLACE_ME" path="res://features/balls/definition/ball_definition.gd" id="3_definition_script"]

[sub_resource type="Resource" id="Resource_effect"]
script = ExtResource("1_effect")
name = "$($ball.name)"
description = "TODO: completar descripcion"
metadata/_custom_type_script = "uid://REPLACE_ME"

[resource]
script = ExtResource("3_definition_script")
ball_id = $($ball.id)
display_name = "$($ball.name)"
rarity = "$($ball.rarity)"
pool_weight = $($ball.weight)
attack_profile = "$($ball.profile)"
category = "$($ball.category)"
design_notes = "TODO: completar notas"
base_damage = $($levels[0])
level_1_damage = $($levels[0])
level_2_damage = $($levels[1])
level_3_damage = $($levels[2])
attack_type = $($ball.attackType)
ball_material = ExtResource("2_material")
ball_effect = SubResource("Resource_effect")
metadata/_custom_type_script = "uid://REPLACE_ME"
"@

    $runtimeTemplate = @"
[gd_resource type="Resource" script_class="BallRuntimeState" format=3 uid="uid://REPLACE_ME"]

[ext_resource type="Resource" uid="uid://REPLACE_ME" path="res://features/balls/definition/ball_${id}_$($ball.slug)_definition.tres" id="1_definition"]
[ext_resource type="Script" uid="uid://REPLACE_ME" path="res://features/balls/runtime/ball_runtime_state.gd" id="2_runtime_script"]

[resource]
script = ExtResource("2_runtime_script")
level_upgrade = 1
used = false
ball_definition = ExtResource("1_definition")
metadata/_custom_type_script = "uid://REPLACE_ME"
"@

    Set-Content -Path $definitionPath -Value $definitionTemplate -Encoding UTF8
    Set-Content -Path $runtimePath -Value $runtimeTemplate -Encoding UTF8
}

Write-Host "Generated $($balls.Count) definition templates and $($balls.Count) runtime templates."
