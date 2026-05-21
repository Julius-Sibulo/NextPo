extends Control

@onready var citizen_sprite: TextureRect = $MarginContainer/VBoxContainer/TopRow/CenterPanel/CitizenSprite
@onready var center_panel: CenterContainer = $MarginContainer/VBoxContainer/TopRow/CenterPanel
@onready var scenario_label: Label = $MarginContainer/VBoxContainer/BottomPanel/BottomVBox/ScenarioLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/BottomPanel/BottomVBox/DescriptionLabel
@onready var feedback_label: Label = $MarginContainer/VBoxContainer/FeedbackLabel
@onready var day_display_label: Label = $TimerBar/DayDisplayLabel 

@onready var choice_a: Button = $MarginContainer/VBoxContainer/TopRow/RightPanel/RightBox/ChoicesGrid/ChoiceA
@onready var choice_b: Button = $MarginContainer/VBoxContainer/TopRow/RightPanel/RightBox/ChoicesGrid/ChoiceB
@onready var choice_c: Button = $MarginContainer/VBoxContainer/TopRow/RightPanel/RightBox/ChoicesGrid/ChoiceC
@onready var choice_d: Button = $MarginContainer/VBoxContainer/TopRow/RightPanel/RightBox/ChoicesGrid/ChoiceD

@onready var end_shift_btn: Button = $EndShiftButton 

@onready var compliance_label: Label = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/ComplianceLabel
@onready var compliance_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/ComplianceBar
@onready var compassion_label: Label = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/CompassionLabel
@onready var compassion_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/CompassionBar
@onready var trust_label: Label = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/TrustLabel
@onready var trust_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/TrustBar

@onready var timer_bar: ProgressBar = $TimerBar
@onready var end_of_day_report: PanelContainer = $EndOfDayReport
@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var game_over_label: Label = $GameOverPanel/Label

@onready var official_book: PanelContainer = $OfficialBook
@onready var official_book_btn: Button = $OfficialBookButton

@onready var rulebook: PanelContainer = $Rulebook
@onready var rulebook_btn: Button = $RulebookButton

@onready var doc_viewer: PanelContainer = $PopupLayer/DocumentViewer
@onready var doc_photo: TextureRect = $PopupLayer/DocumentViewer/HBoxContainer/DocPhoto
@onready var doc_title: Label = $PopupLayer/DocumentViewer/HBoxContainer/TextVBox/DocTitle
@onready var doc_content: Label = $PopupLayer/DocumentViewer/HBoxContainer/TextVBox/DocContent
@onready var close_doc_btn: Button = $PopupLayer/DocumentViewer/HBoxContainer/TextVBox/CloseDocButton

@onready var music_player = $MusicPlayer
@onready var next_po_audio: AudioStreamPlayer = $NextPoAudio

const INVALID_CHANCE := 0.35
const NPC_FRAME_SIZE := Vector2i(24, 42)
const NPC_FRAME_SPACING := 1
const NPC_DISPLAY_SCALE := 8.0

const NPC_SHEET_PATHS := {
	"body": "res://Assets/npc/body.png",
	"expression": "res://Assets/npc/expression.png",
	"shirt": "res://Assets/npc/shirt.png",
	"hair": "res://Assets/npc/hair.png",
	"accessory": "res://Assets/npc/accessories.png",
}

const DOC_ASSETS := {
	"card": "res://Assets/documents/card.png",
	"card_damaged": "res://Assets/documents/card_damaged.png",
	"request_form": "res://Assets/documents/request_form.png",
	"request_form_damaged": "res://Assets/documents/request_form_damaged.png",
	"generic": "res://Assets/documents/generic_doc.png",
}

const REQUEST_REQUIREMENTS := {
	"Financial": ["ID", "Request Form", "Hospital Bill"],
	"Clearance": ["ID", "Request Form"],
	"Permit": ["ID", "Request Form", "Birth Certificate"],
	"Education": ["ID", "Request Form", "Enrollment Certificate"],
}

