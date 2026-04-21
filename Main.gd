extends Control

@onready var citizen_sprite: TextureRect = $MarginContainer/VBoxContainer/TopRow/CenterPanel/CitizenSprite
@onready var scenario_label: Label = $MarginContainer/VBoxContainer/BottomPanel/BottomVBox/ScenarioLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/BottomPanel/BottomVBox/DescriptionLabel
@onready var feedback_label: Label = $MarginContainer/VBoxContainer/FeedbackLabel

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



@onready var rulebook: PanelContainer = $Rulebook
@onready var rulebook_btn: Button = $RulebookButton

# --- DOCUMENT VIEWER UI ELEMENTS (Updated for Photo Layout) ---
@onready var doc_viewer: PanelContainer = $PopupLayer/DocumentViewer
@onready var doc_photo: TextureRect = $PopupLayer/DocumentViewer/HBoxContainer/DocPhoto
@onready var doc_title: Label = $PopupLayer/DocumentViewer/HBoxContainer/TextVBox/DocTitle
@onready var doc_content: Label = $PopupLayer/DocumentViewer/HBoxContainer/TextVBox/DocContent
@onready var close_doc_btn: Button = $PopupLayer/DocumentViewer/HBoxContainer/TextVBox/CloseDocButton

@onready var music_player = $MusicPlayer

var current_docs: Array = []
var day_ended_by_timer: bool = false

func play_game_music():
	music_player.stream = load("res://Assets/clock-tick.mp3")
	music_player.volume_db = 0
	music_player.play()

func _ready() -> void:
	end_of_day_report.visible = false
	game_over_panel.visible = false
	feedback_label.text = ""
	play_game_music()

	choice_a.text = "Approve"
	choice_b.text = "Reject"
	
	if end_shift_btn:
		end_shift_btn.visible = false
		end_shift_btn.pressed.connect(_on_end_shift_pressed)
		
	# Hide popup and connect close button
	if doc_viewer:
		doc_viewer.visible = false
		close_doc_btn.pressed.connect(_on_close_document)

	compliance_bar.max_value = 100
	compassion_bar.max_value = 100
	trust_bar.max_value = 100

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
	rulebook_btn.pressed.connect(_on_rulebook_toggled)

	_on_meters_updated(0.5, 0.5, 0.5)
	
	# THE FIX: This tells the game to start Day 1 immediately upon loading!
	GameManager.start_day()

# ─── Day flow ──────────────────────────────────────────────────────────────────

func _on_day_started(day_number: int) -> void:
	feedback_label.text = "Day %d" % day_number
	timer_bar.start_timer(60.0)
	
	if end_shift_btn:
		end_shift_btn.visible = false

func _on_client_arrived(npc: NPCData) -> void:
	end_of_day_report.visible = false
	_set_buttons_disabled(false)
	feedback_label.text = ""

	timer_bar.resume_timer()
	
	if end_shift_btn:
		if GameManager.current_client_index >= GameManager.MIN_QUOTA:
			end_shift_btn.visible = true
			end_shift_btn.disabled = false
		else:
			end_shift_btn.visible = false

	var day = GameManager.current_day

	if npc.portrait_texture:
		citizen_sprite.texture = npc.portrait_texture
	else:
		citizen_sprite.texture = null

	scenario_label.text = npc.display_name

	var desc = npc.appearance_description
	var greeting = npc.get_memory_greeting()
	if not greeting.is_empty():
		desc += "\n\n\"" + greeting + "\""
	var lore_idx = min(day - 1, npc.lore_stages.size() - 1)
	if lore_idx >= 0 and not npc.lore_stages.is_empty():
		desc += "\n\n" + npc.lore_stages[lore_idx]
	description_label.text = desc

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
	for i in doc_buttons.size():
		var btn = doc_buttons[i]
		if btn == null:
			continue
		if i < current_docs.size():
			var doc = current_docs[i]
			btn.text = "[%s]" % doc["doc_type"]
			btn.tooltip_text = doc["content"]
			btn.modulate = Color(1.0, 0.5, 0.5) if not doc.get("is_valid", true) else Color(1.0, 1.0, 1.0)
			btn.visible = true
			
			# Bind the popup function to the button click
			for conn in btn.pressed.get_connections():
				btn.pressed.disconnect(conn.callable)
			btn.pressed.connect(_show_document_popup.bind(doc))
			
		else:
			btn.visible = false

