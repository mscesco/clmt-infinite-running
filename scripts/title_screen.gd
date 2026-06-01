extends Control

@onready var transition: CanvasLayer = $Transition
@onready var anim_player: AnimationPlayer = $Transition/Fill/AnimationPlayer

func _ready() -> void:
	transition.visible = false
	
	$Play.pressed.connect(_on_play_pressed)
	$Controlls.pressed.connect(_on_controlls_pressed)
	$Exit.pressed.connect(_on_exit_pressed)
	$Play.grab_focus()

func _on_play_pressed() -> void:
	transition.visible = true
	anim_player.play("transition_in")
	await anim_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Corrida.tscn")

func _on_controlls_pressed() -> void:
	transition.visible = true
	anim_player.play("transition_in")
	await anim_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Controls.tscn")

func _on_exit_pressed() -> void:
	transition.visible = true
	anim_player.play("transition_in")
	await anim_player.animation_finished
	get_tree().quit()
