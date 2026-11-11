"""Focused verification for the temporary campaign road-clear bonus.

Checks that each stage's road completion spawns exactly 2 life and 3 bomb
pickups, once per stage, and that practice/boss-only entries do not trigger it.
Runs on Lua 5.1, LuaJIT 2.1 and Lua 5.4. Does not launch the game.
"""
from pathlib import Path
import sys

sys.path.insert(0, 'G:/MySTG/work/six-stages-tools')

ROOT = Path('G:/MySTG')
MOD = ROOT / 'aex-0.8.22/game/mod/SixStageCampaign'
LOG = ROOT / 'work/logs/six-stages/road-bonus'
LOG.mkdir(parents=True, exist_ok=True)

source = (MOD / 'road-bonus.lua').read_text(encoding='utf-8-sig')

STUBS = r'''
spawned={}
function New(cls,x,y)spawned[#spawned+1]={cls=cls,x=x,y=y}end
item_extend={tag='life'}
item_bomb={tag='bomb'}
lstg={world={l=-192,r=192,t=-224,b=224}}
setting={stage12_entry=nil,y3_entry='full',marisa_road=true,hsob5_boss_only=false,nina_phase='all'}
function AfterFrame()end
SixStageCampaign={index=0,install=function()end,controllerAfter=AfterFrame}
'''

TESTS = r'''
local B=SixStageCampaignRoadBonus
local function count()
 local life,bomb=0,0
 for _,o in ipairs(spawned)do if o.cls==item_extend then life=life+1 elseif o.cls==item_bomb then bomb=bomb+1 end end
 return life,bomb
end
local function expect(totalLife,totalBomb,label)
 local l,b=count()
 assert(l==totalLife and b==totalBomb,label..' life='..l..' bomb='..b)
end

-- Stage 1: final-boss label marks road completion.
SixStageCampaign.install(1);SixStageCampaign.index=1;th14={label='Wakasagihime'}
AfterFrame();expect(2,3,'stage1')
AfterFrame();expect(2,3,'stage1 duplicate')
SixStageCampaign.install(1);AfterFrame();expect(4,6,'stage1 rerun')

-- Stage 2: Mamizou phase marks road completion.
SixStageCampaign.install(2);SixStageCampaign.index=2;Stage2Route={phase='Mamizou'}
AfterFrame();expect(6,9,'stage2')

-- Stage 3: seen-active -> inactive marks the Yuyuko road end.
SixStageCampaign.install(3);SixStageCampaign.index=3;Y3Road={active=true}
AfterFrame();expect(6,9,'stage3 active')
Y3Road.active=false
AfterFrame();expect(8,12,'stage3 done')
AfterFrame();expect(8,12,'stage3 duplicate')

-- Stage 4: entry phase follows the natural road drain.
SixStageCampaign.install(4);SixStageCampaign.index=4;MarisaRoad14={state={phase='entry'}}
AfterFrame();expect(10,15,'stage4')

-- Stage 5: HSoB road finished; boss-only skips.
SixStageCampaign.install(5);SixStageCampaign.index=5;HSoB5={finished=true}
AfterFrame();expect(12,18,'stage5')
SixStageCampaign.install(5);setting.hsob5_boss_only=true
AfterFrame();expect(12,18,'stage5 boss-only')

-- Stage 6: road-wait precedes the boss.
setting.hsob5_boss_only=false
SixStageCampaign.install(6);SixStageCampaign.index=6;NinaState={current='road-wait'}
AfterFrame();expect(14,21,'stage6')

-- Practice entries must not trigger.
setting.stage12_entry='s1-non1';SixStageCampaign.install(1);SixStageCampaign.index=1;th14={label='Wakasagihime'}
AfterFrame();expect(14,21,'stage1 practice')
print('PASS road bonus behavior')
'''


def run_lua(module_name, label):
    module = __import__(module_name, fromlist=['LuaRuntime'])
    lua = module.LuaRuntime()
    lua.execute(STUBS)
    lua.execute(source)
    lua.execute(TESTS)
    print('PASS', label)


def main():
    run_lua('lupa.lua51', 'Lua 5.1')
    run_lua('lupa.luajit21', 'LuaJIT 2.1')
    run_lua('lupa.lua54', 'Lua 5.4')
    print('PASS all road-bonus checks')


if __name__ == '__main__':
    main()

