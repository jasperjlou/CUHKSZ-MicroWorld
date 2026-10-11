"""One-time source-based refinement of old lower-campus facades and public frontages."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
p=root/'world/visual_campus/StartZoneBuildings.gd';s=p.read_text(encoding='utf-8')
if 'StartZoneFacades.gd' in s:raise SystemExit('Start-zone migration already applied.')
s=s.replace('const IDS :=','const F := preload("res://world/visual_campus/StartZoneFacades.gd")\nconst Public := preload("res://world/visual_campus/StartZonePublic.gd")\nconst IDS :=',1)
a=s.index('static func facade(');b=s.index('static func bar(',a)
signature=s[a:s.index('\n',a)]
s=s[:a]+signature+'\n\tF.build(b,length,depth,levels,axis,side,ribbon,cages)\n\n'+s[b:]
s=s.replace('for y: float in levels:K.box(b,Vector3(0,y,0),Vector3(size.x,.24,size.y),"c2c6bd",true)', 'for y: float in levels:K.box(b,Vector3(0,y,0),Vector3(size.x,.24,size.y),"a0aa9b" if y==top else "c2c6bd",true,18 if y==top else 15)')
s=s.replace('ribbon and axis==0,cages and axis==0)', 'ribbon and ((size.x>=size.y and axis==0) or (size.y>size.x and axis==1)),cages and ((size.x>=size.y and axis==0) or (size.y>size.x and axis==1)))')
s=s.replace('"d1d0c6")','"c8c9bf",false,22)')
a=s.index('static func glass_entry(');b=s.index('static func banner(',a)
s=s[:a]+'''static func glass_entry(b: Node3D,w: float,z: float,awning: bool) -> void:
	Public.glazing(b,w,z,awning)

'''+s[b:]
s=s.replace('Vector2(w,d*.43),levels,false,true)', 'Vector2(w,d*.43),levels,false,false)')
s=s.replace('\t\t\tK.label(b,"PHILIP WONG YU-HONG &\\nANITA LEUNG FUNG-YEE LIBRARY",Vector3(-w*.22,4,-d*.185),.008)\n','')
a=s.index('\t\t\tfor x in [-12,0,12]:');b=s.index('\t\t"dao_yuan":',a);s=s[:a]+s[b:]
s=s.replace('\tK.label(b,r.name,Vector3(0,4.45,d*.48),.010)', '''\tPublic.build(b,r)
	if r.id=="zhi_xin":
		var title:=K.label(b,"志信楼",Vector3(-w*.38,12.5,d*.485),.016);title.modulate=Color("334f46")
	else:
		var zz: float=d*.055+.2 if r.id=="le_tian" else (d*.29+3.6 if r.id=="zhi_ren" else (d*.35+4.6 if r.id=="dao_yuan" else d*.36+.2))
		K.box(b,Vector3(0,4.43,zz-.08),Vector3(9,.48,.10),"5f7367",false,11)
		K.label(b,r.name,Vector3(0,4.45,zz),.010)''')
p.write_text(s,encoding='utf-8')
p=root/'systems/data/campus_visual_build.json';d=json.loads(p.read_text(encoding='utf-8'));d['version']='official-visual-build-17-start-zone-public'
for b in d['buildings']:
    if b['id'] in ['cheng_dao','le_tian','zhi_ren','zhi_xin','dao_yuan']:
        b['surface_profile']='painted_render_grey_infill_matte_roof_and_individual_dark_frames'
        b['public_space_detail']='source-based entrance glass, recessed thresholds and public-frontage paving; hidden room layout remains inferred'
    if b['id']=='le_tian':b['detail_profile']='plain_narrow_windows_grey_infill_teal_entry_and_single_glass_awning_without_borrowed_equipment_cages'
    if b['id']=='zhi_ren':b['detail_profile']='paired_vertical_windows_open_equipment_balconies_and_recessed_ground_arcade'
    if b['id']=='zhi_xin':b['detail_profile']='ribbon_windows_on_long_wings_teal_return_glazing_library_sign_and_three_pole_forecourt'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Five facade records updated; old campus anchors and navigation positions retained.')