const REQUEST_REASON_POOLS := {
	"Financial": [
		"I am requesting assistance for unpaid hospital charges after an emergency admission.",
		"I need financial aid for medication and follow-up treatment costs.",
		"I am asking for support after a family member's recent hospitalization.",
		"I need emergency medical assistance because my income was interrupted.",
		"I am requesting partial coverage for laboratory tests and consultation fees."
	],
	"Clearance": [
		"I am requesting clearance for my employment requirements.",
		"I need this clearance to complete a pending job application.",
		"I am requesting certification for my local residency records.",
		"I need clearance for a transfer of workplace assignment.",
		"I am requesting this clearance for a scheduled administrative review."
	],
	"Permit": [
		"I am requesting a permit for a small neighborhood business.",
		"I need permission to operate a temporary vending stall.",
		"I am applying for a permit to renovate part of my residence.",
		"I am requesting approval for a short-term community event.",
		"I need authorization for a home-based livelihood activity."
	],
	"Education": [
		"I am requesting education assistance for school fees and supplies.",
		"I need support for enrollment and transportation costs.",
		"I am applying for aid so I can continue the current academic term.",
		"I am requesting assistance after losing a scholarship sponsor.",
		"I need education support for required documents and materials."
	]
}

const FIRST_NAMES := ["Mateo", "Sofia", "Gabriel", "Isabella", "Elias", "Camila", "Julian", "Luna", "Rosa", "Diego"]
const LAST_NAMES := ["Reyes", "Bautista", "Cruz", "Santos", "Mendoza", "Rivera", "Aquino", "Ramos", "Flores", "Morales"]

const DOC_POPUP_SIZE := Vector2(820, 820)
const DOC_TEXT_FONT_SIZE := 30
const DOC_TEXT_COLOR := Color(0.08, 0.06, 0.04)

const CARD_IMAGE_POS := Vector2(60, 200)
const CARD_IMAGE_SIZE := Vector2(700, 460)
const CARD_PORTRAIT_POS := Vector2(49, 93)
const CARD_PORTRAIT_SCALE := 8.0
const CARD_NAME_POS := Vector2(300, 130)
const CARD_ID_POS := Vector2(300, 175)

const FORM_IMAGE_POS := Vector2(120, 48)
const FORM_IMAGE_SIZE := Vector2(516, 720)
const FORM_NAME_POS := Vector2(200, 580)
const FORM_TYPE_POS := Vector2(200, 225)
const FORM_REASON_POS := Vector2(50, 240)
const FORM_REASON_SIZE := Vector2(300, 115)

var current_docs: Array = []
var day_ended_by_timer: bool = false
var _day_timer_started: bool = false
var npc_sheets := {}
var document_textures := {}
var npc_portrait_root: Control
var npc_portrait_layers := {}
var document_popup: PanelContainer
var document_canvas: Control

func play_game_music():
	music_player.stream = load("res://Assets/clock-tick.mp3")
	music_player.volume_db = 0
	music_player.play()

func _ready() -> void:
	end_of_day_report.visible = false
	game_over_panel.visible = false
	if feedback_label: feedback_label.text = ""
	
	_setup_generated_assets()
	_setup_npc_portrait()
	_setup_document_popup()
	
	if day_display_label:
		day_display_label.text = "Day 1"
		
	play_game_music()

	choice_a.text = "Approve"
	choice_b.text = "Reject"
	
	if end_shift_btn:
		end_shift_btn.visible = false
		end_shift_btn.pressed.connect(_on_end_shift_pressed)
		
	if doc_viewer:
		doc_viewer.visible = false
		close_doc_btn.pressed.connect(_on_close_document)

	if official_book: official_book.visible = false
	if rulebook_btn: rulebook_btn.visible = false 
	
	if official_book_btn:
		official_book_btn.pressed.connect(_on_official_book_toggled)
	if rulebook_btn:
		rulebook_btn.pressed.connect(_on_rulebook_toggled)
	
	compliance_bar.max_value = 100
	compassion_bar.max_value = 100
	trust_bar.max_value = 100

	GameManager.calling_next_client.connect(_on_calling_next_client)
	GameManager.client_arrived.connect(_on_client_arrived)
	GameManager.day_started.connect(_on_day_started)
	GameManager.day_ended.connect(_on_day_ended)
	MeterManager.meters_updated.connect(_on_meters_updated)
	MeterManager.game_over.connect(_on_game_over)

	choice_a.pressed.connect(_on_approved)
	choice_b.pressed.connect(_on_rejected)
	choice_c.pressed.connect(_on_requested_more_docs)
	choice_d.pressed.connect(_on_escalated)

	timer_bar.time_expired.connect(_on_time_expired)
	end_of_day_report.continue_pressed.connect(_on_continue_pressed)

	_on_meters_updated(0.5, 0.5, 0.5)

