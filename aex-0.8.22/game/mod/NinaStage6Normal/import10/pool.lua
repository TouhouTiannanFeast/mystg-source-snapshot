Nina10Pool={}
function Nina10Pool.rng(seed)local n=math.floor(seed or 1)%2147483647;if n<=0 then n=1 end;return function()n=n*16807%2147483647;return(n-1)/2147483646 end end
