extends PanelContainer

signal continue_pressed

@onready var report_container = $MarginContainer/VBoxContainer/ScrollContainer/ReportContainer
@onready var continue_btn = $MarginContainer/VBoxContainer/ContinueButton
@onready var day_label = $MarginContainer/VBoxContainer/DayLabel

func show_report(report: Array, day: int, time_expired: bool = false) -> void:
	visible = true
	if time_expired:
		day_label.text = "— Office Closed —"
		continue_btn.text = "Come in tomorrow"
	elif day >= 5:
		day_label.text = "— Final Day —"
		continue_btn.text = "See Final Verdict"
	else:
		day_label.text = "— End of Day %d —" % day
		continue_btn.text = "Next Day"

	for child in report_container.get_children():
		child.queue_free()

	for entry in report:
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)

		var name_lbl = Label.new()
		name_lbl.text = entry["client_name"]
		name_lbl.add_theme_font_size_override("font_size", 15)

		var action_lbl = Label.new()
		var action_text := ""
		match entry["action"]:
			"approve":  action_text = "APPROVED"
			"reject":   action_text = "REJECTED"
			"request":  action_text = "REQUESTED MORE DOCUMENTS"
			"escalate": action_text = "ESCALATED TO SUPERVISOR"
		action_lbl.text = "Your decision: %s" % action_text
		match entry["action"]:
			"approve":  action_lbl.modulate = Color(0.3, 1.0, 0.4)
			"reject":   action_lbl.modulate = Color(1.0, 0.4, 0.4)
			"request":  action_lbl.modulate = Color(1.0, 0.85, 0.3)
			"escalate": action_lbl.modulate = Color(0.6, 0.6, 1.0)

		var consequence_lbl = Label.new()
		consequence_lbl.text = entry["consequence"]
		consequence_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		consequence_lbl.modulate = Color(0.85, 0.85, 0.85)

		var sep = HSeparator.new()

		vbox.add_child(name_lbl)
		vbox.add_child(action_lbl)
		vbox.add_child(consequence_lbl)
		vbox.add_child(sep)
		report_container.add_child(vbox)
		

func _on_continue_button_pressed() -> void:
	visible = false
	emit_signal("continue_pressed")
