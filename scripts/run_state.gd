extends Node

const TOTAL_PHASES: int = 3
var current_phase: int = 1

var upgrades: Dictionary = {
	0: {},
	1: {},
}

var revive_pending: Dictionary = {
	0: false,
	1: false,
}

var race_initial_dead: Dictionary = {
	0: false,
	1: false,
}

func get_upgrade_level(player_id: int, upgrade_id: String) -> int:
	return upgrades[player_id].get(upgrade_id, 0)

func set_upgrade_level(player_id: int, upgrade_id: String, level: int) -> void:
	upgrades[player_id][upgrade_id] = level

func advance_phase() -> void:
	current_phase += 1

func reset_full_run() -> void:
	current_phase = 1
	upgrades = { 0: {}, 1: {} }
	revive_pending = { 0: false, 1: false }
	race_initial_dead = { 0: false, 1: false }

func snapshot_race_start(p0_dead: bool, p1_dead: bool) -> void:
	race_initial_dead = { 0: p0_dead, 1: p1_dead }
