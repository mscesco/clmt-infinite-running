extends Node

const MAX_LIVES: int = 3

var total_coins = 0
var accumulated_coins = 0
var world_speed: float = 300.0
var lives:= { 0: MAX_LIVES, 1: MAX_LIVES }
var dead := { 0: false, 1: false }
var coin_boost_until: Dictionary = { 0: 0.0, 1: 0.0 }
var shield_available: Dictionary = { 0: false, 1: false }
var platform_checkpoint: Dictionary = {}

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

func reset_world_speed() -> void:
	world_speed = FaseConfig.get_fase(RunState.current_phase).vel_base

func flip_gravity():
	gravity_flipped.emit()

func damage_player(player_id: int) -> bool:
	if dead[player_id]: return false
	
	if shield_available[player_id]:
		shield_available[player_id] = false
		print("[Global] Escudo de P%d absorveu o hit" % (player_id + 1))
		return false
	
	lives[player_id] -= 1
	if lives[player_id] <= 0:
		dead[player_id] = true
		player_died.emit(player_id)
		on_double_death()
	return true

func on_double_death() -> void:
	if not (dead[0] and dead[1]):
		return
	
	if platform_checkpoint.is_empty():
		print("[Global] Sem checkpoint — reiniciando a primeira corrida")
		RunState.reset_full_run()
		reset_total()
		reset_world_speed()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Corrida.tscn")
		return
	
	print("[Global] Morte dupla — voltando pro checkpoint da plataforma")
	restore_platform_checkpoint()

func save_platform_checkpoint(scene_path: String) -> void:
	platform_checkpoint = {
		"scene": scene_path,
		"phase": RunState.current_phase,
		"lives": lives.duplicate(true),
		"dead": dead.duplicate(true),
		"total_coins": total_coins,
		"accumulated_coins": accumulated_coins,
		"shield_available": shield_available.duplicate(true),
		"coin_boost_until": coin_boost_until.duplicate(true),
		"upgrades": RunState.upgrades.duplicate(true),
		"revive_pending": RunState.revive_pending.duplicate(true),
	}

func restore_platform_checkpoint() -> void:
	var c: Dictionary = platform_checkpoint
	RunState.current_phase = c["phase"]
	lives = c["lives"].duplicate(true)
	dead = c["dead"].duplicate(true)
	total_coins = c["total_coins"]
	accumulated_coins = c["accumulated_coins"]
	shield_available = c["shield_available"].duplicate(true)
	coin_boost_until = c["coin_boost_until"].duplicate(true)
	RunState.upgrades = c["upgrades"].duplicate(true)
	RunState.revive_pending = c["revive_pending"].duplicate(true)
	get_tree().call_deferred("change_scene_to_file", c["scene"])

func reset_run() -> void:
	lives = { 0: MAX_LIVES, 1: MAX_LIVES }
	dead = { 0: false, 1: false }
	coin_boost_until = { 0: 0.0, 1: 0.0 }
	shield_available = { 0: false, 1: false }

func reset_total() -> void:
	reset_run()
	total_coins = 0
	accumulated_coins = 0
	platform_checkpoint = {}
