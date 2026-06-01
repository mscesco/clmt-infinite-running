extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 2

const HURT_DURATION: float = 0.35
const KNOCKBACK_X: float = 450.0
const KNOCKBACK_UP: float = -150.0
const KNOCKBACK_TIME: float = 0.7

enum PlayerId { P1, P2 }
@export var player_id: PlayerId = PlayerId.P1
@export var modo_plataforma: bool = false

@onready var deathlineTop: Marker2D = $"../DeathlineTop"
@onready var deathlineBottom: Marker2D = $"../DeathlineBottom"


var jump_count: int = 0
var gravity_multiplier: int = 1
var first_jump_direction: float = 0.0
var osCaraNoTeto: bool = false
var _jump_action: String = "jump_p1"
var _move_left_action: String = "move_left_p1"
var _move_right_action: String = "move_right_p1"
var is_dead: bool = false
var _hurt_timer: float = 0.0
var _knockback_timer: float = 0.0

func _ready() -> void:
	$AnimatedSprite2D.play("running")
	_jump_action = "jump_p1" if player_id == PlayerId.P1 else "jump_p2"
	_move_left_action = "move_left_p1" if player_id == PlayerId.P1 else "move_left_p2"
	_move_right_action = "move_right_p1" if player_id == PlayerId.P1 else "move_right_p2"
	Global.gravity_flipped.connect(_on_gravity_flipped)
	Global.player_died.connect(_on_player_died)
	
	collision_mask = 1 << 0
	if player_id == PlayerId.P1:
		collision_layer = 1 << 1
		gravity_multiplier = 1
	else:
		collision_layer = 1 << 2
		gravity_multiplier = -1
		scale.y *= -1
		$AnimatedSprite2D.sprite_frames = load("res://sprites/Characters/vampire_girl_frames.tres")
		$AnimatedSprite2D.play("running")
	
	if Global.dead[player_id]:
		_aplicar_estado_morto()
		return
	
	_aplicar_upgrades()

func is_grounded() -> bool:
	if gravity_multiplier == 1:
		return is_on_floor()
	else:
		return is_on_ceiling()

func _physics_process(delta: float) -> void:
	if _knockback_timer > 0.0:
		_knockback_timer -= delta
	if _hurt_timer > 0.0:
		_hurt_timer -= delta
	
	if modo_plataforma and _knockback_timer <= 0.0:
		_mover_horizontal()
	move_and_slide()
	jump(delta)
	_atualizar_animacao()
	deathline()

func _mover_horizontal() -> void:
	var direction: float = Input.get_axis(_move_left_action, _move_right_action)
	velocity.x = direction * SPEED
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true

func jump(delta):
	if gravity_multiplier < 0:
		osCaraNoTeto = true
	if gravity_multiplier > 0:
		osCaraNoTeto = false
	
	if not is_grounded():
		velocity += get_gravity() * gravity_multiplier * delta
	
	if is_on_ceiling() or is_on_floor():
		jump_count = 0
	
	if Input.is_action_just_pressed(_jump_action) and jump_count < MAX_JUMPS:
		jump_count += 1
		if jump_count == 1:
			first_jump_direction = JUMP_VELOCITY * gravity_multiplier
			velocity.y = first_jump_direction
		elif jump_count == 2:
			velocity.y = first_jump_direction
			Global.flip_gravity()

func _atualizar_animacao() -> void:
	if is_dead:
		return
	if _hurt_timer > 0.0:
		return
	
	if not is_grounded():
		if velocity.y * gravity_multiplier < 0.0:
			_tocar("jump")
		else:
			_tocar("falling")
	elif _esta_se_movendo():
		_tocar("running")
	else:
		_tocar("idle")

func _esta_se_movendo() -> bool:
	if absf(velocity.x) >= 1.0:
		return true
	if not modo_plataforma and Global.world_speed > 1.0:
		return true
	return false

func _tocar(anim: String) -> void:
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)

func levar_dano(com_knockback: bool) -> void:
	if is_dead:
		return
	
	var levou: bool = Global.damage_player(player_id)
	if not levou:
		return
	if is_dead:
		return
	
	$AnimatedSprite2D.play("hurt")
	_hurt_timer = HURT_DURATION
	
	if com_knockback:
		velocity.x = -KNOCKBACK_X            # sempre para trás (esquerda)
		velocity.y = KNOCKBACK_UP * gravity_multiplier
		_knockback_timer = KNOCKBACK_TIME

func _on_gravity_flipped() -> void:
	if is_dead:
		return
	gravity_multiplier *= -1
	$".".scale.y *= -1

func _on_player_died(id: int) -> void:
	if id != player_id: return
	_aplicar_estado_morto()

func _aplicar_estado_morto() -> void:
	is_dead = true
	$AnimatedSprite2D.play("die")
	$Area2D.set_deferred("monitorable", false)
	$Area2D.set_deferred("monitoring", false)
	set_physics_process(false)

func _aplicar_upgrades() -> void:
	var nv_vida = RunState.get_upgrade_level(player_id, "max_lives")
	var nv_boost = RunState.get_upgrade_level(player_id, "coin_boost")
	var nv_escudo = RunState.get_upgrade_level(player_id, "shield")
	
	if nv_vida > 0:
		Global.lives[player_id] = Global.MAX_LIVES + nv_vida
		print("[Player%d] Vida Extra nv%d aplicada (lives=%d)" % [player_id + 1, nv_vida, Global.lives[player_id]])
	
	if nv_boost > 0:
		var item = UpgradeCatalog.get_item("coin_boost")
		var duracao = item.duracoes[nv_boost - 1]
		Global.coin_boost_until[player_id] = Time.get_ticks_msec() / 1000.0 + duracao
		print("[Player%d] Coin Boost ativo por %.1fs" % [player_id + 1, duracao])
	
	if nv_escudo > 0:
		Global.shield_available[player_id] = true
		print("[Player%d] Escudo disponível" % (player_id + 1))

func deathline() -> void:
	if global_position.y <= deathlineTop.global_position.y:
		Global.dead[player_id] = true
		_aplicar_estado_morto()
	if global_position.y >= deathlineBottom.global_position.y:
		Global.dead[player_id] = true
		_aplicar_estado_morto()
