extends Control

@onready var label_descricao: Label = $LabelDescricao
@onready var botao_continuar: Button = $BotoesContainer/BotaoContinuar
@onready var botao_recomecar: Button = $BotoesContainer/BotaoRecomecar

func _ready() -> void:
	label_descricao.text = _construir_descricao()
	
	botao_continuar.pressed.connect(_on_continuar_pressed)
	botao_recomecar.pressed.connect(_on_recomecar_pressed)

func _construir_descricao() -> String:
	var p0_morto: bool = RunState.race_initial_dead[0]
	var p1_morto: bool = RunState.race_initial_dead[1]
	
	if p0_morto and p1_morto:
		return "Continuar deixa ambos mortos. Recomecar reseta tudo."
	elif p0_morto:
		return "Continuar: P1 segue morto, P2 volta vivo na fase %d.\nRecomecar: ambos vivos na fase 1, sem upgrades." % RunState.current_phase
	elif p1_morto:
		return "Continuar: P2 segue morto, P1 volta vivo na fase %d.\nRecomecar: ambos vivos na fase 1, sem upgrades." % RunState.current_phase
	else:
		return ""

func _on_continuar_pressed() -> void:
	print("[GameOver] Continuar — retentando fase %d" % RunState.current_phase)
	
	Global.lives = {
		0: Global.MAX_LIVES if not RunState.race_initial_dead[0] else 0,
		1: Global.MAX_LIVES if not RunState.race_initial_dead[1] else 0,
	}
	Global.dead = {
		0: RunState.race_initial_dead[0],
		1: RunState.race_initial_dead[1],
	}
	Global.reset_world_speed()
	
	get_tree().change_scene_to_file("res://Scenes/Corrida.tscn")

func _on_recomecar_pressed() -> void:
	print("[GameOver] Recomeçar — reset total")
	
	RunState.reset_full_run()
	Global.reset_total()
	Global.reset_world_speed()
	
	get_tree().change_scene_to_file("res://Scenes/Corrida.tscn")
