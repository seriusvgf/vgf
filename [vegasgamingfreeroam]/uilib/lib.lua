geneltablo,kullanilanscriptler,tabciklar = {},{},{}
--
sourceResource = getThisResource()

--
addEvent("uilib:pencerekapatıldı",true)
addEvent("uilib:onClientGUICheckboxSelected",true)
--
gui = {
    ["w"] = {},
    ["b"] = {},
    ["t"] = {},
    ["m"] = {},
    ["c"] = {},
    ["r"] = {},
    ["e"] = {},
    ["g"] = {},
	["load"] = {},
    {"tab"},
    ["sq"] = {},
}
--
_guiCreateButton = guiCreateButton
_guiCreateWindow = guiCreateWindow
_guiCreateEdit = guiCreateEdit
_guiCreateMemo = guiCreateMemo
_guiCreateLabel = guiCreateLabel
_guiCreateGridList = guiCreateGridList
_guiGetPosition = guiGetPosition
_guiSetPosition = guiSetPosition
_guiGetSize = guiGetSize
_guiSetSize = guiSetSize
_guiSetText = guiSetText
_guiGetText = guiGetText
_guiSetEnabled = guiSetEnabled
_guiSetVisible = guiSetVisible
_destroyElement = destroyElement
_guiWindowSetSizable = guiWindowSetSizable
_guiWindowSetMovable = guiWindowSetMovable
_guiWindowIsMovable = guiWindowIsMovable
--
sx,sy = guiGetScreenSize()
--


function isResourceRunning(resName)
	local res = getResourceFromName(resName)
	return (res) and (getResourceState(res) == "running")
end


if isResourceRunning("core") then 
	vegastema = exports["core"]:getVegasServerDataClient("sunucutema")
else 
	vegastema = "1c4d99"
end

--

tema = {
    ["w"] = {
        cerceve = "181818",
        baslik  = "181818",
        fonts = {
            Bebas = guiCreateFont("dosyalar/RobotoB.ttf",10),
        },
    },
	["load"] = {
        cerceve = "181818",
        kenarlar  = vegastema,
        fonts = {
            Roboto = guiCreateFont("dosyalar/RobotoB.ttf",10),
        },
    },
    ["b"] = {
        buttonkenarnormalcolor = "363636",
        buttonkenarhovercolor  = vegastema,
        fonts = {
            Roboto = guiCreateFont("dosyalar/Roboto.ttf",10),
        },
    },
    ["t"] = {
        tabalanrenk = "262626",
        tabselectcolor = vegastema,
        tabcizgi  = vegastema,
        fonts = {
            Roboto = guiCreateFont("dosyalar/Roboto.ttf",10),
        },
    },
    ["c"] = {
        checkcolor = vegastema,
        uncheckedcolor = "363636",
        fonts = {
            Roboto = guiCreateFont("dosyalar/Roboto.ttf",10),
        },
    },
    ["r"] = {
        radcheckcolor = vegastema,
        raduncheckedcolor = "363636",
        fonts = {
            Roboto = guiCreateFont("dosyalar/Roboto.ttf",10),
        },
    },
    ["e"] = {
        editkenarnormalcolor = "363636",
        editkenarhovercolor  = vegastema,
        fonts = {
            Roboto = guiCreateFont("dosyalar/Roboto.ttf",10),
        },
    },
	["m"] = {
        memokenarnormalcolor = "363636",
        memokenarhovercolor  = vegastema,
        fonts = {
            Roboto = guiCreateFont("dosyalar/Roboto.ttf",10),
        },
    },
	["g"] = {
        listekenarnormalcolor = "363636",
        listekenarhovercolor  = vegastema,
        fonts = {
            Roboto = guiCreateFont("dosyalar/Roboto.ttf",8),
        },
    },
    ["sq"] = {
        squarecolor = "212020",
        squarearrowhovercolor = vegastema,
        squarearrownormalcolor = "363636",
    },
}
--
function resimOlustur(isim,a)
	if fileExists(isim..".png") then return isim..".png" end
	local texture = dxCreateTexture(1,1) 
	local pixels = dxGetTexturePixels(texture) 
	local r,g,b,a = 255,255,255,a or 255 
	dxSetPixelColor(pixels,0,0,r,g,b,a) 
	dxSetTexturePixels(texture, pixels) 
	local pxl = dxConvertPixels(dxGetTexturePixels(texture),"png") 
	local nImg = fileCreate(isim..".png") 
	fileWrite(nImg,pxl) 
	fileClose(nImg)
	return isim..".png" 
