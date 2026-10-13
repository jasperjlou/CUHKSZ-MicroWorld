extends "res://tests/ProductExperienceV185.gd"
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director;d.presentation_speed=12
	var index:int=-1
	for i in d.chapters.size():
		if d.chapters[i].id=="library-pool":index=i
	d.begin_chapter(index)
	var count:=0;var samples:=0;var overlaps:Array=[]
	var sphere:=SphereShape3D.new();sphere.radius=.18
	while d.index==index and d.phase!="failed" and count<10000:
		await physics_frame;count+=1
		if d.phase in ["walk","outro"]:
			var q:=PhysicsShapeQueryParameters3D.new();q.shape=sphere;q.collision_mask=1;q.exclude=[product.world.player.get_rid()];q.transform=Transform3D(Basis.IDENTITY,d.camera.global_position)
			var hits=product.world.get_world_3d().direct_space_state.intersect_shape(q,1);samples+=1
			if not hits.is_empty() and overlaps.size()<10:overlaps.append(str(hits[0].collider.get_path()))
	check("pool chapter completes around new grey stair",d.index!=index and d.results.size()==d.chapters[index].route.size()-1)
	check("corrected pool camera volume clear",overlaps.is_empty())
	if d.phase=="failed":
		var p:CharacterBody3D=product.world.player;var collision:=KinematicCollision3D.new();var target:Vector3=d.chapters[index].route[d.leg]
		var delta:Vector3=target-p.position;delta.y=0
		print("POOL_BLOCK ",p.position," target=",target)
		if p.test_move(p.global_transform,delta.normalized()*.3,collision):print("POOL_COLLIDER ",collision.get_collider().get_path()," at ",collision.get_position())
	FileAccess.open("res://tests/artifacts/product_review_v218_accepted.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"checks":checks,"failures":errors,"physical_legs":d.results,"camera_samples":samples,"camera_overlaps":overlaps,"scope":"replaces initial blocked library-pool chapter only; remaining21chapters retained from initial review; no full seamless replay claim"},"\t"))
	print("PRODUCT_V218_ACCEPTED legs=",d.results.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
