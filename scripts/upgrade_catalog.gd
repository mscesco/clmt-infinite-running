class_name UpgradeCatalog

const TYPE_STAT: String = "stat"
const TYPE_ABILITY: String = "ability"
const REVIVE_COST: int = 50

static var ITEMS: Array = [
	{
		"id": "max_lives",
		"type": TYPE_STAT,
		"nome": "Vida Extra",
		"descricao": "+1 vida máxima",
		"max_level": 2,
		"custos": [30, 60],
	},
	{
		"id": "coin_boost",
		"type": TYPE_STAT,
		"nome": "Coin Boost",
		"descricao": "Moedas em dobro no início da corrida",
		"max_level": 3,
		"custos": [20, 40, 80],
		"duracoes": [5.0, 8.0, 10.0],
	},
	{
		"id": "shield",
		"type": TYPE_ABILITY,
		"nome": "Escudo de Dano",
		"descricao": "Absorve 1 hit (1 uso por corrida)",
		"max_level": 1,
		"custos": [80],
	},
]

static func get_item(id: String) -> Dictionary:
	for item in ITEMS:
		if item.id == id:
			return item
	return {}

static func get_next_cost(item_id: String, player_id: int) -> int:
	var item: Dictionary = get_item(item_id)
	if item.is_empty():
		return -1
	var nivel_atual: int = RunState.get_upgrade_level(player_id, item_id)
	if nivel_atual >= item.max_level:
		return -1
	return item.custos[nivel_atual]

static func is_available(item_id: String, player_id: int) -> bool:
	var item: Dictionary = get_item(item_id)
	if item.is_empty():
		return false
	return RunState.get_upgrade_level(player_id, item_id) < item.max_level
