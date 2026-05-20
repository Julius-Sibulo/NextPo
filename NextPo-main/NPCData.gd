class_name NPCData
extends Resource

@export var npc_id: String = ""
@export var display_name: String = ""
@export var portrait_texture: Texture2D
@export var appearance_description: String = ""

@export var interaction_history: Array = []
@export var lore_stages: Array = []
@export var documents_per_visit: Array = []

@export var consequence_if_approved: String = ""
@export var consequence_if_rejected: String = ""
@export var consequence_if_requested: String = ""
@export var consequence_if_escalated: String = ""

func get_memory_greeting() -> String:
	if interaction_history.is_empty():
		return ""
	var last = interaction_history[-1]
	match last["action"]:
		"approve":
			return "You approved me last time. I won't forget that."
		"reject":
			return "You rejected me last time. I still don't understand why."
		"request":
			return "You asked me to come back with more documents. I have them now."
		"escalate":
			return "You sent my case to your supervisor. They denied it. So here I am again."
	return ""

func record_interaction(day: int, action: String) -> void:
	interaction_history.append({
		"day": day,
		"action": action
	})
