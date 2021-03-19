-- globals.lua
-- show all global variables
-- Usage: dump(_G,"")
local globals = {}
  
local seen={}
function globals.dump(t,i)
	seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
  --!strict
	for k,v in ipairs(s) do
		print(i,v)
		v=t[v]
		if type(v)=="table" and not seen[v] then
			globals.dump(v,i.."\t")
		end
	end
end

return globals
