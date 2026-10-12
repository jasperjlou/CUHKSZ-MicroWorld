extends "res://tests/StudentRegisteredV153.gd"
const TS=preload("res://world/visual_campus/TrackOuterSite.gd")
func street_point176(i:int)->Vector3:
	var p:=TS.walk_point(i);p.y=world.builder.height(p.x,p.z)+.10;return p
func ground176(x:float,z:float)->Vector3:return Vector3(x,world.builder.height(x,z)+.10,z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	await fixture(street_point176(2)+Vector3.UP*.3,[[street_point176(1),"refined grade up bend"],[street_point176(0),"refined grade up tie"],[street_point176(1),"refined grade down bend"],[street_point176(2),"refined grade down lower"]])
	await fixture(TS.ROAD[0]+Vector3.UP*.3,[[TS.ROAD[1]+Vector3.UP*.045,"asphalt slope bend"],[TS.ROAD[2]+Vector3.UP*.045,"asphalt slope lower"]])
	await capture("track-v176-grade-corner",Vector3(-160,7,-1128),Vector3(-105,2,-1065))
	await capture("track-v176-grade-tie",Vector3(-112,8,-964),Vector3(-142,0,-1015))
	FileAccess.open("res://tests/artifacts/track_bank_v176_grade.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":2,"scope":"Shared cross-section street grade: affected sidewalk ascent/descent and asphalt slope only. Earlier unchanged bank/frontage checks retained. Relative terrain fit, not site survey or vehicle drive test."},"\t"))
	print("TRACK_BANK_V176_GRADE ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
