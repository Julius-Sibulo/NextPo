extends PanelContainer

signal approved
signal rejected
signal requested_more_docs
signal escalated

@onready var portrait: TextureRect = $VBoxContainer/Portrait
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var appearance_label: Label = $VBoxContainer/AppearanceLabel
@onready var memory_label: Label = $VBoxContainer/MemoryGreeting
@onready var lore_label: Label = $VBoxContainer/LoreLabel
@onready var doc_list: VBoxContainer = $VBoxContainer/DocumentList
@onready var approve_btn: Button = $VBoxContainer/ButtonRow/ApproveButton
@onready var reject_btn: Button = $VBoxContainer/ButtonRow/RejectButton
@onready var request_btn: Button = $VBoxContainer/ButtonRow/RequestButton
@onready var escalate_btn: Button = $VBoxContainer/ButtonRow/EscalateButton

var current_npc: NPCData = null

func load_client(npc: NPCData, day: int) -> void:
	current_npc = npc

	# Reset buttons
	_set_buttons_disabled(false)

	# Portrait
	if npc.portrait_texture:
		portrait.texture = npc.portrait_texture
		portrait.visible = true
	else:
		portrait.visible = false

	# Name and appearance
	name_label.text = npc.display_name
	appearance_label.text = npc.appearance_description

	# Memory greeting — only shows if they've been here before
	var greeting = npc.get_memory_greeting()
	if greeting.is_empty():
		memory_label.visible = false
	else:
		memory_label.text = "\" " + greeting + " \""
		memory_label.visible = true

	# Progressive lore reveal
	var lore_idx = min(day - 1, npc.lore_stages.size() - 1)
	if lore_idx >= 0 and not npc.lore_stages.is_empty():
		lore_label.text = npc.lore_stages[lore_idx]
		lore_label.visible = true
	else:
		lore_label.visible = false

	# Clear and rebuild document list
	for child in doc_list.get_children():
		child.queue_free()

	var visit_idx = min(day - 1, npc.documents_per_visit.size() - 1)
	if visit_idx >= 0 and not npc.documents_per_visit.is_empty():
		for doc in npc.documents_per_visit[visit_idx]:
			var doc_panel = PanelContainer.new()
			var doc_label = Label.new()
			doc_label.text = "[%s]\n%s" % [doc["doc_type"], doc["content"]]
			doc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

			# Red tint if invalid — player may or may not notice
			if not doc["is_valid"]:
				doc_label.modulate = Color(1.0, 0.6, 0.6)

			doc_panel.add_child(doc_label)
			doc_list.add_child(doc_panel)

func _set_buttons_disabled(disabled: bool) -> void:
	approve_btn.disabled = disabled
	reject_btn.disabled = disabled
	request_btn.disabled = disabled
	escalate_btn.disabled = disabled

func _on_approve_button_pressed() -> void:
	_set_buttons_disabled(true)
	emit_signal("approved")

func _on_reject_button_pressed() -> void:
	_set_buttons_disabled(true)
	emit_signal("rejected")

func _on_request_button_pressed() -> void:
	_set_buttons_disabled(true)
	emit_signal("requested_more_docs")

func _on_escalate_button_pressed() -> void:
	_set_buttons_disabled(true)
	emit_signal("escalated")
