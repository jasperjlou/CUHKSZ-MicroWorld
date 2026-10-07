"""Authored qualitative interpretation of the May 2026 Campus Guide.

No pixels/meshes are redistributed. Coordinates are deliberately approximate,
not georeferencing. Rebuild data and derived audits with Python standard library.
"""
from pathlib import Path
import argparse
import hashlib
import heapq
import json
import math

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "systems/data"
DOCS = ROOT / "docs"


def smooth(t):
    t = min(1., max(0., t))
    return t * t * (3 - 2 * t)


def height(x, z):
    return round(8 + 46 * (1 - smooth((z + 80) / 650)), 3)


def position(u, v):
    # Manual guide-plane placement, not a calibrated image transform.
    return [round((u - .11) * 1250, 2), round((v - .25) * 1300, 2)]


def terrain_height(x, z, objects, shore):
    """Same grid and pad blends as CampusGeometry; exported Y is actual ground."""
    def raw(x, z):
        y = 8 + 46 * (1 - smooth((z + 80) / 650))
        if x < 285 and -180 < z < 270:
            inside = False
            distance = math.inf
            for a, b in zip(shore, shore[1:] + shore[:1]):
                ax, az = a; bx, bz = b
                t = max(0., min(1., ((x-ax)*(bx-ax)+(z-az)*(bz-az))/((bx-ax)**2+(bz-az)**2)))
                distance = min(distance, math.hypot(x-ax-t*(bx-ax), z-az-t*(bz-az)))
                if (az > z) != (bz > z) and x < (bx-ax)*(z-az)/(bz-az)+ax:
                    inside = not inside
            y = 20.5 if inside else 24.5 + (y-24.5)*smooth(distance/110)
        for o in objects:
            if o['category'] not in ('building','track','court','plaza','garden'): continue
            edge = max(abs(x-o['center'][0])-o['footprint_width']/2,
                       abs(z-o['center'][2])-o['footprint_depth']/2)
            if edge < 12:
                y = o['elevation'] + (y-o['elevation'])*smooth(max(0,edge)/12)
        return y
    gx = math.floor((x+220)/10)*10-220
    gz = math.floor((z+290)/10)*10-290
    tx = (x-gx)/10; tz = (z-gz)/10
    a = raw(gx,gz); c = raw(gx+10,gz+10)
    return a*(1-tx)+raw(gx+10,gz)*(tx-tz)+c*tz if tx>=tz else a*(1-tz)+c*tx+raw(gx,gz+10)*(tz-tx)


def route_geometry(start, end, objects, shore):
    """Authoring-only detours around estimated buildings and water, not an Agent."""
    obstacles = [o for o in objects if o['category'] in ('building','track')]
    def inside_water(x,z):
        inside=False
        for (ax,az),(bx,bz) in zip(shore,shore[1:]+shore[:1]):
            if (az>z)!=(bz>z) and x<(bx-ax)*(z-az)/(bz-az)+ax: inside=not inside
        return inside
    def free(x,z):
        if not (-185<x<1095 and -255<z<1035) or inside_water(x,z):return False
        return not any(abs(x-o['center'][0]) < o['footprint_width']/2+6 and
                       abs(z-o['center'][2]) < o['footprint_depth']/2+6 for o in obstacles)
    def clear(a,b):
        count=max(1,math.ceil(math.dist(a,b)/2))
        return all(free(a[0]+(b[0]-a[0])*i/count,a[1]+(b[1]-a[1])*i/count) for i in range(count+1))
    if clear(start,end):return [start,end]
    # Five-unit planning grid; exact endpoints retained and checked.
    source=tuple(round(v/5) for v in start);goal=tuple(round(v/5) for v in end)
    assert free(*start) and free(*end),f'route endpoint inside footprint: {start}, {end}'
    queue=[(0,0,source)];cost={source:0};previous={};found=False
    while queue:
        _,g,a=heapq.heappop(queue)
        if g!=cost[a]:continue
        if a==goal:found=True;break
        for dx,dz in ((1,0),(-1,0),(0,1),(0,-1),(1,1),(1,-1),(-1,1),(-1,-1)):
            b=(a[0]+dx,a[1]+dz)
            if not clear((a[0]*5,a[1]*5),(b[0]*5,b[1]*5)):continue
            c=g+math.hypot(dx,dz)
            if c<cost.get(b,math.inf):
                cost[b]=c;previous[b]=a
                heapq.heappush(queue,(c+math.dist(b,goal),c,b))
    assert found,f'No inferred route between {start} and {end}'
    grid=[goal]
    while grid[-1]!=source:grid.append(previous[grid[-1]])
    raw=[start]+[(x*5,z*5) for x,z in reversed(grid)]+[end]
    simplified=[raw[0]];i=0
    while i<len(raw)-1:
        j=len(raw)-1
        while j>i+1 and not clear(raw[i],raw[j]):j-=1
        simplified.append(raw[j]);i=j
    assert all(clear(a,b) for a,b in zip(simplified,simplified[1:]))
    return simplified