end
--
bosresim = resimOlustur("vgfui") -- silme
--
function elementerenkver(resim,hex)
	guiSetProperty(resim,"ImageColours","tl:FF"..hex.." tr:FF"..hex.." bl:FF"..hex.." br:FF"..hex)
end
--
function getParentSize(parent)
	local px,pu = sx,sy
	if parent then px,pu= guiGetSize(parent,false) end
	return px,pu
end
--
function getGuiElement(elm)
	local indeks = geneltablo[elm]
	--if tabciklar[elm] then return tabciklar[elm] end
	return (indeks and indeks.t and gui[indeks.t][indeks.i]) or indeks
end
--
local clickedWindow = nil
function MouseDown(btn, x, y)
    local sira = getGuiElement(source)
    if sira then 
        if btn == "left" and sira.isHeader and gui["w"][sira.i].move then
            clickedWindow = gui["w"][sira.i].resim
            local ex,ey = _guiGetPosition( clickedWindow, false )
            offsetPos = { x - ex, y - ey };
            addEventHandler( "onClientCursorMove",root,cursorMove)
        end
    end
end
--
function MouseUp(btn, x, y)
	if btn == "left" then
        if (clickedWindow) then
            clickedWindow = nil
            removeEventHandler( "onClientCursorMove",root,cursorMove)
        end	
    end
