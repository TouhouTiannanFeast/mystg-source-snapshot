-- Practice entry selection only; original programs and gameplay values are retained.
Th18Stage5Sections={}
local C=Th18Stage5Sections
local entries={['road-0']={'MainFront',1},['road-1']={'MainFront',3},
 ['road-2']={'MainFront',5},['road-3']={'MainFront',7},
 ['road-4']={'MainLatter',3},['road-5']={'MainLatter',6},
 ['road-6']={'MainLatter',8},['road-7']={'MainLatter',12}}
function C.entry(id)
 id=id or 'full'
 if id=='full' then return {front=true,mid=true} end
 if id=='mid' then return {mid=true} end
 local row=entries[id]
 if row then return {front=row[1]=='MainFront',mid=row[1]=='MainFront',program=row[1],first=row[2]} end
 local n=tonumber(id:match('^boss%-([1-8])$'))
 assert(n,'unknown stage5 section: '..tostring(id))
 return {boss=n}
end
function C.phases(phases,entry)
 if not entry.boss then return phases end
 local out={};for i=entry.boss,#phases do out[#out+1]=phases[i]end
 assert(#out>0,'empty stage5 boss entry');return out
end
function C.run(R,entry,name)
 if entry.program~=name then R.run(name);return end
 -- These top-level routines have only sequential calls/waits and a final return.
 -- Copy their remaining operations without mutating the source table.
 local bank=Th18Stage5Programs.th18;local original=assert(bank[name]);local ops={}
 for i=entry.first,#original.ops do ops[#ops+1]=original.ops[i]end
 bank.SectionEntry={params=original.params,ops=ops};R.run('SectionEntry')
end
