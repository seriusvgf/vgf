function guiCreateWindow(x,y,g,u,yazi,close,relative,parent)
	wsayi = #gui["w"] + 1
	if not gui["w"][wsayi] then gui["w"][wsayi] = {} end
	local w = gui["w"][wsayi]
	--
	if relative then
		px,pu   = getParentSize(parent)
		x,y,g,u = x*px,y*pu,g*px,u*pu
	end
	--
	w.move = false
	--
	w.resim = guiCreateStaticImage(x,y,g,u,bosresim,false)
	elementerenkver(w.resim,tema["w"].cerceve)
	guiSetAlpha(w.resim,0.93)
	--
	w.basarka = guiCreateStaticImage(0,0,g,40,bosresim,false,w.resim)
	elementerenkver(w.basarka,tema["w"].baslik)
	--
	w.label = guiCreateLabel(12,3,g,30, utf8.upper(yazi), false, w.basarka)
	guiSetFont(w.label, tema["w"].fonts.Bebas or "default-bold-small")
    guiSetAlpha(w.label,0.8)
	guiLabelSetVerticalAlign(w.label, "center")
	guiSetAlpha(w.label,0.68)
	guiSetEnabled(w.label,false)
	--
	w.closeicon = guiCreateStaticImage(g-22,15,10,10,"dosyalar/close.png",false,w.basarka)
	guiSetAlpha(w.closeicon,0.6)
	--
	if tonumber(g) <= 200 then 
		guiSetVisible(w.closeicon,false)
	else 
		guiSetVisible(w.closeicon,close)
	end
	--
	if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["w"] then kullanilanscriptler[sourceResource]["w"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["w"], {wsayi,w.resim})
	--
	geneltablo[w.resim]={i=wsayi,t="w"}
	geneltablo[w.basarka]={i=wsayi,isHeader=true}
	geneltablo[w.closeicon]={i=wsayi,isClose=true}
	--
	return w.resim,w.basarka
end
--
function guiWindowSetCloseVisible(element,bool)
	local sira = getGuiElement(element)
	if not sira then return end
	if sira.closeicon then 
		local w,h = _guiGetSize(element,false)
		if tonumber(w) <= 200 then 
			guiSetVisible(sira.closeicon,false)
		else 
			guiSetVisible(sira.closeicon,bool)
		end
	end
end
function guiWindowGetCloseVisible(element)
	local sira = getGuiElement(element)
	if not sira then return end
	return guiGetVisible(sira.closeicon)
end
--

