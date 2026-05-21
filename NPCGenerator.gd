@tool
extends EditorScript

const NPC_COUNT := 50
const INVALID_CHANCE := 0.35

const GENDERS := ["male", "female"]
const AGE_GROUPS := ["adult", "old"]

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

const MALE_FIRST_NAMES := [
	"Mateo", "Gabriel", "Elias", "Julian", "Adrian",
	"Leo", "Tomas", "Rafael", "Diego", "Emilio",
	"Felix", "Victor"
]

const FEMALE_FIRST_NAMES := [
	"Sofia", "Isabella", "Camila", "Luna", "Mia",
	"Carmen", "Rosa", "Lucia", "Valeria", "Martina",
	"Clara", "Elena"
]

const LAST_NAMES := [
	"Reyes", "Bautista", "Cruz", "Villanueva", "Santos", "Mendoza", "Torres",
	"Navarro", "Castillo", "Rivera", "Aquino", "Ramos", "Delgado", "Castro",
	"Luna", "Flores", "Vargas", "Ortiz", "Morales"
]

func _run() -> void:
	print("Starting Next Po citizen generation...")

	var dir := DirAccess.open("res://")
	if not dir.dir_exists("data/clients"):
		dir.make_dir_recursive("data/clients")

	for i in range(NPC_COUNT):
		var npc := _generate_npc(i)
		var save_path := "res://data/clients/" + npc.npc_id + ".tres"
		ResourceSaver.save(npc, save_path)

	print("Generated %d citizens in res://data/clients/." % NPC_COUNT)

func _generate_npc(index: int) -> NPCData:
	var npc := NPCData.new()
	npc.npc_id = "gen_npc_" + str(index)
	npc.gender = GENDERS.pick_random()
	npc.true_name = _generate_name(npc.gender)
	npc.display_name = "Citizen " + str(index + 1)
	npc.id_number = "NP-" + str(randi_range(1000, 9999)) + "-" + str(randi_range(10, 99))
	npc.gender = GENDERS.pick_random()
	npc.age_group = AGE_GROUPS.pick_random()
	npc.request_type = REQUEST_REQUIREMENTS.keys().pick_random()

	var portrait := _generate_portrait(npc.gender, npc.age_group)
	npc.body_frame = portrait["body"]
	npc.expression_frame = portrait["expression"]
	npc.shirt_frame = portrait["shirt"]
	npc.hair_frame = portrait["hair"]
	npc.accessory_frame = portrait["accessory"]

	npc.lore_stages = [
		"They quietly wait for you to inspect the submitted papers.",
		"They came back hoping today's documents will finally be enough."
	]

	npc.consequence_if_approved = "Their " + npc.request_type.to_lower() + " request moved forward."
	npc.consequence_if_rejected = "Their " + npc.request_type.to_lower() + " request was denied at the counter."
	npc.consequence_if_requested = "They left to correct the paperwork and promised to return."
	npc.consequence_if_escalated = "A supervisor took over the case and logged it for review."

	var is_invalid := randf() < INVALID_CHANCE
	npc.documents_per_visit.append(_generate_documents(npc, is_invalid))
	if is_invalid:
		npc.documents_per_visit.append(_generate_documents(npc, false))

	return npc

func _generate_documents(npc: NPCData, should_add_error: bool) -> Array:
	var docs := _build_valid_documents(npc)
	if should_add_error:
		_apply_random_error(npc, docs)
	return docs

func _build_valid_documents(npc: NPCData) -> Array:
	var docs := []
	for doc_type in REQUEST_REQUIREMENTS[npc.request_type]:
		match doc_type:
			"ID":
				docs.append(_make_id_doc(npc))
			"Request Form":
				docs.append(_make_request_form_doc(npc))
			_:
				docs.append(_make_generic_doc(doc_type))
	return docs

func _make_id_doc(npc: NPCData) -> Dictionary:
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
		"portrait_frames": _portrait_to_doc_frames(npc),
	}

func _make_request_form_doc(npc: NPCData) -> Dictionary:
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
		"request_reason": REQUEST_REASON_POOLS[npc.request_type].pick_random(),
	}

func _make_generic_doc(doc_type: String) -> Dictionary:
	return {
		"doc_type": doc_type,
		"template": "generic",
		"expandable": false,
		"present": true,
		"is_valid": true,
		"error_type": "",
	}

