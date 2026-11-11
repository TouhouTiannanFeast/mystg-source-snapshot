"""Focused verification for the campaign-only player-shot hit effects.

Checks source-derived sprites and per-shot behavior: TH10 Reimu B main spark,
TH10 Reimu B needle trail, TH13 ofuda spark, stage selection, one effect per
pair, protected/charm exclusion handling and cleanup. Runs on Lua 5.1,
LuaJIT 2.1 and Lua 5.4. Does not launch the game.
"""
from pathlib import Path
import hashlib
import json
import sys

sys.path.insert(0, 'G:/MySTG/work/six-stages-tools')

ROOT = Path('G:/MySTG')
MOD = ROOT / 'aex-0.8.22/game/mod/SixStageCampaign'
ORIGINAL = Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/'
                '20261010-all-works/th10_1fb1d0ffe3/sprites')
ORIGINAL13 = Path('G:/TouHou/MLforDanmu/data/local/bullet-assets/'
                  '20261010-all-works/th13_3443fe0df1/sprites')
LOG = ROOT / 'work/logs/six-stages/hit-effect'
LOG.mkdir(parents=True, exist_ok=True)

source = (MOD / 'hit-effect.lua').read_text(encoding='utf-8-sig')

STUBS = r'''
object={}
function Class(base)
    local c={base=base}
    setmetatable(c,{__index=base})
    return c
end
GROUP_PLAYER_BULLET=3;GROUP_ENEMY=4;GROUP_NONTJT=5;GROUP_GHOST=6
LAYER_PLAYER_BULLET=7
function Color(a,r,g,b)return{a=a,r=r,g=g,b=b}end
function LoadTexture()end
function LoadImage()end
imageStates={}
function SetImageState(name,blend,color)imageStates[#imageStates+1]=name;lastBlend=blend;lastColor=color end
renderCount=0
function Render(...)renderCount=renderCount+1;lastRender={...}end
spawned={}
function New(cls,...)
    local o=setmetatable({class=cls,timer=0},cls)
    if cls.init then cls.init(o,...) end
    spawned[#spawned+1]=o
    return o
end
function Del(o)
    if o.class and o.class.del then o.class.del(o) end
end
function IsValid(o)return o~=nil end
SixStageCampaign={install=function()end}
enemybase={colli=function()end}
enemy={base=enemybase}
boss={base=enemybase}
'''

