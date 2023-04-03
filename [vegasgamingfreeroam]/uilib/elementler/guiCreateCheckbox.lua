function guiCreateCheckBox(x,y,g,u,yazi,state,relative,parent)
	csayi = #gui["c"] +1
	if not gui["c"][csayi] then gui["c"][csayi] = {} end
	local c = gui["c"][csayi]
	if relative  then
		px,pu = getParentSize(parent)
		x,y,g,u = x*px,y*pu,g*px,u*pu
	end
    --
    c.selected = state
    c.selectedcolor = tema["c"].checkcolor
    --
    c.parentlabel = guiCreateLabel(x,y,g,u,"",false,parent)
    --Dolu Kutu
    c.kutu = guiCreateStaticImage(0,0,20,20,"dosyalar/cdolu.png",false,c.parentlabel)
    elementerenkver(c.kutu,c.selectedcolor)
    guiSetAlpha(c.kutu,0.6) guiSetEnabled(c.kutu,false)
	guiSetVisible(c.kutu,state and (true) or (false))	
    --Checkbox Tik
    c.tik = guiCreateStaticImage(0,0,20,20,"dosyalar/ctik.png",false,c.kutu)
    guiSetAlpha(c.tik,0.8)
	guiSetVisible(c.tik,state and (true) or (false))
    --Checkbox yazı
    c.label = guiCreateLabel(20,2,g,u,yazi,false,c.parentlabel)
    guiSetFont(c.label,tema["c"].fonts.Roboto or "default-bold-small")
    guiSetEnabled(c.label,false)
    guiSetAlpha(c.label,state and 0.85 or 0.5)
    --Boş Kutu
    c.kutu2 = guiCreateStaticImage(0,0,20,20,"dosyalar/cbos.png",false,c.parentlabel)
    elementerenkver(c.kutu2,tema["c"].uncheckedcolor)
    guiSetAlpha(c.kutu2,0.6) guiSetEnabled(c.kutu2,false)
	guiSetVisible(c.kutu2,state and (false) or (true))
    --
    if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["c"] then kullanilanscriptler[sourceResource]["c"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["c"], {csayi,c.parentlabel})
    --
	c.isCheckbox=true
    geneltablo[c.parentlabel] = {i=csayi,t="c",kutu1=c.kutu,kutu2=c.kutu2,tik=c.tik,label=c.label,selectedcolor = tema["c"].checkcolor}
    --
	return c.parentlabel
end
--
function guiCheckBoxSetSelected(element,bool)
    local sira = getGuiElement(element)
	if sira and sira.isCheckbox then 
		sira.selected = bool
		guiSetAlpha(sira.label,bool and 0.85 or 0.5)
		guiSetVisible(sira.kutu,bool and (true) or (false))
		guiSetVisible(sira.kutu2,bool and (false) or (true))
		guiSetVisible(sira.tik,bool and (true) or (false))
	end
end
--
function guiCheckBoxSetSelectedColor(element,hex)
    local sira = getGuiElement(element)
	if sira and sira.isCheckbox then 
        sira.selectedcolor = hex
        elementerenkver(sira.kutu,hex)
    end
end
--
function guiCheckBoxGetSelectedColor(element)
    local sira = getGuiElement(element)
	if sira and sira.isCheckbox then 
       return  sira.selectedcolor 
    end
end
--
function guiCheckBoxGetSelected(element)
    local sira = getGuiElement(element)
	if sira and sira.isCheckbox then 
		return sira.selected
	end
end
