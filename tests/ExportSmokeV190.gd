extends SceneTree
var checks:Array=[]
func _initialize()->void:run.call_deferred()
func check(label:String,valid:bool)->void:
	checks.append({"label":label,"valid":valid});print("EXPORT_CHECK ",label," ",valid)
func run()->void:
	var args:=OS.get_cmdline_user_args();var report:="";var expected:="menu";var product_version:=""
	for arg:String in args:
		if arg.begins_with("--product-version="):product_version=arg.trim_prefix("--product-version=")
		if arg.begins_with("--report="):report=arg.trim_prefix("--report=")
		if arg=="--human":expected="player"
		if arg=="--agent-demo":expected="showcase"
	var main:String=ProjectSettings.get_setting("application/run/main_scene")
	var product:Node=load(main).instantiate();root.add_child(product)
	for i in 35:await physics_frame
	if not product_version.is_empty():check("product version matches release",ProjectSettings.get_setting("application/config/version")==product_version)
	check("default scene is product",main=="res://world/product/CampusProduct.tscn")
	check("model matches current stage",product.world.data.version=="official-visual-build-188-library-outer-gallery")
	var batch:Dictionary=product.world.get_meta("render_batch_report",{})
	check("opaque batching preserves instance count",batch.get("instances_before",0)>0 and batch.get("instances_after",0)==batch.get("instances_before",0))
	check("requested entry active",product.mode==expected)
	check("only two public buttons",product.human_button.get_parent().get_children().filter(func(n:Node)->bool:return n is Button).size()==2)
	check("research originals absent",not DirAccess.dir_exists_absolute("res://references"))
	check("test drivers absent",not FileAccess.file_exists("res://tests/ProductExperienceV185.gd"))
	check("legacy photo sign absent",not ResourceLoader.exists("res://assets/signs/walk_without_phone_reference.png"))
	check("new exterior gallery packed",ResourceLoader.exists("res://world/visual_campus/LibraryOuterGallery.gd"))
	var license_dir:=OS.get_executable_path().get_base_dir()+"/licenses"
	DirAccess.make_dir_recursive_absolute(license_dir)
	FileAccess.open(license_dir+"/Godot-LICENSE.txt",FileAccess.WRITE).store_string(Engine.get_license_text())
	FileAccess.open(license_dir+"/Godot-third-party.json",FileAccess.WRITE).store_string(JSON.stringify({"copyright":Engine.get_copyright_info(),"licenses":Engine.get_license_info()},"\t"))
	if expected=="player":check("player active",product.world.player.is_physics_processing() and product.world.player.camera.current and not product.world.player.agent_controlled)
	if expected=="player":check("V190 camera defaults packed",product.world.player.camera.fov==55 and product.world.player.camera.near<.1 and product.world.player.camera_offset==Vector3(0,2.5,5.2))
	if expected=="showcase":check("showcase active with17chapters",product.director.running and product.director.chapters.size()==17 and product.director.camera.current)
	if expected=="showcase":
		for i in 150:await physics_frame
		check("showcase opening fade cleared",product.director.fade.color.a<.01 and product.director.phase!="failed")
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(report.trim_suffix(".json")+".png")
	var ok:bool=checks.all(func(c:Dictionary)->bool:return c.valid)
	FileAccess.open(report,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"valid":ok,"mode":expected,"model_version":product.world.data.version,"executable":OS.get_executable_path(),"scope":"Actual exported template loading packed default scene in clean working directory; external audit driver not packaged."},"\t"))
	quit(0 if ok else 1)
