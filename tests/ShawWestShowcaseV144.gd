extends "res://tests/ProductShowcaseCandidate.gd"
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15)
	product.start_showcase();var d:Node=product.director
	check("fifteen chapters",d.chapters.size()==15)
	var i:int=-1
	for k in d.chapters.size():
		if d.chapters[k].id=="shaw-west":i=k
	check("west chapter present",i>=0)
	if i<0:quit(1);return
	d.begin_chapter(i);d.presentation_speed=1
	while d.phase!="intro":await physics_frame
	await frames(75);await shot("shaw-west-v144-intro")
	d.presentation_speed=12
	var seen:Dictionary={}
	while d.index==i and d.phase not in ["failed","complete","outro"]:
		await physics_frame
		if d.phase=="walk" and not seen.has(d.leg):
			seen[d.leg]=true;print("WEST_SHOWCASE_LEG ",d.leg)
			if d.leg in [6,17,22,28]:
				await frames(8);await shot("shaw-west-v144-leg-"+str(d.leg))
	if d.phase=="failed":errors.append(d.failures.back());print("WEST_BLOCKED ",d.leg," ",product.world.player.position)
	await shot("shaw-west-v144-end")
	check("entire new chapter completed",d.phase=="outro" and d.results.size()==31)
	d.running=false;d.world.player.set_physics_process(false)
	FileAccess.open("res://tests/artifacts/shaw_west_showcase_v144.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":d.results,"checks":checks,"captures":captures,"failures":errors,"fixtures":1,"scope":"One new chapter, same physical body and authored cut. Not a full15chapter run."},"\t"))
	quit(0 if errors.is_empty() else 1)