TESTS = r'''
local H=SixStageCampaignHit
assert(H and type(H.install)=='function','hit effect module missing')
SixStageCampaign.install(1,{})
assert(type(rawget(enemybase,'colli'))=='function','enemybase hook missing')
assert(H.mainImages[1]=='six.hit10.0','stage1 main set')

local function enemy(hp,protect,group)
    return {group=group or GROUP_ENEMY,hp=hp or 10,protect=protect or false,colli=true}
end
local function shot(x,y,vx,img)
    return {group=GROUP_PLAYER_BULLET,dmg=2,x=x or 1,y=y or 2,vx=vx or 24,vy=0,img=img or 'stage12.main'}
end

-- Main shot: TH10 Reimu B main spark, 30 frames, 1/8 velocity.
local e=enemy()
local b=shot(5,6)
enemybase.colli(e,b)
assert(#spawned==1,'main hit did not spawn')
assert(spawned[1].images[1]=='six.hit10.0','main hit did not use TH10 main set')
assert(spawned[1].x==5 and spawned[1].y==6,'spawn position')
assert(math.abs(spawned[1].vx-3)<1e-9 and spawned[1].vy==0,'1/8 velocity')
assert(spawned[1].life==30,'30 frame main life')
assert(H.count==1,'active count after first hit')

enemybase.colli(e,b)
assert(#spawned==1,'same bullet/enemy spawned twice')

enemybase.colli(e,shot(7,8))
assert(#spawned==2,'second bullet did not spawn')

enemybase.colli(enemy(10,true),shot(9,10))
assert(#spawned==2,'protected enemy spawned')

local marisaBoss=enemy();marisaBoss.mmPhaseAge=10
enemybase.colli(marisaBoss,shot(12,13))
assert(#spawned==2,'Marisa source spark doubled')

local noDamage=shot(13,14);noDamage.dmg=0
enemybase.colli(enemy(),noDamage)
assert(#spawned==2,'zero-damage shot spawned')

local playerBody={group=GROUP_GHOST,dmg=2,x=1,y=1}
enemybase.colli(enemy(),playerBody)
assert(#spawned==2,'non-bullet group spawned')

-- Needle: TH10 Reimu B script12 uses the needle image itself, 20 frames.
local nb=shot(15,16,24,'stage12.pierce')
nb.killflag=true;nb.rot=90
enemybase.colli(enemy(),nb)
assert(#spawned==3,'needle hit did not spawn')
local nsp=spawned[3]
assert(nsp.rot==90,'needle orientation')
assert(nsp.life==20,'needle life')
imageStates={}
nsp.timer=0;nsp.class.render(nsp)
assert(imageStates[#imageStates]=='six.needle','needle did not use dedicated art')
for _,name in ipairs(imageStates) do
    assert(name~='stage12.pierce' and name~='y3.player.pierce','needle effect touched live bullet image state')
end
assert(nsp.timer==0,'needle render changed timer')
nsp.timer=19;nsp.class.render(nsp)
nsp.timer=20;nsp.class.frame(nsp)
assert(H.active[nsp]==nil,'needle cleanup')

-- Ofuda: unchanged TH13 row160 sprites, authored12f impact/fade.
local ob=shot(17,18,24,'hs5.player.charm');ob.rot=37
enemybase.colli(enemy(),ob)
assert(#spawned==4,'ofuda hit did not spawn')
assert(spawned[4].images[1]=='six.hit13.0','ofuda did not use TH13 row160 set')
assert(spawned[4].life==12,'ofuda life')
local of=spawned[4];local alpha=255
for _,tick in ipairs({0,4,8,11})do
 of.timer=tick;of.class.render(of)
 assert(lastBlend=='mul+add' and lastColor.a<alpha and lastRender[4]==37,'ofuda fade/orientation')
 alpha=lastColor.a
end
assert(spawned[4].vx==0 and spawned[4].vy==0,'ofuda should be stationary')

-- Main spark render frames 0/10/20 and cleanup.
local s=spawned[1]
imageStates={};local rc=renderCount
s.timer=0;s.class.render(s);assert(renderCount==rc+1)
assert(imageStates[#imageStates]=='six.hit10.0','frame0 image')
s.timer=9;s.class.render(s);assert(imageStates[#imageStates]=='six.hit10.0','frame0 held')
s.timer=10;s.class.render(s);assert(imageStates[#imageStates]=='six.hit10.1','frame1 image')
s.timer=19;s.class.render(s);assert(imageStates[#imageStates]=='six.hit10.1','frame1 held')
s.timer=20;s.class.render(s);assert(imageStates[#imageStates]=='six.hit10.2','frame2 image')
s.timer=29;s.class.render(s);assert(imageStates[#imageStates]=='six.hit10.2','frame2 held')
s.timer=30;s.class.frame(s)
assert(H.active[s]==nil,'main spark cleanup')

-- Stage 3: TH13 main set, TH13 ofuda set, homing source effect suppressed.
local homingKills=0
Y3Player={Homing={kill=function()homingKills=homingKills+1 end}}
local Custom={base=enemybase}
function Custom:colli(other)return enemybase.colli(self,other)end
SixStageCampaign.install(3,{Custom})
assert(H.count==0,'stage install did not clear effects')
assert(H.mainImages[1]=='six.hit13m.0','stage3 main did not use TH13 main set')
assert(Y3Player.Homing.sixHitEffectReplaced,'homing source effect not replaced')
Y3Player.Homing.kill({})
assert(homingKills==0,'source charm effect still ran')

local ce=enemy();local cb=shot(19,20,24,'y3.player.main')
Custom.colli(ce,cb)
assert(#spawned==5,'stage3 main did not spawn')
assert(spawned[5].images[1]=='six.hit13m.0','stage3 main set not retained')

local cb2=shot(21,22,24,'y3.player.pierce');cb2.killflag=true;cb2.rot=90
Custom.colli(enemy(),cb2)
assert(#spawned==6 and spawned[6].rot==90,'stage3 needle asset')
imageStates={}
spawned[6].timer=0;spawned[6].class.render(spawned[6])
assert(imageStates[#imageStates]=='six.needle','stage3 needle dedicated art')

local cb3=shot(23,24,24,'hs5.player.charm')
Custom.colli(enemy(),cb3)
assert(#spawned==7 and spawned[7].images[1]=='six.hit13.0','stage3 ofuda asset')

H.clear()
assert(H.count==0,'clear did not reset count')
print('PASS hit effect behavior')
'''


