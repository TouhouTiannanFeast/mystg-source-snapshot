def boss03(s):
 start=s.index('local function stardust_update(f)')
 stop=s.index('local function laser_f(f)',start)
 return s[:start]+'''local function stardust(o)
    T.Stardust03.run(o)
end
'''+s[stop:]
