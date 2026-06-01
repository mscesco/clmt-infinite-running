extends Area2D

@export var rola_com_mundo: bool = true

func _ready() -> void:
	add_to_group("spike")

func _physics_process(delta: float) -> void:
	if rola_com_mundo == true:
		position.x -= Global.world_speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if rola_com_mundo:
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var corpo := area.get_parent()
	if corpo.is_in_group("Players"):
		corpo.levar_dano(not rola_com_mundo)
		if rola_com_mundo:
			call_deferred("queue_free")
	pass
