$balls = @(
    '01_base_ball', '02_duball', '03_healt_ball', '04_fire_ball', '05_poison_ball', '06_shield_ball', '07_red_ball', '08_black_ball',
    '09_bounce_ball', '10_mirror_ball', '11_leech_ball', '12_prime_ball', '13_random_ball', '14_bank_ball', '15_mute_ball', '16_gold_ball',
    '17_risk_ball', '18_crystal_ball', '19_curse_ball', '20_storm_ball', '21_zero_ball', '22_rig_ball', '23_echo_ball', '24_void_ball',
    '25_fortune_ball', '26_grave_ball', '27_ascend_ball', '28_jackpot_ball', '29_cataclysm_ball', '30_fate_ball', '31_chrono_ball', '32_eclipse_ball'
)

$lines = @()
$allRefs = @()

$lines += '# Ext resources for BallsDatabase (.tres)'
$idx = 4
foreach ($entry in $balls) {
    $parts = $entry.Split('_', 2)
    $id = [int]$parts[0]
    $slug = $parts[1]
    $idPadded = '{0:D2}' -f $id
    $rid = "b$id"
    $lines += ('[ext_resource type="Resource" uid="uid://REPLACE_ME" path="res://features/balls/runtime/ball_{0}_{1}.tres" id="{2}_{3}"]' -f $idPadded, $slug, $idx, $rid)
    $allRefs += ('ExtResource("{0}_{1}")' -f $idx, $rid)
    $idx++
}

$lines += ''
$lines += '# all_balls assignment fragment'
$lines += 'all_balls = Array[ExtResource("1_rt")]([' + ($allRefs -join ', ') + '])'

$outPath = 'features/balls/templates/balls_database_fragment.txt'
Set-Content -Path $outPath -Value ($lines -join "`r`n") -Encoding UTF8
Write-Host "Generated $outPath"