end
--
addEventHandler("onClientClick", root, function(button,state)
	if state == "up" then
		if (clickedButton or resizeWindow) then
			MouseUp(button)
		end	
	end	
end)
--
addEventHandler("onClientMouseEnter", resourceRoot, function()
    local sira = getGuiElement(source)
    if sira then
        if sira.isButton and source == gui["b"][sira.i].label  then  
            for i,v in pairs(gui["b"][sira.i].kenarlar) do 
                elementerenkver(v,sira.renkler.hover) 
                guiSetAlpha(v,0.8)
            end
            guiSetAlpha(gui["b"][sira.i].label,1)
        end
		if sira.isEdit and source == gui["e"][sira.i].edit  then  
            for i,v in pairs(gui["e"][sira.i].kenarlar) do 
                elementerenkver(v,sira.renkler.hover) 
                guiSetAlpha(v,0.8)
            end
            guiSetAlpha(gui["e"][sira.i].edit,1)
        end
		if sira.isMemo and source == gui["m"][sira.i].memo  then  
            for i,v in pairs(gui["m"][sira.i].kenarlar) do 
                elementerenkver(v,sira.renkler.hover) 
                guiSetAlpha(v,0.8)
            end
            guiSetAlpha(gui["m"][sira.i].memo,1)
        end
		if sira.isGridList and source == gui["g"][sira.i].liste  then  
            for i,v in pairs(gui["g"][sira.i].kenarlar) do 
                elementerenkver(v,sira.renkler.hover) 
                guiSetAlpha(v,0.8)
            end
            guiSetAlpha(gui["g"][sira.i].liste,1)
        end
      
        if sira.isCheckbox then 
            getselected = sira.selected
            if getselected then 
                guiSetAlpha(sira.label,0.6)
                guiSetAlpha(sira.kutu,0.3)
                guiSetAlpha(sira.tik,0.3)
            else
                guiSetAlpha(sira.kutu,0.3)
                guiSetAlpha(sira.label,0.85)
            end
        end
        if sira.isSquare then 
            renk(sira.arrow,sira.arrowhovercolor)
            guiSetAlpha(sira.square,0.7)
        end
        if sira.isRadioButton then 
            getselected = gui["r"][sira.i].selected
            if getselected == false then 
                if getselected then 
                    guiSetAlpha(gui["r"][sira.i].dolukutu,0.3)
                    guiSetAlpha(gui["r"][sira.i].label,0.6)
                else
                    guiSetAlpha(gui["r"][sira.i].boskutu,0.3)
                    guiSetAlpha(gui["r"][sira.i].label,0.85)
                end 
            end
        end
        if sira.isClose and source == gui["w"][sira.i].closeicon then  elementerenkver(gui["w"][sira.i].closeicon,"c93a3a") end
    end
end)
addEventHandler("onClientMouseLeave", resourceRoot, function()
    local sira = getGuiElement(source)
    if sira then 
        if sira.isButton and source == gui["b"][sira.i].label  then  
            for i,v in pairs(gui["b"][sira.i].kenarlar) do 
                elementerenkver(v,tema["b"].buttonkenarnormalcolor) 
                guiSetAlpha(v,0.5)
            end
            guiSetAlpha(gui["b"][sira.i].label,0.7)
        end
		if sira.isEdit and source == gui["e"][sira.i].edit  then  
            for i,v in pairs(gui["e"][sira.i].kenarlar) do 
                elementerenkver(v,tema["e"].editkenarnormalcolor) 
                guiSetAlpha(v,0.5)
            end
            guiSetAlpha(gui["e"][sira.i].edit,0.7)
        end
		if sira.isMemo and source == gui["m"][sira.i].memo  then  
            for i,v in pairs(gui["m"][sira.i].kenarlar) do 
                elementerenkver(v,tema["m"].memokenarnormalcolor) 
                guiSetAlpha(v,0.5)
            end
            guiSetAlpha(gui["m"][sira.i].memo,0.7)
        end
		if sira.isGridList and source == gui["g"][sira.i].liste  then  
            for i,v in pairs(gui["g"][sira.i].kenarlar) do 
                elementerenkver(v,tema["g"].listekenarnormalcolor) 
                guiSetAlpha(v,0.5)
            end
            guiSetAlpha(gui["g"][sira.i].liste,0.7)
        end

        if sira.isSquare then 
            renk(sira.arrow,sira.arrownormalcolor)
            guiSetAlpha(sira.square,0.9)
        end
     
        if sira.isCheckbox then 
            getselected = sira.selected
            if getselected then 
               guiSetAlpha(sira.kutu,0.6)
               guiSetAlpha(sira.label,0.85)
               guiSetAlpha(sira.tik,0.8)
            else
               guiSetAlpha(sira.kutu,0.6)
               guiSetAlpha(sira.label,0.6)
            end
        end
       
        if sira.isRadioButton then 
            getselected = gui["r"][sira.i].selected
            if getselected == false then 
                if getselected then 
                    guiSetAlpha(gui["r"][sira.i].dolukutu,0.7)
                    guiSetAlpha(gui["r"][sira.i].label,0.85)
                else
                    guiSetAlpha(gui["r"][sira.i].boskutu,0.7)
                    guiSetAlpha(gui["r"][sira.i].label,0.6)
                end
            end
        end
        if sira.isClose and source == gui["w"][sira.i].closeicon then elementerenkver(gui["w"][sira.i].closeicon,"ffffff") end
    end
end)
--

--
addEventHandler("onClientGUIClick", root, function()
    local sira = getGuiElement(source)
    if sira then 
        if sira and sira.isCheckbox then 
            guiCheckBoxSetSelected(source,not sira.selected)
        end
        if sira.isRadioButton then 
            if gui["r"] then 
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
        if sira.isEditbox then 
            --
            --gui["e"][sira.i].active = source
            --[[
                 gui["e"][sira.i].active = false
                for i,v in pairs(gui["e"][sira.i].kenarlar) do 
                    elementerenkver(v,sira.renkler.normal) 
                    guiSetAlpha(v,0.8)
                end
                guiSetAlpha( gui["e"][sira.i].label,0.6)
                outputChatBox("Edit Devre Dışı")
            else
                gui["e"][sira.i].active = true
                guiSetAlpha( gui["e"][sira.i].label,0.8)
                for i,v in pairs(gui["e"][sira.i].kenarlar) do 
                    elementerenkver(v,sira.renkler.hover) 
                    guiSetAlpha(v,0.8)
                end
                --
                outputChatBox("Edit Aktif")
            ]]
          
            --

       
        end
        if sira.isClose and source == gui["w"][sira.i].closeicon then 
            guiSetVisible(gui["w"][sira.i].resim, false)
            showCursor(false)  
            triggerEvent("uilib:pencerekapatıldı",gui["w"][sira.i].resim)
        end
    end
end)
--
addEventHandler("onClientGUIMouseUp", resourceRoot,MouseUp)
addEventHandler("onClientGUIMouseDown", resourceRoot,MouseDown) 
--
function cursorMove(_, _, x, y)
	if clickedWindow then
		_guiSetPosition(clickedWindow,x-offsetPos[1],y-offsetPos[2], false )
	end
