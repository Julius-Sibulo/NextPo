extends Node

signal meters_updated(compliance: float, compassion: float, public_trust: float)
signal game_over(reason: String)

var compliance: float = 0.5
var compassion: float = 0.5
var public_trust: float = 0.5

func record_decision(action: String, doc_was_valid: bool, time_remaining: float) -> void:
	var comp_delta: float = 0.0
	var comm_delta: float = 0.0

	match action:
		"approve":
			if doc_was_valid:
				comp_delta = 0.05
				comm_delta = 0.02
			else:
				comp_delta = -0.10 # Big hit to compliance for letting a criminal in
				comm_delta = 0.06  # Compassionate, but technically illegal
		"reject":
			if not doc_was_valid:
				comp_delta = 0.08  # The State loves a good rejection
				comm_delta = -0.04 # You're doing your job, but it feels bad
			else:
				comp_delta = -0.05
				comm_delta = -0.09 # Hurting a valid citizen is a huge blow to conscience
		"request":
			comp_delta = -0.02
			comm_delta = 0.04 # Being thorough is a sign of care
		"escalate":
			comp_delta = 0.03 # The State loves you for passing the buck
			comm_delta = -0.05 # You're selling the person out to the system

	
	#Calculation
	compliance = clamp(compliance + comp_delta, 0.0, 1.0)
	compassion = clamp(compassion + comm_delta, 0.0, 1.0)
	
	# "System Pressure": If you try to max both, the system punishes you
	# This forces the player to choose a side (Compliance vs Compassion)
	if (compliance + compassion) > 1.3:
		compliance -= 0.02
		compassion -= 0.02

	_recalculate_trust()

func _recalculate_trust() -> void:
	# Trust is the average. A balance of both is better than maxing only one.
	public_trust = clamp(
		(compliance * 0.5) + (compassion * 0.5),
		0.0, 1.0
	)
	emit_signal("meters_updated", compliance, compassion, public_trust)

	# --- GAME OVER TRIGGERS ---
	if public_trust <= 0.15:
		emit_signal("game_over", "Public trust has collapsed.\nYou have been removed from your post.")
	elif compliance <= 0.05:
		emit_signal("game_over", "Too many procedural violations.\nYour contract has been terminated.")
	elif compassion <= 0.05:
		emit_signal("game_over", "Complaints about your conduct have reached administration.\nYou are suspended.")

# Penalty for failing to hit the daily quota
func apply_quota_penalty() -> void:
	compliance = clamp(compliance - 0.20, 0.0, 1.0)
	compassion = clamp(compassion - 0.05, 0.0, 1.0) 
	_recalculate_trust()