func start_gameplay_loop() -> void:
	GameManager.start_day()

func _setup_generated_assets() -> void:
	for key in NPC_SHEET_PATHS.keys():
		if ResourceLoader.exists(NPC_SHEET_PATHS[key]):
			npc_sheets[key] = load(NPC_SHEET_PATHS[key])
	for key in DOC_ASSETS.keys():
		if ResourceLoader.exists(DOC_ASSETS[key]):
			document_textures[key] = load(DOC_ASSETS[key])

func _setup_npc_portrait() -> void:
	if citizen_sprite:
		citizen_sprite.visible = false

	npc_portrait_root = Control.new()
	npc_portrait_root.name = "GeneratedNPCPortrait"
	npc_portrait_root.custom_minimum_size = Vector2(NPC_FRAME_SIZE.x, NPC_FRAME_SIZE.y) * NPC_DISPLAY_SCALE
	npc_portrait_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	npc_portrait_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	center_panel.add_child(npc_portrait_root)

	for layer_name in ["body", "shirt", "hair", "expression", "accessory"]:
		var layer := TextureRect.new()
		layer.name = layer_name.capitalize() + "Layer"
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		layer.stretch_mode = TextureRect.STRETCH_SCALE
		layer.position = Vector2.ZERO
		layer.size = Vector2(NPC_FRAME_SIZE.x, NPC_FRAME_SIZE.y) * NPC_DISPLAY_SCALE
		npc_portrait_root.add_child(layer)
		npc_portrait_layers[layer_name] = layer

func _setup_document_popup() -> void:
	if doc_viewer:
		doc_viewer.visible = false

	document_popup = PanelContainer.new()
	document_popup.name = "GeneratedDocumentPopup"
	document_popup.visible = false
	document_popup.custom_minimum_size = DOC_POPUP_SIZE
	document_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	document_popup.set_anchors_preset(Control.PRESET_CENTER)
	document_popup.offset_left = -DOC_POPUP_SIZE.x / 2.0
	document_popup.offset_top = -DOC_POPUP_SIZE.y / 2.0
	document_popup.offset_right = DOC_POPUP_SIZE.x / 2.0
	document_popup.offset_bottom = DOC_POPUP_SIZE.y / 2.0
	$PopupLayer.add_child(document_popup)

	document_canvas = Control.new()
	document_canvas.custom_minimum_size = DOC_POPUP_SIZE
	document_canvas.size = DOC_POPUP_SIZE
	document_popup.add_child(document_canvas)

func _apply_npc_portrait(npc: NPCData) -> void:
	# 1. Check if this is a handcrafted Main NPC with a custom portrait
	if npc.npc_id.begins_with("main_") and npc.portrait_texture != null:
		# Hide procedural layers
		for layer in npc_portrait_layers.values():
			layer.visible = false
			
		# Show the custom 2D sprite!
		citizen_sprite.texture = npc.portrait_texture
		citizen_sprite.visible = true
		
	# 2. Otherwise, it's a random citizen. Use the procedural generator!
	else:
		# Hide the custom 2D sprite
		citizen_sprite.visible = false
		
		# Build the procedural layers
		_ensure_npc_runtime_data(npc)
		_apply_portrait_layers(npc_portrait_layers, _portrait_from_npc(npc), NPC_DISPLAY_SCALE)

func _apply_portrait_layers(layers: Dictionary, frames: Dictionary, display_scale: float) -> void:
	for layer_name in ["body", "shirt", "hair", "expression", "accessory"]:
		var layer: TextureRect = layers[layer_name]
		var frame: Vector2i = frames.get(layer_name, Vector2i(-1, -1))
		
		if frame.x < 0 or frame.y < 0 or not npc_sheets.has(layer_name):
			layer.visible = false
			continue

		var atlas := AtlasTexture.new()
		atlas.atlas = npc_sheets[layer_name]
		atlas.region = _get_frame_rect(frame)
		layer.texture = atlas
		layer.size = Vector2(NPC_FRAME_SIZE.x, NPC_FRAME_SIZE.y) * display_scale
		layer.visible = true

