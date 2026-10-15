extends RefCounted
## Navigation knowledge from the current campus paths, not the historical V5 coordinates.
## Candidate edges are checked against the live world when used; failures remain explicit.
var graph:=AStar3D.new()
var goals:Dictionary={}
var cells:Dictionary={}
var world:Node3D
var rejected:Array=[]
var blocked_edges:Array=[]
var body_probe:CapsuleShape3D

func add(p:Vector3)->int:
	var id:=graph.get_point_count();graph.add_point(id,p)
	var cell:=Vector2i(floori(p.x/6),floori(p.z/6))
	if not cells.has(cell):cells[cell]=[]
	cells[cell].append(id);return id

func chain(points:Array)->void:
	var previous:=-1
	for i in points.size()-1:
		var a:Vector3=points[i];var b:Vector3=points[i+1]
		var count:=maxi(1,ceili(a.distance_to(b)/4))
		for j in count:
			var id:=add(a.lerp(b,float(j)/count))
			if previous>=0:graph.connect_points(previous,id)
			previous=id
	if previous>=0:graph.connect_points(previous,add(points[-1]))

func build(scene:Node3D)->void:
	world=scene
	for child in world.player.get_children():
		if child is CollisionShape3D and child.shape is CapsuleShape3D:
			body_probe=CapsuleShape3D.new();body_probe.radius=child.shape.radius*world.player.scale.x;body_probe.height=child.shape.height*world.player.scale.y
	# The paved arrival court is a 2D public area, with a real stone name monument.
	# Sample the apron so A* can choose either pedestrian opening around it.
	for x in range(-18,19,3):
		for z in range(-39,19,3):add(Vector3(x,world.builder.height(x,z),z))
	for route:Dictionary in world.data.routes:
		if route.kind=="green":continue
		var points:Array=[]
		for raw:Array in route.points:
			var p:=Vector3(raw[0],raw[1],raw[2]);p.y=maxf(p.y,world.builder.height(p.x,p.z));points.append(p)
		chain(points)
	# Existing physically walked interior paths provide stair knowledge, not chapter teleports.
	for c:Dictionary in preload("res://world/product/ShowcaseChapters.gd").build(world):
		chain(c.route)
		var id:=add(c.route[-1]);goals["space_"+c.id]={"id":"space_"+c.id,"name":c.title,"node":id,"position":c.route[-1]}
	for record:Dictionary in world.data.landmarks:
		var p:=Vector3(record.position[0],record.position[1],record.position[2])
		p.y=maxf(p.y,world.builder.height(p.x,p.z))
		goals[record.id]={"id":record.id,"name":record.name,"node":add(p),"position":p}
	# Only short, same-level joins; walls are never treated as permission to teleport.
	for id in graph.get_point_ids():
		var p:=graph.get_point_position(id);var cell:=Vector2i(floori(p.x/6),floori(p.z/6))
		for x in range(-2,3):
			for z in range(-2,3):
				for other:int in cells.get(cell+Vector2i(x,z),[]):
					if other<=id:continue
					var q:=graph.get_point_position(other)
					if absf(q.y-p.y)<.65 and p.distance_to(q)<=9.5:graph.connect_points(id,other)
	# Map landmarks can sit in open forecourts away from a path centreline.
	# Candidate last-mile approaches are collision-checked exactly like every other edge.
	for g:Dictionary in goals.values():
		var nearby:Array=[]
		for id in graph.get_point_ids():
			var p:=graph.get_point_position(id)
			if id!=g.node and absf(p.y-g.position.y)<.65 and p.distance_to(g.position)<26:nearby.append([p.distance_to(g.position),id])
		nearby.sort_custom(func(a,b):return a[0]<b[0])
		# Include farther path contacts, not just densely sampled points on the same island.
		for candidate:Array in nearby:graph.connect_points(g.node,candidate[1])

func clear_segment(a:Vector3,b:Vector3)->bool:
	# Full-size body sweep also sees low planters missed by waist-height rays.
	var query:=PhysicsShapeQueryParameters3D.new();query.shape=body_probe;query.collision_mask=1
	query.transform=Transform3D(Basis.IDENTITY,a+Vector3.UP*(body_probe.height/2+.16));query.motion=b-a
	query.exclude=[world.player.get_rid()];query.margin=.015
	var space:=world.get_world_3d().direct_space_state
	if not space.intersect_shape(query,1).is_empty():return false
	if space.cast_motion(query)[0]<.999:return false
	# A visually clear line over a lightwell is not a walkable connection.
	var steps:=maxi(1,ceili(a.distance_to(b)))
	for i in steps+1:
		var p:=a.lerp(b,float(i)/steps)
		var floor_ray:=PhysicsRayQueryParameters3D.create(p+Vector3.UP*.45,p-Vector3.UP*.65,1)
		var support:=space.intersect_ray(floor_ray)
		if support.is_empty() or support.normal.y<.55:return false
	# Additional rays keep the same width on sloped connections.
	var crosswise:=Vector3(-(b-a).z,0,(b-a).x).normalized()*.38
	for side in [-1,0,1]:
		var ray:=PhysicsRayQueryParameters3D.create(a+Vector3.UP*.75+crosswise*side,b+Vector3.UP*.75+crosswise*side,1)
		if not world.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():return false
	return true

func visible(a:Vector3,b:Vector3)->bool:
	var ray:=PhysicsRayQueryParameters3D.create(a+Vector3.UP*1.5,b+Vector3.UP*1.5,1)
	return world.get_world_3d().direct_space_state.intersect_ray(ray).is_empty()

func plan(position:Vector3,target:String)->PackedInt64Array:
	if not goals.has(target):return PackedInt64Array()
	var candidates:Array=[]
	for id in graph.get_point_ids():
		var p:=graph.get_point_position(id)
		if absf(p.y-position.y)<1.1 and p.distance_to(position)<10:candidates.append([p.distance_to(position),id])
	candidates.sort_custom(func(a,b):return a[0]<b[0])
	for candidate:Array in candidates.slice(0,12):
		if not clear_segment(position,graph.get_point_position(candidate[1])):continue
		# Lazy validation removes only the obstructed edge, retaining every target.
		for attempt in 100:
			var ids:=graph.get_id_path(candidate[1],goals[target].node)
			if ids.is_empty():break
			var clear:=true
			for i in ids.size()-1:
				if not clear_segment(graph.get_point_position(ids[i]),graph.get_point_position(ids[i+1])):
					reject(ids[i],ids[i+1],"wall_or_guard");clear=false;break
			if clear:return ids
	return PackedInt64Array()

func reject(a:int,b:int,reason:String)->void:
	if a>=0 and b>=0 and graph.are_points_connected(a,b):
		graph.disconnect_points(a,b);blocked_edges.append([a,b])
	rejected.append({"from":a,"to":b,"reason":reason})

func refresh_obstacles()->void:
	# A new task/retry observes the current world; an obstacle may have moved or a door opened.
	for edge:Array in blocked_edges:graph.connect_points(edge[0],edge[1])
	blocked_edges.clear()
