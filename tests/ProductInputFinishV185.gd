extends "res://tests/ProductExperienceV185.gd"
func run()->void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15)
	product.start_player();await frames(15);await player_controls()
	var geometry:Dictionary={}
	for n:Node in product.world.find_children("*","GeometryInstance3D",true,false):
		if not n.is_visible_in_tree():continue
		var k:String=n.get_class();geometry[k]=geometry.get(k,0)+1
	FileAccess.open("res://tests/artifacts/product_input_finish_v185.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"geometry_nodes":geometry,"scope":"Viewport-local event dispatch including GUI hit test at1440x900,not OS keyboard automation"},"\t"))
	print("PRODUCT_INPUT_V185_DONE ",errors);quit(0 if errors.is_empty() else 1)
