-- TH09 retail world06 STD/ANM reconstruction; native audit NINA6-10.
NinaWorld06 = {}
local W = NinaWorld06
local pi = math.pi
LoadTexture('nina.world06.cloud', 'scenery/art/stg4bg3.png')
LoadImage('nina.world06.cloud', 'nina.world06.cloud', 1, 1, 254, 254)
LoadTexture('nina.world06.parts', 'scenery/art/stg4bg4.png')
LoadImage('nina.world06.pillar', 'nina.world06.parts', 1, 1, 126, 254)
LoadImage('nina.world06.cap', 'nina.world06.parts', 1, 1, 126, 126)
LoadImage('nina.world06.gate', 'nina.world06.parts', 129, 1, 382, 510)
LoadTexture('nina.world06.sigil', 'scenery/art/stg4bg5.png')
LoadImage('nina.world06.sigil', 'nina.world06.sigil', 1, 1, 254, 254)

local function rot(x, y, z, r)
    local c, s = math.cos(r[1]), math.sin(r[1]); y, z = y * c - z * s, y * s + z * c
    c, s = math.cos(r[2]), math.sin(r[2]); x, z = x * c + z * s, -x * s + z * c
    c, s = math.cos(r[3]), math.sin(r[3]); return x * c - y * s, x * s + y * c, z
end

-- Native 0x43b1a0 applies rotations to local vertices, then translation.
-- ANM31 selects the 3D projection (0x437ad6 / 0x439fd2), not billboarding.
local function face(image, x, y, z, w, h, rotation, colour, blend, anchored)
    local v = anchored and {{0,0},{w,0},{w,-h},{0,-h}}
        or {{-w/2,-h/2},{w/2,-h/2},{w/2,h/2},{-w/2,h/2}}
    local p = {}
    for i = 1, 4 do
        local a,b,c = rot(v[i][1],v[i][2],0,rotation or {0,0,0})
        p[i] = {x+a,y+b,z+c}
    end
    SetImageState(image, blend or '', colour)
    Render4V(image,p[1][1],p[1][2],p[1][3],p[2][1],p[2][2],p[2][3],
        p[3][1],p[3][2],p[3][3],p[4][1],p[4][2],p[4][3])
end

-- world06.std entry 1 instances (cloud bands)
local clouds = {1050, 918, 794, 672, 540, 410, 278, 154, 32, -100, -230, -360, -490, -620, -750, -880, -1010, -1140, -1270}
-- entry 2: four pillar faces and their two ANM instance depths
local pillarQuads = {
    {-83, 13, 64, 26, 320, {pi / 2, 0, pi / 2}, {48, 48, 48}},
    {83, 13, 64, 26, 320, {pi / 2, 0, -pi / 2}, {160, 160, 160}},
    {-94, 0, 64, 28, 320, {pi / 2, 0, 0}, {104, 104, 104}},
    {94, 0, 64, 28, 320, {pi / 2, 0, 0}, {104, 104, 104}},
}
local pillarInstances = {672, 540}

local function lerp(a, b, u) return a + (b - a) * u end
-- STD14..18: cubic Hermite with zero endpoint derivatives, 1000f each.
-- STD33(4): native 0x4020db, period 2048f, radius30 orbit and up.x sway.
-- The apparent horizontal pan is this camera orbit, not player tracking.
function W.camera(t)
    local u = (t % 1000) / 1000; u = u*u*(3-2*u)
    local ey,ez
    if t % 2000 < 1000 then ey,ez=lerp(-200,0,u),lerp(-250,-350,u)
    else ey,ez=lerp(0,-200,u),lerp(-350,-250,u) end
    local angle=(t % 2048)*.003067961661145091-pi
    local sn=math.sin(angle)
    local ex=30*sn
    return ex,ey,ez+30*math.cos(angle),0,ey+400,ez+200,-.1*sn,1,0
end

-- ANM34 mode4 is quadratic acceleration, not a cosine wave.
function W.alpha(t,script)
    local u=(t%120)/120;u=u*u
    if script==6 then
        if t%240<120 then return lerp(96,48,u) end
        return lerp(48,96,u)
    end
    -- First leg deliberately holds at64; the steady loop starts at32.
    if t<120 then return 64 end
    if t%240<120 then return lerp(32,64,u) end
    return lerp(64,32,u)
