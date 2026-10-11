extends "res://tests/ProductShowcaseCandidate.gd"
## Concentrated physical/render batch for the two new chapters only.
var selected:Array[String]=["library-rear-shaw","shaw-podium"]
var report_id:="rear_shaw_showcase_v141"
var capture_suffix:="v141"
func run() -> void:
	product=load("res://world/product/CampusProduct.tscn").instantiate()
	root.add_child(product);await frames(15)
	product.start_showcase()
	var d:Node=product.director
	d.presentation_speed=12
	for i in d.chapters.size():
		if d.chapters[i].id not in selected:continue
		d.begin_chapter(i)
		while d.phase!="intro":await physics_frame
		# Let the authored intro camera settle before capturing; no shortened holds here.
		d.presentation_speed=1
		await frames(75)
		await shot(d.chapters[i].id+"-intro-"+capture_suffix)
		d.presentation_speed=12
		var seen:Dictionary={}
		while d.index==i and d.phase not in ["failed","complete","outro"]:
			await physics_frame
			if d.phase=="walk" and not seen.has(d.leg):
				seen[d.leg]=true
				print("REAR_SHAW_LEG ",d.chapters[i].id," ",d.leg)
				if d.leg in [1,10,16]:
					await frames(8)
					await shot(d.chapters[i].id+"-leg-"+str(d.leg)+"-"+capture_suffix)
		if d.phase=="failed":
			errors.append(d.failures.back())
			print("REAR_SHAW_BLOCKED ",d.chapters[i].id," ",d.leg," ",product.world.player.position," target=",d.chapters[i].route[d.leg])
			await shot(d.chapters[i].id+"-blocked-"+capture_suffix)
		else:
			await shot(d.chapters[i].id+"-end-"+capture_suffix)
		d.running=false
		d.world.player.set_physics_process(false)
		# The next independent chapter is a declared fixture, not recovery teleportation.
		d.running=true
	check("same scene has fourteen chapters",d.chapters.size()==14)
	var report={"model_version":product.world.data.version,"physical_legs":d.results,"failures":errors,"checks":checks,"captures":captures,"scope":"Only the two added chapters; 12 unaffected chapters retain prior candidate records. Chapter cuts are explicit; no recovery teleport within a chapter."}
	FileAccess.open("res://tests/artifacts/"+report_id+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("REAR_SHAW_RESULT legs=",d.results.size()," failures=",errors)
	quit(0 if errors.is_empty() else 1)
