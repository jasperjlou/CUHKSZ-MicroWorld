extends "res://tests/ProductReviewV218.gd"
const IDS=["library-seating","library-training209","library-services","library-public-stairs","student-lotus","student-hall301","student-front-west301"]
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director
	check("30 authored chapters",d.chapters.size()==30)
	# New chapters and existing chapters adjacent to changed floors/stairs; explicit cuts only.
	var selected:Array[Dictionary]=[]
	for c:Dictionary in d.chapters:
		if c.id in IDS:selected.append(c)
	check("seven selected chapters",selected.size()==7)
	d.chapters=selected;d.presentation_speed=12;d.begin_chapter(0)
	var count:int=0;var samples:int=0;var overlaps:Array=[];var visible_frames:int=0
	var sphere:=SphereShape3D.new();sphere.radius=.18
	while d.phase!="complete" and count<60000:
		await physics_frame;count+=1
		if d.phase in ["intro","walk","outro"]:
			var q:=PhysicsShapeQueryParameters3D.new();q.shape=sphere;q.collision_mask=1;q.exclude=[product.world.player.get_rid()];q.transform=Transform3D(Basis.IDENTITY,d.camera.global_position)
			var hits=product.world.get_world_3d().direct_space_state.intersect_shape(q,1);samples+=1
			if not hits.is_empty() and overlaps.size()<25:overlaps.append({"chapter":d.chapters[d.index].id,"phase":d.phase,"leg":d.leg,"eye":str(d.camera.position),"object":str(hits[0].collider.get_path())})
		if product.world.player.model.visible:visible_frames+=1
		if d.phase=="failed":
			errors.append(d.failures.back());print("STAGE_AGENT_V235_BLOCK ",d.chapters[d.index].id," leg=",d.leg," position=",product.world.player.position)
			if d.index+1<d.chapters.size():d.begin_chapter(d.index+1)
			else:break
	check("selected chapter sequence reached end",d.phase=="complete")
	check("Agent camera volumes clear including intros",overlaps.is_empty())
	check("Agent avatar hidden",visible_frames==0)
	await key(KEY_ESCAPE);product.start_player();await frames(15)
	check("player controls restored after demo",product.mode=="player" and not product.world.player.agent_controlled and product.world.player.camera.current)
	FileAccess.open("res://tests/artifacts/stage_agent_v235.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"checks":checks,"failures":errors,"physical_legs":d.results,"camera_samples":samples,"camera_overlaps":overlaps,"avatar_visible_frames":visible_frames,"chapters":IDS,"total_product_chapters":30,"scope":"seven selected chapters including four new; real body movement with accelerated holds only; 23 other chapters not rerun; not a full 30-chapter replay"},"\t"))
	print("STAGE_AGENT_V235 legs=",d.results.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
