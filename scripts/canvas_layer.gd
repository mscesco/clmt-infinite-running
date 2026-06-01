extends CanvasLayer

@onready var label_pontuacao: Label = $Label

func _process(delta: float) -> void:
	atualizar_label()

func atualizar_label():
	label_pontuacao.text = "Coins: " + str(Global.total_coins)
