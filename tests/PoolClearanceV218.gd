extends SceneTree
func _initialize()->void:run.call_deferred()
func run()->void:
	var world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world)
	for i in 15:await physics_frame
	world.player.set_physics_process(false)
	var space=world.get_world_3d().direct_space_state;var shape:=CapsuleShape3D.new();shape.radius=.40;shape.height=1.88
	var q:=PhysicsShapeQueryParameters3D.new();q.shape=shape;q.collision_mask=1;q.exclude=[world.player.get_rid()]
	var clear:Dictionary={};var blocked:Dictionary={};var origin:=Vector2(57,-328);var pitch:=.5
	for iz in 61:
		for ix in 29:
			var key:=Vector2i(ix,iz);var v:Vector2=origin+Vector2(key)*pitch
			q.transform=Transform3D(Basis.IDENTITY,Vector3(v.x,2.24+.025+.94,v.y));q.motion=Vector3.ZERO
			var hits=space.intersect_shape(q,1)
			var floor=space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(v.x,2.54,v.y),Vector3(v.x,2.05,v.y),1,[world.player.get_rid()]))
			if hits.is_empty() and not floor.is_empty():clear[key]=true
			else:blocked[str(v)]=str(hits[0].collider.get_path()) if not hits.is_empty() else "no G support"
	var start:=Vector2i(10,6);var goal:=Vector2i(2,52);var queue:Array[Vector2i]=[start];var previous:Dictionary={start:start};var cursor:=0
	while cursor<queue.size() and not previous.has(goal):
		var at:Vector2i=queue[cursor];cursor+=1
		for dir:Vector2i in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
			var next:Vector2i=at+dir
			if not clear.has(next) or previous.has(next):continue
			var v:Vector2=origin+Vector2(at)*pitch
			q.transform=Transform3D(Basis.IDENTITY,Vector3(v.x,2.24+.025+.94,v.y));q.motion=Vector3(dir.x*pitch,0,dir.y*pitch)
			if space.cast_motion(q)[0]<.99:continue
			previous[next]=at;queue.append(next)
	var path:Array=[]
	if previous.has(goal):
		var at:Vector2i=goal
		while at!=start:path.push_front([origin.x+at.x*pitch,2.24,origin.y+at.y*pitch]);at=previous[at]
		path.push_front([62,2.24,-325])
	var smooth:Array=[];var step:=0
	while not path.is_empty():
		smooth.append(path[step])
		if step==path.size()-1:break
		var a:=Vector3(path[step][0],3.205,path[step][2]);var found:=step+1
		for candidate in range(path.size()-1,step,-1):
			var b:=Vector3(path[candidate][0],3.205,path[candidate][2]);q.transform=Transform3D(Basis.IDENTITY,a);q.motion=b-a
			if space.cast_motion(q)[0]<.999:continue
			var supported:=true
			for i in ceili(a.distance_to(b)*2)+1:
				var p:=a.lerp(b,minf(1,float(i)*.5/maxf(.01,a.distance_to(b))))
				if space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(p.x,2.54,p.z),Vector3(p.x,2.05,p.z),1,[world.player.get_rid()])).is_empty():supported=false;break
			if supported:found=candidate;break
		step=found
	FileAccess.open("res://tests/artifacts/pool_clearance_v218.json",FileAccess.WRITE).store_string(JSON.stringify({"path":path,"smoothed":smooth,"blocked":blocked,"scope":"diagnostic capsule clearance grid, long edge sweeps and support rays; not walking validation"},"\t"))
	print("POOL_SMOOTH_PATH ",JSON.stringify(smooth));print("GRID_CLEAR ",clear.size()," reached=",previous.has(goal));quit(0)