func _get_frame_rect(frame: Vector2i) -> Rect2:
	return Rect2(
		frame.x * (NPC_FRAME_SIZE.x + NPC_FRAME_SPACING),
		frame.y * (NPC_FRAME_SIZE.y + NPC_FRAME_SPACING),
		NPC_FRAME_SIZE.x,
		NPC_FRAME_SIZE.y
	)

func _portrait_from_npc(npc: NPCData) -> Dictionary:
	return {
		"body": npc.body_frame,
		"expression": npc.expression_frame,
		"shirt": npc.shirt_frame,
		"hair": npc.hair_frame,
		"accessory": npc.accessory_frame,
	}

func _ensure_npc_runtime_data(npc: NPCData) -> void:
	var h: int = abs(hash(npc.npc_id + npc.display_name))
	if npc.true_name.is_empty():
		npc.true_name = npc.display_name if not npc.display_name.is_empty() else _name_from_hash(h)
	if npc.display_name.is_empty() or npc.display_name == npc.true_name:
		npc.display_name = "Citizen"
	if npc.id_number.is_empty():
		npc.id_number = "NP-" + str(1000 + (h % 9000)) + "-" + str(10 + (int(h / 7) % 90))
	if npc.gender.is_empty():
		npc.gender = "male" if h % 2 == 0 else "female"
	if npc.age_group.is_empty():
		npc.age_group = "old" if int(h / 3) % 4 == 0 else "adult"
	if npc.request_type.is_empty() or not REQUEST_REQUIREMENTS.has(npc.request_type):
		var request_keys := REQUEST_REQUIREMENTS.keys()
		npc.request_type = request_keys[h % request_keys.size()]
	if npc.body_frame.x < 0:
		var frames := _generate_portrait_from_hash(npc.gender, npc.age_group, h)
		npc.body_frame = frames["body"]
		npc.expression_frame = frames["expression"]
		npc.shirt_frame = frames["shirt"]
		npc.hair_frame = frames["hair"]
		npc.accessory_frame = frames["accessory"]

	if npc.documents_per_visit.is_empty() or not _documents_use_new_format(npc.documents_per_visit[0]):
		var invalid := h % 100 < int(INVALID_CHANCE * 100.0)
		npc.documents_per_visit = [_generate_runtime_documents(npc, invalid, h)]
		if invalid:
			npc.documents_per_visit.append(_generate_runtime_documents(npc, false, h + 101))

func _documents_use_new_format(docs: Array) -> bool:
	for doc in docs:
		if doc is Dictionary and doc.has("template"):
			return true
	return false

func _generate_runtime_documents(npc: NPCData, invalid: bool, h: int) -> Array:
	var docs := []
	for doc_type in REQUEST_REQUIREMENTS[npc.request_type]:
		match doc_type:
			"ID":
				docs.append(_make_runtime_id_doc(npc))
			"Request Form":
				docs.append(_make_runtime_request_form_doc(npc, h))
			_:
				docs.append(_make_runtime_generic_doc(doc_type))
	if invalid:
		_apply_runtime_error(npc, docs, h)
	return docs

func _make_runtime_id_doc(npc: NPCData) -> Dictionary:
	return {
		"doc_type": "ID",
		"template": "card",
		"expandable": true,
		"present": true,
		"is_valid": true,
		"error_type": "",
		"damaged": false,
		"name": npc.true_name,
		"id_number": npc.id_number,
		"portrait_frames": _portrait_from_npc(npc),
	}

func _make_runtime_request_form_doc(npc: NPCData, h: int) -> Dictionary:
	return {
		"doc_type": "Request Form",
		"template": "request_form",
		"expandable": true,
		"present": true,
		"is_valid": true,
		"error_type": "",
		"damaged": false,
		"name": npc.true_name,
		"id_number": npc.id_number,
		"request_type": npc.request_type,
		"request_reason": _get_request_reason(npc.request_type, h),
		"reference_number": "REQ-" + str(10000 + (h % 90000)),
	}

func _make_runtime_generic_doc(doc_type: String) -> Dictionary:
	return {
		"doc_type": doc_type,
		"template": "generic",
		"expandable": false,
		"present": true,
		"is_valid": true,
		"error_type": "",
	}

