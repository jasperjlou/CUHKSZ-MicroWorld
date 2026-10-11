extends "res://tests/LegacyLibraryLowerCapture.gd"

func reference_path() -> String:
	return "res://references/legacy-gta-20261011/library-4f-reference.glb"

func cut_height() -> float:
	return 24.0

func view_shots() -> Array:
	return [["library4f-overview",Vector3(500,650,750),Vector3(0,12,0),650.0],["library4f-plan",Vector3(0,850,.1),Vector3.ZERO,650.0]]
