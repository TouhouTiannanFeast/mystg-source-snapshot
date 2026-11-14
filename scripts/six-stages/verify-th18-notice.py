from pathlib import Path
import sys,hashlib,json
sys.path.insert(0,'G:/MySTG/work/six-stages-tools')
from lupa.lua51 import LuaRuntime
R=Path('G:/MySTG');M=R/'aex-0.8.22/game/mod/SixStageCampaign';O=R/'work/logs/six-stages/card-notice-20261113'
s=(M/'campaign.lua').read_text('utf-8');root=(M/'root.lua').read_text('utf-8');l=LuaRuntime()
for name in ['campaign.lua','root.lua']:l.execute('assert(loadstring(...))',(M/name).read_text('utf-8'))
for name in ['notice','ok00']:
 assert (M/'se'/('th18-'+name+'.wav')).read_bytes()==(O/'source'/('se_'+name+'.wav')).read_bytes()
block=s[s.index(' if C.reward then',s.index('FrameFunc=function')):s.index(' if press(KEY.F6)',s.index('FrameFunc=function'))]
l.execute("C={reward={age=0,blocked=true}};KEY={Z=90,ENTER=13};setting={};down=true;sounds={};stage={Set=function(...) ended=true end};function GetKeyState(k)return down end;function PlaySound(s,...)sounds[#sounds+1]=s end")
f=l.execute('return function() '+block+' end')
for _ in range(40):f()
assert l.eval('C.reward.exit==nil')
l.execute('down=false');f();l.execute('down=true');f()
assert l.eval("C.reward.exit==1 and #sounds==1 and sounds[1]=='six.notice.confirm'")
for _ in range(29):f()
assert l.eval('C.reward==nil and ended and #sounds==1')
render=s[s.index('  -- Original notice.anm'):s.index('\n end\n if C.select then',s.index('  -- Original notice.anm'))]
assert 'six.cards18.orb'not in render and 'RenderTTF'not in render
assert "PlaySound('six.notice.appear',1,0,true)"in s
l.execute("C={reward={age=0}};r=C.reward;function Color(...)return {...}end;function SetImageState(...)end;function RenderRect(...)end;function Render(...)end")
rf=l.execute('return function()local r=C.reward '+render+' end')
for age in [0,15,30,70]:l.execute('C.reward={age=...}',age);rf()
for age in [1,15,29]:l.execute('C.reward={age=80,exit=...}',age);rf()
(O/'verify-port.log').write_text('PASS original sound bytes; Lua51; held-key rejection, fresh Z/Enter confirmation, exactly one confirm cue,30f exit/handoff; entry/hold/exit renderer; no orb/custom caption.\n','utf-8')
print('PASS TH18 notice targeted lifecycle/assets/render')
