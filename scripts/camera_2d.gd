extends Camera2D

@export var markers: Array[Marker2D] = []

func _physics_process(_delta: float) -> void:
	if markers.is_empty():
		return

	var melhor_indice: int = -1

	for p in get_tree().get_nodes_in_group("Players"):
		if p.is_dead:
			continue
		var indice_p: int = _marker_mais_proximo(p.global_position)
		if indice_p > melhor_indice:
			melhor_indice = indice_p

	if melhor_indice < 0:
		return

	var alvo: Marker2D = markers[melhor_indice]
	if is_instance_valid(alvo):
		global_position = alvo.global_position

func _marker_mais_proximo(pos: Vector2) -> int:
	var melhor: int = -1
	var menor_dist: float = INF
	for i in markers.size():
		var m: Marker2D = markers[i]
		if not is_instance_valid(m):
			continue
		var d: float = pos.distance_to(m.global_position)
		if d < menor_dist:
			menor_dist = d
			melhor = i
	return melhor