# ID, Chinese, English, region, guide anchor, width/depth/height, massing, accent.
SITES = [
    ("ling", "道扬书院", "Ling College", "upper", .345,.255,72,75,48,"college","708ba1"),
    ("muse", "思廷书院", "Muse College", "upper", .40,.205,64,68,35,"college","8c9a79"),
    ("diligentia", "学勤书院", "Diligentia College", "upper", .46,.245,80,77,36,"college","c7ac60"),
    ("harmonia", "祥波书院", "Harmonia College", "upper", .375,.365,88,83,38,"college","b77768"),
    ("duan", "永平书院", "Duan Family College", "upper", .485,.12,66,64,42,"college","879faa"),
    ("minerva", "厚含书院", "Minerva College", "upper", .545,.14,72,72,45,"college","769bad"),
    ("eighth", "第八书院", "Eighth College", "middle", .175,.38,74,104,40,"college","a67469"),
    ("amenity", "服务中心", "Amenity Centre", "upper", .385,.155,51,33,13,"podium","b38d72"),
    ("upper_gym", "上园健身设施（近似）", "Upper fitness placeholder", "upper", .43,.16,23,18,8,"box","91a297"),
    ("staff_1", "教职员宿舍1", "Staff Residence 1", "upper", .40,.055,24,22,57,"tower","adb5b2"),
    ("staff_2", "教职员宿舍2", "Staff Residence 2", "upper", .443,.055,24,22,57,"tower","adb5b2"),
    ("staff_3", "教职员宿舍3", "Staff Residence 3", "upper", .483,.055,24,22,57,"tower","adb5b2"),
    ("staff_4", "教职员宿舍4", "Staff Residence 4", "upper", .523,.055,24,22,57,"tower","adb5b2"),
    ("staff_5", "教职员宿舍5", "Staff Residence 5", "upper", .56,.085,24,22,55,"tower","adb5b2"),
    ("music", "音乐学院", "School of Music", "middle", .12,.465,120,94,24,"music","b5a78a"),
    ("research", "科研楼", "Research Complex", "lower", .255,.545,55,55,42,"tower","8ba8a6"),
    ("bell", "钟楼", "Bell Tower", "lower", .28,.61,17,17,38,"bell","c0b49e"),
    ("zhiren", "志仁楼", "Zhi Ren Building", "lower", .35,.61,38,42,24,"academic","b1ae94"),
    ("letian", "乐天楼", "Le Tian Building", "lower", .393,.60,36,42,25,"academic","b1ae94"),
    ("chengdao", "诚道楼", "Cheng Dao Building", "lower", .365,.65,35,35,24,"academic","b1ae94"),
    ("shaw_west", "逸夫书院（西座）", "Shaw College West", "lower", .44,.58,53,54,39,"courtyard","9cafab"),
    ("shaw_east", "逸夫书院（东座）", "Shaw College East", "lower", .462,.67,62,55,30,"courtyard","9cafab"),
    ("sports_hall", "大学体育馆", "University Sports Hall", "lower", .282,.705,86,66,18,"sports","82999e"),
    ("sports_complex", "综合运动馆", "Sports Complex", "lower", .234,.70,18,82,13,"academic","bda260"),
    ("zhixin", "知新楼", "Zhi Xin Building", "lower", .31,.76,83,43,22,"academic","c2ad94"),
    ("daoyuan", "道远楼", "Dao Yuan Building", "lower", .30,.81,79,38,23,"academic","c2ad94"),
    ("library_annex", "图书馆附馆", "Library Annex", "lower", .348,.725,64,45,19,"academic","b0afa5"),
    ("student_centre", "学生中心", "Student Centre", "lower", .548,.688,67,54,23,"student","c0ad83"),
    ("library", "大学图书馆", "University Library", "lower", .621,.724,92,70,27,"library","b6a67d"),
    ("hllu", "涂辉龙楼", "HLTu Building", "lower", .46,.788,36,65,29,"academic","b0ada1"),
    ("leeyin", "李贤义楼", "Lee Yin Yee Building", "lower", .51,.815,52,68,27,"academic","b0ada1"),
    ("zhangling", "张灵斌楼", "Zhang Ling Bin Building", "lower", .58,.83,56,71,27,"academic","bd9b75"),
    ("teaching_c", "教学楼C", "Teaching C", "lower", .657,.855,48,77,25,"academic","bd9b75"),
    ("teaching_b", "教学楼B", "Teaching B", "lower", .729,.845,61,86,25,"courtyard","aaa998"),
    ("teaching_a", "教学楼A", "Teaching A", "lower", .77,.91,60,62,23,"courtyard","aaa998"),
    ("administration", "行政楼", "Administration Building", "lower", .78,.75,82,63,24,"admin","9aa9a2"),
    ("conference", "逸夫国际会议中心", "Run Run Shaw Conference Centre", "lower", .86,.754,52,66,25,"courtyard","b7ad91"),
    ("conference_2", "会议楼II", "Conference Complex II", "lower", .855,.68,47,34,19,"academic","b7ad91"),
    ("conference_1", "会议楼I", "Conference Complex I", "lower", .915,.763,49,47,23,"academic","b7ad91"),
    ("liwen", "礼文堂", "Liwen Hall", "lower", .943,.819,33,43,20,"podium","b7ad91"),
    ("teaching_complex_c", "综合教学楼C座", "Teaching Complex C", "lower", .869,.842,46,52,27,"academic","a3aa9d"),
    ("teaching_complex_d", "综合教学楼D座", "Teaching Complex D", "lower", .923,.885,45,52,27,"academic","a3aa9d"),
    ("teaching_complex_b", "综合教学楼B座", "Teaching Complex B", "lower", .873,.925,45,52,27,"academic","a3aa9d"),
    ("teaching_complex_a", "综合教学楼A座", "Teaching Complex A", "lower", .925,.973,45,52,27,"academic","a3aa9d"),
]


