function guiCreateGridList(x,y,g,u,relative,parent,listeuzunluk,listegenislik)
	Lsayi = #gui["g"] +1
	if not gui["g"][Lsayi] then gui["g"][Lsayi] = {} end
	local L = gui["g"][Lsayi]	
	if relative  then
		px,pu=getParentSize(parent)
		x,y,g,u=x*px,y*pu,g*px,u*pu
	end
	L.resim = guiCreateLabel(x,y,g,u, "", false, parent)
	L.liste = _guiCreateGridList(-5,-8,g+(listeuzunluk or 12), u+(listegenislik or 30),false, L.resim)
	guiSetAlpha(L.liste,0.7)
	guiSetFont(L.liste,tema["g"].fonts.Roboto or "default-bold-small")
	guiSetProperty(L.liste, "SelectionColour", "E3"..tema["g"].listekenarhovercolor)
	--
	
	L.kenarlar = {
		ortaust = guiCreateStaticImage(0,0,g,1,bosresim,false,L.resim),
		ortaalt = guiCreateStaticImage(0,u-1,g,1,bosresim,false,L.resim),
		sol = guiCreateStaticImage(0,0,1,u,bosresim,false,L.resim),
		sag = guiCreateStaticImage(g-1,0,1,u,bosresim,false,L.resim)		
	}
    --
	for i,v in pairs(L.kenarlar) do
		elementerenkver(v,tema["g"].listekenarnormalcolor)
		guiSetProperty(v, "AlwaysOnTop", "True")
	    guiSetAlpha(v,0.7)
	end

	if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["g"] then kullanilanscriptler[sourceResource]["g"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["g"], {Lsayi,L.resim})
	geneltablo[L.liste]={i=Lsayi,t="g"}
	geneltablo[L.liste]={i=Lsayi,isGridList=true,renkler={normal = tema["g"].listekenarnormalcolor,hover = tema["g"].listekenarhovercolor}}
	return L.liste
end

--[[
_guiCreateGridList = guiCreateGridList
function guiCreateGridList(x,y,g,u,relative,parent,listekenarelementerenkver,a,ua,au)
	listesayi =  #lib.liste + 1
	if not lib.liste[listesayi] then lib.liste[listesayi] = {} end
	if relative  then
		px,pu = guiGetSize(parent,false)
		x,y,g,u = x*px,y*pu,g*px,u*pu
		relative = false
	end
	local a = a or 30.5
	lib.liste[listesayi].resim = guiCreateLabel(x,y,g,u, "", relative, parent)
	lib.liste[listesayi].listee = _guiCreateGridList(-5,-8,g+(ua or 12), u+(au or 30),false, lib.liste[listesayi].resim)
	guiGridListSetSortingEnabled (lib.liste[listesayi].listee , false )
	guiSetFont(lib.liste[listesayi].listee,guiCreateFont("lib/font.ttf",8.9))
	lib.liste[listesayi].kenarlar = {
		ortaust = guiCreateStaticImage(1, 0, g - 2, 1,bosresim,false,lib.liste[listesayi].resim),
		ortaalt = guiCreateStaticImage(1, u-1, g - 2, 1,bosresim,false,lib.liste[listesayi].resim),
		sol = guiCreateStaticImage(0, 1, 1, u-2,bosresim,false,lib.liste[listesayi].resim),
		sag = guiCreateStaticImage(g-1, 1, 1, u-2,bosresim,false,lib.liste[listesayi].resim)		
	}
	for i,v in pairs(lib.liste[listesayi].kenarlar) do
		elementerenkver(v,listekenarelementerenkver or lib.temarenginormal)
		guiSetProperty(v, "AlwaysOnTop", "True")
		guiSetAlpha(v,0.5)
	end	
	lib.genelfor[lib.liste[listesayi].listee] = lib.liste[listesayi].kenarlar
	return lib.liste[listesayi].listee
end

]]