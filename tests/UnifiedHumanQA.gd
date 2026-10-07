extends "res://tests/CampusSeamlessQA.gd"
# Reuse Human routes, preserve older screenshot names on subsequent runs.
func capture(name: String) -> void:
	await super.capture("V6_Human_"+name)
