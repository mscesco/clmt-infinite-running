extends Node

@export var platformA: PackedScene
@export var coinScene: PackedScene
@export var spikeScene: PackedScene

@onready var marker: Marker2D = $Marker2D
@onready var markerPlataforma: Marker2D = $Marker2DPlat

const COIN_PATTERN_GAP: float = 450.0
const SPIKE_GAP_MIN: float = 700.0
const SPIKE_GAP_VAR: float = 500.0
const SPIKE_Y_CHAO: float = 424.0
const SPIKE_Y_TETO: float = 88.0
const SPIKE_PAIR_CHANCE: float = 0.25

var distance_since_last_pattern: float = 0.0
var distance_since_last_spike: float = 0.0
var next_spike_gap: float = SPIKE_GAP_MIN
var spike_pair_chance: float = SPIKE_PAIR_CHANCE

func _ready() -> void:
	spike_pair_chance = FaseConfig.get_fase(RunState.current_phase).spike_pair_chance

func _physics_process(delta: float) -> void:
	
	spawnRule()
	spawn_coins_by_distance(delta)
	spawn_spikes_by_distance(delta)
	
	pass

func spawnRule():
	
	for plataforma in get_tree().get_nodes_in_group("platform"):
		if plataforma.global_position.x <= -823:
			plataforma.remove_from_group("platform")
			spawnPlat()
	
	pass

func spawnPlat():
	
	var platform = platformA.instantiate()
	get_tree().current_scene.add_child(platform)
	platform.global_position = markerPlataforma.position
	
	pass

func spawn_coins_by_distance(delta: float) -> void:
	
	distance_since_last_pattern += Global.world_speed * delta
	if distance_since_last_pattern >= COIN_PATTERN_GAP:
		distance_since_last_pattern = 0.0
		spawn_coin_pattern()
	
	pass

func spawn_coin_pattern():
	
	var pattern: Array = CoinPatterns.PATTERNS.pick_random()
	var base_x: float = marker.global_position.x
	for offset in pattern:
		var coin = coinScene.instantiate()
		get_tree().current_scene.add_child(coin)
		coin.global_position = Vector2(base_x + offset.x, offset.y)
	
	pass

func spawn_spikes_by_distance(delta: float) -> void:
	distance_since_last_spike += Global.world_speed * delta
	if distance_since_last_spike >= next_spike_gap:
		distance_since_last_spike = 0.0
		next_spike_gap = SPIKE_GAP_MIN + randf() * SPIKE_GAP_VAR
		spawn_spikes()

func spawn_spikes():
	
	var spawn_x: float = marker.global_position.x
	if randf() < spike_pair_chance:
		_make_spike(spawn_x, SPIKE_Y_CHAO, false)
		_make_spike(spawn_x, SPIKE_Y_TETO, true)
	else:
		if randf() < 0.5:
			_make_spike(spawn_x, SPIKE_Y_CHAO, false)
		else:
			_make_spike(spawn_x, SPIKE_Y_TETO, true)
	
	pass

func _make_spike(x: float, y: float, is_teto: bool) -> void:
	var spike = spikeScene.instantiate()
	get_tree().current_scene.add_child(spike)
	spike.global_position = Vector2(x, y)
	if is_teto:
		spike.scale.y = -1