func _apply_random_error(npc: NPCData, docs: Array) -> void:
	var possible_errors := ["wrong_name", "wrong_portrait", "damaged_document"]
	var supporting_doc_indexes := _get_supporting_doc_indexes(docs)
	if not supporting_doc_indexes.is_empty():
		possible_errors.append("missing_document")

	var error_type: String = possible_errors.pick_random()
	match error_type:
		"wrong_name":
			_apply_wrong_name(npc, docs)
		"wrong_portrait":
			_apply_wrong_portrait(npc, docs)
		"damaged_document":
			_apply_damaged_document(docs)
		"missing_document":
			var missing_index: int = supporting_doc_indexes.pick_random()
			docs[missing_index]["present"] = false
			docs[missing_index]["is_valid"] = false
			docs[missing_index]["error_type"] = "missing_document"

func _generate_wrong_name(gender: String, true_name: String) -> String:
	var wrong_name := _generate_name(gender)
	while wrong_name == true_name:
		wrong_name = _generate_name(gender)
	return wrong_name

func _apply_wrong_name(npc: NPCData, docs: Array) -> void:
	var targets := _find_docs_by_templates(docs, ["card", "request_form"])
	if targets.is_empty():
		return

	var doc: Dictionary = targets.pick_random()
	doc["name"] = _generate_wrong_name(npc.gender, npc.true_name)
	doc["is_valid"] = false
	doc["error_type"] = "wrong_name"

func _apply_wrong_portrait(npc: NPCData, docs: Array) -> void:
	var id_doc := _find_first_doc_by_template(docs, "card")
	if id_doc.is_empty():
		return

	var wrong_gender := "female" if npc.gender == "male" else "male"
	var wrong_portrait := _generate_portrait(wrong_gender, AGE_GROUPS.pick_random())
	id_doc["portrait_frames"] = wrong_portrait
	id_doc["is_valid"] = false
	id_doc["error_type"] = "wrong_portrait"

func _apply_damaged_document(docs: Array) -> void:
	var targets := _find_docs_by_templates(docs, ["card", "request_form"])
	if targets.is_empty():
		return

	var doc: Dictionary = targets.pick_random()
	doc["damaged"] = true
	doc["is_valid"] = false
	doc["error_type"] = "damaged_document"

func _get_supporting_doc_indexes(docs: Array) -> Array:
	var indexes := []
	for i in range(docs.size()):
		if not docs[i].get("expandable", false):
			indexes.append(i)
	return indexes

func _find_docs_by_templates(docs: Array, templates: Array) -> Array:
	var matches := []
	for doc in docs:
		if templates.has(doc.get("template", "")):
			matches.append(doc)
	return matches

func _find_first_doc_by_template(docs: Array, template: String) -> Dictionary:
	for doc in docs:
		if doc.get("template", "") == template:
			return doc
	return {}

func _generate_name(gender: String) -> String:
	var first_name := ""
	if gender == "male":
		first_name = MALE_FIRST_NAMES.pick_random()
	else:
		first_name = FEMALE_FIRST_NAMES.pick_random()

	return first_name + " " + LAST_NAMES.pick_random()

func _generate_portrait(gender: String, age_group: String) -> Dictionary:
	return {
		"body": Vector2i(randi_range(0, 2), 0),
		"expression": Vector2i(randi_range(0, 2), 0),
		"shirt": Vector2i(randi_range(0, 3), 0 if gender == "male" else 1),
		"hair": Vector2i(randi_range(0, 3), _get_hair_row(gender, age_group)),
		"accessory": _pick_accessory(gender),
	}

func _portrait_to_doc_frames(npc: NPCData) -> Dictionary:
	return {
		"body": npc.body_frame,
		"expression": npc.expression_frame,
		"shirt": npc.shirt_frame,
		"hair": npc.hair_frame,
		"accessory": npc.accessory_frame,
	}

func _get_hair_row(gender: String, age_group: String) -> int:
	if gender == "male" and age_group == "old":
		return 1
	if gender == "female" and age_group == "old":
		return 3
	if gender == "female":
		return 2
	return 0

func _pick_accessory(gender: String) -> Vector2i:
	if randf() > 0.20:
		return Vector2i(-1, -1)

	var allowed := [
		Vector2i(0, 0), # dirty
		Vector2i(1, 0), # sunglasses
		Vector2i(2, 0), # glasses
		Vector2i(0, 1), # facemask
		Vector2i(1, 1), # earrings
		Vector2i(2, 1), # scar
	]

	if gender == "male":
		allowed.append(Vector2i(3, 0)) # beard
	else:
		allowed.append(Vector2i(3, 1)) # makeup

	return allowed.pick_random()
