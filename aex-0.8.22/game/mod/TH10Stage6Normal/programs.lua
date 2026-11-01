-- Generated from stage06 ECL; Normal only.
TH10S6Programs={th10={}};local P=TH10S6Programs.th10;local R=TH10S6Runtime
P["BCir00"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{2}) end},
{t=0,run=function(a,e) R.call(a,"Cir00",{49, 45}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["BCir01"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{2}) end},
{t=0,run=function(a,e) R.call(a,"Cir01",{49, 45}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["BCir01b"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{2}) end},
{t=0,run=function(a,e) R.call(a,"Cir01b",{49, 45}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["BGirl00"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{2}) end},
{t=0,run=function(a,e) R.call(a,"Girl00",{20, 45}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["Cir00"]={params={"A","B"},ops={
{t=0,run=function(a,e) R.command(a,e,"anmSelect",{1}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetSprite",{0, e.i.A}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetSprite",{1, e.i.B}) end},
{t=0,run=function(a,e) R.command(a,e,"flagSet",{32}) end},
{t=0,run=function(a,e) R.command(a,e,"setHurtbox",{24.0, 24.0}) end},
{t=0,run=function(a,e) R.command(a,e,"setHitbox",{16.0, 16.0}) end},
{t=0,run=function(a,e) R.command(a,e,"moveVel",{1.5707964, 3.0}) end},
{t=0,run=function(a,e) R.spawn(a,"Cir00_at",{},-1) end},
{t=60,run=function(a,e) R.command(a,e,"moveVelTime",{40, 0, -0.7853982, 1.5}) end},
{t=6060,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=6060,run=function(a,e) return 0 end}
}}
P["Cir00_at"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"etNew",{0}) end},
{t=0,run=function(a,e) R.command(a,e,"etAim",{0, 2}) end},
{t=0,run=function(a,e) R.command(a,e,"etSprite",{0, 1, 6}) end},
{t=0,run=function(a,e) R.command(a,e,"etCountD",{0, 3, 3, 7, 11, 1, 1, 1, 1}) end},
{t=0,run=function(a,e) R.command(a,e,"etAngle",{0, 0.0, 0.06544985}) end},
{t=0,run=function(a,e) R.command(a,e,"etSpeedD",{0, 2.4, 4.0, 5.0, 6.0, 1.0, 1.0, 1.0, 1.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etEx",{0, 0, 1, 4, -999999, -999999, -999999.0, -999999.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etEx",{0, 0, 1, 1, -999999, -999999, -999999.0, -999999.0}) end},
{t=0,run=function(a,e) R.command(a,e,"wait",{(R.value(a,"RAND") % 60) + 30}) end},
{t=0,run=function(a,e) if true then return 13,0 end end},
{t=0,run=function(a,e) R.command(a,e,"etOn",{0}) end},
{t=0,run=function(a,e) R.command(a,e,"diffWait",{(R.value(a,"RAND") % 60) + 90, 60, 30, 20}) end},
{t=0,run=function(a,e) if R.truth(1) then return 11,0 end end},
{t=0,run=function(a,e) return 0 end}
}}
P["Cir01"]={params={"A","B"},ops={
{t=0,run=function(a,e) R.command(a,e,"anmSelect",{1}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetSprite",{0, e.i.A}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetSprite",{1, e.i.B}) end},
{t=0,run=function(a,e) R.command(a,e,"flagSet",{32}) end},
{t=0,run=function(a,e) R.command(a,e,"setHurtbox",{24.0, 24.0}) end},
{t=0,run=function(a,e) R.command(a,e,"setHitbox",{16.0, 16.0}) end},
{t=0,run=function(a,e) R.command(a,e,"moveVel",{0.0, 4.0}) end},
{t=0,run=function(a,e) R.spawn(a,"Cir01_at",{},-1) end},
{t=60,run=function(a,e) R.command(a,e,"moveVelTime",{40, 0, -0.3926991, -999999.0}) end},
{t=6060,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=6060,run=function(a,e) return 0 end}
}}
P["Cir01_at"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"etNew",{0}) end},
{t=0,run=function(a,e) R.command(a,e,"etAim",{0, 2}) end},
{t=0,run=function(a,e) R.command(a,e,"etSprite",{0, 3, 6}) end},
{t=0,run=function(a,e) R.command(a,e,"etCountD",{0, 24, 48, 48, 48, 1, 1, 2, 3}) end},
{t=0,run=function(a,e) R.command(a,e,"etAngle",{0, 0.0, 0.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etSpeedD",{0, 1.0, 1.0, 2.0, 3.0, 1.0, 1.0, 1.0, 1.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etEx",{0, 0, 1, 4, -999999, -999999, -999999.0, -999999.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etEx",{0, 0, 1, 1, -999999, -999999, -999999.0, -999999.0}) end},
{t=0,run=function(a,e) R.command(a,e,"wait",{60 + (R.value(a,"RAND") % 60)}) end},
{t=0,run=function(a,e) if true then return 13,0 end end},
{t=0,run=function(a,e) R.command(a,e,"etOn",{0}) end},
{t=0,run=function(a,e) R.command(a,e,"wait",{60}) end},
{t=0,run=function(a,e) if R.truth(1) then return 11,0 end end},
{t=0,run=function(a,e) return 0 end}
}}
P["Cir01b"]={params={"A","B"},ops={
{t=0,run=function(a,e) R.command(a,e,"anmSelect",{1}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetSprite",{0, e.i.A}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetSprite",{1, e.i.B}) end},
{t=0,run=function(a,e) R.command(a,e,"flagSet",{32}) end},
{t=0,run=function(a,e) R.command(a,e,"setHurtbox",{24.0, 24.0}) end},
{t=0,run=function(a,e) R.command(a,e,"setHitbox",{16.0, 16.0}) end},
{t=0,run=function(a,e) R.command(a,e,"moveVel",{0.0, 4.0}) end},
{t=0,run=function(a,e) R.spawn(a,"Cir01_at",{},-1) end},
{t=60,run=function(a,e) R.command(a,e,"moveVelTime",{40, 0, 0.3926991, 1.5}) end},
{t=6060,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=6060,run=function(a,e) return 0 end}
}}
P["GCir00"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{3}) end},
{t=0,run=function(a,e) R.call(a,"Cir00",{51, 47}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["GCir01"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{3}) end},
{t=0,run=function(a,e) R.call(a,"Cir01",{51, 47}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["GCir01b"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{3}) end},
{t=0,run=function(a,e) R.call(a,"Cir01b",{51, 47}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["Girl00"]={params={"A","B"},ops={
{t=0,run=function(a,e) R.command(a,e,"anmSelect",{1}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetSprite",{0, e.i.A}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetSprite",{1, e.i.B}) end},
{t=0,run=function(a,e) R.command(a,e,"flagSet",{36}) end},
{t=0,run=function(a,e) R.command(a,e,"setHurtbox",{24.0, 24.0}) end},
{t=0,run=function(a,e) R.command(a,e,"setHitbox",{16.0, 16.0}) end},
{t=0,run=function(a,e) R.command(a,e,"dropClear",{}) end},
{t=0,run=function(a,e) R.command(a,e,"dropExtra",{2, 2}) end},
{t=0,run=function(a,e) R.command(a,e,"dropArea",{16.0, 16.0}) end},
{t=0,run=function(a,e) R.command(a,e,"moveCircleRel",{a.f[0], a.f[1], 0.0, 1.5}) end},
{t=40,run=function(a,e) R.command(a,e,"moveCircleRel",{-999999.0, a.f[1], -999999.0, 0.0}) end},
{t=100,run=function(a,e) R.command(a,e,"moveVel",{R.value(a,"ABS_ANGLE_PLAYER"), 0.0}) end},
{t=100,run=function(a,e) R.command(a,e,"moveVelTime",{60, 0, -999999.0, 2.0}) end},
{t=160,run=function(a,e) R.command(a,e,"flagClear",{4}) end},
{t=6160,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=6160,run=function(a,e) return 0 end}
}}
P["Girl01"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"anmSelect",{1}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetMain",{0, 40}) end},
{t=0,run=function(a,e) R.command(a,e,"flagSet",{32}) end},
{t=0,run=function(a,e) R.command(a,e,"setHurtbox",{40.0, 40.0}) end},
{t=0,run=function(a,e) R.command(a,e,"setHitbox",{16.0, 16.0}) end},
{t=0,run=function(a,e) R.command(a,e,"dropClear",{}) end},
{t=0,run=function(a,e) R.command(a,e,"dropExtra",{1, 4}) end},
{t=0,run=function(a,e) R.command(a,e,"dropExtra",{2, 3}) end},
{t=0,run=function(a,e) R.command(a,e,"dropArea",{32.0, 32.0}) end},
{t=0,run=function(a,e) R.command(a,e,"setInvuln",{120}) end},
{t=0,run=function(a,e) R.command(a,e,"unknown361",{120}) end},
{t=0,run=function(a,e) R.command(a,e,"moveVel",{1.5707964, 5.0}) end},
{t=0,run=function(a,e) R.command(a,e,"moveVelTime",{60, 4, -999999.0, 0.0}) end},
{t=60,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=60,run=function(a,e) a.f[0]=R.value(a,"RANDRAD") end},
{t=60,run=function(a,e) a.f[1]=0.05236 end},
{t=60,run=function(a,e) R.spawn(a,"Girl01_at",{},-1) end},
{t=60,run=function(a,e) R.spawn(a,"Girl01_at2",{6, 0.0, 0.049087387},-1) end},
{t=60,run=function(a,e) R.spawn(a,"Girl01_at2",{2, 3.1415927, -0.049087387},-1) end},
{t=120,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=120,run=function(a,e) a.f[0]=R.value(a,"RANDRAD") end},
{t=120,run=function(a,e) a.f[1]=-0.05236 end},
{t=120,run=function(a,e) R.spawn(a,"Girl01_at",{},-1) end},
{t=180,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=180,run=function(a,e) a.f[0]=R.value(a,"RANDRAD") end},
{t=180,run=function(a,e) a.f[1]=0.05236 end},
{t=180,run=function(a,e) R.spawn(a,"Girl01_at",{},-1) end},
{t=240,run=function(a,e) R.command(a,e,"moveVelTime",{40, 4, 1.5707964, 2.0}) end},
{t=240,run=function(a,e) R.command(a,e,"killAllAsync",{}) end},
{t=6240,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=6240,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["Girl01_at"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"playSound",{41}) end},
{t=0,run=function(a,e) R.command(a,e,"enmCreate",{"BGirl00", 0.0, 0.0, 120, 1000, 1}) end},
{t=0,run=function(a,e) a.f[0]=a.f[0] + 1.570796 end},
{t=0,run=function(a,e) R.command(a,e,"enmCreate",{"BGirl00", 0.0, 0.0, 120, 1000, 1}) end},
{t=0,run=function(a,e) a.f[0]=a.f[0] + 1.570796 end},
{t=0,run=function(a,e) R.command(a,e,"enmCreate",{"BGirl00", 0.0, 0.0, 120, 1000, 1}) end},
{t=0,run=function(a,e) a.f[0]=a.f[0] + 1.570796 end},
{t=0,run=function(a,e) R.command(a,e,"enmCreate",{"BGirl00", 0.0, 0.0, 120, 1000, 1}) end},
{t=0,run=function(a,e) return 0 end}
}}
P["Girl01_at2"]={params={"A","B","C"},ops={
{t=0,run=function(a,e) R.command(a,e,"etNew",{0}) end},
{t=0,run=function(a,e) R.command(a,e,"etAim",{0, 5}) end},
{t=0,run=function(a,e) R.command(a,e,"etSprite",{0, 5, e.i.A}) end},
{t=0,run=function(a,e) R.command(a,e,"etCountD",{0, 8, 8, 8, 8, 1, 1, 2, 2}) end},
{t=0,run=function(a,e) R.command(a,e,"etAngle",{0, e.f.B, 0.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etSpeedD",{0, 1.5, 2.8, 3.5, 5.0, 0.8, 0.8, 2.8, 2.8}) end},
{t=0,run=function(a,e) R.command(a,e,"etEx",{0, 0, 1, 4, -999999, -999999, -999999.0, -999999.0}) end},
{t=0,run=function(a,e) if true then return 14,0 end end},
{t=0,run=function(a,e) R.command(a,e,"etAngle",{0, e.f.B, 0.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etOn",{0}) end},
{t=0,run=function(a,e) e.f.B=e.f.B + e.f.C end},
{t=0,run=function(a,e) e.f.B=R.rad(e.f.B) end},
{t=0,run=function(a,e) R.command(a,e,"wait",{8}) end},
{t=0,run=function(a,e) if R.truth(1) then return 9,0 end end},
{t=0,run=function(a,e) return 0 end}
}}
P["Girl02"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"anmSelect",{1}) end},
{t=0,run=function(a,e) R.command(a,e,"anmSetMain",{0, 40}) end},
{t=0,run=function(a,e) R.command(a,e,"flagSet",{32}) end},
{t=0,run=function(a,e) R.command(a,e,"setHurtbox",{40.0, 40.0}) end},
{t=0,run=function(a,e) R.command(a,e,"setHitbox",{16.0, 16.0}) end},
{t=0,run=function(a,e) R.command(a,e,"dropClear",{}) end},
{t=0,run=function(a,e) R.command(a,e,"dropExtra",{4, 2}) end},
{t=0,run=function(a,e) R.command(a,e,"dropExtra",{1, 4}) end},
{t=0,run=function(a,e) R.command(a,e,"dropExtra",{2, 3}) end},
{t=0,run=function(a,e) R.command(a,e,"dropArea",{32.0, 32.0}) end},
{t=0,run=function(a,e) R.command(a,e,"setInvuln",{600}) end},
{t=0,run=function(a,e) R.command(a,e,"unknown361",{120}) end},
{t=0,run=function(a,e) R.command(a,e,"moveVel",{1.5707964, 5.0}) end},
{t=0,run=function(a,e) R.command(a,e,"moveVelTime",{60, 4, -999999.0, 0.0}) end},
{t=60,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=60,run=function(a,e) R.spawn(a,"Girl02_at",{},-1) end},
{t=760,run=function(a,e) R.command(a,e,"moveVelTime",{40, 4, -1.5707964, 1.0}) end},
{t=6760,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=6760,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["Girl02_at"]={params={},ops={
{t=0,run=function(a,e) e.i.A=R.integer(10) end},
{t=0,run=function(a,e) e.i.B=R.integer(6) end},
{t=0,run=function(a,e) R.command(a,e,"etNew",{1}) end},
{t=0,run=function(a,e) R.command(a,e,"etAim",{1, 3}) end},
{t=0,run=function(a,e) R.command(a,e,"etSprite",{1, 0, 2}) end},
{t=0,run=function(a,e) R.command(a,e,"etCountD",{1, 1, 1, 2, 2, 1, 1, 1, 1}) end},
{t=0,run=function(a,e) R.command(a,e,"etAngle",{1, 0.0, 3.1415927}) end},
{t=0,run=function(a,e) R.command(a,e,"etSpeedD",{1, 1.2, 1.2, 2.2, 3.2, 1.0, 1.0, 1.0, 1.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etEx",{1, 0, 1, 4, -999999, -999999, -999999.0, -999999.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etEx",{1, 1, 1, 1, -999999, -999999, -999999.0, -999999.0}) end},
{t=0,run=function(a,e) if true then return 41,0 end end},
{t=0,run=function(a,e) e.i.A=R.integer(60) end},
{t=0,run=function(a,e) e.f.C=R.value(a,"RANDRAD") end},
{t=0,run=function(a,e) R.command(a,e,"etSprite",{1, 0, 4}) end},
{t=0,run=function(a,e) if true then return 25,0 end end},
{t=0,run=function(a,e) R.command(a,e,"wait",{1}) end},
{t=0,run=function(a,e) e.f.C=e.f.C + ((R.value(a,"RANDRAD") / R.float(80)) + (3.1415927 / R.float(80))) end},
{t=0,run=function(a,e) R.command(a,e,"etAngle",{1, e.f.C, 0.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etOffset",{1, R.value(a,"RANDF2") * 32.0, R.value(a,"RANDF2") * 32.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etOn",{1}) end},
{t=0,run=function(a,e) e.f.C=e.f.C + ((R.value(a,"RANDRAD") / R.float(80)) + (3.1415927 / R.float(80))) end},
{t=0,run=function(a,e) R.command(a,e,"etAngle",{1, e.f.C, 0.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etOffset",{1, R.value(a,"RANDF2") * 32.0, R.value(a,"RANDF2") * 32.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etOn",{1}) end},
{t=0,run=function(a,e) if R.truth(R.dec(e.i,"A")) then return 16,0 end end},
{t=0,run=function(a,e) e.i.A=R.integer(60) end},
{t=0,run=function(a,e) e.f.C=R.value(a,"RANDRAD") end},
{t=0,run=function(a,e) R.command(a,e,"etSprite",{1, 0, 6}) end},
{t=0,run=function(a,e) if true then return 39,0 end end},
{t=0,run=function(a,e) R.command(a,e,"wait",{1}) end},
{t=0,run=function(a,e) e.f.C=e.f.C - ((R.value(a,"RANDRAD") / R.float(80)) + (3.1415927 / R.float(80))) end},
{t=0,run=function(a,e) R.command(a,e,"etAngle",{1, e.f.C, 0.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etOffset",{1, R.value(a,"RANDF2") * 32.0, R.value(a,"RANDF2") * 32.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etOn",{1}) end},
{t=0,run=function(a,e) e.f.C=e.f.C - ((R.value(a,"RANDRAD") / R.float(80)) + (3.1415927 / R.float(80))) end},
{t=0,run=function(a,e) R.command(a,e,"etAngle",{1, e.f.C, 0.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etOffset",{1, R.value(a,"RANDF2") * 32.0, R.value(a,"RANDF2") * 32.0}) end},
{t=0,run=function(a,e) R.command(a,e,"etOn",{1}) end},
{t=0,run=function(a,e) if R.truth(R.dec(e.i,"A")) then return 30,0 end end},
{t=0,run=function(a,e) R.command(a,e,"etOffset",{1, 0.0, 0.0}) end},
{t=0,run=function(a,e) if R.truth(R.dec(e.i,"B")) then return 12,0 end end},
{t=0,run=function(a,e) return 0 end}
}}
P["MainSub1"]={params={},ops={
{t=0,run=function(a,e) a.i[0]=R.integer(6) end},
{t=160,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=160,run=function(a,e) R.spawn(a,"MainSub1a",{},-1) end},
{t=160,run=function(a,e) R.spawn(a,"MainSub1b",{},-1) end},
{t=275,run=function(a,e) R.command(a,e,"movePos",{-140.0, 0.0}) end},
{t=275,run=function(a,e) R.spawn(a,"MainSub1a",{},-1) end},
{t=275,run=function(a,e) R.spawn(a,"MainSub1b",{},-1) end},
{t=390,run=function(a,e) R.command(a,e,"movePos",{140.0, 0.0}) end},
{t=390,run=function(a,e) R.spawn(a,"MainSub1a",{},-1) end},
{t=390,run=function(a,e) R.spawn(a,"MainSub1b",{},-1) end},
{t=505,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=505,run=function(a,e) R.command(a,e,"movePos",{0.0, 0.0}) end},
{t=505,run=function(a,e) R.spawn(a,"MainSub2",{},-1) end},
{t=505,run=function(a,e) return 0 end}
}}
P["MainSub1a"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"enmCreate",{"BCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=16,run=function(a,e) R.command(a,e,"enmCreate",{"BCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=32,run=function(a,e) R.command(a,e,"enmCreate",{"BCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=48,run=function(a,e) R.command(a,e,"enmCreate",{"BCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=64,run=function(a,e) R.command(a,e,"enmCreate",{"RCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=80,run=function(a,e) R.command(a,e,"enmCreate",{"RCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=96,run=function(a,e) R.command(a,e,"enmCreate",{"GCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=96,run=function(a,e) return 0 end}
}}
P["MainSub1b"]={params={},ops={
{t=8,run=function(a,e) R.command(a,e,"enmCreateM",{"BCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=24,run=function(a,e) R.command(a,e,"enmCreateM",{"BCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=40,run=function(a,e) R.command(a,e,"enmCreateM",{"BCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=56,run=function(a,e) R.command(a,e,"enmCreateM",{"BCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=72,run=function(a,e) R.command(a,e,"enmCreateM",{"RCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=88,run=function(a,e) R.command(a,e,"enmCreateM",{"RCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=104,run=function(a,e) R.command(a,e,"enmCreateM",{"GCir00", 0.0, -24.0, 20, 1000, 1}) end},
{t=104,run=function(a,e) return 0 end}
}}
P["MainSub2"]={params={},ops={
{t=0,run=function(a,e) a.i[0]=R.integer(6) end},
{t=300,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=300,run=function(a,e) R.command(a,e,"movePos",{-224.0, 64.0}) end},
{t=300,run=function(a,e) R.spawn(a,"MainSub2a",{},-1) end},
{t=300,run=function(a,e) R.spawn(a,"MainSub2b",{},-1) end},
{t=415,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=415,run=function(a,e) R.command(a,e,"movePos",{224.0, 96.0}) end},
{t=415,run=function(a,e) R.spawn(a,"MainSub2c",{},-1) end},
{t=415,run=function(a,e) R.spawn(a,"MainSub2d",{},-1) end},
{t=530,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=530,run=function(a,e) R.command(a,e,"movePos",{-224.0, 128.0}) end},
{t=530,run=function(a,e) R.spawn(a,"MainSub2a",{},-1) end},
{t=530,run=function(a,e) R.spawn(a,"MainSub2b",{},-1) end},
{t=645,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=645,run=function(a,e) R.command(a,e,"movePos",{224.0, 32.0}) end},
{t=645,run=function(a,e) R.spawn(a,"MainSub2c",{},-1) end},
{t=645,run=function(a,e) R.spawn(a,"MainSub2d",{},-1) end},
{t=645,run=function(a,e) R.spawn(a,"MainSub3",{},-1) end},
{t=645,run=function(a,e) return 0 end}
}}
P["MainSub2a"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"enmCreate",{"BCir01", 0.0, 0.0, 20, 1000, 1}) end},
{t=16,run=function(a,e) R.command(a,e,"enmCreate",{"BCir01", 0.0, 0.0, 20, 1000, 1}) end},
{t=32,run=function(a,e) R.command(a,e,"enmCreate",{"BCir01", 0.0, 0.0, 20, 1000, 1}) end},
{t=48,run=function(a,e) R.command(a,e,"enmCreate",{"BCir01", 0.0, 0.0, 20, 1000, 1}) end},
{t=64,run=function(a,e) R.command(a,e,"enmCreate",{"RCir01", 0.0, 0.0, 20, 1000, 1}) end},
{t=80,run=function(a,e) R.command(a,e,"enmCreate",{"RCir01", 0.0, 0.0, 20, 1000, 1}) end},
{t=96,run=function(a,e) R.command(a,e,"enmCreate",{"GCir01", 0.0, 0.0, 20, 1000, 1}) end},
{t=96,run=function(a,e) return 0 end}
}}
P["MainSub2b"]={params={},ops={
{t=8,run=function(a,e) R.command(a,e,"enmCreate",{"BCir01b", 0.0, 0.0, 20, 1000, 1}) end},
{t=24,run=function(a,e) R.command(a,e,"enmCreate",{"BCir01b", 0.0, 0.0, 20, 1000, 1}) end},
{t=40,run=function(a,e) R.command(a,e,"enmCreate",{"BCir01b", 0.0, 0.0, 20, 1000, 1}) end},
{t=56,run=function(a,e) R.command(a,e,"enmCreate",{"BCir01b", 0.0, 0.0, 20, 1000, 1}) end},
{t=72,run=function(a,e) R.command(a,e,"enmCreate",{"RCir01b", 0.0, 0.0, 20, 1000, 1}) end},
{t=88,run=function(a,e) R.command(a,e,"enmCreate",{"RCir01b", 0.0, 0.0, 20, 1000, 1}) end},
{t=104,run=function(a,e) R.command(a,e,"enmCreate",{"GCir01b", 0.0, 0.0, 20, 1000, 1}) end},
{t=104,run=function(a,e) return 0 end}
}}
P["MainSub2c"]={params={},ops={
{t=0,run=function(a,e) e.f.A=R.value(a,"FINAL_X") end},
{t=0,run=function(a,e) e.f.B=R.value(a,"FINAL_Y") end},
{t=0,run=function(a,e) R.command(a,e,"enmCreateAM",{"BCir01", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=16,run=function(a,e) R.command(a,e,"enmCreateAM",{"BCir01", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=32,run=function(a,e) R.command(a,e,"enmCreateAM",{"BCir01", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=48,run=function(a,e) R.command(a,e,"enmCreateAM",{"BCir01", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=64,run=function(a,e) R.command(a,e,"enmCreateAM",{"RCir01", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=80,run=function(a,e) R.command(a,e,"enmCreateAM",{"RCir01", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=96,run=function(a,e) R.command(a,e,"enmCreateAM",{"GCir01", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=96,run=function(a,e) return 0 end}
}}
P["MainSub2d"]={params={},ops={
{t=0,run=function(a,e) e.f.A=R.value(a,"FINAL_X") end},
{t=0,run=function(a,e) e.f.B=R.value(a,"FINAL_Y") end},
{t=8,run=function(a,e) R.command(a,e,"enmCreateM",{"BCir01b", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=24,run=function(a,e) R.command(a,e,"enmCreateM",{"BCir01b", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=40,run=function(a,e) R.command(a,e,"enmCreateM",{"BCir01b", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=56,run=function(a,e) R.command(a,e,"enmCreateM",{"BCir01b", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=72,run=function(a,e) R.command(a,e,"enmCreateM",{"RCir01b", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=88,run=function(a,e) R.command(a,e,"enmCreateM",{"RCir01b", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=104,run=function(a,e) R.command(a,e,"enmCreateM",{"GCir01b", e.f.A, e.f.B, 20, 1000, 1}) end},
{t=104,run=function(a,e) return 0 end}
}}
P["MainSub3"]={params={},ops={
{t=200,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=200,run=function(a,e) R.command(a,e,"movePos",{0.0, 0.0}) end},
{t=200,run=function(a,e) R.command(a,e,"enmCreate",{"Girl01", 0.0, -24.0, 400, 1000, 4}) end},
{t=200,run=function(a,e) R.spawn(a,"MainSub4",{},-1) end},
{t=200,run=function(a,e) return 0 end}
}}
P["MainSub4"]={params={},ops={
{t=0,run=function(a,e) a.i[0]=R.integer(6) end},
{t=200,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=200,run=function(a,e) R.command(a,e,"movePos",{-96.0, 0.0}) end},
{t=200,run=function(a,e) R.spawn(a,"MainSub1a",{},-1) end},
{t=200,run=function(a,e) R.spawn(a,"MainSub1b",{},-1) end},
{t=315,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=315,run=function(a,e) R.command(a,e,"movePos",{96.0, 0.0}) end},
{t=315,run=function(a,e) R.spawn(a,"MainSub1a",{},-1) end},
{t=315,run=function(a,e) R.spawn(a,"MainSub1b",{},-1) end},
{t=430,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=430,run=function(a,e) R.command(a,e,"movePos",{-128.0, 0.0}) end},
{t=430,run=function(a,e) R.spawn(a,"MainSub1a",{},-1) end},
{t=430,run=function(a,e) R.spawn(a,"MainSub1b",{},-1) end},
{t=545,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=545,run=function(a,e) R.command(a,e,"movePos",{0.0, 0.0}) end},
{t=545,run=function(a,e) R.spawn(a,"MainSub5",{},-1) end},
{t=545,run=function(a,e) return 0 end}
}}
P["MainSub5"]={params={},ops={
{t=0,run=function(a,e) a.i[0]=R.integer(6) end},
{t=160,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=160,run=function(a,e) R.command(a,e,"movePos",{-224.0, 64.0}) end},
{t=160,run=function(a,e) R.spawn(a,"MainSub2a",{},-1) end},
{t=160,run=function(a,e) R.spawn(a,"MainSub2b",{},-1) end},
{t=275,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=275,run=function(a,e) R.command(a,e,"movePos",{224.0, 96.0}) end},
{t=275,run=function(a,e) R.spawn(a,"MainSub2c",{},-1) end},
{t=275,run=function(a,e) R.spawn(a,"MainSub2d",{},-1) end},
{t=390,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=390,run=function(a,e) R.command(a,e,"movePos",{-224.0, 128.0}) end},
{t=390,run=function(a,e) R.spawn(a,"MainSub2a",{},-1) end},
{t=390,run=function(a,e) R.spawn(a,"MainSub2b",{},-1) end},
{t=505,run=function(a,e) R.command(a,e,"nop",{}) end},
{t=505,run=function(a,e) R.command(a,e,"movePos",{224.0, 32.0}) end},
{t=505,run=function(a,e) R.spawn(a,"MainSub2c",{},-1) end},
{t=505,run=function(a,e) R.spawn(a,"MainSub2d",{},-1) end},
{t=545,run=function(a,e) R.command(a,e,"movePos",{0.0, 0.0}) end},
{t=545,run=function(a,e) R.command(a,e,"enmCreate",{"Girl02", 0.0, -24.0, 1500, 1, 3}) end},
{t=545,run=function(a,e) R.command(a,e,"movePos",{0.0, 0.0}) end},
{t=545,run=function(a,e) return 0 end}
}}
P["RCir00"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{1}) end},
{t=0,run=function(a,e) R.call(a,"Cir00",{50, 46}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["RCir01"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{1}) end},
{t=0,run=function(a,e) R.call(a,"Cir01",{50, 46}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
P["RCir01b"]={params={},ops={
{t=0,run=function(a,e) R.command(a,e,"dropMain",{1}) end},
{t=0,run=function(a,e) R.call(a,"Cir01b",{50, 46}) end},
{t=0,run=function(a,e) R.command(a,e,"delete",{}) end}
}}
