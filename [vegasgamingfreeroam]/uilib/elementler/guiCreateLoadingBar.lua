function guiCreateLoadingBar(x,y,g,u,yazi,relative,parent)
	ldsayi = #gui["load"] + 1
	if not gui["load"][ldsayi] then gui["load"][ldsayi] = {} end
	local ld = gui["load"][ldsayi]
	--
	if relative then
		px,pu   = getParentSize(parent)
		x,y,g,u = x*px,y*pu,g*px,u*pu
	end
	
	ld.resim = guiCreateStaticImage(x,y,g,u,bosresim,relative,parent)
	elementerenkver(ld.resim,tema["load"].cerceve)
	
	--border
	ld.kenarlar = {
		ortaust = guiCreateStaticImage(1, 0, g - 2, 1,bosresim,false,ld.resim),
		ortaalt = guiCreateStaticImage(1, u-1, g - 2, 1,bosresim,false,ld.resim),
		--sol = guiCreateStaticImage(0, 1, 1, h-2,bosresim,false,lib.loadinglabel[loadinglabelsayi].arkataraf),
		--sag = guiCreateStaticImage(w-1, 1, 1, h-2,bosresim,false,lib.loadinglabel[loadinglabelsayi].arkataraf)
	}
	for i,v in pairs(ld.kenarlar) do
		elementerenkver(v,tema["load"].kenarlar)
		guiSetProperty(v, "AlwaysOnTop", "True")
	end	
	
	ld.label = guiCreateLabel(0,-2,g,u, yazi, false,ld.resim)
	--guiSetFont(ld.label,font2)
	guiLabelSetHorizontalAlign(ld.label, "center")
	guiLabelSetVerticalAlign(ld.label, "center")
	guiLabelSetColor(ld.label,200, 200, 200)
	guiSetFont(ld.label, tema["load"].fonts.Roboto or "default-bold-small")
	
	--
	if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["load"] then kullanilanscriptler[sourceResource]["load"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["load"], {ldsayi,ldsayi.resim})
	--
	
	
	geneltablo[ldsayi.resim]={i=ldsayi,t="load"}
	return ldsayi.label
end
