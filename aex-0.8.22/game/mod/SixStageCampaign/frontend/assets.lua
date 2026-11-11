-- Exact sprite rectangles from TH10 title.anm, native 640x480 coordinates.
local root="mod/SixStageCampaign/frontend/"
local sprites={
 [0]={"title01.png",0,0,160,32},
 [1]={"title01.png",160,0,160,32},
 [2]={"title01.png",0,32,160,32},
 [3]={"title01.png",160,32,160,32},
 [4]={"title01.png",0,64,208,32},
 [5]={"title01.png",208,64,208,32},
 [6]={"title01.png",0,96,96,32},
 [7]={"title01.png",96,96,96,32},
 [8]={"title01.png",0,128,176,32},
 [9]={"title01.png",176,128,176,32},
 [10]={"title01.png",0,160,176,32},
 [11]={"title01.png",176,160,176,32},
 [12]={"title01.png",0,192,176,32},
 [13]={"title01.png",176,192,176,32},
 [14]={"title01.png",0,224,112,32},
 [15]={"title01.png",112,224,112,32},
 [16]={"title01.png",0,256,80,32},
 [17]={"title01.png",80,256,80,32},
 [73]={"title00a.png",0,0,512,480},
 [74]={"title00b.png",0,0,128,480},
 [75]={"title_logo.png",0,0,512,128},
 [76]={"title_logo.png",0,128,320,80},
 [77]={"select00.png",0,0,512,480},
 [78]={"select00b.png",0,0,128,480},
 [79]={"select01.png",0,0,256,48},
 [80]={"select01.png",0,48,256,48},
 [82]={"select01.png",0,144,256,48},
 [83]={"select01.png",0,192,256,48},
 [87]={"select01.png",0,384,256,48},
 [89]={"rank00.png",0,0,256,96},
 [91]={"rank00.png",0,192,256,96},
 [92]={"rank00.png",0,288,256,96},
 [95]={"rank00.png",256,96,256,96},
 [90]={"rank00.png",0,96,256,96},
 [99]={"sl_pl00.png",0,0,256,256},
 [101]={"sl_pl00b.png",0,0,256,256},
}
local textures={}
for id,s in pairs(sprites)do
 local tex="six.title.tex."..s[1]
 if not textures[tex]then LoadTexture(tex,root..s[1]);textures[tex]=true end
 local img="six.title."..id
 LoadImage(img,tex,s[2],s[3],s[4],s[5]);SetImageCenter(img,0,0)
end
LoadMusic("six.title.bgm",root.."title-bgm.wav",98.0299319727891,95.9998185941043)
for _,n in ipairs({'select00','ok00','cancel00','invalid'})do LoadSound('six.title.'..n,root..'se_'..n..'.wav')end

-- Same Windows font family requested by the retail EXE (MS Gothic).
LoadTTF('six.title.question.font','mod/SixStageCampaign/frontend/ms-gothic.ttc',120)

-- Original TH10 ascii.anm loading sprites232..234.
LoadTexture("six.loading.tex",root.."loading.png")
LoadImage("six.loading.jp","six.loading.tex",1,1,126,30)
LoadImage("six.loading.en","six.loading.tex",1,33,126,30)
LoadImage("six.loading.star","six.loading.tex",1,65,30,30)
