function guiCreateMemo(x,y,g,u,yazi,relative,parent)
	msayi = #gui["m"] + 1
	if not gui["m"][msayi] then gui["m"][msayi] = {} end
	local m = gui["m"][msayi]
	--
	if relative then
		px,pu   = getParentSize(parent)
		x,y,g,u = x*px,y*pu,g*px,u*pu
	end
	m.resim = guiCreateLabel(x,y,g,u, "", false, parent)
	m.memo = _guiCreateMemo(-7,-5,g+15, u+8,yazi,false, m.resim)
	guiSetAlpha(m.memo,0.7)
	guiSetProperty(m.memo, "ActiveSelectionColour", "E3"..tema["m"].memokenarhovercolor)
	guiSetFont(m.memo,tema["m"].fonts.Roboto or "default-bold-small")
	--
	if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["m"] then kullanilanscriptler[sourceResource]["m"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["m"], {msayi,m.resim})
	
	m.kenarlar = {
		ortaust = guiCreateStaticImage(0,0,g,1,bosresim,false,m.resim),
		ortaalt = guiCreateStaticImage(0,u-1,g,1,bosresim,false,m.resim),
		sol = guiCreateStaticImage(0,0,1,u,bosresim,false,m.resim),
		sag = guiCreateStaticImage(g-1,0,1,u,bosresim,false,m.resim)		
	}
    --
	for i,v in pairs(m.kenarlar) do
		elementerenkver(v,tema["m"].memokenarnormalcolor)
		guiSetProperty(v, "AlwaysOnTop", "Trum")
	    guiSetAlpha(v,0.7)
	end
	
	geneltablo[m.memo] = {i=msayi,t="m"}
    geneltablo[m.memo]={i=msayi,isMemo=true,renkler={normal = tema["m"].memokenarnormalcolor,hover = tema["m"].memokenarhovercolor}}
	return m.memo
end
