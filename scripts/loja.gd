extends Control

var carrinho: Array = []
var confirmados_nesta_visita: Array = []

var item_selecionado: String = ""

@onready var label_fase: Label = $Header/LabelFase
@onready var label_moedas: Label = $Header/LabelMoedas
@onready var lista_itens: VBoxContainer = $Corpo/PainelItens/VBoxItens/ScrollItens/ListaItens
@onready var lista_carrinho: VBoxContainer = $Corpo/PainelCarrinho/VBoxCarrinho/ScrollCarrinho/ListaCarrinho
@onready var label_total_carrinho: Label = $Corpo/PainelCarrinho/VBoxCarrinho/LabelTotalCarrinho
@onready var botao_confirmar: Button = $Acoes/BotaoConfirmar
@onready var botao_proxima_fase: Button = $Acoes/BotaoProximaFase

@onready var popup: PopupPanel = $PopupPlayer
@onready var botao_p1: Button = $PopupPlayer/MarginPopup/VBoxPopup/BotoesPopup/BotaoP1
@onready var botao_p2: Button = $PopupPlayer/MarginPopup/VBoxPopup/BotoesPopup/BotaoP2
@onready var botao_cancelar: Button = $PopupPlayer/MarginPopup/VBoxPopup/BotoesPopup/BotaoCancelar

func _ready() -> void:
	label_fase.text = "LOJA — Fase %d/%d" % [RunState.current_phase, RunState.TOTAL_PHASES]
	
	botao_confirmar.pressed.connect(_on_confirmar_pressed)
	botao_proxima_fase.pressed.connect(_on_proxima_fase_pressed)
	botao_p1.pressed.connect(_on_player_escolhido.bind(0))
	botao_p2.pressed.connect(_on_player_escolhido.bind(1))
	botao_cancelar.pressed.connect(_on_popup_cancelar)
	popup.popup_hide.connect(_on_popup_fechou)
	
	_atualizar_ui()

func _gerar_botoes_itens() -> void:
	for child in lista_itens.get_children():
		child.queue_free()
	
	for pid in [0, 1]:
		if Global.dead[pid]:
			lista_itens.add_child(_criar_botao_revive(pid))
	
	for item in UpgradeCatalog.ITEMS:
		lista_itens.add_child(_criar_botao_item(item))

func _criar_botao_revive(player_id: int) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 80)
	btn.add_theme_font_size_override("font_size", 18)
	
	var pid_nome = "P1" if player_id == 0 else "P2"
	var custo = UpgradeCatalog.REVIVE_COST
	btn.text = "Ressuscitar %s — %d moedas" % [pid_nome, custo]
	
	btn.disabled = not _pode_adicionar_revive(player_id)
	
	btn.pressed.connect(_on_revive_clicado.bind(player_id))
	return btn

func _criar_botao_item(item: Dictionary) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 80)
	btn.add_theme_font_size_override("font_size", 16)
	
	var info_niveis = "P1 nv %d/%d  |  P2 nv %d/%d" % [
		RunState.get_upgrade_level(0, item.id), item.max_level,
		RunState.get_upgrade_level(1, item.id), item.max_level
	]
	btn.text = "%s\n%s" % [item.nome, info_niveis]
	
	btn.disabled = not (_pode_adicionar_ao_carrinho(item.id, 0) or _pode_adicionar_ao_carrinho(item.id, 1))
	
	btn.pressed.connect(_on_item_clicado.bind(item.id))
	return btn

func _on_item_clicado(item_id: String) -> void:
	item_selecionado = item_id
	var item = UpgradeCatalog.get_item(item_id)
	
	_configurar_botao_popup(botao_p1, item_id, 0)
	_configurar_botao_popup(botao_p2, item_id, 1)
	
	popup.title = "%s — para qual player?" % item.nome
	popup.popup_centered()
	_focar_no_popup.call_deferred()

func _configurar_botao_popup(btn: Button, item_id: String, player_id: int) -> void:
	var pid_nome = "P1" if player_id == 0 else "P2"
	var pode = _pode_adicionar_ao_carrinho(item_id, player_id)
	btn.disabled = not pode
	
	if pode:
		var custo = UpgradeCatalog.get_next_cost(item_id, player_id)
		btn.text = "%s\n(%d moedas)" % [pid_nome, custo]
	else:
		btn.text = "%s\n(indisponível)" % pid_nome


func _on_revive_clicado(player_id: int) -> void:
	if not _pode_adicionar_revive(player_id):
		return
	
	carrinho.append({
		"item_id": "revive",
		"player_id": player_id,
		"custo": UpgradeCatalog.REVIVE_COST,
		"nome": "Ressuscitar P%d" % (player_id + 1)
	})
	_atualizar_ui()