func _apply_runtime_error(npc: NPCData, docs: Array, h: int) -> void:
	var support_indexes := []
	for i in range(docs.size()):
		if not docs[i].get("expandable", false):
			support_indexes.append(i)

	var errors := ["wrong_name", "wrong_portrait", "damaged_document"]
	if not support_indexes.is_empty():
		errors.append("missing_document")
	var error_type: String = errors[h % errors.size()]

	match error_type:
		"wrong_name":
			var targets := _expandable_docs(docs)
			var doc: Dictionary = targets[h % targets.size()]
			doc["name"] = _name_from_hash(h + 77)
			doc["is_valid"] = false
			doc["error_type"] = "wrong_name"
		"wrong_portrait":
			var id_doc := _doc_by_template(docs, "card")
			var wrong_gender := "female" if npc.gender == "male" else "male"
			id_doc["portrait_frames"] = _generate_portrait_from_hash(wrong_gender, npc.age_group, h + 33)
			id_doc["is_valid"] = false
			id_doc["error_type"] = "wrong_portrait"
		"damaged_document":
			var targets := _expandable_docs(docs)
			var doc: Dictionary = targets[h % targets.size()]
			doc["damaged"] = true
			doc["is_valid"] = false
			doc["error_type"] = "damaged_document"
		"missing_document":
			var missing_index: int = support_indexes[h % support_indexes.size()]
			docs[missing_index]["present"] = false
			docs[missing_index]["is_valid"] = false
			docs[missing_index]["error_type"] = "missing_document"

func _expandable_docs(docs: Array) -> Array:
	var result := []
	for doc in docs:
		if doc.get("expandable", false):
			result.append(doc)
	return result

func _doc_by_template(docs: Array, template: String) -> Dictionary:
	for doc in docs:
		if doc.get("template", "") == template:
			return doc
	return {}

func _generate_portrait_from_hash(gender: String, age_group: String, h: int) -> Dictionary:
	return {
		"body": Vector2i(h % 3, 0),
		"expression": Vector2i(int(h / 3) % 3, 0),
		"shirt": Vector2i(int(h / 9) % 4, 0 if gender == "male" else 1),
		"hair": Vector2i(int(h / 36) % 4, _get_hair_row(gender, age_group)),
		"accessory": _accessory_from_hash(gender, h),
	}

func _get_hair_row(gender: String, age_group: String) -> int:
	if gender == "male" and age_group == "old":
		return 1
	if gender == "female" and age_group == "old":
		return 3
	if gender == "female":
		return 2
	return 0

func _accessory_from_hash(gender: String, h: int) -> Vector2i:
	if h % 100 >= 20:
		return Vector2i(-1, -1)
	var allowed := [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(2, 1),
	]
	if gender == "male":
		allowed.append(Vector2i(3, 0))
	else:
		allowed.append(Vector2i(3, 1))
	return allowed[int(h / 100) % allowed.size()]

func _name_from_hash(h: int) -> String:
	return FIRST_NAMES[h % FIRST_NAMES.size()] + " " + LAST_NAMES[int(h / FIRST_NAMES.size()) % LAST_NAMES.size()]

func _get_request_reason(request_type: String, h: int) -> String:
	if not REQUEST_REASON_POOLS.has(request_type):
		return "I am submitting this request for review."
	var pool: Array = REQUEST_REASON_POOLS[request_type]
	return pool[h % pool.size()]

# ─── Day flow ──────────────────────────────────────────────────────────────────

func _on_day_started(day_number: int) -> void:
	if day_display_label:
		day_display_label.text = "Day " + str(day_number)
	_day_timer_started = false
	timer_bar.pause_timer()
	if end_shift_btn:
		end_shift_btn.visible = false

# --- NEW: Clears the desk and plays the audio before the NPC arrives ---
func _on_calling_next_client() -> void:
	_set_buttons_disabled(true)
	scenario_label.text = "Next Po!"
	description_label.text = ""
	
	# Clear the procedural portrait
	for layer in npc_portrait_layers.values():
		layer.visible = false
		
	# Hide previous documents
	current_docs.clear()
	_display_docs() 
	
	# Play the voice line!
	if next_po_audio:
		next_po_audio.play()

