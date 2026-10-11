"""One-off V50 data migration; retained anchors, fitted road curvature."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
path = ROOT / 'systems/data/campus_visual_build.json'
data = json.loads(path.read_text(encoding='utf-8'))

def sample(control):
    result = []
    for i in range(len(control)-1):
        p0, p1, p2, p3 = (control[max(0,i-1)],control[i],control[i+1],control[min(len(control)-1,i+2)])
        for j in range(12):
            t=j/12
            xy=[.5*(2*p1[k]+(-p0[k]+p2[k])*t+(2*p0[k]-5*p1[k]+4*p2[k]-p3[k])*t*t+(-p0[k]+3*p1[k]-3*p2[k]+p3[k])*t*t*t) for k in range(2)]
            result.append([round(xy[0],3),2.24,round(xy[1],3)])
    result.append([control[-1][0],2.24,control[-1][1]])
    return result

whole=sample([(113,-575),(104,-582),(88,-586),(68,-586),(48,-583),(25,-600),(9,-617),(0,-636),(0,-660)])
bend=whole[48:85]
connector=list(reversed(whole[:49]))
for route in data['routes']:
    if route['id']=='main_road':
        route['points']=bend+[[0,2.24,-735],[0,2.24,-805],[0,2.24,-843]]
        route['alignment_note']='V50 fitted smooth bend; authoritative polyline shared with visible surface. Not surveyed.'
    if route['id']=='student_south_garden':
        # Follow the outer curve to the old library side, rather than cutting across asphalt.
        from math import hypot
        outer=[]
        for i,p in enumerate(bend):
            a,c=bend[max(0,i-1)],bend[min(len(bend)-1,i+1)]
            dx,dz=c[0]-a[0],c[2]-a[2]; length=hypot(dx,dz)
            outer.append([round(p[0]+dz/length*8.1,3),2.24,round(p[2]-dx/length*8.1,3)])
        outer[-1]=[-8.1,2.24,-636]
        route['points']=[[30,2.24,-400],[30,2.24,-428],[30,2.24,-476],[42,2.24,-502],[42,2.24,-571]]+outer
    if route['id']=='shaw_west_approach':
        route['points']=[[42,2.24,-571],[44,2.24,-576],[56,2.24,-578],[56,2.24,-594],[61,2.24,-597],[92,2.24,-605],[110,2.24,-620],[110,2.24,-640],[121,2.24,-640]]
    if route['id']=='shaw_rear_to_front':
        route['points']=[[108,2.24,-575],[108,2.24,-589],[87,2.24,-599],[61,2.24,-597],[56,2.24,-594],[56,2.24,-578],[44,2.24,-576],[42,2.24,-571]]
data['routes']=[r for r in data['routes'] if r['id']!='shaw_corner_link']
data['routes'].append({'id':'shaw_corner_link','kind':'vehicle','width':9,'points':connector,'render_surface':False,'alignment_note':'V50 fitted connection from main bend to library rear/research service junction. Anniversary image supports street character, not exact world coordinates.'})
data['version']='official-visual-build-50-shaw-corner'
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

path=ROOT/'world/visual_campus/LowerCorridor.gd'
s=path.read_text(encoding='utf-8')
if '\t# Turn at Shaw' in s:
    start=s.index('\t# Turn at Shaw')
    end=s.index('\t# Court between',start)
    s=s[:start]+'\t# V50 owns the continuous curved corner and its crossing/landscape.\n'+s[end:]
path.write_text(s,encoding='utf-8')

path=ROOT/'world/visual_campus/StartZoneLandscape.gd'
s=path.read_text(encoding='utf-8')
s=s.replace('(-587+gap+4)/2,6.8,-587-(gap+4)','(-636+gap+4)/2,6.8,-636-(gap+4)')
s=s.replace('Vector2(-588,-627),','').replace('[-612,-678,-719,-777,-823]','[-678,-719,-777,-823]')
s=s.replace('[-605,-630,-680,-705,-755,-780]','[-680,-705,-755,-780]').replace('[-605,-630,-655,-680,-705,-755,-780]','[-655,-680,-705,-755,-780]')
path.write_text(s,encoding='utf-8')
print('V50: curved road, rear connector, two pedestrian routes and old straight overlays updated.')
