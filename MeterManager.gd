# MeterManager.gd
extends Node

signal meters_updated(compliance: float, compassion: float, public_trust: float)
signal game_over(reason: String)

var compliance: float = 0.50
var compassion: float = 0.50
var public_trust: float = 0.50

func record_decision(action: String, doc_was_valid: bool, time_remaining: float) -> void:
	var comp_delta: float = 0.0
	var comm_delta: float = 0.0

	match action:
		"approve":
			if doc_was_valid:
				comp_delta =  0.06
				comm_delta =  0.04
			else:
				# ANTI-SPAM FIX: Massive penalty for approving bad docs. 
				comp_delta = -0.25 
				comm_delta =  0.05 
		"reject":
			if not doc_was_valid:
				comp_delta =  0.08
				comm_delta = -0.04
			else:
				# Anti-spam: Massive penalty for rejecting perfect docs
				comp_delta = -0.15
				comm_delta = -0.15
		"request":
			if not doc_was_valid:
				# Correctly caught a missing document error and asked them to fix it
				comp_delta =  0.05
				comm_delta = -0.02 
			else:
				# Asked for papers they already gave you (wasting time)
				comp_delta = -0.08 
				comm_delta = -0.10 
		"escalate":
			# Safe play, but looks cowardly. Always hits compassion.
			comp_delta =  0.02
			comm_delta = -0.08

	# Apply deltas strictly
	compliance = clamp(compliance + comp_delta, 0.0, 1.0)
	compassion = clamp(compassion + comm_delta, 0.0, 1.0)

	# System Pressure
	if (compliance + compassion) > 1.35:
		compliance -= 0.02
		compassion -= 0.02

	_recalculate_trust()

func _recalculate_trust() -> void:
	public_trust = clamp((compliance * 0.5) + (compassion * 0.5), 0.0, 1.0)
	emit_signal("meters_updated", compliance, compassion, public_trust)
	_check_game_over()

func apply_quota_penalty() -> void:
	compliance = clamp(compliance - 0.20, 0.0, 1.0)
	compassion = clamp(compassion - 0.05, 0.0, 1.0)
	_recalculate_trust()

func get_trust_summary() -> String:
	if public_trust >= 0.75: return "Public Trust: HIGH — The community is satisfied with your service."
	elif public_trust >= 0.50: return "Public Trust: MODERATE — Some concerns have been noted."
	elif public_trust >= 0.30: return "Public Trust: LOW — Complaints are beginning to reach administration."
	else: return "Public Trust: CRITICAL — Your conduct is under review."

func _check_game_over() -> void:
	if public_trust <= 0.15:
		emit_signal("game_over", "Public trust has collapsed.\nThe community no longer has confidence in this office.\nYou have been removed from your post.")
	elif compliance <= 0.05:
		emit_signal("game_over", "Too many procedural violations have been recorded.\nYour contract has been terminated.\nYour supervisor's final note: 'Consistent disregard for protocol.'")
	elif compassion <= 0.05:
		emit_signal("game_over", "Formal complaints about your conduct have reached administration.\nYou are suspended pending investigation.\nThe last complaint read: 'They didn't even look at me.'")