func _on_client_arrived(npc: NPCData) -> void:
	end_of_day_report.visible = false
	_set_buttons_disabled(false)
	if feedback_label: feedback_label.text = ""

	if not _day_timer_started:
		_day_timer_started = true
		timer_bar.start_timer(60.0)
	else:
		timer_bar.resume_timer()
	
	if end_shift_btn:
		if GameManager.current_client_index >= GameManager.MIN_QUOTA:
			end_shift_btn.visible = true
			end_shift_btn.disabled = false
		else:
			end_shift_btn.visible = false

	var day = GameManager.current_day

	_apply_npc_portrait(npc)

	scenario_label.text = npc.request_type + " Request"

	var desc = npc.appearance_description
	var greeting = npc.get_memory_greeting()
	if not greeting.is_empty():
		desc += "\n\n\"" + greeting + "\""
	var lore_idx = min(day - 1, npc.lore_stages.size() - 1)
	if lore_idx >= 0 and not npc.lore_stages.is_empty():
		desc += "\n\n" + npc.lore_stages[lore_idx]

	var visit_idx = min(npc.interaction_history.size(), npc.documents_per_visit.size() - 1)
	current_docs = npc.documents_per_visit[visit_idx] if visit_idx >= 0 else []

	_display_docs()
	await get_tree().process_frame
	_setup_dynamic_buttons(npc)
	propagate_call("queue_sort")

func _display_docs() -> void:
	var doc_buttons = [
		get_node_or_null("MarginContainer/VBoxContainer/BottomPanel/BottomVBox/ButtonRow/DocButton1"),
		get_node_or_null("MarginContainer/VBoxContainer/BottomPanel/BottomVBox/ButtonRow/DocButton2"),
		get_node_or_null("MarginContainer/VBoxContainer/BottomPanel/BottomVBox/ButtonRow/DocButton3"),
		get_node_or_null("MarginContainer/VBoxContainer/BottomPanel/BottomVBox/ButtonRow/DocButton4"),
	]
	for btn in doc_buttons:
		if btn == null:
			continue
		for conn in btn.pressed.get_connections():
			btn.pressed.disconnect(conn.callable)
		btn.visible = false
		btn.disabled = false
		btn.modulate = Color.WHITE
		btn.tooltip_text = ""
		btn.expand_icon = true

	var visible_index := 0
	for doc in current_docs:
		if not doc.get("present", true):
			continue
		if visible_index >= doc_buttons.size():
			break

		var btn: Button = doc_buttons[visible_index]
		visible_index += 1
		if btn == null:
			continue

		btn.text = doc.get("doc_type", "Document")
		btn.visible = true
		if doc.get("expandable", false):
			btn.tooltip_text = "Open document"
			btn.pressed.connect(_show_document_popup.bind(doc))
		else:
			btn.tooltip_text = "Submitted document"

func _show_document_popup(doc: Dictionary) -> void:
	for child in document_canvas.get_children():
		child.queue_free()

	var template_key: String = str(doc.get("template", "generic"))
	if doc.get("damaged", false):
		if template_key == "card":
			template_key = "card_damaged"
		elif template_key == "request_form":
			template_key = "request_form_damaged"

	var image_pos := CARD_IMAGE_POS
	var image_size := CARD_IMAGE_SIZE

	if doc.get("template", "") == "request_form":
		image_pos = FORM_IMAGE_POS
		image_size = FORM_IMAGE_SIZE
	
	var document_body := Control.new()
	document_body.position = image_pos
	document_body.size = image_size
	document_body.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	document_canvas.add_child(document_body)
	
	var background := TextureRect.new()
	background.texture = document_textures.get(template_key, document_textures.get("generic", null))
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.size = image_size
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	document_body.add_child(background)

	match doc.get("template", ""):
		"card":
			_populate_card_document(document_body, doc)
		"request_form":
			_populate_request_form_document(document_body, doc)
		_:
			_add_document_label(document_body, doc.get("doc_type", "Document"), Vector2(150, 180))

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.position = Vector2(DOC_POPUP_SIZE.x - 150, 18)
	close_button.size = Vector2(115, 46)
	close_button.pressed.connect(_on_close_document)
	document_canvas.add_child(close_button)

	document_popup.visible = true

