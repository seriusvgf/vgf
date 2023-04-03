_guiCreateTabPanel = guiCreateTabPanel
_guiCreateTab = guiCreateTab
_guiSetSelectedTab = guiSetSelectedTab
_guiGetSelectedTab = guiGetSelectedTab
_guiDeleteTab = guiDeleteTab
function guiCreateTabPanel(x,y,g,u,relative,parent)
	local sira = #gui["t"]+1
	if not gui["t"][sira] then gui["t"][sira] = {} end
	local t = gui["t"][sira]
	if relative  then
		px,pu = getParentSize(parent)
		x,y,g,u=x*px,y*pu,g*px,u*pu
	end
	t.resim = guiCreateLabel(x,y,g,u,"",false,parent)
	t.tabciklar_arka = guiCreateLabel(0,0,0,20,"",false,t.resim)
	guiSetProperty(t.tabciklar_arka, "AlwaysOnTop", "True")
	t.x,t.y = x,y
	t.g,t.u = g,u
	t.secili,t.tabciklar = nil,{}
	t.tabciklar[0] = {}
	t.tabciklar[0].arka = guiCreateLabel(0,0,0,0,"",false,t.tabciklar_arka)
	if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["t"] then kullanilanscriptler[sourceResource]["t"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["t"], {sira,t.resim})
	geneltablo[t.resim] = {i=sira,t="t"}
	
	return t.resim
end
function guiCreateTab(yazi,parent,alanrenk)
	local ind = geneltablo[parent]
	local t = gui["t"][ind.i]
	local sira = #t.tabciklar+1
	if not t.tabciklar[sira] then t.tabciklar[sira] = {} end
	local tab = t.tabciklar[sira]
	if not alanrenk or string.len(alanrenk) > 6 then
		alanrenk =  "1a1a1a" 
	end
	tab.alanrenk = tema["t"].tabselectcolor
	local ox,_ = guiGetPosition(t.tabciklar[sira-1].arka,false) 
	local og,_ = guiGetSize(t.tabciklar[sira-1].arka,false)
	local tabciklar_arka_g,_ = _guiGetSize(t.tabciklar_arka,false)
	local tab_width = utf8.len(yazi)*8
	_guiSetSize(t.tabciklar_arka,tabciklar_arka_g+tab_width,20,false)
	local new_x = (ox+og)
	tab.arka = guiCreateStaticImage(new_x,0,tab_width,20,bosresim,false,t.tabciklar_arka)
	renk(tab.arka,"1a1a1a")
	tab.yazi = guiCreateLabel(0,0,tab_width,20,yazi,false,tab.arka)
	guiSetFont(tab.yazi,tema["t"].fonts.Roboto or "default-bold-small")
	guiLabelSetHorizontalAlign(tab.yazi, "center") guiLabelSetVerticalAlign(tab.yazi, "center")
	tab.alan = guiCreateStaticImage(0,20,t.g,t.u-20,bosresim,false,parent)
	renk(tab.alan,tema["t"].tabalanrenk) _guiSetVisible(tab.alan,false) guiSetAlpha(tab.arka,0.7)
	tabciklar[tab.yazi] = {i=sira,t="t",pi=ind.i,label=true}
	tabciklar[tab.alan] = {i=sira,t="t",pi=ind.i}
	if sira == 1 then guiSetSelectedTab(parent,tab.alan) end
	return tab.alan
end
function guiSetSelectedTab(tabpanel,tab)
	local t = getTabPanel(tabpanel)
	local ttab = getTab(t,tab)
	if t.secili then 
		local ttab = getTab(t,t.secili)
		_guiSetVisible(t.secili,false)
		guiSetAlpha(ttab.arka,0.7)
		renk(ttab.arka,"1a1a1a")
		ttab.secili = nil
	end	
	_guiSetVisible(tab,true)	
	guiSetAlpha(ttab.arka,1)
	renk(ttab.arka,ttab.alanrenk)
	ttab.secili = true
	t.secili = tab
end
function guiGetSelectedTab(tabpanel)
	local t = getTabPanel(tabpanel)
	return t.secili
end
function guiDeleteTab(tab,tabpanel)
	local t = getTabPanel(tabpanel)
	local ttab,sira = getTab(t,tab)
	if not ttab then return false end
	if isElement(ttab.arka) then _destroyElement(ttab.arka) end
	table.remove(t.tabciklar,sira)
	for i=1,#t.tabciklar do
		local ox,_ = guiGetPosition(t.tabciklar[i-1].arka,false) 
		local og,_ = guiGetSize(t.tabciklar[i-1].arka,false)
		local tabciklar_arka_g,_ = _guiGetSize(t.tabciklar_arka,false)
		_guiSetSize(t.tabciklar_arka,tabciklar_arka_g+og,20,false)
		guiSetPosition(t.tabciklar[i].arka,ox+og,0,false)
	end
	guiTabSetHorizontalAlign(tabpanel,t.align or "left")
end
function guiTabSetHorizontalAlign(elm,align)
	local ind = geneltablo[elm]
	if not ind then return end
	if ind.t ~= "t" then return end
	local t = gui["t"][ind.i]
	if not t.tabciklar_arka then return end
	local g,_ = _guiGetSize(t.tabciklar_arka,false)
	t.align = align
	
	_guiSetPosition(t.tabciklar_arka,(align=="left" and 0) or (align=="center" and (t.g-g)/2 or (t.g-g)),0,false)
end
addEventHandler("onClientGUIClick", resourceRoot, function()
	local t = tabciklar[source]
	if t and t.label then
		guiSetSelectedTab(gui[t.t][t.pi].resim,gui[t.t][t.pi].tabciklar[t.i].alan)
		triggerEvent("onClientGUITabSwitched", gui[t.t][t.pi].tabciklar[t.i].alan, gui[t.t][t.pi].tabciklar[t.i].alan)
	end
end)
function getTabPanel(element)
	if type(element) ~= "table" then
		return getGuiElement(element)
	else
		return element
	end	
end
function getTab(tabpanel,element)
	local sira = tabciklar[element] 
	return gui["t"][sira.pi].tabciklar[sira.i],sira.i
end

