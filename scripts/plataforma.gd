extends StaticBody2D


func _ready() -> void:
	add_to_group("platform")
	pass

func _physics_process(delta: float) -> void:
	
	position.x -= Global.world_speed * delta
	
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	
	print("Plataforma removida em x=", position.x)
	queue_free()
	