func _populate_card_document(parent: Control, doc: Dictionary) -> void:
	var portrait_root := Control.new()
	portrait_root.position = CARD_PORTRAIT_POS
	portrait_root.size = Vector2(NPC_FRAME_SIZE.x, NPC_FRAME_SIZE.y) * CARD_PORTRAIT_SCALE
	portrait_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(portrait_root)

	var layers := {}
	for layer_name in ["body", "shirt", "hair", "expression", "accessory"]:
		var layer := TextureRect.new()
		layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		layer.stretch_mode = TextureRect.STRETCH_SCALE
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.size = Vector2(NPC_FRAME_SIZE.x, NPC_FRAME_SIZE.y) * CARD_PORTRAIT_SCALE
		portrait_root.add_child(layer)
		layers[layer_name] = layer

	_apply_portrait_layers(layers, doc.get("portrait_frames", {}), CARD_PORTRAIT_SCALE)
	_add_document_label(parent, doc.get("name", ""), CARD_NAME_POS, Vector2(390, 48), DOC_TEXT_FONT_SIZE, true)
	_add_document_label(parent, doc.get("id_number", ""), CARD_ID_POS)

func _populate_request_form_document(parent: Control, doc: Dictionary) -> void:
	_add_document_label(parent, doc.get("name", ""), FORM_NAME_POS, Vector2(390, 48), DOC_TEXT_FONT_SIZE, true)
	_add_document_label(parent, doc.get("request_type", ""), FORM_TYPE_POS)
	var reason: String = str(doc.get("request_reason", ""))
	if reason.is_empty():
		reason = _get_request_reason(doc.get("request_type", ""), abs(hash(doc.get("name", "") + doc.get("id_number", ""))))
	_add_document_label(parent, reason, FORM_REASON_POS, FORM_REASON_SIZE)

func _add_document_label(
	parent: Control,
	text: String,
	pos: Vector2,
	size := Vector2(390, 48),
	font_size := DOC_TEXT_FONT_SIZE,
	is_bold := false
) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = size
	label.add_theme_font_size_override("font_size", font_size + 6 if is_bold else font_size)
	label.add_theme_color_override("font_color", DOC_TEXT_COLOR)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func _on_close_document() -> void:
	if doc_viewer:
		doc_viewer.visible = false
	if document_popup:
		document_popup.visible = false

func _on_day_ended(report: Array) -> void:
	_set_buttons_disabled(true)
	if end_shift_btn:
		end_shift_btn.visible = false
	timer_bar.pause_timer()
	end_of_day_report.show_report(report, GameManager.current_day, day_ended_by_timer)
	day_ended_by_timer = false

func _on_continue_pressed() -> void:
	if GameManager.current_day >= GameManager.MAX_DAYS:
		Global.compliance = int(MeterManager.compliance * 100)
		Global.compassion = int(MeterManager.compassion * 100)
		get_tree().change_scene_to_file("res://End.tscn")
	else:
		GameManager.start_day()

# ─── Dynamic Buttons Logic ─────────────────────────────────────────────────────

func _setup_dynamic_buttons(npc: NPCData) -> void:
	var error = _get_document_error()
	
	# Make the Request button smart!
	if error == "missing_document": 
		choice_c.text = "Request Missing Document"
	elif error != "none": 
		choice_c.text = "There is an issue here."
	else: 
		choice_c.text = "Request Secondary Proof"
		
	var current_text = description_label.text.to_lower()
	var is_bribing = "bribe" in current_text or "bill" in current_text or "500" in current_text
	
	if is_bribing:
		var previous_visits = npc.interaction_history.size()
		if previous_visits == 0:
			choice_d.text = "Escalate to Supervisor" 
		elif previous_visits == 1:
			if randf() > 0.5:
				choice_d.text = "Escalate to Supervisor"
			else:
				choice_d.text = "Report Bribery"
		else:
			choice_d.text = "Report Bribery"
	else:
		choice_d.text = "Escalate to Supervisor"

	var default_size = 18
	var small_size = 18
	var character_limit = 22 
	
	if choice_c.text.length() > character_limit:
		choice_c.add_theme_font_size_override("font_size", small_size)
	else:
		choice_c.add_theme_font_size_override("font_size", default_size)
		
	if choice_d.text.length() > character_limit:
		choice_d.add_theme_font_size_override("font_size", small_size)
	else:
		choice_d.add_theme_font_size_override("font_size", default_size)

# ─── Player decisions ──────────────────────────────────────────────────────────

# --- NEW LOGIC: Checks EXACTLY what is wrong to judge the player ---
func _get_document_error() -> String:
	for doc in current_docs:
		if not doc.get("is_valid", true):
			# Checks generated error_type first, falls back to hand-written flaw
			return doc.get("error_type", doc.get("flaw", "unknown"))
	return "none"

