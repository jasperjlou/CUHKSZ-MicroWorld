extends Node
var world: Node3D
const G := preload("res://world/campus_master/CampusGeometry.gd")
var checks := 0
var errors: Array = []

func _ready() -> void:
	run.call_deferred()

func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: errors.append(message);push_error(message)

func frames(count: int) -> void:
	for i in range(count): await get_tree().physics_frame

func capture(name: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await frames(3)
	get_tree().paused=true
	await RenderingServer.frame_post_draw
	var error := get_viewport().get_texture().get_image().save_png("res://tests/artifacts/"+name+".png")
	get_tree().paused=false
	check(error==OK,"capture "+name)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	await frames(5)
	await capture("campus_masterplan_pass1" if "--pass1" in OS.get_cmdline_user_args() else "campus_masterplan_pass2")
	print("CAMPUS_MASTER_QA ",checks," checks; ",errors.size()," failures")
	get_tree().quit(0 if errors.is_empty() else 1)
