shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color = vec4(.55,.58,.55,1.0);
uniform int surface_kind = 0;
uniform vec2 tile_size = vec2(.9,.45);
uniform float variation = .045;
uniform float joint_width = .004;
uniform bool research_ground_blend = false;
uniform bool shaw_ground_blend = false;
uniform vec3 research_origin = vec3(0.0);
uniform vec2 research_axis = vec2(1.0,0.0);
uniform vec2 floor_origin=vec2(0.0);
uniform vec2 floor_axis=vec2(1.0,0.0);
varying vec2 floor_local;
varying vec3 world_point;
varying vec3 world_normal;
varying vec4 instance_tint;

float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 cell=floor(p), f=fract(p);f=f*f*(3.0-2.0*f);
    return mix(mix(hash(cell),hash(cell+vec2(1,0)),f.x),mix(hash(cell+vec2(0,1)),hash(cell+vec2(1,1)),f.x),f.y);
}
void vertex() {
    vec2 floor_delta=VERTEX.xz-floor_origin;
    floor_local=vec2(dot(floor_delta,floor_axis),dot(floor_delta,vec2(-floor_axis.y,floor_axis.x)));
    world_point=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
    world_normal=normalize(transpose(inverse(mat3(MODEL_MATRIX)))*NORMAL);
    instance_tint=COLOR;
}
void fragment() {
    vec3 n=abs(world_normal);
    vec2 p=n.y>.7 ? world_point.xz : (n.x>n.z ? world_point.zy : world_point.xy);
    float footprint=max(length(dFdx(p)),length(dFdy(p)));
    float near_detail=1.0-smoothstep(.02,.28,footprint);
    vec3 color=base_color.rgb;
    ROUGHNESS=.86;SPECULAR=.20;
    if (surface_kind==88) {
        // V254 Main Square grey court. .60m squares are fitted, not a site survey.
        vec2 stone=p-vec2(-47.1,-754.8), unit=vec2(.60);
        vec2 q=stone/unit, e=min(fract(q),1.0-fract(q))*unit;
        vec2 pixel=max(fwidth(stone),vec2(.0003));
        vec2 gaps=min(clamp((vec2(.0015)+pixel*.5-e)/pixel,vec2(0),vec2(1)),vec2(.003)/pixel);
        float detail=1.0-smoothstep(.04,.18,footprint);
        color*=.99+(hash(floor(q))-.5)*.055*detail;
        color*=1.0-max(gaps.x,gaps.y)*.25;
        color+=(noise(stone*85.0)-.5)*.026*near_detail;
        ROUGHNESS=.91;SPECULAR=.12;
    } else if (surface_kind==87) {
        // V252 photo222613: smaller paired orthogonal concrete pavers.
        // .30x.15m is a visual fit; neutral daylight colour is not sampled from night lighting.
        vec2 local=p-vec2(-44.0,-676.52);
        vec2 cell=floor(local/.30), f=fract(local/.30)*.30;
        vec2 q=mod(cell.x+cell.y,2.0)<1.0 ? f.yx : f;
        vec2 e=min(mod(q,vec2(.30,.15)),vec2(.30,.15)-mod(q,vec2(.30,.15)));
        float gap=min(e.x,e.y), aa=max(fwidth(gap),.0005);
        float detail=1.0-smoothstep(.018,.10,footprint);
        float seam=(1.0-smoothstep(.0018-aa,.0018+aa,gap))*detail;
        float bevel=(1.0-smoothstep(.005-aa,.005+aa,gap))*detail;
        float block=hash(cell+vec2(floor(q.y/.15)*13.1,0));
        float grit=(noise(local*84.0)-.5)*(1.0-smoothstep(.003,.025,footprint));
        color*=.97+(block-.5)*.11*detail+grit*.10;
        color*=1.0-seam*.24-bevel*.08;
        ROUGHNESS=.96;SPECULAR=.08;
    } else if (surface_kind==85) {
        // Orthogonal 2:1 dominoes form a continuous herringbone, rotated to the street fit.
        vec2 local=p-vec2(70.0,-580.0);
        vec2 stone=vec2(local.x+local.y,local.y-local.x)*.70710678;
        vec2 q=stone/.12,cell=floor(q);
        float phase=mod(cell.x+cell.y,4.0);
        bool vertical=phase>=2.0;
        vec2 anchor=cell-(phase<1.0 ? vec2(0) : (phase<2.0 ? vec2(1,0) : (phase<3.0 ? vec2(0) : vec2(0,1))));
        vec2 unit=vertical ? vec2(.12,.24) : vec2(.24,.12);
        vec2 within=(q-anchor)*.12;
        vec2 e=min(within,unit-within);
        vec2 pixel=max(fwidth(stone),vec2(.0003));
        vec2 gaps=min(clamp((vec2(.0015)+pixel*.5-e)/pixel,vec2(0),vec2(1)),vec2(.003)/pixel);
        float detail=1.0-smoothstep(.035,.12,footprint);
        color*=.985+(hash(anchor)-.5)*.13*detail;
        color*=1.0-max(gaps.x,gaps.y)*.22;
        color+=(noise(stone*73.0)-.5)*.025*near_detail;
        ROUGHNESS=.94;SPECULAR=.10;
    } else if (surface_kind==86) {
        // Local grey stone apron: long rectangles, fine joints and restrained mixed blocks.
        vec2 stone=p-vec2(55.0,-580.0),unit=vec2(.60,.30);
        vec2 q=stone/unit;q.x+=mod(floor(q.y),2.0)*.5;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        vec2 pixel=max(fwidth(stone),vec2(.0003));
        vec2 gaps=min(clamp((vec2(.0015)+pixel*.5-e)/pixel,vec2(0),vec2(1)),vec2(.003)/pixel);
        float tone=hash(floor(q));
        color*=.99+(tone-.5)*.065-(1.0-step(.15,tone))*.065;
        color*=1.0-max(gaps.x,gaps.y)*.20;
        color+=(noise(stone*82.0)-.5)*.040*near_detail+(noise(stone*2.2)-.5)*.025;
        ROUGHNESS=.90;SPECULAR=.12;
    } else if (surface_kind==84) {
        // V248 granite monument: local coordinates avoid large-world hash precision patterns.
        vec3 stone_point=world_point-vec3(64.5,2.24,-576.5);
        vec2 stone=n.y>.7 ? stone_point.xz : (n.x>n.z ? stone_point.zy : stone_point.xy);
        float cloud=noise(stone*.85)*.65+noise(stone*2.7)*.35;
        float grain=noise(stone*97.0)-.5;
        float grain_visible=1.0-smoothstep(.003,.022,footprint);
        color*=.97+(cloud-.5)*.12;
        color+=grain*.065*grain_visible;
        ROUGHNESS=.94;SPECULAR=.10;
    } else if (surface_kind==83) {
        // Official Shaw Road panorama: grey-mauve running-bond blocks and scattered dark units.
        // Per-axis box filtering keeps fine seams from growing into a coarse distant grid.
        vec2 stone=p-vec2(42.0,-500.0);
        vec2 unit=vec2(.40,.20);
        vec2 q=stone/unit;q.x+=mod(floor(q.y),2.0)*.5;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        vec2 pixel=max(fwidth(stone),vec2(.0003));
        vec2 gaps=clamp((vec2(.0015)+pixel*.5-e)/pixel,vec2(0),vec2(1));
        gaps=min(gaps,vec2(.003)/pixel);
        float seam=max(gaps.x,gaps.y);
        float tile=hash(floor(q));
        color*=.985+(tile-.5)*.06;
        float dark=1.0-step(.17,tile);
        color=mix(color,color*vec3(.92,.93,.94),dark);
        color=mix(color,color*vec3(1.025,1.018,.98),step(.80,tile)*.55);
        color+=(noise(stone*65.0)-.5)*.038*near_detail;
        color*=1.0-seam*.22;
        ROUGHNESS=.91;SPECULAR=.12;
    } else if (surface_kind==81) {
        // Small irregular acoustic perforations, photographed around the study-pod heads.
        vec2 q=p/.045;vec2 cell=floor(q);vec2 f=fract(q)-.5;
        vec2 offset=vec2(hash(cell),hash(cell+vec2(17.0)))*.30-.15;
        float radius=.055+hash(cell+vec2(31.0))*.11;
        float aa=max(fwidth(p.x),fwidth(p.y))/.045;
        float holes=1.0-smoothstep(radius-aa,radius+aa,length(f-offset));
        float visible=1.0-smoothstep(.008,.045,footprint);
        color*=1.0-holes*.72*visible;
        ROUGHNESS=.82;SPECULAR=.14;
    } else if (surface_kind==78) {
        // Warm timber inside rounded study rooms, distinct from public textile.
        vec2 wood=floor_local;
        float row=floor(wood.y/.18);
        vec2 q=vec2(wood.x/1.2+mod(row,3.0)/3.0,wood.y/.18);
        vec2 e=min(fract(q),1.0-fract(q))*vec2(1.2,.18);
        vec2 px=max(fwidth(wood),vec2(.0004));
        vec2 seams=clamp((vec2(.0008)+px*.5-e)/px,vec2(0.0),vec2(1.0));
        seams=min(seams,vec2(.0016)/px);
        float grain=noise(vec2(wood.x*3.5,wood.y*95.0))-.5;
        color*=.99+(hash(vec2(floor(q.x),row))-.5)*.07+grain*.048*near_detail;
        color*=1.0-max(seams.x,seams.y)*.16;
        ROUGHNESS=.59;SPECULAR=.24;
    } else if (surface_kind==77) {
        // June2025 1F carpet: cloudy pale horizontal streaks, sparse ochre threads.
        // Local library axes keep one textile direction across the angled floor pieces.
        vec2 t=floor_local;
        vec2 cell=floor(t/.60);
        float shift=(hash(cell)-.5)*.36;
        float cloud=noise(vec2(t.x*6.0+shift,t.y*24.0));
        float fine=noise(vec2(t.x*16.0,t.y*65.0)+vec2(shift*5.0,0.0));
        float fibre=noise(t*vec2(140.0,210.0))-.5;
        float fade=1.0-smoothstep(.012,.07,footprint);
        float warm=smoothstep(.65,.84,noise(t*vec2(4.0,20.0)+vec2(7.0)))*.12;
        color*=.91+cloud*.16+(fine-.5)*.055*near_detail+(hash(cell)-.5)*.008;
        color+=fibre*.028*fade;
        color=mix(color,color*vec3(1.11,1.035,.77),warm);
        ROUGHNESS=.99;SPECULAR=.055;METALLIC=0.0;
    } else if (surface_kind==76) {
        // Registered canteen floor: derivatives BEFORE the repeating tile function.
        // Box-filter the millimetre seam independently on each axis, avoiding jagged
        // min(fract()) derivatives and dark constant-width distant lines.
        vec2 stone=floor_local;
        vec2 unit=vec2(.6,1.2);
        vec2 q=stone/unit;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        vec2 pixel=max(fwidth(stone),vec2(.0003));
        vec2 seam_axis=clamp((vec2(.0015)+pixel*.5-edge)/pixel,vec2(0.0),vec2(1.0));
        seam_axis=min(seam_axis,vec2(.003)/pixel);
        float seam=max(seam_axis.x,seam_axis.y);
        float tone=hash(floor(q));
        float dark=step(.87,tone);
        color*=.985+(tone-.5)*.028-dark*.19;
        float grain=noise(vec2(stone.x*72.0,stone.y*14.0))-.5;
        color+=(grain*.012+(noise(stone*4.0)-.5)*.012)*near_detail;
        color*=1.0-seam*.21;
        ROUGHNESS=.53+dark*.045;SPECULAR=.29;
    } else if (surface_kind==73) {
        // Student outdoor courts: fine-jointed squares, not coarse checked aggregate.
        vec2 q=floor_local/.60;
        vec2 e=min(fract(q),1.0-fract(q))*.60;
        float gap=min(e.x,e.y), aa=max(fwidth(gap),.0006);
        float joint=1.0-smoothstep(.0015-aa,.0015+aa,gap);
        joint*=1.0-smoothstep(.045,.25,footprint);
        color*=.988+(hash(floor(q))-.5)*.032+(noise(floor_local*3.5)-.5)*.022;
        color+=(noise(floor_local*58.0)-.5)*.012*near_detail;
        color*=1.0-joint*.17;
        ROUGHNESS=.78;SPECULAR=.19;
    } else if (surface_kind==75) {
        // Glossy small green wall tiles seen behind the canteen's curved counter.
        vec2 unit=vec2(.10,.20);
        vec2 edge=min(fract(p/unit),1.0-fract(p/unit))*unit;
        float gap=min(edge.x,edge.y);
        float seam=1.0-smoothstep(.001,max(.0025,fwidth(gap)*1.3),gap);
        color*=1.0-seam*.28+(hash(floor(p/unit))-.5)*.06;
        ROUGHNESS=.30;SPECULAR=.45;
    } else if (surface_kind==74) {
        // Individual outdoor treads own their edges; no projected slab grid on risers.
        color*=.99+(noise(p*3.0)-.5)*.024+(noise(p*72.0)-.5)*.020*near_detail;
        ROUGHNESS=.73;SPECULAR=.20;
    } else if (surface_kind==71 || surface_kind==72) {
        // Public hall polished pale stone and gray service stone have separate fitted modules.
        vec2 stone_p=floor_local;
        vec2 unit=surface_kind==71 ? vec2(1.2) : vec2(.6,1.2);
        vec2 q=stone_p/unit;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float dist=min(edge.x,edge.y);
        float seam=1.0-smoothstep(.001,max(.0025,fwidth(dist)*1.3),dist);
        color*=.98+(hash(floor(q))-.5)*.026+(noise(stone_p*3.0)-.5)*.025-seam*.07;
        color+=(noise(stone_p*68.0)-.5)*.012*near_detail;
        if(surface_kind==71) {
            // Sparse dark square insets visible in entry panorama;spacing/width fitted.
            vec2 inset=abs(mod(stone_p+vec2(1.2),vec2(2.4))-vec2(1.2));
            float inset_edge=max(inset.x,inset.y);
            float aa=max(fwidth(inset_edge),.001);
            float dark=(1.0-smoothstep(.050-aa,.050+aa,inset_edge));
            color=mix(color,vec3(.24,.25,.22),dark*.85);
        }
        ROUGHNESS=surface_kind==71 ? .28 : .53;SPECULAR=.36;
    } else if (surface_kind==70) {
        // Library public stair: pale mineral stone from official entry panorama.
        // Individual treads own their joints; do not project giant floor-grid lines over them.
        float cloud=noise(p*2.3)*.65+noise(p*7.0)*.35;
        float grain=noise(p*95.0)-.5;
        color*=.985+(cloud-.5)*.042+grain*.023*near_detail;
        ROUGHNESS=.37+(cloud-.5)*.045;SPECULAR=.34;
    } else if (surface_kind==69) {
        // Official2F Lotus Pavilion: warm square stone tiles, fitted600mm joints.
        vec2 q=p/.6;vec2 edge=min(fract(q),1.0-fract(q))*.6;
        float width=min(edge.x,edge.y);
        float seam=1.0-smoothstep(.001,max(.003,fwidth(width)*1.4),width);
        color*=.97+(hash(floor(q))-.5)*.06-seam*.12;
        color+=(noise(p*35.)-.5)*.015*near_detail;
        ROUGHNESS=.70;SPECULAR=.22;
    } else if (surface_kind==68) {
        // Official1F dining: mixed grey rectangular tiles, fitted600mm module.
        vec2 unit=vec2(.6,1.2);vec2 q=p/unit;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float width=min(edge.x,edge.y);
        float seam=1.0-smoothstep(.001,max(.003,fwidth(width)*1.4),width);
        float tone=hash(floor(q));
        color*=.89+tone*.16-step(.84,tone)*.13-seam*.14;
        color+=(noise(p*38.0)-.5)*.018*near_detail;
        ROUGHNESS=.66;SPECULAR=.23;
    } else if (surface_kind==67) {
        // Pale veneered hall lining; subtle grain avoids the generic coarse timber stripes.
        color*=.98+(noise(vec2(p.x*18.0,p.y*.8))-.5)*.045*near_detail;
        ROUGHNESS=.71;SPECULAR=.22;
    } else if (surface_kind==66) {
        //301 hall staggered wood blocks, from photographs; dimensions/color are fitted.
        vec2 unit=vec2(.70,.12);
        vec2 q=p/unit;q.x+=mod(floor(q.y),3.0)/3.0;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float seam=1.0-smoothstep(.001,.001+max(.001,footprint),min(edge.x,edge.y));
        color*=.94+(hash(floor(q))-.5)*.11;
        color*=1.0-seam*.08*near_detail;
        color*=1.0+(noise(vec2(p.x*.9,p.y*45.0))-.5)*.09*near_detail;
        ROUGHNESS=.63;SPECULAR=.24;
    } else if (surface_kind==62) {
        // G-floor expanded metal: tiny diamond apertures over a dark plenum.
        // Opaque optical approximation; filter to coverage before subpixel aliasing.
        vec2 mesh_p=vec2(p.x/.018,p.y/.010);
        vec2 diamond=abs(fract(vec2(mesh_p.x+mesh_p.y,mesh_p.x-mesh_p.y))-.5);
        float wire=max(diamond.x,diamond.y);
        float aa=clamp(footprint/.010,.015,.45);
        float opening=1.0-smoothstep(.34-aa,.34+aa,wire);
        float resolved=1.0-smoothstep(.0015,.007,footprint);
        color*=1.0-mix(.47,opening,resolved)*.48;
        ROUGHNESS=.76;SPECULAR=.23;
    } else if (surface_kind==60 || surface_kind==61) {
        // East Gate square cube ground faces: dark granite field and pale granite border.
        // Modules are fitted; narrow joints and mineral grains fade with pixel footprint.
        vec2 unit=surface_kind==60 ? vec2(.60) : vec2(.60,.30);
        vec2 q=p/unit,cell=floor(q);
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0005);
        float joint=1.0-smoothstep(.0015-aa,.0015+aa,gap);
        float tile_detail=1.0-smoothstep(.03,.18,footprint);
        float grain_detail=1.0-smoothstep(.0015,.022,footprint);
        float grain=noise(p*168.0),fleck=noise(p*83.0);
        float weather=noise(p*1.7)*.65+noise(p*5.1)*.35;
        float stone=hash(cell+vec2(7.3,19.8));
        color*=.97+(stone-.5)*.045*tile_detail+(weather-.5)*.055;
        float crystals=smoothstep(.58,.78,grain)-smoothstep(.59,.78,1.0-fleck);
        color*=1.0+crystals*(surface_kind==60 ? .08 : .16)*grain_detail;
        color*=1.0-joint*.27*tile_detail;
        ROUGHNESS=clamp(.84+(weather-.5)*.08,.79,.91);SPECULAR=.12;
    } else if (surface_kind==59) {
        // Forest litter only: broad soil/low moss variation, subtle close leaves.
        vec2 ground_p=world_point.xz;
        float patches=noise(ground_p*.45);
        color=mix(base_color.rgb*.76,vec3(.31,.36,.23),smoothstep(.35,.8,patches)*.45);
        color*=.94+noise(ground_p*8.0)*.10;
        vec2 cell=floor(ground_p/.32),f=fract(ground_p/.32)-.5;
        float a=hash(cell)*6.283185;
        vec2 leaf=mat2(vec2(cos(a),sin(a)),vec2(-sin(a),cos(a)))*f;
        float shape=length(leaf/vec2(.31,.10));
        float litter=(1.0-smoothstep(.75,1.1,shape))*step(.63,hash(cell+17.0))*near_detail;
        color=mix(color,vec3(.43,.36,.23),litter*.30);
        ROUGHNESS=1.0;SPECULAR=.06;
    } else if (surface_kind==58) {
        // Library G arcade: grey rectangular stone in Sept2026 entrance photographs.
        // Fitted .8/.4m modules; joints follow library axes, not the world camera.
        vec2 stone_p=vec2(world_point.z,-world_point.x);
        vec2 unit=vec2(.8,.4),q=stone_p/unit;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        vec2 aa=max(fwidth(stone_p)*.65,vec2(.0005));
        vec2 seams=vec2(1.0)-smoothstep(vec2(.002)-aa,vec2(.002)+aa,edge);
        float joint=max(seams.x,seams.y);
        float detail=1.0-smoothstep(.025,.16,footprint);
        float grain=(noise(stone_p*83.0)-.5)*.045*near_detail;
        color*=.99+(hash(floor(q))-.5)*.035*detail+grain-joint*.20*detail;
        ROUGHNESS=.88;SPECULAR=.12;
    } else if (surface_kind==57) {
        // Outside the researched build bounds only. Neutral context, not a paving claim.
        float context_edge=mix(-220.0,-169.0,1.0-smoothstep(-975.0,-955.0,world_point.z));
        float outside=max(max(context_edge-world_point.x,world_point.x-245.0),max(-1150.0-world_point.z,world_point.z-100.0));
        vec3 edge_ground=mix(vec3(.42,.49,.35),vec3(.32,.35,.25),smoothstep(150.0,245.0,world_point.x));
        float wooded=smoothstep(180.0,260.0,world_point.x)*(1.0-smoothstep(60.0,170.0,world_point.z))*smoothstep(-1240.0,-1130.0,world_point.z);
        color=mix(edge_ground,base_color.rgb,smoothstep(0.0,28.0,outside)*(1.0-wooded));
        color*=.985+(noise(p*.12)-.5)*.025;
        ROUGHNESS=1.0;SPECULAR=.05;
    } else if (surface_kind==55) {
        // Old library2025 maintenance photograph: grey carpet with fine yellow-green traces.
        float fibre=(noise(p*95.0)-.5)*.11*near_detail;
        vec2 weave=p*7.0+vec2(noise(p*2.3),noise(p*2.1+11.0))*.85;
        float line=abs(sin(weave.x+weave.y*1.6))*abs(sin(weave.y-weave.x*.7));
        float thread=(1.0-smoothstep(.025,.10,line))*.24*near_detail;
        color=mix(vec3(.42,.45,.42),vec3(.64,.66,.40),thread)+fibre;
        ROUGHNESS=1.0;SPECULAR=.05;
    } else if (surface_kind==56) {
        // Fine task-chair weave, not the much coarser architectural screen aperture.
        vec2 cell=abs(fract(p/.008)-.5);
        float resolved=1.0-smoothstep(.0008,.0028,footprint);
        if(max(cell.x,cell.y)<.27*resolved) discard;
        color*=.95+(noise(p*80.0)-.5)*.05*resolved;
        ROUGHNESS=.94;SPECULAR=.08;
    } else if (surface_kind==54) {
        // Red perforated screen: real near-view apertures, filtered opaque red at distant subpixels.
        vec2 rotated=vec2(p.x+p.y,p.y-p.x)*.70710678;
        vec2 cell=abs(fract(rotated/.035)-.5);
        float visible_hole=1.0-smoothstep(.004,.010,footprint);
        if(max(cell.x,cell.y)<.29*visible_hole) discard;
        color*=.96+(noise(p*5.0)-.5)*.045;
        ROUGHNESS=.85;SPECULAR=.13;
    } else if (surface_kind==52) {
        // Student court mosaic: filter in continuous metres, before fract folds derivatives.
        // No high-frequency per-cell hash; distant yellow stays quiet rather than hatching.
        vec2 unit=vec2(.045), edge=min(fract(p/unit),1.0-fract(p/unit))*unit;
        vec2 aa=max(fwidth(p)*.65,vec2(.00035));
        vec2 lines=vec2(1.0)-smoothstep(vec2(.0008)-aa,vec2(.0008)+aa,edge);
        float seam=max(lines.x,lines.y);
        float detail=1.0-smoothstep(.004,.014,footprint);
        color*=.995-mix(.07,seam,detail)*.10;
        ROUGHNESS=.80;SPECULAR=.16;
    } else if (surface_kind==50) {
        // 2025-09 published6F photo: sparse small flecks in a pale partition band.
        vec2 cell=floor(p/.065),q=fract(p/.065);
        vec2 centre=vec2(.2+.6*hash(cell),.2+.6*hash(cell+13.7));
        float radius=mix(.025,.070,hash(cell+4.3));
        float mark=(1.0-smoothstep(radius,radius+.035,length(q-centre)))*step(.35,hash(cell+7.9));
        color*=1.0-mark*.48*near_detail;
        ROUGHNESS=.87;SPECULAR=.12;
    } else if (surface_kind==51) {
        // Cloth grain stays below high-contrast weave frequencies that caused moire.
        float grain=noise(p*40.0)-.5;
        color*=.96+grain*.055*(1.0-smoothstep(.003,.012,footprint));
        ROUGHNESS=.91;SPECULAR=.13;
    } else if (surface_kind==49) {
        // Gift-shop entrance cube 25308214: aligned rectangular grey stone with fine riven grain.
        // Module is a visual fit; restrained per-tile variation, no checkerboard or high gloss.
        vec2 unit=vec2(.60,.90),q=p/unit;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0005);
        float joint=1.0-smoothstep(.0018-aa,.0018+aa,gap);
        float detail=1.0-smoothstep(.025,.18,footprint);
        float grain=noise(p*vec2(91.0,12.0))*.65+noise(p*vec2(153.0,31.0))*.35;
        color*=.985+(hash(floor(q))-.5)*.035*detail+(grain-.5)*.048*near_detail-joint*.23*detail;
        ROUGHNESS=.81;SPECULAR=.17;
    } else if (surface_kind==47) {
        // ICC panorama: small rectangular stone modules, not storey-high panels.
        vec2 unit=vec2(.64,.32),q=p/unit;
        q.x+=mod(floor(q.y),2.0)*.5;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0005);
        float joint=1.0-smoothstep(.003-aa,.003+aa,gap);
        float detail=1.0-smoothstep(.035,.16,footprint);
        color*=.985+(hash(floor(q))-.5)*.045*detail;
        color*=1.0-joint*.21*detail+(noise(p*51.0)-.5)*.027*near_detail;
        ROUGHNESS=.88;SPECULAR=.13;
    } else if (surface_kind==44) {
        // Fine perforated metal/mesh, resolved only when it is larger than a pixel.
        vec2 cell=fract(p/.018)-.5;
        float aa=max(footprint/.018,.015);
        float perforation=1.0-smoothstep(.13-aa,.13+aa,length(cell));
        float detail=1.0-smoothstep(.006,.020,footprint);
        color*=.975-perforation*.14*detail;
        ROUGHNESS=.87;SPECULAR=.10;
    } else if (surface_kind==43) {
        // Interior pale timber veneer: fine matte grain without metre-wide zebra stripes.
        float grain=noise(p*vec2(78.0,2.3))-.5;
        float pore=noise(p*vec2(157.0,14.0))-.5;
        color*=.99+(grain*.055+pore*.025)*near_detail;
        ROUGHNESS=.82;SPECULAR=.12;
    } else if (surface_kind==42) {
        // Gate lawn promenade: quiet rectangular granite, not high-contrast checkerboard.
        vec2 unit=vec2(.40,.80),q=p/unit;
        q.y+=mod(floor(q.x),2.0)*.5;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0006);
        float joint=1.0-smoothstep(.002-aa,.002+aa,gap);
        float detail=1.0-smoothstep(.025,.20,footprint);
        color*=.98+(hash(floor(q))-.5)*.035*detail+(noise(p*24.0)-.5)*.045*near_detail-joint*.20*detail;
        ROUGHNESS=.89;SPECULAR=.12;
    } else if (surface_kind==41) {
        // Teaching A arcade: grey square stone slabs, subtle mineral grain and subdued reflection.
        // 800mm module is photo-fitted, not surveyed. Derivatives suppress distant seam shimmer.
        vec2 unit=vec2(.8),q=p/unit;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0006);
        float joint=1.0-smoothstep(.0015-aa,.0015+aa,gap);
        float detail=1.0-smoothstep(.025,.14,footprint);
        color*=.96+(hash(floor(q))-.5)*.045+(noise(p*18.0)-.5)*.035*near_detail-joint*.16*detail;
        ROUGHNESS=.78;SPECULAR=.14;
    } else if (surface_kind==63 || surface_kind==64) {
        // Oct2026 colonnade photos: long grey stone, aligned courses and faint cleft grain.
        vec2 stone_p=surface_kind==63 ? p : p.yx;
        vec2 unit=vec2(.80,.32), q=stone_p/unit;
        q.x+=mod(floor(q.y),2.0)*.5;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        // V239 use continuous-axis derivatives before the staggered repeating seams.
        vec2 pixel=max(fwidth(stone_p),vec2(.0004));
        vec2 seams=clamp((vec2(.0022)+pixel*.5-edge)/pixel,vec2(0.0),vec2(1.0));
        seams=min(seams,vec2(.0044)/pixel);
        float joint=max(seams.x,seams.y);
        float detail=1.0-smoothstep(.028,.17,footprint);
        float cloud=noise(stone_p*vec2(5.0,11.0))-.5;
        float cleft=noise(stone_p*vec2(17.0,87.0))-.5;
        color*=.98+(hash(floor(q))-.5)*.055*detail+cloud*.055+cleft*.035*near_detail-joint*.20*detail;
        ROUGHNESS=.86;SPECULAR=.13;
    } else if (surface_kind==40) {
        // Photo mall: grey rectangular stone, slight stagger and varied mineral grain.
        vec2 unit=vec2(.40,.80);vec2 q=p/unit;
        q.y+=mod(floor(q.x),2.0)*.5;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0006);
        float joint=1.0-smoothstep(.0025-aa,.0025+aa,gap);
        float detail=1.0-smoothstep(.025,.14,footprint);
        float mineral=noise(p*vec2(8.0,19.0))*.6+noise(p*42.0)*.4;
        // Keep a coherent grey stone field; the former 16% random block
        // contrast read as a checkerboard from the mall/colonnade cameras.
        color*=.97+hash(floor(q))*.055+(mineral-.5)*.065*near_detail-joint*.18*detail;
        ROUGHNESS=.89;SPECULAR=.14;
    } else if (surface_kind==39) {
        // Old-library render: subdued broad weathering, fine plaster at close range.
        // World-space scale prevents stretched streaks on differently sized facade pieces.
        float stain=noise(p*vec2(.65,.43))*.65+noise(p*vec2(2.2,.78))*.35;
        float streak=smoothstep(.53,.77,noise(p*vec2(3.1,.32)));
        color*=.92+stain*.13-streak*.10;
        color*=1.0+(noise(p*67.0)-.5)*.045*near_detail;
        ROUGHNESS=.97;SPECULAR=.08;
    } else if (surface_kind==38) {
        // Pavilion stair landings: small square setts separated by grass joints.
        vec2 unit=vec2(.24);vec2 q=p/unit;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float edge=min(e.x,e.y),aa=max(fwidth(edge),.0006);
        float joint=1.0-smoothstep(.012-aa,.012+aa,edge);
        float detail=1.0-smoothstep(.03,.14,footprint);
        color*=.90+(hash(floor(q))-.5)*.17+(noise(p*49.0)-.5)*.09*near_detail;
        color=mix(color,base_color.rgb*vec3(.46,.59,.35),joint*.82*detail);
        ROUGHNESS=.98;SPECULAR=.08;
    } else if (surface_kind==37) {
        // Irregular grey stepping stones with dark grass joints, fitted from user photos.
        vec2 q=p*2.1,cell=floor(q),local=fract(q);
        float first=10.0,second=10.0,stone=0.0;
        for(int x=-1;x<=1;x++)for(int y=-1;y<=1;y++) {
            vec2 offset=vec2(float(x),float(y));
            vec2 seed=vec2(hash(cell+offset),hash(cell+offset+vec2(51,19)));
            float dist=length(offset+vec2(.25)+seed*.5-local);
            if(dist<first){second=first;first=dist;stone=hash(cell+offset+vec2(17,7));}
            else if(dist<second){second=dist;}
        }
        float edge=second-first,aa=max(fwidth(edge),.001);
        float gap=1.0-smoothstep(.035-aa,.035+aa,edge);
        float detail=1.0-smoothstep(.09,.35,footprint);
        color*=.88+stone*.20+(noise(p*47.0)-.5)*.08*near_detail;
        color=mix(color,base_color.rgb*vec3(.40,.48,.31),gap*.8*detail);
        ROUGHNESS=.98;SPECULAR=.09;
    } else if (surface_kind==36) {
        // Older Zhixin/Daoyuan roofs: broad weathering and pale construction joints.
        // Fitted 4 m modules; keep high-frequency aggregate below the pixel footprint.
        vec2 unit=vec2(4.0);vec2 edge=min(fract(p/unit),1.0-fract(p/unit))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.001);
        float joint=1.0-smoothstep(.017-aa,.017+aa,gap);
        float stain=noise(p*.27)*.6+noise(p*.83)*.4;
        color*=.78+stain*.39+(noise(p*29.0)-.5)*.10*near_detail;
        color=mix(color,color*1.22,joint*.60);
        ROUGHNESS=.98;SPECULAR=.08;
    } else if (surface_kind==35) {
        // Weathered narrow outdoor boards from Zhiren garden; fitted module and grain.
        vec2 unit=vec2(2.4,.14);vec2 q=(p-vec2(45,-751))/unit;
        q.x+=mod(floor(q.y),3.0)/3.0;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0005);
        float seam=1.0-smoothstep(.002-aa,.002+aa,gap);
        float detail=1.0-smoothstep(.025,.14,footprint);
        float grain=noise(vec2(p.x*1.6,p.y*95.0))-.5;
        float worn=noise(p*vec2(.4,2.0));
        color*=.96+(hash(floor(q))-.5)*.16*detail+grain*.13*near_detail-seam*.23*detail;
        color=mix(color,vec3(dot(color,vec3(.3,.59,.11))),worn*.22);
        ROUGHNESS=.93;SPECULAR=.11;
    } else if (surface_kind==65) {
        // User photo222613: paired orthogonal pavers beside the court.
        // Local coordinates avoid high-frequency precision loss far from the origin.
        vec2 local=p-vec2(-46.0,-676.4);
        vec2 cell=floor(local/.40),f=fract(local/.40)*.40;
        bool vertical=mod(cell.x+cell.y,2.0)<1.0;
        vec2 q=vertical ? f.yx : f;
        vec2 edge=min(mod(q,vec2(.40,.20)),vec2(.40,.20)-mod(q,vec2(.40,.20)));
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0007);
        float seam=1.0-smoothstep(.002-aa,.002+aa,gap);
        float detail=1.0-smoothstep(.02,.12,footprint);
        float block=hash(cell+vec2(floor(q.y/.20)*11.7,0));
        float grain=(noise(local*45.0)-.5)*(1.0-smoothstep(.005,.035,footprint));
        color*=.97+(block-.5)*.17*detail-seam*.23*detail+grain*.055;
        ROUGHNESS=.94;SPECULAR=.10;
    } else if (surface_kind==34) {
        // Main Square ochre narrow bricks: long axis runs away from the road curb.
        // 300 x 100 mm is a visual fit, not a measured specification.
        vec2 unit=vec2(.30,.10);vec2 q=(p-vec2(0,-733))/unit;
        q.x+=mod(floor(q.y),2.0)*.5;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0005);
        float seam=1.0-smoothstep(.0018-aa,.0018+aa,gap);
        float detail=1.0-smoothstep(.015,.10,footprint);
        color*=.98+(hash(floor(q))-.5)*.11*detail-seam*.22*detail;
        color*=1.0+(noise(p*65.0)-.5)*.07*near_detail;
        ROUGHNESS=.94;SPECULAR=.10;
    } else if (surface_kind==33) {
        // Shaw outer walk: staggered rectangular pavers with scattered darker units.
        // Module size is fitted from panorama, not a measured paving schedule.
        vec2 q=(p-vec2(42.0,-500.0))/vec2(.40,.20);
        q.x+=mod(floor(q.y),2.0)*.5;
        vec2 e=min(fract(q),1.0-fract(q))*vec2(.40,.20);
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0007);
        float seam=1.0-smoothstep(.002-aa,.002+aa,gap);
        float detail=1.0-smoothstep(.025,.15,footprint);
        float unit=hash(floor(q));
        color*=.96+(unit-.5)*.18*detail-(1.0-step(.17,unit))*.10*detail;
        color*=1.0-seam*.25*detail+(noise((p-vec2(42,-500))*48.0)-.5)*.065*near_detail;
        ROUGHNESS=.91;SPECULAR=.12;
    } else if (surface_kind==82) {
        // V243 precast drain covers and concrete stair: no false masonry grid.
        float grain=noise(p*64.0)-.5;
        float broad=noise(p*1.9)-.5;
        float detail=1.0-smoothstep(.014,.07,footprint);
        color*=.99+broad*.036+grain*.075*detail;
        ROUGHNESS=.90;SPECULAR=.12;
    } else if (surface_kind==32) {
        // Library service apron: small exposed aggregate, fading before aliasing.
        float detail=1.0-smoothstep(.009,.065,footprint);
        float aggregate=noise((p-vec2(120.0,-290.0))*85.0)-.5;
        float wear=noise(p*.20)-.5;
        color*=.99+aggregate*.24*detail+wear*.035;
        ROUGHNESS=clamp(.95+aggregate*.05*detail,.90,1.0);SPECULAR=.09;
    } else if (surface_kind==31) {
        // East Gate granite: square modules observed in the official pavement faces.
        // 600 mm is fitted from the image, not a measured dimension.
        vec2 unit=vec2(.6);vec2 q=p/unit;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0006);
        float seam=1.0-smoothstep(.0015-aa,.0015+aa,gap);
        float detail=1.0-smoothstep(.028,.18,footprint);
        float mineral=noise(p*52.0)-.5;
        color*=.98+(hash(floor(q))-.5)*.048*detail+mineral*.07*near_detail;
        color=mix(color,color*.66,seam*.34*detail);
        ROUGHNESS=clamp(.82+mineral*.08*near_detail,.76,.92);SPECULAR=.18;
    } else if (surface_kind==30) {
        // Indoor sports parquet: short staggered boards, not broad continuous timber bands.
        vec2 unit=vec2(.09,.60);vec2 q=p/unit;
        q.y+=mod(floor(q.x),4.0)*.25;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0005);
        float seam=1.0-smoothstep(.0007-aa,.0007+aa,gap);
        float detail=1.0-smoothstep(.018,.09,footprint);
        float grain=noise(vec2(p.x*130.0,p.y*7.0))-.5;
        color*=.98+(hash(floor(q))-.5)*.14*detail+grain*.055*near_detail-seam*.075*detail;
        ROUGHNESS=.50;SPECULAR=.32;
    } else if (surface_kind==29) {
        // Grey indoor porcelain, 600 mm square modules and restrained fine grout.
        vec2 unit=vec2(.6);vec2 q=p/unit;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0006);
        float seam=1.0-smoothstep(.001-aa,.001+aa,gap);
        float detail=1.0-smoothstep(.025,.16,footprint);
        color*=.995+(hash(floor(q))-.5)*.035+(noise(p*14.0)-.5)*.02*near_detail-seam*.10*detail;
        ROUGHNESS=.57;SPECULAR=.27;
    } else if (surface_kind==28) {
        // Natural granite boulder: multi-scale mineral grain, no paving/mortar grid.
        float mineral=noise(p*35.0)-.5;
        float vein=noise(p*.9+vec2(noise(p*2.0)))-.5;
        color*=.94+vein*.20+mineral*.26*near_detail;
        ROUGHNESS=.97;SPECULAR=.10;
    } else if (surface_kind==27) {
        // Dark green structural-glass floor panels at ICC; no blue facade-glass override.
        color*=.985+noise(p*1.6)*.025;
        ROUGHNESS=.54;SPECULAR=.12;METALLIC=0.0;
    } else if (surface_kind==46) {
        // Library G public carpet replaced in June2025 (official article1203).
        // Pale mottled modular textile, with cloudy grey streaks and sparse warm fibres.
        // Module size and colour are fitted; world projection joins adjacent floor pieces.
        vec2 cell=floor(p/.60);
        vec2 grain_p=p+vec2(hash(cell)*1.7,hash(cell+vec2(13.0))*2.3);
        float drift=noise(grain_p*vec2(1.4,4.0));
        float cloud=noise(grain_p*vec2(3.8,12.0)+vec2(drift*1.8,0));
        float fibre=noise(grain_p*vec2(115.0,170.0))-.5;
        float warm=smoothstep(.68,.87,noise(grain_p*vec2(7.0,18.0)))*.065;
        color*=.89+cloud*.18+(hash(cell)-.5)*.018+fibre*.05*near_detail;
        color=mix(color,color*vec3(1.07,1.025,.88),warm);
        ROUGHNESS=.99;SPECULAR=.06;METALLIC=0.0;
    } else if (surface_kind==45) {
        // 4F September 2024 photos: alternating grey carpet modules with subdued fibres.
        // Separate from ICC glass (27); avoid the previously unreachable duplicate branch.
        vec2 cell=floor(p/.60);
        float checker=mod(cell.x+cell.y,2.0);
        float fibre=noise(p*96.0)-.5;
        color*=.98+checker*.025+(hash(cell)-.5)*.024+fibre*.045*near_detail;
        ROUGHNESS=.98;SPECULAR=.08;METALLIC=0.0;
    } else if (surface_kind==26 || surface_kind==53) {
        // Flamed granite paving: metric modules, shallow seams and matte mineral grain.
        // World-space projection keeps adjacent regional meshes on the same tile grid.
        vec2 q=p/tile_size;
        vec2 edge=min(fract(q),1.0-fract(q))*tile_size;
        float width=min(edge.x,edge.y), aa=max(fwidth(width),.001);
        float seam=1.0-smoothstep(.004-aa,.004+aa,width);
        seam*=1.0-smoothstep(.06,.4,footprint);
        float mineral=noise(p*46.0)-.5;
        color*=.97+(hash(floor(q))-.5)*(surface_kind==53 ? .04 : .075)+mineral*.075*near_detail;
        color=mix(color,color*.55,seam*.42);
        ROUGHNESS=clamp(.88+mineral*.09*near_detail,.8,.97);SPECULAR=.13;
    } else if (surface_kind==0 || surface_kind==1 || surface_kind==6 || surface_kind==7) {
        vec2 q=p/tile_size;
        if (surface_kind==1 || surface_kind==7) q.x+=mod(floor(q.y),2.0)*.5;
        vec2 tile=floor(q), edge=min(fract(q),1.0-fract(q))*tile_size;
        float width=min(edge.x,edge.y);
        float aa=max(fwidth(width),.0008);
        float joint=1.0-smoothstep(joint_width-aa,joint_width+aa,width);
        float bevel=1.0-smoothstep(joint_width+.003-aa,joint_width+.003+aa,width);
        float tile_detail=1.0-smoothstep(min(tile_size.x,tile_size.y)*.20,min(tile_size.x,tile_size.y)*.80,footprint);
        joint*=tile_detail;bevel*=tile_detail;
        float grain=noise(p*34.0)-.5;
        color*=1.0+(hash(tile)-.5)*variation+grain*.035*near_detail;
        color=mix(color,color*.76,bevel*.16);
        color=mix(color,color*.56,joint*.48);
        if (surface_kind!=0) {
            color*=.86;
            // Low contrast mineral flecks and broad wear; detail fades with pixel footprint.
            color*=.97+noise(p*.12)*.05;
            ROUGHNESS=clamp(.89+grain*.04*near_detail,.84,.98);SPECULAR=.12;
        }
    } else if (surface_kind==2) {
        color*=.94+(noise(p*27.0)-.5)*.13*near_detail+noise(p*.1)*.025;
        ROUGHNESS=.96;SPECULAR=.10;
    } else if (surface_kind==3) {
        color=mix(color,vec3(dot(color,vec3(.2126,.7152,.0722))),.16);
        color*=.78+noise(p*.11)*.14+(noise(p*5.0)-.5)*.055*near_detail;
        ROUGHNESS=1.0;SPECULAR=.08;
    } else if (surface_kind==4) {
        color*=.83+noise(vec2(p.x*11.0,p.y*.45))*.24;
        ROUGHNESS=.77;
    } else if (surface_kind==5) {
        color*=.86+.10*noise(p*.13);
        ROUGHNESS=.28;METALLIC=.20;SPECULAR=.60;
    } else if (surface_kind==8) {
        color*=.92+(noise(p*30.0)-.5)*.09*near_detail;
        ROUGHNESS=.96;SPECULAR=.08;
    } else if (surface_kind==10) {
        color*=.68+.05*sin(p.x*.65+TIME*.6)*sin(p.y*.45-TIME*.3);
        NORMAL_MAP=vec3(.5+.025*sin(p.x*2.0+TIME*.5),.5+.02*cos(p.y*2.6-TIME*.35),1.0);
        NORMAL_MAP_DEPTH=.35;
        ROUGHNESS=.14;METALLIC=.38;SPECULAR=.70;
    } else if (surface_kind==11) {
        float rib=1.0-smoothstep(.01,.03,min(fract(p.x/.5),1.0-fract(p.x/.5))*.5);
        color*=1.0-rib*.07;ROUGHNESS=.72;METALLIC=.06;SPECULAR=.25;
    } else if (surface_kind==12) {
        // Polished interior slabs: broad joints and restrained mineral variation.
        vec2 q=p/vec2(1.8,1.2);
        vec2 edge=min(fract(q),1.0-fract(q))*vec2(1.8,1.2);
        float width=min(edge.x,edge.y);
        float joint=1.0-smoothstep(.002,max(.005,fwidth(width)*1.5),width);
        color*=.98+(noise(p*2.0)-.5)*.025-joint*.09;
        ROUGHNESS=.48;SPECULAR=.36;
    } else if (surface_kind==13) {
        // Large dark facade panels avoid miniature masonry on the metal shell.
        vec2 q=p/vec2(1.5,3.8);
        vec2 edge=min(fract(q),1.0-fract(q))*vec2(1.5,3.8);
        float width=min(edge.x,edge.y);
        float joint=1.0-smoothstep(.003,max(.008,fwidth(width)*1.5),width);
        color*=1.0-joint*.14+(noise(p*.8)-.5)*.02;
        ROUGHNESS=.65;METALLIC=.08;
    } else if (surface_kind==14) {
        color*=instance_tint.rgb*(.89+noise(world_point.xz*7.0+world_point.y)*.16);
        ROUGHNESS=.96;SPECULAR=.10;
    } else if (surface_kind==15) {
        // Large warm stone/concrete panels, not miniature brickwork across the facade.
        vec2 q=p/vec2(2.4,3.7);
        vec2 e=min(fract(q),1.0-fract(q))*vec2(2.4,3.7);
        float edge=min(e.x,e.y);
        float seam=1.0-smoothstep(.002,max(.006,fwidth(edge)*1.4),edge);
        float mineral=noise(p*.8)-.5;
        float streak=noise(vec2(p.x*7.0,p.y*.19))-.5;
        color*=1.0+mineral*.025+streak*.018-seam*.075;
        ROUGHNESS=.84;SPECULAR=.16;
    } else if (surface_kind==16) {
        vec2 lattice=fract(p/.035)-.5;
        float hole=1.0-smoothstep(.24,.39,length(lattice));
        float mesh_detail=1.0-smoothstep(.009,.05,footprint);
        color*=1.0-hole*.50*mesh_detail;
        ROUGHNESS=.72;METALLIC=.08;
    } else if (surface_kind==17) {
        EMISSION=color*.65;
        ROUGHNESS=.68;SPECULAR=.12;
    } else if (surface_kind==18) {
        // Weathered roof membrane: low reflection and fine aggregate, not reflective metal.
        color*=.93+(noise(p*8.0)-.5)*.05*near_detail+noise(p*.13)*.025;
        ROUGHNESS=.96;SPECULAR=.10;
    } else if (surface_kind==20) {
        // Administration rear: broad rectangular metal panels, not continuous ribs.
        vec2 unit=vec2(1.4,1.85);
        vec2 edge=min(fract(p/unit),1.0-fract(p/unit))*unit;
        float width=min(edge.x,edge.y);
        float seam=1.0-smoothstep(.002,max(.007,fwidth(width)*1.5),width);
        color*=1.0-seam*.10+(hash(floor(p/unit))-.5)*.016;
        ROUGHNESS=.64;METALLIC=.08;SPECULAR=.24;
    } else if (surface_kind==21) {
        // Canteen yellow mosaic: millimetre joints fade before the pattern aliases at distance.
        vec2 unit=vec2(.045);
        vec2 cell=floor(p/unit);
        vec2 edge=min(fract(p/unit),1.0-fract(p/unit))*unit;
        float width=min(edge.x,edge.y);
        float seam=1.0-smoothstep(.001,max(.0018,fwidth(width)*1.25),width);
        float detail=1.0-smoothstep(.003,.026,footprint);
        color*=1.0+((hash(cell)-.5)*.055-seam*.18)*detail;
        ROUGHNESS=.76;SPECULAR=.20;
    } else if (surface_kind==22) {
        // Start-zone painted render: broad tone variation, no masonry-grid overlay.
        color*=.985+noise(p*.18)*.025+(noise(p*24.0)-.5)*.015*near_detail;
        ROUGHNESS=.91;SPECULAR=.10;
    } else if (surface_kind==23) {
        // Long gray wood-look floor strips in the Teaching C official arcade panorama.
        vec2 unit=vec2(.18,1.2);vec2 q=p/unit;
        q.y+=mod(floor(q.x),3.0)*.3333;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float seam=1.0-smoothstep(.001,max(.004,fwidth(min(e.x,e.y))*1.4),min(e.x,e.y));
        float detail=1.0-smoothstep(.028,.16,footprint);
        float grain=noise(vec2(p.x*65.0,p.y*1.7))-.5;
        color*=.94+(hash(floor(q))-.5)*.12+grain*.10*near_detail-seam*.14*detail;
        ROUGHNESS=.65;SPECULAR=.22;
    } else if (surface_kind==24) {
        // Warm pressed-wood wall: short irregular strands, not long timber stripes.
        float strands=noise(vec2(p.x*53.0+p.y*24.0,p.y*8.0-p.x*3.0))-.5;
        float crossgrain=noise(vec2(p.y*41.0-p.x*18.0,p.x*7.0+p.y*2.0))-.5;
        color*=.98+(strands*.17+crossgrain*.10)*near_detail;
        ROUGHNESS=.93;SPECULAR=.10;
    } else if (surface_kind==25) {
        // Dense neutral carpet in the G collaborative room, without stone joints.
        color*=.95+(noise(p*64.0)-.5)*.12*near_detail+noise(p*.5)*.04;
        ROUGHNESS=1.0;SPECULAR=.06;
    }
    if (research_ground_blend) {
        // Smooth ground-cover boundary in building space; never select whole large
        // terrain triangles by their centre, which produced conspicuous saw teeth.
        vec2 delta=world_point.xz-research_origin.xz;
        vec2 q=vec2(research_axis.x*delta.x-research_axis.y*delta.y,
                    research_axis.y*delta.x+research_axis.x*delta.y);
        float rear=min(min(q.x+76.0,67.0-q.x),min(q.y+91.0,-65.0-q.y));
        float side=min(min(q.x+95.0,-75.0-q.x),min(q.y+60.0,57.0-q.y));
        float edge=max(rear,side)+(noise(world_point.xz*.36)-.5)*1.2;
        float cover=smoothstep(-2.0,2.0,edge);
        vec3 floor_color=mix(vec3(.135,.16,.09),vec3(.23,.25,.145),noise(world_point.xz*.5));
        floor_color*=.94+noise(world_point.xz*8.0)*.10;
        color=mix(color,floor_color,cover);
        SPECULAR=mix(SPECULAR,.06,cover);
        ROUGHNESS=mix(ROUGHNESS,1.0,cover);
    }
    if (shaw_ground_blend) {
        // V244 feather the planted slope on existing terrain without changing triangles.
        float boundary=171.0+sin((world_point.z+510.0)*.045)*4.0;
        float edge=min(min(world_point.x-boundary,238.0-world_point.x),
                       min(world_point.z+579.0,-472.0-world_point.z));
        float cover=smoothstep(-2.5,3.5,edge+(noise(world_point.xz*.27)-.5)*1.4);
        vec3 soil=mix(vec3(.145,.16,.085),vec3(.215,.23,.135),noise(world_point.xz*.35));
        soil*=.96+noise(world_point.xz*13.0)*.08;
        color=mix(color,soil,cover);ROUGHNESS=mix(ROUGHNESS,1.0,cover);
        SPECULAR=mix(SPECULAR,.06,cover);
    }
    ALBEDO=color;
}
