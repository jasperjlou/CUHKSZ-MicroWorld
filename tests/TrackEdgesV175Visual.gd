extends "res://tests/StudentRegisteredV153.gd"
var tt:=Transform3D.IDENTITY
func tp(x:float,y:float,z:float)->Vector3:return tt*Vector3(x,y,z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	tt=world.builder.buildings["track"].global_transform
	var checks:Array=[]
	await capture("track-v175-final-overall",tp(126,96,-147),tp(0,0,4))
	await capture("track-v175-final-frontage",tp(52,2.0,61),tp(-42,1.8,56))
	await capture("track-v175-final-red-end",tp(-83,2.0,-16),tp(-40,1.5,12))
	await capture("track-v175-final-mesh",tp(-21,1.9,-48),tp(-16,1.7,-57))
	FileAccess.open("res://tests/artifacts/track_edges_v175_visual_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":0,"scope":"Changed track frontage, infield ends and outer service circulation; no full-campus or surveyed grade claim."},"\t"))
	print("TRACK_V175_VISUAL ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
