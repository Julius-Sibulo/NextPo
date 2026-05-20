# MeterManager.gd
# Autoload — add as singleton named "MeterManager"
# Tracks Compliance, Compassion, and Public Trust.
# Decisions affect both meters differently depending on whether documents were valid.
# "System Pressure" mechanic prevents players from easily maxing both.
extends Node

signal meters_updated(compliance: float, compassion: float, public_trust: float)
signal game_over(reason: String)

var compliance: float = 0.5
var compassion: float = 0.5
var public_trust: float = 0.5

# ─── Decision Recording ────────────────────────────────────────────────────────
# Called by Main.gd after every player action.
# action:        "approve" | "reject" | "request" | "escalate"
# doc_was_valid: true if ALL submitted documents were valid
# time_remaining: how much timer was left (unused for now, ready for future use)

func record_decision(action: String, doc_was_valid: bool, time_remaining: float) -> void:
	var comp_delta: float = 0.0
	var comm_delta: float = 0.0

	match action:
		"approve":
			if doc_was_valid:
				# Correct approval: good for everyone
				comp_delta =  0.06
				comm_delta =  0.04
			else:
				# Approved bad documents: compassionate but a procedural violation
				comp_delta = -0.12
				comm_delta =  0.07
		"reject":
			if not doc_was_valid:
				# Correct rejection: system approves, but it still stings
				comp_delta =  0.08
				comm_delta = -0.04
			else:
				# Rejected a valid application: compliance fine, humanity takes a hit
				comp_delta = -0.05
				comm_delta = -0.10
		"request":
			# Asking for more docs: thorough and fair, minor bureaucratic friction
			comp_delta = -0.02
			comm_delta =  0.05
		"escalate":
			# Passing it up: the system likes it, the human behind the desk doesn't
			comp_delta =  0.03
			comm_delta = -0.06

	# Apply deltas
	compliance = clamp(compliance + comp_delta, 0.0, 1.0)
	compassion = clamp(compassion + comm_delta, 0.0, 1.0)

	# ── System Pressure ────────────────────────────────────────────────────────
	# The system punishes you for trying to be both fully compliant AND fully
	# compassionate. It forces a choice. This is intentional game design.
	if (compliance + compassion) > 1.35:
		compliance -= 0.02
		compassion -= 0.02

	_recalculate_trust()

# ─── Trust Calculation ─────────────────────────────────────────────────────────
func _recalculate_trust() -> void:
	# Trust is a weighted average. Balance is rewarded over extremes.
	# Maxing only compliance or only compassion yields ~0.5 trust.
	# Keeping both around 0.65 yields better trust than either extreme.
	public_trust = clamp(
		(compliance * 0.5) + (compassion * 0.5),
		0.0, 1.0
	)

	emit_signal("meters_updated", compliance, compassion, public_trust)
	_check_game_over()

# ─── Quota Penalty ─────────────────────────────────────────────────────────────
# Applied by Main.gd when the timer expires before the daily quota is met.
func apply_quota_penalty() -> void:
	compliance = clamp(compliance - 0.20, 0.0, 1.0)
	compassion = clamp(compassion - 0.05, 0.0, 1.0)
	_recalculate_trust()

# ─── End-of-Day Trust Reveal ───────────────────────────────────────────────────
# Called by Main.gd when the day ends to return a label string for the report.
func get_trust_summary() -> String:
	if public_trust >= 0.75:
		return "Public Trust: HIGH — The community is satisfied with your service."
	elif public_trust >= 0.50:
		return "Public Trust: MODERATE — Some concerns have been noted."
	elif public_trust >= 0.30:
		return "Public Trust: LOW — Complaints are beginning to reach administration."
	else:
		return "Public Trust: CRITICAL — Your conduct is under review."

# ─── Game Over Checks ──────────────────────────────────────────────────────────
func _check_game_over() -> void:
	if public_trust <= 0.15:
		emit_signal("game_over",
			"Public trust has collapsed.\nThe community no longer has confidence in this office.\nYou have been removed from your post.")
	elif compliance <= 0.05:
		emit_signal("game_over",
			"Too many procedural violations have been recorded.\nYour contract has been terminated.\nYour supervisor's final note: 'Consistent disregard for protocol.'")
	elif compassion <= 0.05:
		emit_signal("game_over",
			"Formal complaints about your conduct have reached administration.\nYou are suspended pending investigation.\nThe last complaint read: 'They didn't even look at me.'")
