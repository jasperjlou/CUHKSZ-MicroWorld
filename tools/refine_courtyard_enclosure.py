"""Record the three-sided enclosure and fitted lower public rooms."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-24-district-landscape':
    raise SystemExit('Expected v24; refuse to overwrite newer courtyard metadata')
for s in d.get('public_spaces',[]):
    if s.get('id')=='student_sunken_court':
        s['features']=['retained north walking stair and west ramp','seating terraces beside normal stair','four planted garden panels','two open doorways into lower glazed public gallery','three-sided upper enclosure linked through student gallery to library']
        s['upper_gallery_segments']=[[[56,6.64,-331],[56,6.64,-382]],[[10,6.64,-331],[56,6.64,-331]],[[10,6.64,-400],[78,6.64,-400]]]
        s['lower_gallery_bounds']=[48,-377,53.75,-343]
        s['measurement_limit']='Enclosure, slatted galleries and planted/stepped courtyard supported by WWJ completed photos; exact width/depth, lower room function and doors remain inferred within retained campus anchors.'
for ident,name,position in [('courtyard_lower_gallery','中庭下层休憩廊',[51,-1.76,-360]),('courtyard_library_wing','中庭图书馆侧上廊',[15,6.64,-331]),('courtyard_student_wing','中庭学生中心侧上廊',[18,6.64,-400])]:
    d['landmarks'].append(dict(id=ident,name=name,position=position,indoor=True,courtyard_detail=True))
d['version']='official-visual-build-25-courtyard-enclosure'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],len(d['landmarks']),'landmarks; building anchors and routes retained')
