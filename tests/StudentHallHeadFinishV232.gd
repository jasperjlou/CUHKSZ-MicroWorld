extends "res://tests/StudentSkylightFinishV232.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/student-skylight-v232-final-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