# --- NEW: Popup Functions with Image Placeholder Support ---
func _show_document_popup(doc: Dictionary) -> void:
	if doc_title:
		doc_title.text = doc.get("doc_type", "Unknown Document")
	if doc_content:
		doc_content.text = doc.get("content", "No information provided.")
		
	if doc_photo:
		if doc.has("photo") and doc["photo"] != null:
			doc_photo.texture = doc["photo"]
		else:
			doc_photo.texture = load("res://icon.svg")
		doc_photo.visible = true

	if doc_viewer:
		doc_viewer.visible = true

func _on_close_document() -> void:
	if doc_viewer:
		doc_viewer.visible = false

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
	var flawed_doc = null
	
	for doc in current_docs:
		if not doc.get("is_valid", true):
			flawed_doc = doc
			break
			
	if flawed_doc:
		var doc_type = flawed_doc["doc_type"]
		var flaw = flawed_doc.get("flaw", "").to_lower()
		
		if "missing" in flaw:
			choice_c.text = "I need your %s." % doc_type
		elif "expired" in flaw:
			choice_c.text = "This %s is expired." % doc_type
		elif "clear" in flaw or "smudge" in flaw or "illegible" in flaw:
			choice_c.text = "The %s must be clear." % doc_type
		else:
			choice_c.text = "There is an issue with your %s." % doc_type
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

func _on_approved() -> void:
	var doc_valid = _all_docs_valid()
	var time_left = timer_bar.stop_timer()
	_set_buttons_disabled(true)
	feedback_label.text = "Approved."
	MeterManager.record_decision("approve", doc_valid, time_left)
	GameManager.submit_decision("approve")

func _on_rejected() -> void:
	var doc_valid = _all_docs_valid()
	var time_left = timer_bar.stop_timer()
	_set_buttons_disabled(true)
	feedback_label.text = "Rejected."
	MeterManager.record_decision("reject", not doc_valid, time_left)
	GameManager.submit_decision("reject")

func _on_requested_more_docs() -> void:
	var time_left = timer_bar.stop_timer()
	_set_buttons_disabled(true)
	feedback_label.text = "Requested additional documents."
	MeterManager.record_decision("request", false, time_left)
	GameManager.submit_decision("request")

func _on_escalated() -> void:
	var time_left = timer_bar.stop_timer()
	_set_buttons_disabled(true)
	
	var current_text = description_label.text.to_lower()
	var was_bribing = "bribe" in current_text or "bill" in current_text or "500" in current_text
	
	if choice_d.text == "Report Bribery":
		feedback_label.text = "You reported the bribery attempt. Security escorted them out."
	elif was_bribing:
		feedback_label.text = "You quietly passed the 'donation' and the problem to your boss."
	else:
		feedback_label.text = "You passed the headache up the chain of command."
	MeterManager.record_decision("escalate", false, time_left)
	GameManager.submit_decision("escalate")

func _on_time_expired() -> void:
	_set_buttons_disabled(true)
	if end_shift_btn:
		end_shift_btn.disabled = true
		
	day_ended_by_timer = true
	var met_quota = GameManager.current_client_index >= GameManager.MIN_QUOTA
	
	if met_quota:
		feedback_label.text = "The office is now closed for the day."
	else:
		feedback_label.text = "Time's up! You failed to meet the daily quota."
		MeterManager.apply_quota_penalty()
		
	GameManager.force_end_day(met_quota)

func _on_end_shift_pressed() -> void:
	_set_buttons_disabled(true)
	if end_shift_btn:
		end_shift_btn.disabled = true
		
	timer_bar.pause_timer() 
	feedback_label.text = "You packed up your desk and went home early."
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

# ─── Rulebook ──────────────────────────────────────────────────────────────────

func _on_rulebook_toggled() -> void:
	rulebook.toggle()

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
