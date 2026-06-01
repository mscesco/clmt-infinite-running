extends Area2D

@export_file("*.tscn") var proxima_cena: String = ""

var _ja_disparou: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if _ja_disparou:
		return
	var corpo := area.get_parent()
	if not corpo.is_in_group("Players"):
		return
	if proxima_cena == "":
		push_warning("[PlatCheckpoint] Nenhuma cena definida em 'proxima_cena'.")
		return
	_ja_disparou = true
	get_tree().call_deferred("change_scene_to_file", proxima_cena)