func _on_approved() -> void:
	var doc_valid = _get_document_error() == "none"
	var time_left = timer_bar.stop_timer()
	_set_buttons_disabled(true)
	if feedback_label: feedback_label.text = "Approved."
	MeterManager.record_decision("approve", doc_valid, time_left)
	GameManager.submit_decision("approve")

func _on_rejected() -> void:
	var error = _get_document_error()
	var time_left = timer_bar.stop_timer()
	_set_buttons_disabled(true)
	
	if error == "missing_document":
		if feedback_label: feedback_label.text = "Rejected for missing papers. (Should have requested them)"
		MeterManager.record_decision("reject", false, time_left) # Bad reject!
	elif error == "none":
		if feedback_label: feedback_label.text = "Rejected valid documents."
		MeterManager.record_decision("reject", false, time_left) # Bad reject!
	else:
		if feedback_label: feedback_label.text = "Rejected for invalid documentation."
		MeterManager.record_decision("reject", true, time_left)  # Good reject!
		
	GameManager.submit_decision("reject")

func _on_requested_more_docs() -> void:
	var error = _get_document_error()
	var time_left = timer_bar.stop_timer()
	_set_buttons_disabled(true)
	
	if error == "missing_document":
		if feedback_label: feedback_label.text = "Requested missing documents."
		MeterManager.record_decision("request", false, time_left) # Correct play!
	else:
		if feedback_label: feedback_label.text = "Requested unnecessary documents. (Wasted time)"
		MeterManager.record_decision("request", true, time_left)  # Bad play!
		
	GameManager.submit_decision("request")

func _on_escalated() -> void:
	var doc_valid = _get_document_error() == "none"
	var time_left = timer_bar.stop_timer()
	_set_buttons_disabled(true)
	if feedback_label: feedback_label.text = "Escalated to Supervisor Abad."
	MeterManager.record_decision("escalate", doc_valid, time_left)
	GameManager.submit_decision("escalate")

func _on_time_expired() -> void:
	_set_buttons_disabled(true)
	if end_shift_btn:
		end_shift_btn.disabled = true
	day_ended_by_timer = true
	var met_quota = GameManager.current_client_index >= GameManager.MIN_QUOTA
	
	GameManager.force_end_day(met_quota)

func _on_end_shift_pressed() -> void:
	_set_buttons_disabled(true)
	if end_shift_btn:
		end_shift_btn.disabled = true
	timer_bar.pause_timer() 
	GameManager.force_end_day(true)

# ─── Meters ────────────────────────────────────────────────────────────────────

func _on_meters_updated(compliance: float, compassion: float, public_trust: float) -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(compliance_bar, "value", compliance * 100, 0.3)
	tween.tween_property(compassion_bar, "value", compassion * 100, 0.3)
	tween.tween_property(trust_bar, "value", public_trust * 100, 0.3)
	compliance_label.text = "Compliance: %3d%%" % int(compliance * 100)
	compassion_label.text = "Compassion: %3d%%" % int(compassion * 100)
	trust_label.text = "Trust: %3d%%" % int(public_trust * 100)

# ─── Game over ─────────────────────────────────────────────────────────────────

func _on_game_over(reason: String) -> void:
	_set_buttons_disabled(true)
	if end_shift_btn:
		end_shift_btn.disabled = true
	timer_bar.pause_timer()
	end_of_day_report.visible = false
	game_over_panel.visible = true
	game_over_label.text = reason

# ─── Rulebook Toggles ──────────────────────────────────────────────────────────

func _on_official_book_toggled() -> void:
	if official_book:
		official_book.visible = not official_book.visible

func _on_rulebook_toggled() -> void:
	if rulebook and rulebook.has_method("toggle"):
		rulebook.toggle() # This specifically triggers your awesome page animations!

# ─── Helpers ───────────────────────────────────────────────────────────────────

func _set_buttons_disabled(disabled: bool) -> void:
	choice_a.disabled = disabled
	choice_b.disabled = disabled
	choice_c.disabled = disabled
	choice_d.disabled = disabled

func _all_docs_valid() -> bool:
	for doc in current_docs:
		if not doc.get("is_valid", false):
			return false
	return true
