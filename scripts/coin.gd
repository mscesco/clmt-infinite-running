extends Area2D

func _ready() -> void:
	add_to_group("coin")

func _on_area_entered(area: Area2D) -> void:
	var corpo = area.get_parent()
	if not corpo.is_in_group("Players"):
		return
	
	var pid = corpo.player_id
	var valor = 1
	
	if Time.get_ticks_msec() / 1000.0 < Global.coin_boost_until[pid]:
		valor = 2
	
	Global.total_coins += valor
	queue_free()

	pass

func _physics_process(delta: float) -> void:
	
	position.x -= Global.world_speed * delta
	
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	
	print("Coin removida em x=", position.x)
	queue_free()
	
	pass # Replace with function body.
