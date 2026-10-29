$ErrorActionPreference='Stop'
$game='G:\MySTG\aex-0.8.22\game'
$root=Join-Path $game 'mod\YuyukoStage3\root.lua'
$settings=Join-Path $game 'userdata\setting.json'
if(Get-Process LuaSTGSub -ErrorAction SilentlyContinue){throw 'Running game preserved'}
$before=[IO.File]::ReadAllBytes($settings);$code=[IO.File]::ReadAllBytes($root)
try{
$probe=@'
player_lib.debug_data.keep_shooting=true
local render=RenderFunc;local done=false;local enabled=false
RenderFunc=function()
 render()
 if Le03 and Le03.tick>1100 then
  for _,o in ObjList(GROUP_ENEMY)do
   if o.data and o.data.appear and GetAttr(o,'colli')then enabled=true end
  end
  if Le03.tick>=1750 and not done then
   done=true
   assert(enabled,'Road engine collision never enabled')
   assert(Le03.counts.damage>0,'Real player shots did no road damage')
   print('DAMAGE12 PASS actual_player_damage='..Le03.counts.damage..' defeats='..Le03.counts.defeats..' collision_enabled='..tostring(enabled))
   lstg.Snapshot('userdata/snapshot/damage12-road.jpg');stage.QuitGame()
  end
 end
end
local frame=DoFrame;DoFrame=function(...)for i=1,4 do frame(...)end end
'@
[IO.File]::AppendAllText($root,"`n"+$probe,[Text.UTF8Encoding]::new($false))
$args="setting.mod='YuyukoStage3';setting.y3_full=true;setting.y3_entry='road-1100';setting.y3_practice='all';setting.y3_invincible=true;setting.y3_test=false;setting.windowed=true;start_game=true"
$p=Start-Process (Join-Path $game 'LuaSTGSub.exe') -WorkingDirectory $game -ArgumentList ('"'+$args+'"') -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(45000)){throw 'Probe timeout, process retained'}
Copy-Item (Join-Path $game 'engine.log') 'G:\MySTG\work\logs\yuyuko3\damage12-native.log'
$log=Get-Content 'G:\MySTG\work\logs\yuyuko3\damage12-native.log' -Raw
if($p.ExitCode-ne0 -or $log-notmatch'DAMAGE12 PASS'){throw 'Probe failed; see damage12-native.log'}
Copy-Item (Join-Path $game 'userdata\snapshot\damage12-road.jpg') 'G:\MySTG\work\logs\yuyuko3\damage12-road.jpg'
Select-String -InputObject $log -Pattern 'DAMAGE12 PASS[^\r\n]*' -AllMatches | ForEach-Object {$_.Matches.Value}
}finally{[IO.File]::WriteAllBytes($root,$code);[IO.File]::WriteAllBytes($settings,$before)}
