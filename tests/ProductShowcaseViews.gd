extends "res://tests/ProductShowcaseCandidate.gd"
var selected_chapters: Array[int] = []
var selected_ids: Array[String] = []
var view_suffix := "views"
## Visual-only finishing pass after the physical route batch; no repeat of those 88 legs.
func run() -> void:
	product = load("res://world/product/CampusProduct.tscn").instantiate()
	root.add_child(product)
	await frames(12)
	await shot("menu-final")
	product.start_showcase()
	var d: Node=product.director
	for i in d.chapters.size():
		if not selected_chapters.is_empty() and i not in selected_chapters:continue
		if not selected_ids.is_empty() and d.chapters[i].id not in selected_ids:continue
		d.begin_chapter(i)
		while d.phase!="intro":await physics_frame
		await frames(80)
		await shot(d.chapters[i].id+"-intro-final")
		# An explicit local fixture preview, not another asserted physical route pass.
		d.phase="walk"
		d.elapsed=0
		d.start_leg()
		await frames(18)
		await shot(d.chapters[i].id+"-walk-final")
	product.show_menu()
	product.start_player()
	await frames(15)
	check("player body visible after hidden-body tour",product.world.player.model.visible and not product.world.player.agent_controlled)
	var report={"model_version":product.world.data.version,"captures":captures,"checks":checks,"failures":errors,"scope":"cinematic camera/overlay/hidden-avatar finishing views only;physical routes retained from product_showcase_candidate.json","draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"object_count":Performance.get_monitor(Performance.OBJECT_NODE_COUNT)}
	FileAccess.open("res://tests/artifacts/product_showcase_"+view_suffix+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	quit(0 if errors.is_empty() else 1)