end
--
function guiWindowSetMovable(element, bool)
	local sira = getGuiElement(element)
	if sira then
		sira.move = bool
	else
		return _guiWindowSetMovable(element, bool)
	end	
end
function guiWindowIsMovable(element, bool)
	local sira = getGuiElement(element)
	if sira then
		return sira.move
	else
		_guiWindowIsMovable(element, bool)
	end	
end
--
function guiSetVisible(element, bool)
    if not element then return end
	local sira = getGuiElement(element)
    if sira then 
        if sira.isSquare then 
            _guiSetVisible(sira.square,bool)
        end
    end
	return _guiSetVisible(sira and (sira.pi and gui["t"][sira.pi].tabciklar[sira.i].arka or sira.resim) or (element),bool)
end
--
function destroyElement(element)
	local tip = getElementType(element)
	if tip:find("gui-") then
		local sira = geneltablo[element]
		if sira and sira.t then
			_destroyElement(gui[sira.t][sira.i].resim)
			gui[sira.t][sira.i]=nil
		else
			return _destroyElement(element)
		end	
	else
		return _destroyElement(element)
	end	
end	
--
addEventHandler("onClientResourceStop", root, function(sc)
	if kullanilanscriptler[sc] and sc ~= getThisResource() then
		for tablo,v in pairs(kullanilanscriptler[sc]) do
			for a,s in pairs(v) do 
				local sira,element = unpack(s)
				if isElement(element) then _destroyElement(element) end
				if gui[tablo][sira] then gui[tablo][sira]= nil end
			end	
		end
		kullanilanscriptler[sc] = nil
	end
end)
--
function RGBToHex(red, green, blue, alpha)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function hex2rgb(hex) 
	hex = hex:gsub("#","") 
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)) 
  end 

function rgb2hex(r,g,b) 
	return string.format("%02X%02X%02X", r,g,b) 
end 

function renk(resim,hex)
	guiSetProperty(resim,"ImageColours","tl:FF"..hex.." tr:FF"..hex.." bl:FF"..hex.." br:FF"..hex)
end

local r,g,b = hex2rgb(vegastema)
local Roboto1 = dxCreateFont("dosyalar/Roboto.ttf",9)
function customCreateLoaderBar(yazi1,yazi2,x,y,w,h,yuzde,ilerleme)
	local yuzde = yuzde or true
	local ilerleme = ilerleme or 30
	--
	dxDrawRoundedRectangle(x,y,w,h,tocolor(28, 28, 28,210),{ 0.28, 0.28, 0.28, 0.28 })
	if yuzde then 
		dxDrawRoundedRectangle(x,y,(w/100)*ilerleme,h,tocolor(b,g,r,255),{ 0.28, 0.28, 0.28, 0.28 })
	end
	--
	if yazi1 then 
		dxDrawText(yazi1,x,y-5,w+x,y-20,tocolor(210,210,210,190),0.88,Roboto1,"center","center", false, false, false, true)
	end
	if yazi2 then 
		dxDrawText(yazi2,x,y-5,w+x,y+34,tocolor(210,210,210,190),0.89,Roboto1,"center","center")
	end
	dxDrawImage(x+3,y+3.3,22,22,"dosyalar/spin.png",getTickCount()%360,0,0,tocolor(255,255,255,180))
end

function guiSetText(element, yazi)
	local sira = getGuiElement(element)
	if sira then 
		if sira.basarka and sira.label then
			_guiSetText(sira.label, yazi)
			guiLabelSetHorizontalAlign(sira.label, "center") guiLabelSetVerticalAlign(sira.label, "center")
			return
		end	
        --
		if sira.isCheckbox and sira.label then 
			_guiSetText(sira.label, yazi)
			else
			_guiSetText(element, yazi)
		end
		--
	else
		return _guiSetText(element, yazi)
	end
end

