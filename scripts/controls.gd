extends Control

@onready var transition: CanvasLayer = $Transition
@onready var anim_player: AnimationPlayer = $Transition/Fill/AnimationPlayer

func _ready() -> void:
	transition.visible = false
	
	$BackButton.pressed.connect(_on_back_pressed)
	$BackButton.grab_focus()

func _on_back_pressed() -> void:
	transition.visible = true
	anim_player.play("transition_in")
	await anim_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
