function guiCreateRadioButton(x,y,g,u,yazi,relative,parent)
	rsayi = #gui["r"] +1
	if not gui["r"][rsayi] then gui["r"][rsayi] = {} end
	local r = gui["r"][rsayi]
	if relative  then
		px,pu = getParentSize(parent)
		x,y,g,u = x*px,y*pu,g*px,u*pu
	end
    r.selected = false
    r.selectedcolor = tema["r"].radcheckcolor
    --
    r.label = guiCreateLabel(x+21,y+2,g+50,25,yazi,false,parent)
    guiSetFont(r.label,tema["c"].fonts.Roboto or "default-bold-small")
    --
	r.dolukutu = guiCreateStaticImage(x,y,21,21,"dosyalar/raddolu.png",relative,parent)
    elementerenkver(r.dolukutu,r.selectedcolor)
    guiSetVisible(r.dolukutu,false)
    --
    if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["r"] then kullanilanscriptler[sourceResource]["r"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["r"], {rsayi,r.dolukutu})
    --
    r.boskutu = guiCreateStaticImage(x,y,21,21,"dosyalar/radbos.png",relative,parent)
    elementerenkver(r.boskutu,tema["r"].raduncheckedcolor)
    guiSetVisible(r.boskutu,true)
    guiSetAlpha(r.label,0.6)
    --
    geneltablo[r.dolukutu] = {i=rsayi,t="r"}
    geneltablo[r.boskutu]  = {i=rsayi,t="r"}
    geneltablo[r.dolukutu] = {i=rsayi,isRadioButton = true,durum = r.selected}
    geneltablo[r.boskutu]  = {i=rsayi,isRadioButton = true,durum = r.selected}
    geneltablo[r.label]    = {i=rsayi,isRadioButton = true,durum = r.selected}
    --
    return r.dolukutu,r.boskutu
end
--

function guiRadioButtonSetSelectedColor(element,hex)
    local sira = getGuiElement(element)
	if not sira then return end
	if sira.isRadioButton then 
        gui["r"][sira.i].selectedcolor = hex
        if gui["r"][sira.i].dolukutu then 
            elementerenkver(gui["r"][sira.i].dolukutu,hex)
        end
    end
end
--
function guiRadioButtonGetSelectedColor(element)
    local sira = getGuiElement(element)
	if not sira then return end
	if sira.isRadioButton then 
       return gui["r"][sira.i].selectedcolor 
    end
end
--
function guiRadioButtonGetSelected(element)
    local sira = getGuiElement(element)
	if not sira then return end
	if sira.isRadioButton then 
		return gui["r"][sira.i].selected
	end
end
--
function guiRadioButtonSetSelected(element,bool)
    local sira = getGuiElement(element)
	if not sira then return end
    if sira.isRadioButton then 
        --
        for i=1,#gui["r"] do 
            tablo = gui["r"][i]
            if tablo then 
                radiobut = tablo
                radiobut.selected = false
                guiSetVisible(radiobut.dolukutu,false)
                guiSetVisible(radiobut.boskutu,true)
                guiSetAlpha(radiobut.label,0.6)
            end
        end
        radiobut = gui["r"][sira.i]
        --
        radiobut.selected = true 
        guiSetVisible(radiobut.dolukutu,true)
        guiSetVisible(radiobut.boskutu,false)
        guiSetAlpha(radiobut.label,0.85)
        --
    end
end
