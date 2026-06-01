extends Control

const _DELAY: float = 0.5
var _pronto: bool = false

func _ready() -> void:
	await get_tree().create_timer(_DELAY).timeout
	_pronto = true

func _unhandled_input(event: InputEvent) -> void:
	if not _pronto:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("jump_p1") or event.is_action_pressed("jump_p2"):
		_voltar_ao_inicio()

func _voltar_ao_inicio() -> void:
	_pronto = false
	RunState.reset_full_run()
	Global.reset_total()
	Global.reset_world_speed()
	get_tree().change_scene_to_file("res://Scenes/Corrida.tscn")