def build(stage):
    objects = []
    for sid, zh, en, region, u,v,w,d,h,kind,accent in SITES:
        x,z = position(u,v)
        y = height(x,z)
        low = sid == "upper_gym"
        objects.append(dict(id=sid,name_zh=zh,name_en=en,region=region,category="building",
            center=[x,y,z],yaw_deg=0,footprint_width=w,footprint_depth=d,
            estimated_height=h,elevation=y,confidence="placeholder" if low else "inferred",
            confidence_label="LOW_CONFIDENCE" if low else "APPROXIMATED",
            metric_confidence="ESTIMATED_METRIC",source_refs=["CAMPUS_MAP"] +
            (["UPPER_OVERALL"] if region=="upper" else ["LOWER_OVERALL"] if region=="lower" else []),
            model_stage=stage,massing=kind,accent=accent,map_anchor_normalized=[u,v],
            replaceable=True,basis="Manual qualitative guide arrangement; local footprints and yaw are estimated."))
    extra = [
        ("upper_central","上园中央广场","Upper Central","upper",.41,.292,38,30,"plaza"),
        ("athletics","田径场","Athletics Field","lower",.184,.656,94,176,"track"),
        ("upper_basketball","上园篮球场","Upper Basketball","upper",.267,.307,30,34,"court"),
        ("upper_tennis","上园网球场","Upper Tennis","upper",.485,.215,23,36,"court"),
        ("lower_courts","下园运动场地","Lower Courts","lower",.405,.76,42,40,"court"),
        ("memorial_garden","凌道扬纪念园","Ling Daoyang Memorial Garden","lower",.60,.675,44,26,"garden"),
        ("upper_stop","上园接驳站（占位）","Upper shuttle placeholder","upper",.455,.305,16,8,"stop"),
        ("lower_stop","下园接驳站（占位）","Lower shuttle placeholder","lower",.26,.66,16,8,"stop"),
        ("north_gate","北门","North Gate","upper",.55,.245,19,8,"gate"),
        ("west_gate","西门","West Gate","lower",.20,.585,19,8,"gate"),
        ("south_old","老南门","Old South Gate","lower",.268,.864,23,8,"gate"),
        ("south_new","新南门","New South Gate","lower",.737,.961,23,8,"gate"),
        ("east_gate","东门","East Gate","lower",.964,.875,19,8,"gate"),
        ("lake_stone","神仙湖题字石（近似定位）","Fairy Lake Stone","fairy_lake",.235,.318,3,2,"stone"),
        ("lake_pavilion","湖畔亭（近似定位）","Lakeside Pavilion","fairy_lake",.005,.29,9,9,"pavilion"),
        ("reservoir_sign","神仙岭水库设施牌（占位定位）","Reservoir sign","fairy_lake",.255,.355,2,1,"sign"),
    ]
    for sid,zh,en,reg,u,v,w,d,cat in extra:
        x,z=position(u,v); y=height(x,z)
        objects.append(dict(id=sid,name_zh=zh,name_en=en,region=reg,category=cat,
            center=[x,y,z],yaw_deg=0,footprint_width=w,footprint_depth=d,estimated_height=0,
            elevation=y,confidence="placeholder" if cat in ("stop","sign") else "inferred",
            confidence_label="LOW_CONFIDENCE" if cat in ("stop","sign") else "APPROXIMATED",
            metric_confidence="ESTIMATED_METRIC",source_refs=["CAMPUS_MAP"],
            model_stage="LANDMARK" if stage!="PLACEMENT" else stage,massing=cat,
            accent="9bad86",map_anchor_normalized=[u,v],replaceable=True,basis="Guide topology; unsurveyed placement."))
    # Concave polygon, west inlet + southern coves, open lake-basin geometry.
    shore = [[-145,-67],[-70,-48],[8,-23],[119,-9],[156,26],[131,110],
        [98,130],[53,108],[17,144],[-30,131],[-58,83],[-88,91],[-117,59],[-106,24],[-145,39]]
    for o in objects:
        if o['category'] in ('stop','gate','stone','pavilion','sign'):
            o['elevation'] = o['center'][1] = round(terrain_height(o['center'][0],o['center'][2],objects,shore),3)
            o['basis'] += ' Landmark grounded on shared terrain; exact registration deferred.'
    objects.append(dict(id="fairy_lake",name_zh="神仙湖",name_en="Fairy Lake",region="fairy_lake",
        category="lake",center=[0,24,0],yaw_deg=0,footprint_width=301,footprint_depth=211,
        estimated_height=0,elevation=24,confidence="inferred",confidence_label="APPROXIMATED",
        metric_confidence="ESTIMATED_METRIC",source_refs=["CAMPUS_MAP","LAKE_01","LAKE_09"],
        model_stage="LANDMARK",massing="lake",replaceable=True,basis="Qualitative guide shoreline; not surveyed."))
    sources = json.loads((ROOT/"references/index.json").read_text(encoding="utf-8"))["references"]
    source_lookup={r["reference_id"]:r for r in sources}
    refs={k:dict(source_url=source_lookup[k].get("source_url"),role="reference_only",raw_asset_imported=False)
          for k in ("CAMPUS_MAP","UPPER_OVERALL","LOWER_OVERALL","LAKE_01","LAKE_09","LEGACY_DAE","OFFICIAL_VR")}
    refs["DUAN_CURRENT_NAME"] = dict(source_url="https://duanfamily.cuhk.edu.cn/",role="current name confirmation",raw_asset_imported=False)
    next(o for o in objects if o["id"]=="duan")["source_refs"].append("DUAN_CURRENT_NAME")
    refs["ZHANG_NAME"] = dict(source_url="https://career.cuhk.edu.cn/en/lecture/view/id/1739",role="building name confirmation only",raw_asset_imported=False)
    next(o for o in objects if o["id"]=="zhangling")["source_refs"].append("ZHANG_NAME")
    master=dict(schema_version=1,version="campus-masterplan-v1",created_at="2026-10-07",
        rc1_baseline="bcbfc9431ae73e3d94a8f440f88ad3c0f56bcb63",
        coordinate_system=dict(up="+Y",east="+X",north="-Z",origin="Fairy Lake qualitative centre",
            north_confidence="APPROXIMATED",map_north_arrow="NOT_PRESENT_IN_GUIDE",
            north_basis="Guide visual up adopted as provisional north; gates are not compass calibration.",
            scale_policy="APPROXIMATED_METRIC_SCALE",units="GAME UNIT APPROXIMATES REAL-WORLD METER SCALE",
            elevation_datum="lower plateau 8 game units; relative relief estimated",real_distance="UNKNOWN"),
        sources=refs,bounds=[[-190,-280],[680,-280],[730,180],[1085,440],[1100,1040],[140,1040],[-190,590]],
        terrain=dict(grid_step=10,x_min=-220,x_max=1140,z_min=-290,z_max=1060,
            lake_water_y=24,upper_plateau=54,lower_plateau=8,confidence="placeholder",replaceable=True,
            basis="Qualitative upper/lower relief and lake basin; no surveyed terrain dataset.",source_refs=["CAMPUS_MAP"]),
        regions=[dict(id="upper",name_zh="上园",name_en="Upper Campus",center=[470,54,-105],color="78908e"),
            dict(id="middle",name_zh="中园",name_en="Middle Campus",center=[170,40,290],color="789867"),
            dict(id="fairy_lake",name_zh="神仙湖",name_en="Fairy Lake",center=[0,24,32],color="609fa6"),
            dict(id="lower",name_zh="下园",name_en="Lower Campus",center=[620,8,735],color="b8ab8a")],
        lake=dict(shoreline=shore,confidence="inferred",metric_confidence="ESTIMATED_METRIC",source_refs=["CAMPUS_MAP","LAKE_01"],replaceable=True),
        objects=objects,high_table=dict(status="PROTOTYPE_UNREGISTERED",scene="res://world/MainWorld.tscn",reason="No reliable real-campus venue registration; retained separately."),
        legacy_names=[dict(legacy_name=k,resolution=v) for k,v in [("诚道楼","chengdao: guide-confirmed"),("乐天楼","letian: guide-confirmed"),("志仁楼","zhiren: guide-confirmed"),("道远楼","daoyuan: guide-confirmed"),("知新楼","zhixin: guide-confirmed"),("TA","teaching_a: label association only"),("逸夫 ABC","UNRESOLVED local block suffixes"),("逸夫 DEF","UNRESOLVED local block suffixes"),("T-BCD","UNRESOLVED aggregate nickname"),("RA","UNRESOLVED exact legacy identity")]])
    # Shared nodes make connectivity explicit; roads and pedestrian routes distinct.
    coords={"upper_central":[375,55],"upper_west":[280,65],"upper_north":[430,-130],
        "upper_east":[590,-35],"north_gate":[600,15],"ling_entry":[248,20],
        "lake_junction":[178,130],"lake_east":[178,170],"lake_south":[15,177],
        "lake_west":[-157,60],"lake_north":[-35,-80],"music_entry":[150,310],
        "middle_lower":[275,450],"west_gate":[190,485],"sports_entry":[280,565],
        "sports_corner":[340,565],"lower_west":[340,635],"lower_central":[565,665],"student_entry":[548,614],
        "library_entry":[655,665],"admin_entry":[825,718],"conference_entry":[945,735],
        "academic_east":[1045,847],"east_gate":[1060,820],"south_new":[785,966],
        "academic_south":[580,935],"south_old":[290,865],"shaw_entry":[445,500]}
    nodes=[dict(id=k,position=[x,round(terrain_height(x,z,objects,shore)+.22,3),z]) for k,(x,z) in coords.items()]
    road_specs=[("upper_internal",["ling_entry","upper_west","upper_central","upper_east","north_gate"],9),
        ("upper_north_loop",["upper_west","upper_north","upper_east"],8),
        ("upper_middle_connector",["upper_west","lake_junction","lake_east","music_entry","middle_lower","west_gate","sports_entry"],9),
        ("lower_main",["sports_entry","sports_corner","lower_west","lower_central","library_entry","admin_entry","conference_entry","east_gate"],9),
        ("lower_perimeter",["lower_west","south_old","academic_south","south_new","academic_east","east_gate"],9),
        ("lower_shaw",["sports_entry","shaw_entry","student_entry","lower_central"],7)]
    path_specs=[("upper_main_walk",["ling_entry","upper_west","upper_central","upper_east"],4),
        ("upper_to_middle",["upper_central","upper_west","lake_junction"],5),
        ("fairy_lake_main",["lake_junction","lake_east"],4),
        ("fairy_lake_scenic",["lake_east","lake_south","lake_west","lake_north","lake_junction"],4),
        ("middle_to_lower",["lake_east","music_entry","middle_lower","west_gate","sports_entry","sports_corner","lower_west","lower_central"],5),
        ("lower_main_walk",["lower_west","lower_central","library_entry","admin_entry","conference_entry"],5),
        ("library_student_center",["student_entry","lower_central","library_entry"],5),
        ("lower_academic_loop",["lower_central","academic_south","south_new","academic_east","conference_entry","admin_entry","library_entry","lower_central"],5),
        ("shaw_walk",["shaw_entry","student_entry","lower_central"],4)]
    def route(rid, ns, width, category):
        return dict(id=rid,nodes=ns,width=width,category=category,confidence="inferred",
            metric_confidence="ESTIMATED_METRIC",source_refs=["CAMPUS_MAP"],replaceable=True,
            basis="Guide road tendency with inferred safe gaps between estimated footprints.")
    master["roads"]=[route(*r,"vehicle") for r in road_specs]
    paths=dict(schema_version=1,version=master["version"],nodes=nodes,
        paths=[route(*r,"pedestrian") for r in path_specs],
        traversal_corridor=["upper_central","upper_west","lake_junction","lake_east","music_entry","middle_lower","west_gate","sports_entry","sports_corner","lower_west","lower_central"],
        agent_navigation_integrated=False,notes="Separate planning topology; existing RC1 AStar graph is unchanged.")
    routed={}
    for r in master['roads']+paths['paths']:
        geometry=[]
        for a,b in zip(r['nodes'],r['nodes'][1:]):
            key=tuple(sorted((a,b)))
            if key not in routed:routed[key]=route_geometry(coords[key[0]],coords[key[1]],objects,shore)
            pts=routed[key] if a==key[0] else list(reversed(routed[key]))
            geometry += pts if not geometry else pts[1:]
        r['geometry']=[[x,round(terrain_height(x,z,objects,shore)+.22,3),z] for x,z in geometry]
        r['footprint_clearance_game_units']=6
        r['basis'] += ' Detoured around building/track envelopes and water; this is inferred, not surveyed routing.'
        r['segment_game_distances']=[round(sum(math.dist(u,v) for u,v in zip(
            [[x,terrain_height(x,z,objects,shore),z] for x,z in routed[tuple(sorted((a,b)))]],
            [[x,terrain_height(x,z,objects,shore),z] for x,z in routed[tuple(sorted((a,b)))]][1:])),3)
            for a,b in zip(r['nodes'],r['nodes'][1:])]
    corridor=[]
    for a,b in zip(paths['traversal_corridor'],paths['traversal_corridor'][1:]):
        key=tuple(sorted((a,b)));pts=routed[key] if a==key[0] else list(reversed(routed[key]))
        corridor+=pts if not corridor else pts[1:]
    paths['physical_traversal_points']=[[x,round(terrain_height(x,z,objects,shore)+.22,3),z] for x,z in corridor]
    DATA.mkdir(exist_ok=True)
    (DATA/"campus_masterplan.json").write_text(json.dumps(master,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    (DATA/"campus_paths.json").write_text(json.dumps(paths,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    write_docs(master,paths)
    print(f"Authored {len(objects)} objects, {len(SITES)} buildings, {len(nodes)} graph nodes.")


def write_docs(m,p):
    intro="# Campus Masterplan V1\n\n2026-10-07. Guide-derived, replaceable qualitative layout. All distances are GAME_DISTANCE; REAL_DISTANCE = UNKNOWN.\n\n"
    inventory=intro+"| ID | 中文名称 | Region | Category | Stage | Sources |\n|---|---|---|---|---|---|\n"
    table=intro+"| Name | Region | World position X,Y,Z | Yaw | Footprint | Height | Elevation | Nearest major neighbors / GAME_DISTANCE | Confidence | Sources | Stage |\n|---|---|---|---|---|---|---|---|---|---|---|\n"
    for o in m["objects"]:
        inventory+=f"| {o['id']} | {o['name_zh']} | {o['region']} | {o['category']} | {o['model_stage']} | {', '.join(o['source_refs'])} |\n"
        near=sorted((math.dist(o["center"],b["center"]),b["name_zh"]) for b in m["objects"] if b["id"]!=o["id"])[:3]
        neighbors="; ".join(f"{n} {d:.1f}" for d,n in near)
        table+=f"| {o['name_zh']} | {o['region']} | {o['center']} | {o['yaw_deg']}° approx | {o['footprint_width']} × {o['footprint_depth']} | {o['estimated_height']} | {o['elevation']} | {neighbors} | {o['confidence']} / {o['metric_confidence']} | {', '.join(o['source_refs'])} | {o['model_stage']} |\n"
    inventory+="\n## Legacy name resolutions\n\n"+"\n".join(f"- `{r['legacy_name']}`: {r['resolution']}" for r in m["legacy_names"])+"\n"
    (DOCS/"CAMPUS_OBJECT_INVENTORY.md").write_text(inventory,encoding="utf-8")
    (DOCS/"CAMPUS_PLACEMENT_TABLE.md").write_text(table,encoding="utf-8")
    ids=["upper_central","fairy_lake","library","administration","student_centre","shaw_west","ling","athletics"]
    obs={o["id"]:o for o in m["objects"]}
    text=intro+"## Straight-line 3D GAME_DISTANCE\n\n| From / To | "+" | ".join(ids)+" |\n|---|"+"---|"*len(ids)+"\n"
    for a in ids:
        text+="| "+a+" | "+" | ".join(f"{math.dist(obs[a]['center'],obs[b]['center']):.1f}" for b in ids)+" |\n"
    # Graph distances to nearest planning node plus explicit connector offsets.
    graph={n["id"]:{} for n in p["nodes"]}; pos={n["id"]:n["position"] for n in p["nodes"]}
    for route in p["paths"]:
        for a,b,d in zip(route["nodes"],route["nodes"][1:],route['segment_game_distances']):
            graph[a][b]=graph[b][a]=min(d,graph[a].get(b,math.inf))
    text+="\n## Planning graph GAME_DISTANCE (not physical route certification)\n\nNearest-node access offsets are included; lake centre represents access to its shoreline, not walking on water.\n\n| From / To | "+" | ".join(ids)+" |\n|---|"+"---|"*len(ids)+"\n"
    nearest={a:min(pos,key=lambda n:math.dist(obs[a]["center"],pos[n])) for a in ids}
    for a in ids:
        dist={k:math.inf for k in graph}; start=nearest[a]; dist[start]=0;todo=set(graph)
        while todo:
            k=min(todo,key=lambda n:dist[n]);todo.remove(k)
            for n,d in graph[k].items(): dist[n]=min(dist[n],dist[k]+d)
        vals=[]
        for b in ids:
            d=dist[nearest[b]]+math.dist(obs[a]["center"],pos[start])+math.dist(obs[b]["center"],pos[nearest[b]])
            vals.append("0.0" if a==b else f"{d:.1f}")
        text+="| "+a+" | "+" | ".join(vals)+" |\n"
    (DOCS/"CAMPUS_DISTANCE_MATRIX.md").write_text(text,encoding="utf-8")


if __name__=="__main__":
    parser=argparse.ArgumentParser();parser.add_argument("--stage",choices=["PLACEMENT","MASSING"],default="MASSING")
    build(parser.parse_args().stage)
