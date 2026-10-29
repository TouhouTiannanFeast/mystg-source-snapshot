-- User-selected HP tiers; original LE03 table remains untouched.
Le03EnemyHealth={}
function Le03EnemyHealth.value(e)
 local original=e.sourceHP or e.hp
 if e.kind==0 then return original>=20000 and 1500 or 600 end
 if original>=5000 then return 120 elseif original>=2000 then return 100 else return 80 end
end
