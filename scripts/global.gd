extends Node

const MAX_LIVES: int = 3

var total_coins = 0
var accumulated_coins = 0
var world_speed: float = 300.0
var lives:= { 0: MAX_LIVES, 1: MAX_LIVES }
var dead := { 0: false, 1: false }
var coin_boost_until: Dictionary = { 0: 0.0, 1: 0.0 }
var shield_available: Dictionary = { 0: false, 1: false }

signal gravity_flipped
signal player_died(player_id: int)

func _ready():
	pass

func new_game():
	pass

func _process(_delta):
	pass

func accelerate_world(amount: float) -> void:
	
	world_speed += amount
	
	pass

func reset_world_speed() -> void:
	
	world_speed = FaseConfig.get_fase(RunState.current_phase).vel_base
	
	pass

func flip_gravity():
	
	gravity_flipped.emit()
	
	pass

func damage_player(player_id: int) -> bool:
	if dead[player_id]: return false
	
	# Escudo absorve o primeiro hit
	if shield_available[player_id]:
		shield_available[player_id] = false
		print("[Global] Escudo de P%d absorveu o hit" % (player_id + 1))
		return false
	
	lives[player_id] -= 1
	if lives[player_id] <= 0:
		dead[player_id] = true
		player_died.emit(player_id)
		_check_race_over()
	return true

func _check_race_over() -> void:
	if not (dead[0] and dead[1]):
		return
	
	print("[Global] Morte dupla detectada. Fase atual: %d" % RunState.current_phase)
	
	if RunState.current_phase == 1:
		print("[Global] Reset total (fase 1)")
		RunState.reset_full_run()
		reset_total()
		reset_world_speed()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Corrida.tscn")
		return
	
	var alguem_iniciou_morto: bool = RunState.race_initial_dead[0] or RunState.race_initial_dead[1]
	
	if not alguem_iniciou_morto:
		print("[Global] Caso A: retentando corrida")
		reset_run()
		reset_world_speed()
		get_tree().call_deferred("reload_current_scene")
	else:
		print("[Global] Caso B: abrindo Game Over")
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/GameOver.tscn")

func reset_run() -> void:
	lives = { 0: MAX_LIVES, 1: MAX_LIVES }
	dead = { 0: false, 1: false }
	coin_boost_until = { 0: 0.0, 1: 0.0 }
	shield_available = { 0: false, 1: false }

func reset_total() -> void:
	reset_run()
	total_coins = 0
	accumulated_coins = 0
