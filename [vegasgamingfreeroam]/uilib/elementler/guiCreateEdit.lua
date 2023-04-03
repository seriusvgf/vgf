function guiCreateEdit(x,y,g,u,yazi,relative,parent)
	esayi = #gui["e"] + 1
	if not gui["e"][esayi] then gui["e"][esayi] = {} end
	local e = gui["e"][esayi]
	--
	if relative then
		px,pu   = getParentSize(parent)
		x,y,g,u = x*px,y*pu,g*px,u*pu
	end
	e.resim = guiCreateLabel(x,y,g,u, "", false, parent)
	e.edit = _guiCreateEdit(-7,-5,g+15, u+8,yazi,false, e.resim)
	guiSetAlpha(e.edit,0.7)
	guiSetProperty(e.edit, "ActiveSelectionColour", "E3"..tema["e"].editkenarhovercolor)
	guiSetFont(e.edit,tema["e"].fonts.Roboto or "default-bold-small")
	--
	if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["e"] then kullanilanscriptler[sourceResource]["e"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["e"], {esayi,e.resim})
	
	e.kenarlar = {
		ortaust = guiCreateStaticImage(0,0,g,1,bosresim,false,e.resim),
		ortaalt = guiCreateStaticImage(0,u-1,g,1,bosresim,false,e.resim),
		sol = guiCreateStaticImage(0,0,1,u,bosresim,false,e.resim),
		sag = guiCreateStaticImage(g-1,0,1,u,bosresim,false,e.resim)		
	}
    --
	for i,v in pairs(e.kenarlar) do
		elementerenkver(v,tema["e"].editkenarnormalcolor)
		guiSetProperty(v, "AlwaysOnTop", "True")
	    guiSetAlpha(v,0.7)
	end
	
	geneltablo[e.edit] = {i=esayi,t="e"}
    geneltablo[e.edit]={i=esayi,isEdit=true,renkler={normal = tema["e"].editkenarnormalcolor,hover = tema["e"].editkenarhovercolor}}
	return e.edit
end
