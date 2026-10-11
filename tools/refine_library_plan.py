"""Apply the bounded library envelope/plan upgrade and register primary-source evidence."""
from pathlib import Path
import json, shutil
root=Path(__file__).resolve().parents[1]
p=root/'world/visual_campus/LibraryEnvelope.gd'
s=p.read_text(encoding='utf-8')
if 'const P := preload("res://world/visual_campus/LibraryUpperLevels.gd")' in s:
    raise SystemExit('Library plan migration already applied; edit the current modules instead of replaying this one-time migration.')
s=s.replace('const CLADDING :=', 'const P := preload("res://world/visual_campus/LibraryUpperLevels.gd")\nconst CLADDING :=',1)
start=s.index('static func return_x(');end=s.index('static func framed_bay(',start)
s=s[:start]+'''static func return_x(z: float,w: float,d: float,side: int) -> float:
	return P.side_x(z,w,d,side)

static func return_top(z: float,w: float,d: float,side: int) -> float:
	return P.roof_y(Vector2(return_x(z,w,d,side),z),w,d)

'''+s[end:]
s=s.replace('yaw: float,seed: int) -> void:', 'yaw: float,seed: int,door: bool=false) -> void:',1)
s=s.replace('\tfor row in 3:\n\t\tvar y:=', '''\tfor row in 3:
		if door and row==0:
			K.box(b,p+basis*Vector3(0,12.45,-.28),Vector3(pitch+.02,.7,.56),CLADDING,true,13,yaw)
			continue
		var y:=''',1)
s=s.replace('var roof:=PackedVector3Array();var fascia:=','var fascia:=',1)
start=s.index('\t\t\tvar edge0:=');end=s.index('\t\t\tvar a:=',start)
s=s[:start]+s[end:]
start=s.index('\t# Rear uses');end=s.index('\tK.surface(n,soffit',start)
s=s[:start]+'''	# Re-entrant two-wing rear outline replaces the old full-width flat wall.
	var back:=P.rear(w,d)
	for segment in range(back.size()-1):
		var a: Vector2=back[segment];var c: Vector2=back[segment+1]
		var length:=a.distance_to(c);var steps:=maxi(2,int(length/1.8));var bay_width:=length/steps
		var yaw: float=-atan2(c.y-a.y,c.x-a.x)
		for i in steps:
			var q:=a.lerp(c,(i+.5)/steps);var q0:=a.lerp(c,float(i)/steps);var q1:=a.lerp(c,(i+1.0)/steps)
			var door: bool=segment==3 and q.x>-13 and q.x<-7
			framed_bay(n,Vector3(q.x,0,q.y),bay_width+.025,yaw,100+segment*16+i,door)
			var y0:=P.roof_y(q0,w,d);var y1:=P.roof_y(q1,w,d)
			face(fascia,Vector3(q0.x,20.8,q0.y),Vector3(q0.x,y0,q0.y),Vector3(q1.x,y1,q1.y),Vector3(q1.x,20.8,q1.y))
			K.box(n,Vector3(q.x,(y0+y1)/2+.035,q.y),Vector3(bay_width+.025,.07,.22),"a8ada6",false,11,yaw)
	K.surface(n,fascia,CLADDING,13)
'''+s[end:]
s=s.replace('var skin:=PackedVector3Array();var roof:=PackedVector3Array()', 'var skin:=PackedVector3Array()')
start=s.index('\t\tvar scale_x:');end=s.index('\t\t# Interior curved',start)
s=s[:start]+s[end:]
start=s.index('\tK.surface(b,skin,');s=s[:start]+'''	K.surface(b,skin,CLADDING,13)
	P.sheet(b,P.outline(w,d),0,"858b84",18,false,true,w,d)
	returns(b,w,d)
	P.lantern(b)
'''
p.write_text(s,encoding='utf-8')
p=root/'world/visual_campus/VisualCampusBuilder.gd';s=p.read_text(encoding='utf-8')
s=s.replace('\tK.box(b,Vector3(0,8.7,-3),Vector3(w*.90,.32,d*.70),"babeb4",true)\n','')
s=s.replace('\tLibrary.detail(b,r,self)','\tLibrary.detail(b,r,self)\n\tpreload("res://world/visual_campus/LibraryUpperLevels.gd").build(b,r,self)',1)
p.write_text(s,encoding='utf-8')
p=root/'world/visual_campus/LibrarySpaces.gd';s=p.read_text(encoding='utf-8')
s=s.replace('for x in range(-14,15,2):K.box(b,Vector3(x,8.28,-11),Vector3(.075,.18,17),"c6c7b8",false,11)', 'for x in range(-14,15,2):\n\t\tif x not in [6,8,10]:K.box(b,Vector3(x,8.28,-11),Vector3(.075,.18,17),"c6c7b8",false,11)')
s=s.replace('for x in [-10,0,10]:light_panel', 'for x in [-10,0,12]:light_panel')
p.write_text(s,encoding='utf-8')
src=Path('C:/Users/12345/AppData/Local/Temp/browser-use/assets/4024e4a3-0d22-4ce7-a6c7-7b03db51c396')
dst=root/'references/visual_build_20261008/originals/library-plan-20261010';dst.mkdir(parents=True,exist_ok=True)
for i,name in enumerate(['a63f3b5f5e7806d4','92df4a0b9134ebb8','8554a40040c9e431','1e175f322f1da5cb','c4d4c1698f7871ba','866a8420886a7f13'],1):shutil.copy2(src/(name+'.jpg'),dst/f'official-library-floor-{i}.jpg')
shutil.copy2(src/'manifest.json',dst/'manifest.json')
p=root/'systems/data/campus_visual_build.json';d=json.loads(p.read_text(encoding='utf-8'))
d['version']='official-visual-build-15-library-plan'
for b in d['buildings']:
    if b['model']=='library':
        b.update(detail_profile='concave_front_asymmetric_returns_reentrant_rear_3f_terrace_folded_lantern',plan_source='https://library.cuhk.edu.cn/floor-maps',
                 observed='official six floor maps confirm bent wings, deep rear notch, 3F outdoor open study area and reduced upper floor footprint; completed architect aerial confirms folded roof lantern',
                 floor_levels=[0,4.4,8.8,12.8,16.8,22.3],model_storeys=6,
                 footprint_confidence='topology and terrace based on official plans; no map scale/compass, footprint proportions and absolute dimensions fitted to retained pond/entry/link anchors',
                 interior_plan='G/2F retained; added usable 3F stair/reading bays/terrace with inferred circulation and furnishings; full 4F-6F interiors not reconstructed')
d['landmarks']=[p for p in d['landmarks'] if not p.get('library_plan_detail')]
for ident,name,position in [('library_3f','图书馆三层研习区',[77,11.04,-282]),('library_terrace','图书馆三层露台',[97,11.04,-303])]:
    d['landmarks'].append(dict(id=ident,name=name,position=position,indoor=True,library_plan_detail=True,source='https://library.cuhk.edu.cn/floor-maps'))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Library envelope, 3F connection and six primary-source plans recorded; original anchors retained.')