func _on_player_escolhido(player_id: int) -> void:
	if not _pode_adicionar_ao_carrinho(item_selecionado, player_id):
		return
	
	var item = UpgradeCatalog.get_item(item_selecionado)
	var custo = UpgradeCatalog.get_next_cost(item_selecionado, player_id)
	
	carrinho.append({
		"item_id": item_selecionado,
		"player_id": player_id,
		"custo": custo,
		"nome": item.nome
	})
	
	popup.hide()
	_atualizar_ui()


func _on_popup_cancelar() -> void:
	popup.hide()

func _pode_adicionar_ao_carrinho(item_id: String, player_id: int) -> bool:
	if not UpgradeCatalog.is_available(item_id, player_id):
		return false
	
	if "%s:%d" % [item_id, player_id] in confirmados_nesta_visita:
		return false
	
	for item in carrinho:
		if item.item_id == item_id and item.player_id == player_id:
			return false
	
	var custo = UpgradeCatalog.get_next_cost(item_id, player_id)
	if _saldo_disponivel() < custo:
		return false
	
	return true

func _pode_adicionar_revive(player_id: int) -> bool:
	if not Global.dead[player_id]:
		return false
	
	if "revive:%d" % player_id in confirmados_nesta_visita:
		return false
	
	for item in carrinho:
		if item.item_id == "revive" and item.player_id == player_id:
			return false
	
	if _saldo_disponivel() < UpgradeCatalog.REVIVE_COST:
		return false
	
	return true

func _saldo_disponivel() -> int:
	return Global.total_coins - _total_carrinho()


func _total_carrinho() -> int:
	var total = 0
	for item in carrinho:
		total += item.custo
	return total

func _atualizar_ui() -> void:
	
	var total = _total_carrinho()
	label_moedas.text = "Moedas: %d (carrinho: -%d)" % [Global.total_coins, total]
	label_total_carrinho.text = "Total: %d moedas" % total
	botao_confirmar.disabled = carrinho.is_empty()
	
	for child in lista_carrinho.get_children():
		child.queue_free()
	
	for i in carrinho.size():
		lista_carrinho.add_child(_criar_linha_carrinho(carrinho[i], i))
	
	_gerar_botoes_itens()
	_garantir_foco.call_deferred()

func _criar_linha_carrinho(item: Dictionary, index: int) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	
	var lbl = Label.new()
	var pid_nome = "P1" if item.player_id == 0 else "P2"
	lbl.text = "%s → %s  (%d)" % [item.nome, pid_nome, item.custo]
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)
	
	var btn_remover = Button.new()
	btn_remover.text = "X"
	btn_remover.custom_minimum_size = Vector2(40, 30)
	btn_remover.pressed.connect(_on_remover_do_carrinho.bind(index))
	hbox.add_child(btn_remover)
	
	return hbox


func _on_remover_do_carrinho(index: int) -> void:
	carrinho.remove_at(index)
	_atualizar_ui()

func _on_confirmar_pressed() -> void:
	var total = _total_carrinho()
	Global.total_coins -= total
	
	for item in carrinho:
		confirmados_nesta_visita.append("%s:%d" % [item.item_id, item.player_id])
		if item.item_id == "revive":
			RunState.revive_pending[item.player_id] = true
			print("[Loja] Revive comprado pra P%d" % (item.player_id + 1))
		else:
			var nivel_atual = RunState.get_upgrade_level(item.player_id, item.item_id)
			RunState.set_upgrade_level(item.player_id, item.item_id, nivel_atual + 1)
			print("[Loja] %s pra P%d agora nv %d" % [item.nome, item.player_id + 1, nivel_atual + 1])
	
	carrinho.clear()
	_atualizar_ui()

func _on_proxima_fase_pressed() -> void:
	if not carrinho.is_empty():
		print("[Loja] Carrinho não confirmado foi descartado")
		carrinho.clear()
	for pid in [0, 1]:
		if RunState.revive_pending[pid]:
			Global.lives[pid] = Global.MAX_LIVES
			Global.dead[pid] = false
			RunState.revive_pending[pid] = false
			print("[Loja] P%d ressuscitado pra próxima corrida" % (pid + 1))
		elif not Global.dead[pid]:
			Global.lives[pid] = Global.MAX_LIVES
	var destino: String = "res://Scenes/plataformer_fase_%d.tscn" % RunState.current_phase
	RunState.advance_phase()
	Global.reset_world_speed()
	
	get_tree().change_scene_to_file(destino)

func _garantir_foco() -> void:
	var atual: Control = get_viewport().gui_get_focus_owner()
	if atual != null and not atual.is_queued_for_deletion():
		return
	
	for btn in lista_itens.get_children():
		if btn is Button and not btn.disabled and not btn.is_queued_for_deletion():
			btn.grab_focus()
			return
	
	botao_proxima_fase.grab_focus()

func _focar_no_popup() -> void:
	for btn in [botao_p1, botao_p2, botao_cancelar]:
		if not btn.disabled:
			btn.grab_focus()
			return

func _on_popup_fechou() -> void:
	_garantir_foco.call_deferred()