def run_lua(module_name, label):
    module = __import__(module_name, fromlist=['LuaRuntime'])
    lua = module.LuaRuntime()
    lua.execute(STUBS)
    lua.execute(source)
    lua.execute(TESTS)
    print('PASS', label)


def verify_assets():
    reference = json.loads((MOD / 'source-reference.json').read_text(encoding='utf-8'))
    assets = reference['hit_effect']['assets']
    sets = [
        ('th10', ORIGINAL, 25),
        ('th13', ORIGINAL13, 32),
    ]
    for prefix, folder, first in sets:
        for i in range(3):
            name = f'{prefix}-hit-{i}.png'
            ours = MOD / 'art' / name
            original = folder / f'pl00.entry0.sprite{first + i}.png'
            assert ours.read_bytes() == original.read_bytes(), f'{name} is not the original sprite'
            digest = hashlib.sha256(ours.read_bytes()).hexdigest()
            assert digest in assets['art/' + name], f'{name} hash missing from provenance'
            print(f'PASS {name} {digest}')

    needle = MOD / 'art/th10-needle.png'
    needle_src = ORIGINAL / 'pl00.entry0.sprite28.png'
    assert needle.read_bytes() == needle_src.read_bytes(), 'needle art is not TH10 sprite28'
    needle_hash = hashlib.sha256(needle.read_bytes()).hexdigest()
    assert needle_hash in assets['art/th10-needle.png'], 'needle hash missing from provenance'
    print(f'PASS th10-needle.png {needle_hash}')

    # TH13 script10 (main shot) hit frames are TH13 sprites 26..28; they are
    # byte-identical to TH10 sprites 25..27, proving the shared main set.
    for i in range(3):
        main = ORIGINAL13 / f'pl00.entry0.sprite{26 + i}.png'
        ours = MOD / 'art' / f'th10-hit-{i}.png'
        assert ours.read_bytes() == main.read_bytes(), f'TH13 main frame {i} mismatch'
    assert hashlib.sha256((ROOT / 'aex-0.8.22/game/mod/YuyukoStage3/art/player/th13-pl00.png').read_bytes()).hexdigest() == \
        '4e6db7395cffddd68c8b67ef2c07667806cd2321a3aa69caf6dd9ead9750438a'
    print('PASS TH13 main frames and player atlas')

    assert (MOD / 'root.lua').read_text(encoding='utf-8').find(
        "Include('mod/SixStageCampaign/hit-effect.lua')") >= 0
    print('PASS root include')


def main():
    verify_assets()
    run_lua('lupa.lua51', 'Lua 5.1')
    run_lua('lupa.luajit21', 'LuaJIT 2.1')
    run_lua('lupa.lua54', 'Lua 5.4')
    print('PASS all hit-effect checks')


if __name__ == '__main__':
    main()