end
W.Object = Class(background)
function W.Object:init()
    background.init(self, false); self.bound = false
end
function W.Object:render()
    if self.ninaHidden then return end
    local t=(NinaScenery and NinaScenery.host and NinaScenery.host.timer) or self.timer
    local ex,ey,ez,ax,ay,az,ux,uy,uz=W.camera(t)
    Set3D('eye',ex,ey,ez);Set3D('at',ax,ay,az);Set3D('up',ux,uy,uz)
    Set3D('fovy',.6283185482);Set3D('z',30,1800)
    Set3D('fog',800,1200,Color(255,144,122,128))
    SetViewMode('3d')
    -- Retail is a 288x448 field; stretch that field to the mod viewport.
    SetPerspective(ex,ey,ez,ax,ay,az,ux,uy,uz,.6283185482,288/448,30,1800)
    SetZBufferEnable(1);RenderClear(Color(255,144,122,128));ClearZBuffer()
    local white=Color(255,255,255,255)
    face('nina.world06.gate',0,918,64,512,800,{pi/2,0,0},white)
    face('nina.world06.sigil',0,878,64,470,470,{pi/2,-t*.0007853982,0},Color(W.alpha(t,7),255,255,255),'mul+add')
    face('nina.world06.sigil',0,838,64,370,370,{pi/2,t*.0015707964,0},Color(W.alpha(t,6),255,255,255),'mul+add')
    for _,iy in ipairs(pillarInstances)do
        for _,q in ipairs(pillarQuads)do
            face('nina.world06.pillar',q[1],q[2]+iy,q[3],q[4],q[5],q[6],Color(255,q[7][1],q[7][2],q[7][3]))
        end
        face('nina.world06.cap',-96,iy+13,-94,26,26,{0,0,0},white)
        face('nina.world06.cap',96,iy+13,-94,26,26,{0,0,0},white)
    end
    -- Native 0x40364e: opaque layer0 first, translucent cloud layer1 second.
    -- Cloud depth tests retain architecture occlusion; no depth writes.
    -- ANM0 is the sole screen-facing sprite (ins25=2), anchored top-left.
    -- Its local screen-up basis follows the camera; no rotation of its origin.
    local dx,dy,dz=ax-ex,ay-ey,az-ez
    local len=math.sqrt(dx*dx+dy*dy+dz*dz)
    local fx,fy,fz=dx/len,dy/len,dz/len
    local rx,ry,rz=uy*fz-uz*fy,uz*fx-ux*fz,ux*fy-uy*fx
    local rl=math.sqrt(rx*rx+ry*ry+rz*rz);rx,ry,rz=rx/rl,ry/rl,rz/rl
    local vx,vy,vz=fy*rz-fz*ry,fz*rx-fx*rz,fx*ry-fy*rx
    SetFog() -- projected ANM mode2 applies distance fog to diffuse/alpha itself
    for _,iy in ipairs(clouds)do
        local x,y,z=-280,iy,-100
        local distance=math.sqrt((x-ex)^2+(y-ey)^2+(z-ez)^2)
        local fog=math.max(0,math.min(1,(distance-800)/400))
        if fog<1 then
            SetImageState('nina.world06.cloud','',Color(128*(1-fog),lerp(255,144,fog),lerp(255,122,fog),lerp(255,128,fog)))
            local p={}
            -- Native mode2 recomputes a uniform scale from projected width,
            -- overwriting the STD height scale (0x4030c4..0x4030cf).
            local size=680*680/254
            for i,q in ipairs({{0,0},{size,0},{size,-size},{0,-size}})do
                p[i]={x+rx*q[1]+vx*q[2],y+ry*q[1]+vy*q[2],z+rz*q[1]+vz*q[2]}
            end
            Render4V('nina.world06.cloud',p[1][1],p[1][2],p[1][3],p[2][1],p[2][2],p[2][3],p[3][1],p[3][2],p[3][3],p[4][1],p[4][2],p[4][3])
        end
    end
    SetZBufferEnable(0);SetViewMode('world')
end
