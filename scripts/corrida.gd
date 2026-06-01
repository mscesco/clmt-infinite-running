extends Node2D

@export var DURACAO_CORRIDA: float = 60.0
const DURACAO_DESACELERACAO: float = 2.0
const DURACAO_FADE: float = 1.0

@onready var timer_corrida: Timer = $TimerCorrida
@onready var label_fase_completa: Label = $UICorrida/LabelFaseCompleta
@onready var fade_overlay: ColorRect = $UICorrida/FadeOverlay

var vel_teto: float = 0.0
var aceleracao: float = 0.0
var acelerando: bool = false

func _ready() -> void:
	
	RunState.snapshot_race_start(Global.dead[0], Global.dead[1])
	
	var cfg: Dictionary = FaseConfig.get_fase(RunState.current_phase)
	Global.world_speed = cfg.vel_base
	vel_teto = cfg.vel_teto
	aceleracao = cfg.aceleracao
	acelerando = true
	
	label_fase_completa.visible = false
	fade_overlay.color = Color(0, 0, 0, 0)
	
	timer_corrida.wait_time = DURACAO_CORRIDA
	timer_corrida.one_shot = true
	timer_corrida.timeout.connect(_on_corrida_completa)
	timer_corrida.start()

func _physics_process(delta: float) -> void:
	if acelerando and Global.world_speed < vel_teto:
		Global.world_speed = min(Global.world_speed + aceleracao * delta, vel_teto)

func _on_corrida_completa() -> void:
	print("[Corrida] FASE COMPLETA")
	acelerando = false
	
	var tween_speed: Tween = create_tween()
	tween_speed.tween_property(Global, "world_speed", 0.0, DURACAO_DESACELERACAO)
	label_fase_completa.modulate.a = 0.0
	
	label_fase_completa.visible = true
	var tween_label: Tween = create_tween()
	tween_label.tween_property(label_fase_completa, "modulate:a", 1.0, DURACAO_DESACELERACAO)
	
	await get_tree().create_timer(DURACAO_DESACELERACAO).timeout
	var tween_fade: Tween = create_tween()
	tween_fade.tween_property(fade_overlay, "color:a", 1.0, DURACAO_FADE)
	await tween_fade.finished
	
	get_tree().change_scene_to_file("res://Scenes/Loja.tscn")
