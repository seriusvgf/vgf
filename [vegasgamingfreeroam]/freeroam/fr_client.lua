loadstring(exports["uilib"]:getLoadUI())()

local commands = {}
local font 
local kapilar = {1,2,3,4,5,6,7,8}
local customSpawnTable = false
local allowedStyles =
{
	[4] = true,
	[5] = true,
	[6] = true,
	[7] = true,
	[15] = true,
	[16] = true,
}
local internallyBannedWeapons = -- Fix for some debug warnings
{
	[19] = true,
	[20] = true,
	[21] = true,
}
local server = setmetatable(
		{},
		{
			__index = function(t, k)
				t[k] = function(...) triggerServerEvent('onServerCall', resourceRoot, k, ...) end
				return t[k]
			end
		}
	)
guiSetInputMode("no_binds_when_editing")
setCameraClip(true, false)

local antiCommandSpam = {} -- Place to store the ticks for anti spam:
local playerGravity = getGravity() -- Player's current gravity set by gravity window --
local knifeRestrictionsOn = false

-- Local settings received from server
local g_settings = {}
local _addCommandHandler = addCommandHandler
local _setElementPosition = setElementPosition

if not (g_PlayerData) then
    g_PlayerData = {}
end

-- Settings are stored in meta.xml
function freeroamSettings(settings)
	if settings then
		g_settings = settings
		for _,gui in ipairs(disableBySetting) do
			--guiSetEnabled(getControl(gui.parent,gui.id),g_settings["gui/"..gui.id])
		end
	end
end

-- Store the tries for forced global cooldown
local global_cooldown = 0
function isFunctionOnCD(func, exception)
	local tick = getTickCount()
	-- check if a global cd is active
	if g_settings.command_spam_protection and global_cooldown ~= 0 then
		if tick - global_cooldown <= g_settings.command_spam_ban_duration then
			local duration = math.ceil((g_settings.command_spam_ban_duration-tick+global_cooldown)/1000)
			errMsg("Komut kullanımın " .. duration .." saniye yasaklandı")
			return true
		end
	end

	if not g_settings.command_spam_protection then
		return false
	end

	if not antiCommandSpam[func] then
		antiCommandSpam[func] = {time = tick, tries = 1}
		return false
	end

	local oldTime = antiCommandSpam[func].time
	if (tick-oldTime) > 2000 then
		antiCommandSpam[func].time = tick
		antiCommandSpam[func].tries = 1
		return false
	end

	antiCommandSpam[func].tries = antiCommandSpam[func].tries + 1

	if exception and (antiCommandSpam[func].tries < g_settings.g_settings.tries_required_to_trigger_low_priority) then
		return false
	end

	if (exception == nil) and (antiCommandSpam[func].tries < g_settings.tries_required_to_trigger) then
		return false
	end

	-- activate a global command cooldown
	global_cooldown = tick
	antiCommandSpam[func].tries = 0
	--errMsg("Failed, do not spam the commands!")
	return true
end

local function executeCommand(cmd,...)

	local func = commands[cmd]
	cmd = string.lower(cmd)
	if not commands[cmd] then return end
	if table.find(g_settings["command_exception_commands"],cmd) then
		func(cmd,...)
		return
	end
	if isFunctionOnCD(func) then return end
	func(cmd,...)

end

local function addCommandHandler(cmd,func)

	commands[cmd] = func
	_addCommandHandler(cmd,executeCommand,false)

end

local function cancelKnifeEvent(target)

	if knifingDisabled then
		cancelEvent()
		--errMsg("Knife restrictions are in place")
	end

	if g_PlayerData[localPlayer].knifing or g_PlayerData[target].knifing then
		cancelEvent()
	end

end

local function resetKnifing()

	knifeRestrictionsOn = false

end

local function setElementPosition(element,x,y,z)

	if g_settings["weapons/kniferestrictions"] and not knifeRestrictionsOn then
		knifeRestrictionsOn = true
		setTimer(resetKnifing,5000,1)
	end

	_setElementPosition(element,x,y,z)

end


---------------------------
-- Gardrop
---------------------------

local outfitList
local outfits

function initOutfits()
	outfitList = wndOutfits.controls[1].element
	if outfits then return end
	loadOutfits()
	addEventHandler('onClientGUIDoubleClick', outfitList, loadClothes)
end

function loadOutfits()
	outfits = {}

	local xml = xmlLoadFile('outfits.xml')
	if not xml then
		xml = xmlCreateFile('outfits.xml', 'catalog')
	end
	guiGridListClear(outfitList)
	for i,child in ipairs (xmlNodeGetChildren(xml) or {}) do
		local row = guiGridListAddRow(outfitList)
		guiGridListSetItemText(outfitList, row, 1, tostring(xmlNodeGetAttribute(child, 'name')), false, false)
		outfits[row+1] = {}
		for j=0,17 do
			table.insert(outfits[row+1], j, xmlNodeGetAttribute(child, 'c'..j))
		end
	end
end

function saveOutfits()
	if fileExists('outfits.xml') then
		fileDelete('outfits.xml')
	end
	local xml = xmlCreateFile('outfits.xml', 'catalog')
	for row=0,(guiGridListGetRowCount(outfitList)-1) do
		local child = xmlCreateChild(xml, 'outfit')
		xmlNodeSetAttribute(child, 'name', guiGridListGetItemText(outfitList, row, 1))
		for k,v in pairs (outfits[row+1]) do
			xmlNodeSetAttribute(child, 'c'..k,v)
		end
	end
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end

function saveOutfit()
	local name = getControlText(wndOutfits,'outfitname')
	if name ~= "" then
		local row = guiGridListAddRow(outfitList)
		outfits[row+1] = {}
		for i=0,17 do
			local texture,model = getPedClothes (localPlayer, i)
			if texture and model then
				table.insert(outfits[row+1], i, texture ..', '.. model)
			else
				table.insert(outfits[row+1], i, 'none')
			end
		end
		guiGridListSetItemText(outfitList, row, 1, name, false, false)
		setControlText(wndOutfits, 'outfitname', '')
		saveOutfits()
	else
		exports["vg-ustmesaj"]:sendClientMessage('Kaydedeceğiniz kıyafet setinin adını giriniz.',255,0,0)
	end
end

function deleteOutfit()
	local row = guiGridListGetSelectedItem(outfitList)
	if row and row ~= -1 then
		table.remove(outfits, row+1)
		guiGridListRemoveRow(outfitList, row)
		saveOutfits()
	end
end

function loadClothes()
	local row = guiGridListGetSelectedItem(outfitList)
	if row and row ~= -1 then
		for k,v in pairs (outfits[row+1]) do
			if v ~= 'none' then
				local clothes = split(v, ', ')
				server.addPedClothes(localPlayer, clothes[1], clothes[2], k)
			else
				server.removePedClothes(localPlayer, k)
			end
		end
	end
end

wndOutfits = {
	'wnd',
	text = 'KAYDETTİĞİM KIYAFETLERİM',
	width = 250,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='outfits',
			width=230,
			height=250,
			y=42,
			columns={
				{text='Mevcut Kayıtlı Kıyafetler', attr='name', width=0.85},
			}
		},
		{"br"},
		{'txt', id='outfitname', text='Kıyafet adı girin...',y=295, width=230},
		{"br"},
		{'btn', id='KAYDET', onclick=saveOutfit, width=90,y=325, height=22},
		{'btn', id='KALDIR', onclick=deleteOutfit,x=150, width=90,y=325, height=22},
		{"br"},
		{'btn', id='KAPAT', closeswindow=true,  width=230,y=350, height=22}
	},
	oncreate = initOutfits
}


---------------------------
-- Question window
---------------------------
-- SORULAR --
function showSSS(leaf)
    if leaf.cevap then
        setControlText(wndSSS, 'sorucevap', leaf.cevap)
    end
end

wndSSS = {
    'wnd',
    text = 'SIKÇA SORULAN SORULAR',
    width  = 450,
	height = 650,
    controls = {
        {
            'lst',
            id='Mevcut Sorular',
			width=430,
			height=250,
			y =42,
            columns={
                {text='Mevcut Sorular', attr='name', width=0.9}
            },
            rows={xml='data/question.xml', attrs={'id', 'name', 'cevap'}},
            onitemclick=showSSS,
            onitemdoubleclick=selectSSS
        },
		{"br"},
		{"br"},
        {'lbl', id='sorucevap', text='» Üst listede en fazla sorulan sorular yer almaktadır.',x=15,y=310, width=505,height=110},
        {'btn', id='Paneli Kapat',align = "left", closeswindow=true, x=10, height  = 25, width = 430},
    },
	oncreate = intShowSS,
}


---------------------------
-- Set skin window
---------------------------
function skinInit()
	setControlNumber(wndSkin, 'skinid', getElementModel(localPlayer))
end

function showSkinID(leaf)
	if leaf.id then
		setControlNumber(wndSkin, 'skinid', leaf.id)
	end
end

function applySkin()
	local skinID = getControlNumber(wndSkin, 'skinid')
	if skinID then
		server.setMySkin(skinID)
		fadeCamera(true)
	end
end

wndSkin = {
	'wnd',
	text = 'KARAKTERLER',
	width = 265,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='skinlist',
			width=245,
			height=360,
			x=08,
			y=45,
			columns={
				{text='Mevcut Karakterler', attr='name'}
			},
			rows={xml='data/skins.xml', attrs={'id', 'name'}},
			onitemclick=showSkinID,
			onitemdoubleclick=applySkin
		},
		{"br"},
		{'txt', id='skinid', text='', x=9,y=410,width=50,height=22},
		{'btn', id='SEÇ', onclick=applySkin,y=410,width=70, height=22},
		{'btn', id='KAPAT', closeswindow=true, y=410,width=70, height=22}
	},
	oncreate = skinInit
}

function setSkinCommand(cmd, skin)
	local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end
	skin = skin and tonumber(skin)
	if skin then
		server.setMySkin(skin)
		fadeCamera(true)
		closeWindow(wndSpawnMap)
		closeWindow(wndSetPos)
	end
end
addCommandHandler('setskin', setSkinCommand)
addCommandHandler('ss', setSkinCommand)

---------------------------
--- Set animation window
---------------------------

function applyAnimation(leaf)
	--if exports["ZG-GarageSystem"]:isGarageActive() == true then return end
	--if getElementData(localPlayer,"eventsystem:paintballspawn") == true then  return false end
	--if getElementData(localPlayer,"işlemyapıor") == true then return end
	if type(leaf) ~= 'table' then
		leaf = getSelectedGridListLeaf(wndAnim, 'animlist')
		if not leaf then
			return
		end
	end
	server.setPedAnimation(localPlayer, leaf.parent.name, leaf.name, true, true)
end

function stopAnimation()
	--if exports["ZG-GarageSystem"]:isGarageActive() == true then return end
	local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end
	if getElementData(localPlayer,"eventsystem:paintballspawn") == true then  return false end
	if getElementData(localPlayer,"işlemyapıor") == true then return end
	server.setPedAnimation(localPlayer, false)
end
addCommandHandler("stopanim", stopAnimation)
bindKey("lshift", "down", stopAnimation)

wndAnim = {
	'wnd',
	text = 'HAREKETLER',
	width = 290,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='animlist',
			width=270,
			height=365,
			y=43,
			columns={
				{text='Mevcut Hareketler', attr='name'}
			},
			rows={xml='data/animations.xml', attrs={'name'}},
			expandlastlevel=false,
			onitemdoubleclick=applyAnimation,
			DoubleClickSpamProtected=true,
		},
		{"br"},
		{'btn', id='BAŞLAT', onclick=applyAnimation, ClickSpamProtected=true, width=65, y=415,height=22},
		{'btn', id='DURDUR', onclick=stopAnimation, x=110,width=65, y=415,height=22},
		{'btn', id='KAPAT', closeswindow=true, x=215,width=65, y=415,height=22}
	}
}

addCommandHandler('anim',
	function(command, lib, name)
	local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end
	if not getElementData(localPlayer,"Drop") then
           errMsg("Bu komutu sadece drop alanında kullanabilirsin.")
         return
     end 
	if getElementData(localPlayer, 'Turf') == true then return false end
		if lib and name and (
			(lib:lower() == "finale" and name:lower() == "fin_jump_on") or
			(lib:lower() == "finale2" and name:lower() == "fin_cop1_climbout")
		) then
			errMsg('This animation may not be set by command.')
			return
		end
		server.setPedAnimation(localPlayer, lib, name, true, true)
	end
)

function oturCommand()
--if exports["ZG-GarageSystem"]:isGarageActive() == true then return end
--if getElementData(localPlayer,"işlemyapıor") == true then return end
server.setPedAnimation(localPlayer,"ped","SEAT_idle",-1,true,false,false)
end
addCommandHandler("otur", oturCommand)


---------------------------
-- Walk style
--------------------------- 
function applyWalkStyle( leaf )
    if type( leaf ) ~= 'table' then
        leaf = getSelectedGridListLeaf( wndWalking, 'walkStyle' )
        if not leaf then
            return
        end
    end
    server.setPedWalkingStyle(localPlayer, leaf.id)
end
 
function stopWalkStyle()
    server.setPedWalkingStyle(localPlayer, 0)
end
 
wndWalking = {
    'wnd',
    text = 'YÜRÜYÜŞ STİLLERİ',
    width = 250,
	x=-20,
    controls = {
        {
            'lst',
            id = 'walkStyle',
            width = 230,
			y=42,
            height = 300,
            columns = {
                { text = 'Mevcut Stiller', attr = 'name' }
            },
            rows = { xml = 'data/y_stilleri.xml', attrs = { 'id', 'name' } },
            onitemdoubleclick = applyWalkStyle
        },
      	{'btn', id = 'KULLAN', onclick = applyWalkStyle,ClickSpamProtected=true,width=65, y=350,height=22 },
		{'btn', id='KALDIR', onclick=stopWalkStyle, x=92,width=65, y=350,height=22},
		{'btn', id='KAPAT', closeswindow=true, x=175,width=65, y=350,height=22}
    }
}


---------------------------
-- Fighting style
---------------------------

function applyFightStyle( leaf )
    if type( leaf ) ~= 'table' then
        leaf = getSelectedGridListLeaf( wndFighting, 'fightStyle' )
        if not leaf then
            return
        end
    end
    server.setPedFightingStyle( localPlayer, leaf.id )
end
 
function stopFightStyle()
    server.setPedFightingStyle( localPlayer, 0 )
end

wndFighting = {
    'wnd',
    text = "DÖVÜŞ STİLLERİ",
    width = 250,
	height = 320,
    controls = {
        {
            'lst',
            id = 'fightStyle',
            width = 230,
            height = 140,
			y=42,
            columns = {
                { text = 'Stiller Listesi', attr = 'name' }
            },
            rows = { xml = 'data/d_stilleri.xml', attrs = { 'id', 'name' } },
            onitemdoubleclick = applyFightStyle
        },
          { 'btn', id = 'KULLAN', onclick = applyFightStyle,y=188, height=22, width=70 },
          { 'btn', id = 'KALDIR', onclick = stopFightStyle,x=90,y=188, height=22, width=70},
          { 'btn', id = 'KAPAT', closeswindow = true,x=170, y=188, height=22, width=70 }
    }
}
addCommandHandler('setstyle',
	function(cmd, style)
	local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end
	--if exports["ZG-GarageSystem"]:isGarageActive() == true then return end
		style = style and tonumber(style) or 7
		if allowedStyles[style] then
			server.setPedFightingStyle(localPlayer, style)
		end
	end
)
---------------------------
-- Clothes window
---------------------------
function clothesInit()
	if getElementModel(localPlayer) ~= 0 then
		errMsg('CJ (Carl Johnson) olmalısın. [ /ss 0 ]')
		closeWindow(wndClothes)
		return
	end
	if not g_Clothes then
		triggerServerEvent('onClothesInit', resourceRoot)
	end
end

addEvent('onClientClothesInit', true)
addEventHandler('onClientClothesInit', resourceRoot,
	function(clothes)
		g_Clothes = clothes.allClothes
		for i,typeGroup in ipairs(g_Clothes) do
			for j,cloth in ipairs(typeGroup.children) do
				if not cloth.name then
					cloth.name = cloth.model .. ' - ' .. cloth.texture
				end
				cloth.wearing =
					clothes.playerClothes[typeGroup.type] and
					clothes.playerClothes[typeGroup.type].texture == cloth.texture and
					clothes.playerClothes[typeGroup.type].model == cloth.model
					or false
			end
			table.sort(typeGroup.children, function(a, b) return a.name < b.name end)
		end
		bindGridListToTable(wndClothes, 'clothes', g_Clothes, false)
	end
)

function clothListClick(cloth)
	setControlText(wndClothes, 'addremove', cloth.wearing and 'Çıkar' or 'Giy')
end

function applyClothes(cloth)
	if not cloth then
		cloth = getSelectedGridListLeaf(wndClothes, 'clothes')
		if not cloth then
			return
		end
	end
	if cloth.wearing then
		cloth.wearing = false
		setControlText(wndClothes, 'addremove', 'Giy')
		server.removePedClothes(localPlayer, cloth.parent.type)
	else
		local prevClothIndex = table.find(cloth.siblings, 'wearing', true)
		if prevClothIndex then
			cloth.siblings[prevClothIndex].wearing = false
		end
		cloth.wearing = true
		setControlText(wndClothes, 'addremove', 'Çıkar')
		server.addPedClothes(localPlayer, cloth.texture, cloth.model, cloth.parent.type)
	end
end

function sifirlaClothes()
triggerServerEvent ( "kiyafetSifirlama", localPlayer)
end

wndClothes = {
	'wnd',
	text = 'CJ KIYAFETLERİ',
	x = -20,
	y = 0.2,
	width = 350,
	controls = {
		{
			'lst',
			id='clothes',
			width=330,
			y=42,
			height=380,
			columns={
				{text='Mevcut Kıyafetler', attr='name', width=0.6},
				{text='', attr='wearing', enablemodify=true, width=0.3}
			},
			rows={
				{name='Giysi Listesi Alınıyor...'}
			},
			onitemclick=clothListClick,
			onitemdoubleclick=applyClothes,
			DoubleClickSpamProtected=true,
		},
		{'br'},
		{'btn', text='Seçilen Kıyafeti Çıkar', id='addremove', height=22,y=435, width=330, onclick=applyClothes, ClickSpamProtected=true, x=10},
	    {'btn', id='Kıyafetleri Sıfırla', onclick=sifirlaClothes, height=22,y=460, width=330},
		{'btn', id='Menüyü Kapat', closeswindow=true, height=22, width=330,y=485}
	},
	oncreate = clothesInit
}

function addClothesCommand(cmd, type, model, texture)
	local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end
	type = type and tonumber(type)
	if type and model and texture then
		server.addPedClothes(localPlayer, texture, model, type)
	end
end
addCommandHandler('addclothes', addClothesCommand)
addCommandHandler('ac', addClothesCommand)

function removeClothesCommand(cmd, type)
	local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end
	type = type and tonumber(type)
	if type then
		server.removePedClothes(localPlayer, type)
	end
end
addCommandHandler('removeclothes', removeClothesCommand)
addCommandHandler('rc', removeClothesCommand)

---------------------------
-- Jetpack toggle
---------------------------
noktalar = {
	{ 1496.52759, -1833.08374, 2516.02661 },
	--{ 1493.3000488281, -1829.8000488281, 2516 },
	--{ 1509.1999511719, -1827.3000488281, 2516 },
}

addCommandHandler("devmode", function()
        setDevelopmentMode(true)
    end
)

function alanagirdi(giren)
	if ( giren == localPlayer ) then
		triggerServerEvent("zafer:jetpacksil",localPlayer)
		--setElementPosition(localPlayer,1508.46606, -1827.74304, 2516.02661)
	--	for _,vehicle in ipairs(getElementsByType("player")) do
	--		destroyElement(vehicle)
	---	end
	end
end

for i,v in pairs(noktalar) do
   drop_konum = createColSphere(v[1], v[2], v[3], 44)
   addEventHandler("onClientColShapeHit",drop_konum,alanagirdi)
end

function toggleJetPack()
local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end
if exports["vg-duel"]:getPlayerDuelData(localPlayer,"durumm") then
	return 
end
if  isElementWithinColShape(localPlayer,drop_konum) then outputChatBox("Dropta iken jetpack kullanamazsın.",255,0,0,true) return end
if getElementData(localPlayer, 'Turf') == true then return false end
	if not doesPedHaveJetPack(localPlayer) then
		server.givePedJetPack(localPlayer)
		--guiCheckBoxSetSelected(getControl(wndMain, 'jetpack'), true)
	else
		server.removePedJetPack(localPlayer)
		--guiCheckBoxSetSelected(getControl(wndMain, 'jetpack'), false)
	end
end

bindKey('j', 'down', toggleJetPack)

addCommandHandler('jetpack', toggleJetPack)
addCommandHandler('jp', toggleJetPack)

---------------------------
-- Set position window
---------------------------
do
	local screenWidth, screenHeight = guiGetScreenSize()
	g_MapSide = (screenHeight * 0.85)
end

function setPosInit()
	local x, y, z = getElementPosition(localPlayer)
	setControlNumbers(wndSetPos, { x = x, y = y, z = z })

	addEventHandler('onClientRender', root, updatePlayerBlips)
end

function fillInPosition(relX, relY, btn)
	if (btn == 'right') then
		closeWindow (wndSetPos)
		return
	end

	local x = relX*6000 - 3000
	local y = 3000 - relY*6000
	local hit, hitX, hitY, hitZ
	hit, hitX, hitY, hitZ = processLineOfSight(x, y, 3000, x, y, -3000)
	setControlNumbers(wndSetPos, { x = x, y = y, z = hitZ or 0 })
end

function setPosClick()
	if setPlayerPosition(getControlNumbers(wndSetPos, {'x', 'y', 'z'})) ~= false then
		if getElementInterior(localPlayer) ~= 0 then
			local vehicle = localPlayer.vehicle
			if vehicle and vehicle.interior ~= 0 then
				server.setElementInterior(getPedOccupiedVehicle(localPlayer), 0)
				local occupants = vehicle.occupants
				for seat,occupant in pairs(occupants) do
					if occupant.interior ~= 0 then
						server.setElementInterior(occupant,0)
					end
				end
			end
			if localPlayer.interior ~= 0 then
				server.setElementInterior(localPlayer,0)
			end
		end
		closeWindow(wndSetPos)
	end
end

local function forceFade()

	fadeCamera(false,0)

end

local function calmVehicle(veh)

	if not isElement(veh) then return end
	local z = veh.rotation.z
	veh.velocity = Vector3(0,0,0)
	veh.turnVelocity = Vector3(0,0,0)
	veh.rotation = Vector3(0,0,z)
	if not (localPlayer.inVehicle and localPlayer.vehicle) then
		server.warpMeIntoVehicle(veh)
	end

end

local function retryTeleport(elem,x,y,z,isVehicle,distanceToGround)

	local hit, groundX, groundY, groundZ = processLineOfSight(x, y, 3000, x, y, -3000)
	if hit then
		local waterZ = getWaterLevel(x, y, 100)
		z = (waterZ and math.max(groundZ, waterZ) or groundZ) + distanceToGround
		setElementPosition(elem,x, y, z + distanceToGround)
		setCameraPlayerMode()
		setGravity(grav)
		if isVehicle then
			--server.fadeVehiclePassengersCamera(true)
			setTimer(calmVehicle,100,1,elem)
		else
			--fadeCamera(true)
		end
		killTimer(g_TeleportTimer)
		g_TeleportTimer = nil
		grav = nil
	end

end

function setPlayerPosition(x, y, z, skipDeadCheck)
	local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end
	local elem = getPedOccupiedVehicle(localPlayer)
	local isVehicle
	if elem and getPedOccupiedVehicle(localPlayer) then
		local controller = getVehicleController(elem)
		if controller and controller ~= localPlayer then
			errMsg('Sadece araç sürücüsü konumunu ayarlayabilir.')
			return false
		end
		isVehicle = true
	else
		elem = localPlayer
		isVehicle = false
	end
	if isPedDead(localPlayer) and not skipDeadCheck then
		customSpawnTable = {x,y,z}
	--	fadeCamera(false,0)
		--addEventHandler("onClientPreRender",root,forceFade)
		--outputChatBox("Belirlediğiniz yerde yeniden doğacaksınız..",0,255,0)
		return
	end
	local distanceToGround = getElementDistanceFromCentreOfMassToBaseOfModel(elem)
	local hit, hitX, hitY, hitZ = processLineOfSight(x, y, 3000, x, y, -3000)
	if not hit then
		if isVehicle then
			--server.fadeVehiclePassengersCamera(false)
		else
			---fadeCamera(false)
		end
		if isTimer(g_TeleportMatrixTimer) then killTimer(g_TeleportMatrixTimer) end
		g_TeleportMatrixTimer = setTimer(setCameraMatrix, 300, 1, x, y, z)
		if not grav then
			grav = playerGravity
			setGravity(0.001)
		end
		if isTimer(g_TeleportTimer) then killTimer(g_TeleportTimer) end
		g_TeleportTimer = setTimer(retryTeleport,50,0,elem,x,y,z,isVehicle,distanceToGround)
	else
		distanceToGround = 0.4
		setElementPosition(elem,x, y, z + distanceToGround)
		if isVehicle then
			setTimer(calmVehicle,100,1,elem)
		end
	end
end

local blipPlayers = {}

local function destroyBlip()

	blipPlayers[source] = nil

end

local function warpToBlip()

	local wnd = isWindowOpen(wndSpawnMap) and wndSpawnMap or wndSetPos
	local elem = blipPlayers[source]

	if isElement(elem) then
		warpMe(elem)
		closeWindow(wnd)
	end

end



function updatePlayerBlips()
	if not g_PlayerData then
		return
	end
	local wnd = isWindowOpen(wndSpawnMap) and wndSpawnMap or wndSetPos
	local mapControl = getControl(wnd, 'map')
	for elem,player in pairs(g_PlayerData) do
		if not player.gui.mapBlip then
			player.gui.mapBlip = guiCreateStaticImage(0, 0, 9, 9,'img/playerblip.png', false, mapControl)
			player.gui.mapLabelShadow = guiCreateLabel(0, 0, 100, 15, player.name:gsub("#%x%x%x%x%x%x",""), false, mapControl)
			player.gui.mapLabelShadow2 = guiCreateLabel(0, 0, 100, 15, "", false, mapControl)
			--gölge
			local labelWidth = guiLabelGetTextExtent(player.gui.mapLabelShadow)
			guiSetSize(player.gui.mapLabelShadow, labelWidth, 15, false)
			guiSetFont(player.gui.mapLabelShadow,font)
			guiLabelSetColor(player.gui.mapLabelShadow, 0, 0, 0)
			--isim
			player.gui.mapLabel = guiCreateLabel(0, 0, labelWidth, 14, player.name:gsub("#%x%x%x%x%x%x",""), false, mapControl)
			guiSetFont(player.gui.mapLabel, font)	
			
			--dgsSetProperty(player.gui.mapLabel,"wordBreak",false)
			--dgsSetProperty(player.gui.mapLabelShadow,"wordBreak",false)
			--dgsSetProperty(player.gui.mapLabelShadow2,"wordBreak",false)
			
			--yetkisi
			--player.gui.mapLabelStaff = guiCreateLabel(0, 0, labelWidth+80,20, "", false, mapControl)
			--guiSetFont(player.gui.mapLabelStaff, fontss)	
			
			if elem == localPlayer then 
				renk(player.gui.mapBlip,"ffcc00")
				--r,g,b = hex2rgb("6a4091") 
				--dgsSetProperty(player.gui.mapBlip,"color",tocolor(r,g,b,210))
			else 
				local r,g,b = getPlayerNametagColor(elem)
				--dgsSetProperty(player.gui.mapBlip,"color",tocolor())
				hex = rgb2hex(r,g,b)
				renk(player.gui.mapBlip,hex)
			end		
		--çift tıklayarak gitme
		for i,name in ipairs({'mapBlip', 'mapLabelShadow'}) do
			addEventHandler('onClientGUIDoubleClick',player.gui[name],function()
					if getElementDimension(elem) == 0 and getElementData(elem,"isinlanma") == false then					
						server.warpMe(elem)
						closeWindow(wnd)
					else
					    errMsg("Işınlandığın oyuncu ışınlanma özelliğini kapatmış durumda (/isinlanma)")
					end
				end,false)
			end
		end
		local x, y = getElementPosition(elem)
		local visible = (localPlayer.interior == elem.interior and localPlayer.dimension == elem.dimension)
	
		x = math.floor((x + 3000) * g_MapSide / 6000) - 4
		y = math.floor((3000 - y) * g_MapSide / 6000) - 4
		
		local iw,ih = guiGetSize(player.gui.mapLabel,false)
		guiSetPosition(player.gui.mapBlip, x, y, false)
		guiSetPosition(player.gui.mapLabelShadow, x + 12, y - 3, false)
		guiSetPosition(player.gui.mapLabel, x + 11, y - 3, false)
		--guiSetPosition(player.gui.mapLabelShadow2, x +iw+15, y - 3, false)
		--guiSetPosition(player.gui.mapLabelStaff, x + iw+15, y - 3, false)
    
		guiSetVisible(player.gui.mapBlip,visible)
		guiSetVisible(player.gui.mapLabelShadow,visible)
		guiSetVisible(player.gui.mapLabel,visible)
		--guiSetVisible(player.gui.mapLabelStaff,visible)
		--guiSetVisible(player.gui.mapLabelShadow2,visible)
		--yetkili olay 
		--[[
		if getElementData(elem,"isinlanma")==true then
		    guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
		else 
			guiLabelSetColor(player.gui.mapLabel, 255, 255, 255)				   
		end	
		--]]
		--[[
		local data = getElementData(elem,"nametag:yetki") or {"",255, 255, 255}
		local yetki,r,g,b = data[1],data[2],data[3],data[4]
		if yetki == "☀ Sunucu Sahibi ☀" then 
		if getElementData(elem,"isinlanma")==true then
			guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
			else 
			guiLabelSetColor(player.gui.mapLabel,0, 255, 255)
		end
		elseif yetki == "❂ Sunucu Ortağı ❂" then
		if getElementData(elem,"isinlanma")==true then
			guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
			else 
			guiLabelSetColor(player.gui.mapLabel,r, g, b)
		end
		elseif yetki == "✦ Genel Sorumlu ✦" then 
		if getElementData(elem,"isinlanma")==true then
			guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
			else 
			guiLabelSetColor(player.gui.mapLabel,r, g, b)
		end
		elseif yetki == "✹ Yardımcı Kurucu ✹" then 
		if getElementData(elem,"isinlanma")==true then
			guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
			else 
			guiLabelSetColor(player.gui.mapLabel,r, g, b)
		end
		elseif yetki == "↪ Baş Admin ↩" then 
		if getElementData(elem,"isinlanma")==true then
			guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
			else 
			guiLabelSetColor(player.gui.mapLabel,r, g, b)
		end
		elseif yetki == "✢ Admin ✢" then 
		if getElementData(elem,"isinlanma")==true then
			guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
			else 
			guiLabelSetColor(player.gui.mapLabel,r, g, b)
		end
		elseif yetki == "◖ Süper Moderator ◗" then 
		if getElementData(elem,"isinlanma")==true then
			guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
			else 
			guiLabelSetColor(player.gui.mapLabel,r, g, b)
		end
		elseif yetki == "◵ Moderator ◶" then 
		if getElementData(elem,"isinlanma")==true then
			guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
			else 
			guiLabelSetColor(player.gui.mapLabel,r, g, b)
		end
		elseif yetki == "☬ Gold Üye ☬" then 
		if getElementData(elem,"isinlanma")==true then
			guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
			else 
			guiLabelSetColor(player.gui.mapLabel,r, g, b)
		end
		elseif yetki == "" then
			if getElementData(elem,"isinlanma")==true then
				guiLabelSetColor(player.gui.mapLabel, 196, 0, 0)	
				else 
				guiLabelSetColor(player.gui.mapLabel,255, 255, 255)
			end
		end
		--]]
		guiLabelSetColor(player.gui.mapLabel,255, 255, 255)
		--oyuncu ara 
		local isim = getControlText(wndSetPos,"isim")
		if ( string.find ( string.upper ( getPlayerName(elem) ), string.upper ( isim ), 1, true ) ) then		
		else
			if isim~="Oyuncu Ara.." then
			guiSetPosition(player.gui.mapBlip, -500, -500, false)
			guiSetPosition(player.gui.mapLabelShadow, -500, -500, false)
			guiSetPosition(player.gui.mapLabel, -500, -500, false)
			end		
		end
		
		--ışınlanma özellik		
	end
end


--[[
function updatePlayerBlips()
	if not g_PlayerData then
		return
	end
	local wnd = isWindowOpen(wndSpawnMap) and wndSpawnMap or wndSetPos
	local mapControl = getControl(wnd, 'map')
	for elem,player in pairs(g_PlayerData) do
		if not player.gui.mapBlip then
			player.gui.mapBlip = guiCreateStaticImage(0, 0, 9, 9, elem == localPlayer and 'img/localplayerblip.png' or 'img/playerblip.png', false, mapControl)
			player.gui.mapLabelShadow = guiCreateLabel(0, 0, 100, 14, player.name:gsub("#%x%x%x%x%x%x",""), false, mapControl)
			local labelWidth = guiLabelGetTextExtent(player.gui.mapLabelShadow)
			guiSetSize(player.gui.mapLabelShadow, labelWidth, 14, false)
			guiSetFont(player.gui.mapLabelShadow, 'default-bold-small')
			guiLabelSetColor(player.gui.mapLabelShadow, 255, 255, 255)
			player.gui.mapLabel = guiCreateLabel(0, 0, labelWidth, 14, player.name:gsub("#%x%x%x%x%x%x",""), false, mapControl)
			guiSetFont(player.gui.mapLabel, 'default-bold-small')				
			for i,name in ipairs({'mapBlip', 'mapLabelShadow'}) do
				addEventHandler('onClientGUIDoubleClick', player.gui[name],
					function()
					if getElementDimension(elem) == 0 and getElementData(elem,"isinlanma") == false then					
						server.warpMe(elem)
						closeWindow(wnd)
					else
					    errMsg("Işınlandığın oyuncu ışınlanma özelliğini kapatmış durumda (/isinlanma)")
					end
					end,
					false
				)
			end
		end
		local x, y = getElementPosition(elem)
		x = math.floor((x + 3000) * g_MapSide / 6000) - 4
		y = math.floor((3000 - y) * g_MapSide / 6000) - 4
		guiSetPosition(player.gui.mapBlip, x, y, false)
		guiSetPosition(player.gui.mapLabelShadow, x + 14, y - 4, false)
		guiSetPosition(player.gui.mapLabel, x + 13, y - 5, false)
        if getElementDimension(elem)~=0 then	
		guiSetPosition(player.gui.mapBlip, -500, -500, false)
		guiSetPosition(player.gui.mapLabelShadow, -500, -500, false)
		guiSetPosition(player.gui.mapLabel, -500, -500, false)		
        end
		local isim = getControlText(wndSetPos,"isim")
		if ( string.find ( string.upper ( getPlayerName(elem) ), string.upper ( isim ), 1, true ) ) then		
			else
		if isim~="Oyuncu Ara.." then
		guiSetPosition(player.gui.mapBlip, -500, -500, false)
		guiSetPosition(player.gui.mapLabelShadow, -500, -500, false)
		guiSetPosition(player.gui.mapLabel, -500, -500, false)
        end		
		end
			if getElementData(elem,"isinlanma")==true then
			    guiLabelSetColor(player.gui.mapLabel, 255, 0, 0)		
			end
			if getElementData(elem,"isinlanma")==false then
			    guiLabelSetColor(player.gui.mapLabel, 0, 0, 0)		
			end			
	end
end
--]]

function updateName(oldNick, newNick)
	if (not g_PlayerData) then return end
	local source = getElementType(source) == "player" and source or oldNick
	local player = g_PlayerData[source]
	player.name = newNick
	if player.gui.mapLabel then
		guiSetText(player.gui.mapLabelShadow, newNick)
		guiSetText(player.gui.mapLabel, newNick)
		local labelWidth = guiLabelGetTextExtent(player.gui.mapLabelShadow)
		guiSetSize(player.gui.mapLabelShadow, labelWidth, 14, false)
		guiSetSize(player.gui.mapLabel, labelWidth, 14, false)
	end
end

addEventHandler('onClientPlayerChangeNick', root,updateName)

function closePositionWindow()
	removeEventHandler('onClientRender', root, updatePlayerBlips)
end

wndSetPos = {
	'wnd',
	text = 'HARİTA',
	width = g_MapSide + 20,
	controls = {
		{'img', id='map', src='img/map.png', y=40,width=g_MapSide, height=g_MapSide, onclick=fillInPosition, ondoubleclick=setPosClick, DoubleClickSpamProtected=true},
		{"br"},
		{"br"},
		{'txt', id='x', text='', height=22, width=100},
		{'txt', id='y', text='', height=22, width=100},
		{'txt', id='z', text='', height=22, width=85},
		{'txt', id='isim', text='Oyuncu Ara..',x=325,  height=22, width=100},	
		{'btn', id='TAMAM', onclick=setPosClick, x=460, height=22, width=100},	
		{'btn', id='KAPAT',  closeswindow=true, x=564, height=22, width=100},	
	},
	oncreate = setPosInit,
	onclose = closePositionWindow
}

function getPosCommand(cmd, playerName)
	local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end 
	if getElementData(localPlayer, 'Turf') == true then return false end
	local player, sentenceStart

	if playerName then
		player = getPlayerFromName(playerName)
		if not player then
			errMsg('There is no player named "' .. playerName .. '".')
			return
		end
		playerName = getPlayerName(player)		-- make sure case is correct
		sentenceStart = playerName .. ' is '
	else
		player = localPlayer
		sentenceStart = 'You are '
	end

	local px, py, pz = getElementPosition(player)
	local vehicle = getPedOccupiedVehicle(player)
	if vehicle then
		outputChatBox(sentenceStart .. 'in a ' .. getVehicleName(vehicle), 0, 255, 0)
	else
		outputChatBox(sentenceStart .. 'on foot', 0, 255, 0)
	end
	outputChatBox(sentenceStart .. 'at {' .. string.format("%.5f", px) .. ', ' .. string.format("%.5f", py) .. ', ' .. string.format("%.5f", pz) .. '}', 0, 255, 0)
end
addCommandHandler('getpos', getPosCommand)
addCommandHandler('gp', getPosCommand)

function setPosCommand(cmd, x, y, z, r) 
	local durum = getElementData(localPlayer,"Durum")
	if durum == "Eventde" then 
		return 
	end 
	--if exports["ZG-GarageSystem"]:isGarageActive() == true then return end
	if exports["vg-duel"]:getPlayerDuelData(localPlayer,"durumm") then
		return 
	end
	if getElementData(localPlayer,"Turf") then return end
	-- Handle setpos if used like: x, y, z, r or x,y,z,r
	local x, y, z, r = string.gsub(x or "", ",", " "), string.gsub(y or "", ",", " "), string.gsub(z or "", ",", " "), string.gsub(r or "", ",", " ")
	-- Extra handling for x,y,z,r
	if (x and y == "" and not tonumber(x)) then
		x, y, z, r = unpack(split(x, " "))
	end
	
	local px, py, pz = getElementPosition(localPlayer)
	local pr = getPedRotation(localPlayer)
	
	local message = ""
	if (not tonumber(x)) then
		message = "X "
	end
	if (not tonumber(y)) then
		message = message.."Y "
	end
	if (not tonumber(z)) then
		message = message.."Z "
	end
	if (message ~= "") then
	end
	
	setPlayerPosition(tonumber(x) or px, tonumber(y) or py, tonumber(z) or pz)
	if (isPedInVehicle(localPlayer)) then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if (vehicle and isElement(vehicle) and getVehicleController(vehicle) == localPlayer) then
			setElementRotation(vehicle, 0, 0, tonumber(r) or pr)
		end
	else
		setPedRotation(localPlayer, tonumber(r) or pr)
	end
end
addCommandHandler('setpos', setPosCommand)
addCommandHandler('sp', setPosCommand)

noktalar = {
	{ 1496.52759, -1833.08374, 2516.02661 },
	--{ 1493.3000488281, -1829.8000488281, 2516 },
	--{ 1509.1999511719, -1827.3000488281, 2516 },
}

addCommandHandler("devmode", function()
        setDevelopmentMode(true)
    end
)

function alanagirdi(giren)
	if ( giren == localPlayer ) then
    server.removePedJetPack(localPlayer)
    setElementData(localPlayer,"Drop",true)
    if getElementData(giren,"Olumsuz") then setElementData(localPlayer,"Olumsuz",nil) end
		-- triggerServerEvent("axe:jetpacksil",localPlayer)
		--setElementPosition(localPlayer,1508.46606, -1827.74304, 2516.02661)
	--	for _,vehicle in ipairs(getElementsByType("player")) do
	--		destroyElement(vehicle)
	---	end
	end
end
function alandancikti(giren)
	if ( giren == localPlayer ) then
    -- server.removePedJetPack(localPlayer)
    setElementData(localPlayer,"Drop",nil)
		-- triggerServerEvent("axe:jetpacksil",localPlayer)
		--setElementPosition(localPlayer,1508.46606, -1827.74304, 2516.02661)
	--	for _,vehicle in ipairs(getElementsByType("player")) do
	--		destroyElement(vehicle)
	---	end
	end
end

for i,v in pairs(noktalar) do
   drop_konum = createColSphere(v[1], v[2], v[3], 44)
   addEventHandler("onClientColShapeHit",drop_konum,alanagirdi)
   addEventHandler("onClientColShapeLeave",drop_konum,alandancikti)
end

---------------------------
-- Spawn map window
---------------------------
function warpMapInit()
	addEventHandler('onClientRender', root, updatePlayerBlips)
end

function spawnMapDoubleClick(relX, relY)
	setPlayerPosition(relX*6000 - 3000, 3000 - relY*6000, 0)
	closeWindow(wndSpawnMap)
end

function closeSpawnMap()
	showCursor(false)
	removeEventHandler('onClientRender', root, updatePlayerBlips)
	for elem,data in pairs(g_PlayerData) do
		for i,name in ipairs({'mapBlip', 'mapLabelShadow', 'mapLabel'}) do
			if data.gui[name] then
				destroyElement(data.gui[name])
				data.gui[name] = nil
			end
		end
	end
end

wndSpawnMap = {
	'wnd',
	text = 'Select spawn position',
	width = g_MapSide + 20,
	controls = {
		{'img', id='map', src='img/map.png', width=g_MapSide, height=g_MapSide, ondoubleclick=spawnMapDoubleClick},
		{'lbl', text='Welcome to freeroam. Double click a location on the map to spawn.', width=g_MapSide-60, align='center'},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = warpMapInit,
	onclose = closeSpawnMap
}

---------------------------
-- Create vehicle window
---------------------------
function createSelectedVehicle(leaf)
	if not leaf then
		leaf = getSelectedGridListLeaf(wndCreateVehicle, 'vehicles')
		if not leaf then
			return
		end
	end
	server.giveMeVehicles(leaf.id)
end

wndCreateVehicle = {
	'wnd',
	text = 'ARAÇLAR',
	width = 310,
	height = 350,
	controls = {
		{
			'lst',
			id='vehicles',
			width=290,
			height=300,
			y=45,
			columns={
				{text='Mevcut Araçlar', attr='name'}
			},
			rows={xml='data/vehicles.xml', attrs={'id', 'name'}},
			onitemdoubleclick=createSelectedVehicle,
			DoubleClickSpamProtected=true,
		},
		{'btn', id="OLUŞTUR", onclick=createSelectedVehicle, ClickSpamProtected=true,x=10, width=290,y=350, height=22},
		{'btn', id='KAPAT', closeswindow=true,x=10, width=290,y=378, height=22}
	},
    oncreate = createInit,
}

---------------------------
-- Color
---------------------------

function setColorCommand(cmd, ...)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then
		return
	end
	local colors = { getVehicleColor(vehicle) }
	local args = { ... }
	for i=1,12 do
		colors[i] = args[i] and tonumber(args[i]) or colors[i]
	end
	server.setVehicleColor(vehicle, unpack(colors))
end
addCommandHandler('color', setColorCommand)
addCommandHandler('cl', setColorCommand)



local bdurum = true 
function boyapaneli()
	if not isPedInVehicle(localPlayer) then  errMsg('Boya eklemek için bir arabaya sahip olmalısın.') return end
	editingVehicle = getPedOccupiedVehicle(localPlayer)
        if getVehicleController(editingVehicle) ~= localPlayer then
		return
    end
	if bdurum == true then 
		
		guiCheckBoxSetSelected(checkColor1,true)
		colorPicker.openSelect(colors)
		bdurum = false
		else
		bdurum = true
		colorPicker.closeSelect()
	end	
end

function closedColorPicker()
	local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4 = getVehicleColor(editingVehicle, true)
	server.setVehicleColor(editingVehicle, r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4)
	local r, g, b = getVehicleHeadLightColor(editingVehicle)
	server.setVehicleHeadLightColor(editingVehicle, r, g, b)
	editingVehicle = nil
end

function setSmokeColor(color, right)
	if not localPlayer.vehicle then end
	if not color then end
	if not right then end
	if not right then
		localPlayer.vehicle:setData("SmokeColorL", color)
	else
		localPlayer.vehicle:setData("SmokeColorR", color)
	end
end
local r6,g6,b6,r7,g7,b7
function updateColor()
	if (not colorPicker.isSelectOpen) then return end
	local r, g, b = colorPicker.updateTempColors()
	if (editingVehicle and isElement(editingVehicle)) then
		local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4  = getVehicleColor(editingVehicle, true)
		if (guiCheckBoxGetSelected(checkColor1)) then
			r1, g1, b1 = r, g, b
		end
		if (guiCheckBoxGetSelected(checkColor2)) then
			r2, g2, b2 = r, g, b
		end
		if (guiCheckBoxGetSelected(checkColor3)) then
			r3, g3, b3 = r, g, b
		end
		if (guiCheckBoxGetSelected(checkColor4)) then
			r4, g4, b4 = r, g, b
			--renk = RGBToHex(r4, g4, b4)
			--setElementData(editingVehicle,"neon",{neontip = 1,neondosya = 1, neonrenk=renk,neonanimhizi = 1})
		end
		if (guiCheckBoxGetSelected(checkColor5)) then
			--r4, g4, b4 = r, g, b
			setVehicleHeadLightColor(editingVehicle, r, g, b)
		end
		if (guiCheckBoxGetSelected(dumansag)) then
			--setVehicleHeadLightColor(editingVehicle, r, g, b)
			setSmokeColor({r, g, b}, false)
		end
		if (guiCheckBoxGetSelected(dumansol)) then
			--setVehicleHeadLightColor(editingVehicle, r, g, b)
			setSmokeColor({r, g, b}, true)
		end
		if (guiCheckBoxGetSelected(checkColor6)) then
			if (r6 ~= r) or (g6 ~= g) or (b6 ~= b) then
				r6,g6,b6 = r, g, b
				setElementData(editingVehicle,"colorTypeRGB",{r,g,b})
				setElementData(editingVehicle,"WheelsColorF",{r/255,g/255,b/255})
			end	
		end
		if (guiCheckBoxGetSelected(checkColor7)) then
			if r7 ~= r or g7 ~= g or b7 ~= b then
				r7,g7,b7 = r, g, b
				setElementData(editingVehicle,"WheelsColorR",{r/255,g/255,b/255})
			end	
		end
		setVehicleColor(editingVehicle, r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4)
	end
end
addEventHandler("onClientRender", root, updateColor)


---------------------------
-- Main window
---------------------------

function updateGUI(updateVehicle)

end

function mainWndShow()
	if not getPedOccupiedVehicle(localPlayer) then
		hideControls(wndMain, 'repair', 'flip', 'upgrades', 'color', 'paintjob', 'lightson', 'lightsoff')
	end
	updateTimer = updateTimer or setTimer(updateGUI, 2000, 0)
	updateGUI(true)
end

function mainWndClose()
	killTimer(updateTimer)
	updateTimer = nil
	colorPicker.closeSelect()
end

function hasDriverGhost(vehicle)
	if not g_PlayerData then return end
	if not isElement(vehicle) then return end
	if getElementType(vehicle) ~= "vehicle" then return end
	local driver = getVehicleController(vehicle)
	if g_PlayerData[driver] and g_PlayerData[driver].ghostmode then return true end
	return false

end

function onEnterVehicle(vehicle,seat)
	if source == localPlayer then
		showControls(wndMain, 'repair', 'flip', 'upgrades', 'color', 'paintjob', 'lightson', 'lightsoff')
--		guiCheckModeSetState(getControl(wndMain, 'fartik'),false)
		if getVehicleOverrideLights(vehicle) == 2 then  
			guiCheckBoxSetSelected(getControl(wndMain, 'fartik'),false)
			guiSetText(getControl(wndMain, 'fartik'),"Farları Kapat")
		else
			guiCheckBoxSetSelected(getControl(wndMain, 'fartik'),true)
			guiSetText(getControl(wndMain, 'fartik'),"Farları Aç")
		end
	end
	if seat == 0 and g_PlayerData[source] then
		setVehicleGhost(vehicle,hasDriverGhost(vehicle))
	end
end

function onExitVehicle(vehicle,seat)
	if (eventName == "onClientPlayerVehicleExit" and source == localPlayer) or (eventName == "onClientElementDestroy" and getElementType(source) == "vehicle" and getPedOccupiedVehicle(localPlayer) == source) then
		hideControls(wndMain, 'repair', 'flip', 'upgrades', 'color', 'paintjob', 'lightson', 'lightsoff')
		closeWindow(wndUpgrades)
		closeWindow(wndColor)
	elseif vehicle and seat == 0 then
		if source and g_PlayerData[source] then
			setVehicleGhost(vehicle,hasDriverGhost(vehicle))
		end
	end
end



function killLocalPlayer()
	--if hangidunyadadata(localPlayer) == "Freeroam" then
	if g_settings["kill"] then
		setElementHealth(localPlayer,0)
	end
end
addCommandHandler('kill', killLocalPlayer)

---------------------------
-- YER KAYDET
---------------------------

local bookmarkList
local bookmarks

function initBookmarks ()
	bookmarkList = wndBookmarks.controls[1].element
	if bookmarks then return end
	loadBookmarks ()
	addEventHandler("onClientGUIDoubleClick",bookmarkList,gotoBookmark)
end

function loadBookmarks ()
	bookmarks = {}
	local xml = xmlLoadFile("bookmarks.xml")
	if not xml then
		xml = xmlCreateFile("bookmarks.xml","catalog")
	end
	guiGridListClear(bookmarkList)
	for i,child in ipairs (xmlNodeGetChildren(xml) or {}) do
		local row = guiGridListAddRow(bookmarkList)
		guiGridListSetItemText(bookmarkList,row,1,tostring(xmlNodeGetAttribute(child,"name")),false,false)
		guiGridListSetItemText(bookmarkList,row,2,tostring(xmlNodeGetAttribute(child,"zone")),false,false)
		bookmarks[row+1] = {tonumber(xmlNodeGetAttribute(child,"x")),tonumber(xmlNodeGetAttribute(child,"y")),tonumber(xmlNodeGetAttribute(child,"z"))}
	end
end

function saveBookmarks ()
	if fileExists("bookmarks.xml") then
		fileDelete("bookmarks.xml")
	end
	local xml = xmlCreateFile("bookmarks.xml","catalog")
	for row=0,(guiGridListGetRowCount(bookmarkList)-1) do
		local child = xmlCreateChild(xml,"bookmark")
		xmlNodeSetAttribute(child,"name",guiGridListGetItemText(bookmarkList,row,1))
		xmlNodeSetAttribute(child,"zone",guiGridListGetItemText(bookmarkList,row,2))
		xmlNodeSetAttribute(child,"x",tostring(bookmarks[row+1][1]))
		xmlNodeSetAttribute(child,"y",tostring(bookmarks[row+1][2]))
		xmlNodeSetAttribute(child,"z",tostring(bookmarks[row+1][3]))
	end
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end

function saveLocation ()
	local name = getControlText(wndBookmarks,"bookmarkname")
	if name ~= "" then
		local x,y,z = getElementPosition(localPlayer)
		local zone = getZoneName(x,y,z,false)
		if x and y and z then
			local row = guiGridListAddRow(bookmarkList)
			guiGridListSetItemText(bookmarkList,row,1,name,false,false)
			guiGridListSetItemText(bookmarkList,row,2,zone,false,false)
			bookmarks[row+1] = {x,y,z}
			setControlText(wndBookmarks,"bookmarkname","")
			saveBookmarks()
		end
	else
		exports["vg-ustmesaj"]:sendClientMessage("Oluşturacağınız bölgenin ismini giriniz.", 255, 0, 0, true)
	end
end

function deleteLocation ()
	local row,column = guiGridListGetSelectedItem(bookmarkList)
	if row and row ~= -1 then
		table.remove(bookmarks,row+1)
		guiGridListRemoveRow(bookmarkList,row)
		saveBookmarks()
	end
end

function gotoBookmark ()
	local row,column = guiGridListGetSelectedItem(bookmarkList)
	if row and row ~= -1 then
		fadeCamera(false)
		if isPedDead(localPlayer) then
			setTimer(server.spawnMe,1000,1,unpack(bookmarks[row+1]))
		else
			setTimer(setElementPosition,1000,1,localPlayer,unpack(bookmarks[row+1]))
		end
		setTimer(function () fadeCamera(true) setCameraTarget(localPlayer) end,2000,1)
	end
end

wndBookmarks = {
	'wnd',
	text = 'YER KAYDETME',
	width = 400,
	--x = -,
	y = 0.307,
	controls = {
		{
			'lst',
			id='bookmarklist',
			width=380,
			height = 290,
			y =42,
			columns={
				{text='Yerin İsmi', attr='name', width=0.3},
				{text='Yerin Bölgesi', attr='zone', width=0.6}
			}
		},
		{'txt', id='bookmarkname', text='Yer ismi girin..',x=11, width=225,y=335},
		{'btn', id='KAYDET', onclick=saveLocation, width=144, height = 25,y=335},
		{'btn', id='Seçilen Bölgeyi Sil', onclick=deleteLocation, width=225, height = 25,y=365},
		{'btn', id='KAPAT', closeswindow=true, width=144, height = 25,y=365}
	},
	oncreate = initBookmarks
}

--ÖZELLİKLER

function motormod()
	local state = guiCheckBoxGetSelected( getControl(wndMain, 'falloff') )
	if state == true then 
		errMsg('Motordan Düşmeme modu kapatıldı.')
		setPedCanBeKnockedOffBike(localPlayer,false)
		else 
		sufMsg("Motordan Düşmeme modu açıldı.")
		setPedCanBeKnockedOffBike(localPlayer,true)
		---triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"knifing",true)
	end
--	setPedCanBeKnockedOffBike(localPlayer, guiCheckBoxGetSelected(getControl(wndMain, 'falloff')))
end


function hayaletarac(state)
	if state then
	triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"ghostmode",true)
	else
	triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"ghostmode",false)
	end
end

function isInNightTime()
    local hour, minutes = getTime()
   return (hour>=22 or hour<=5)
end

function aractamir()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
	if kapilar[getPedOccupiedVehicleSeat(localPlayer)] then 
		exports["vg-ustmesaj"]:sendClientMessage("#6b6b6bBu işlemi sadece araç sürücüsü yapabilir.")
		return 
	end
		server.fixVehicle(vehicle)
	end
end
addCommandHandler('tamir', aractamir)
addCommandHandler('repair', aractamir)
addCommandHandler('rp', aractamir)
function araccevir()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
		if kapilar[getPedOccupiedVehicleSeat(localPlayer)] then 
			exports["vg-ustmesaj"]:sendClientMessage("#6b6b6bBu işlemi sadece araç sürücüsü yapabilir.")
			return 
		end
		local rX, rY, rZ = getElementRotation(vehicle)
		setElementRotation(vehicle, 0, 0, (rX > 90 and rX < 270) and (rZ + 180) or rZ)
	end
end
--SAAT 
function setTimeCommand(cmd, hours, minutes)
	
	if not hours then
		return
	end
	local curHours, curMinutes = getTime()
	hours = tonumber(hours) or curHours
	minutes = minutes and tonumber(minutes) or curMinutes
	setTime(hours, minutes)
end
addCommandHandler('saat', setTimeCommand)
addCommandHandler('st', setTimeCommand)
--HAVA 
function setWeatherCommand(cmd, weather)
	weather = weather and tonumber(weather)
	if weather then
		setWeather(weather)
	end
end
addCommandHandler('setweather', setWeatherCommand)
addCommandHandler('sw', setWeatherCommand)
--OLUMSUZLUK
function renderolay()
    if getPedWeaponSlot(localPlayer) ~= 0 then
    setPedWeaponSlot(localPlayer,0)
    end
end
function iptalFunc()
    cancelEvent()
end
function olumsuzlukmodd()
	if guiCheckBoxGetSelected(getControl(wndMain,"olumsuzluk")) == false then
		triggerServerEvent("oyuncuozellikleri:olaylar",localPlayer,"olumsuzluk","+")
		addEventHandler("onClientRender", root, renderolay)
		guiSetEnabled(getControl(wndMain,"olumsuzluk"),false)
		setTimer(function()
				addEventHandler("onClientPlayerDamage",localPlayer,iptalFunc)
				guiSetEnabled(getControl(wndMain,"olumsuzluk"),true)
				setElementData(localPlayer,"oyuncuozellik:olumsuzluk",true)
				sufMsg("Ölümsüzlük modu açıldı.")
		end, 5*1000, 1 )
		exports["vg-progesbar"]:drawProgressBar("olumsuzluk", "Ölümsüzlük Modu Açılıyor", 77, 77, 77,5*1000)
	else
		removeEventHandler("onClientPlayerDamage", localPlayer, iptalFunc)
		triggerServerEvent("oyuncuozellikleri:olaylar",localPlayer,"olumsuzluk","-")
		removeEventHandler("onClientRender", root, renderolay)
		setElementData(localPlayer,"oyuncuozellik:olumsuzluk",nil)
		errMsg("Ölümsüzlük modu kapatıldı.")
	end
end 

local silahkontroller = {"fire","aim_weapon", "next_weapon","previous_weapon"}


function olumsuzlukmod(durum)
	if durum == true then
		addEventHandler("onClientPlayerDamage",localPlayer,iptalFunc)
		guiSetEnabled(getControl(wndMain,"olumsuzluk"),true)
		for i,v in pairs(silahkontroller) do
			toggleControl(v, false)
		end
		--setElementData(localPlayer,"oyuncuozellik:olumsuzluk",true)
	else
		for i,v in pairs(silahkontroller) do
			toggleControl(v, true)
		end
		removeEventHandler("onClientPlayerDamage", localPlayer, iptalFunc)
		triggerServerEvent("oyuncuozellikleri:olaylar",localPlayer,"olumsuzluk","-")
		removeEventHandler("onClientRender", root, renderolay)
		--setElementData(localPlayer,"oyuncuozellik:olumsuzluk",nil)
	end
end
--
function arachasarsizlikmod()
	if isPedInVehicle(localPlayer) == false then
		--guiCheckModeSetState(getControl(wndMain, 'arachasarsizlik'),true)
		errMsg("Hasarsız araç modu arabada değilken kullanılamaz.")
		return 
	end
	if guiCheckBoxGetSelected(getControl(wndMain,"arachasarsizlik")) == false then
		--guiCheckModeSetState(getControl(wndMain, 'arachasarsizlik'),false)
		guiSetEnabled(getControl(wndMain,"arachasarsizlik"),false)
		setTimer(function()
			guiSetEnabled(getControl(wndMain,"arachasarsizlik"),true)
			triggerServerEvent("oyuncuozellikleri:olaylar",localPlayer,"arachazarsız","+")
			sufMsg("Hasarsız araç modu açıldı.")
		end, 5*1000, 1 )
		exports["vg-progesbar"]:drawProgressBar("ahasarsız", "Araç Dokunulmazlık Modu Açılıyor", 77, 77, 77,5*1000)
	else
		sufMsg("Hasarsız araç modu kapatıldı.")
		triggerServerEvent("oyuncuozellikleri:olaylar",localPlayer,"arachazarsız","-")
	end
end
--MODİFİYE PANEL 
function modifiyesistemi()
	if not getPedOccupiedVehicle(localPlayer) then errMsg('Bu sistemi kullanabilmen için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Modifiye sistemini açman için sürücü sahibi olman gerekmektedir.')
		return
    end
	closeWindow(wndSkin)
	closeWindow(wndAnim)
	closeWindow(wndClothes)
	closeWindow(wndWalking)
	closeWindow(wndVehicleSystem)
	exports["vg-modifiyepanel"]:modifiyepanel()
end
--AİR PANEL
function airpanel()
	if not getPedOccupiedVehicle(localPlayer) then errMsg('Bu sistemi kullanabilmen için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Air sistemini açman için sürücü sahibi olman gerekmektedir.')
		return
    end
	exports["vg-airpanel"]:airPanelAcKapat()
end
--NEON PANEL 
function neonpanel()
    if not getPedOccupiedVehicle(localPlayer) then errMsg('Bu sistemi kullanabilmen için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Neon sistemini açman için sürücü sahibi olman gerekmektedir.')
		return
    end
	exports["vg-neonpanel"]:neonPanelAcKapat()
end

function modyoneticisipanel()
    --[[if not getPedOccupiedVehicle(localPlayer) then errMsg('Bu sistemi kullanabilmen için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Neon sistemini açman için sürücü sahibi olman gerekmektedir.')
		return
    end
	--]]
	
	exports["vgf-modyonetme"]:modpanelackapat()
end

-- TUNING PANEL --
function tuningpanel()
	if not getPedOccupiedVehicle(localPlayer) then errMsg('Bu sistemi kullanabilmen için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Tuning sistemini açman için sürücü sahibi olman gerekmektedir.')
		return
    end
	exports["vg-ustmesaj"]:sendClientMessage("#9c9c9cBu sistem henüz aktif edilmedi eklenecektir.",2)
	--hideAllWindows()
	--colorPicker.closeSelect()
	--exports["vg-tunnigsistemi"]:tunnigpanelackapat()
end

-- KAMBER PANEL --
function kamberpanelo()
	if not getPedOccupiedVehicle(localPlayer) then errMsg('Bu sistemi kullanabilmen için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Kamber sistemini açman için sürücü sahibi olman gerekmektedir.')
		return
    end
	exports["vg-kamberpanel"]:kamberpanel()
end

--KORNA PANEL 
function kornapanel()
    if not getPedOccupiedVehicle(localPlayer) then errMsg('Bu sistemi kullanabilmen için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Korna sistemini açman için sürücü sahibi olman gerekmektedir.')
		return
    end
	exports["vg-kornapanel"]:kornapanelackapat()
end
--MOTOR SESLERİ PANEL 
function motorsesleripanel()
    if not getPedOccupiedVehicle(localPlayer) then errMsg('Bu sistemi kullanabilmen için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Korna sistemini açman için sürücü sahibi olman gerekmektedir.')
		return
    end
	exports["vg-motorsesleri"]:motorpanelackapat()
end

function kaplamapaneli()
	if not getPedOccupiedVehicle(localPlayer) then errMsg('Bu sistemi kullanabilmen için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Kaplama sistemini açman için sürücü sahibi olman gerekmektedir.')
    return
end
	triggerEvent("arackaplama.panelac",resourceRoot)
end

--AYARLAR PANEL 
function ayarlarpanel()
	exports["vg-ayarlarpanel"]:ayarlarpanelackapat()
end

function plaka()
    if not getPedOccupiedVehicle(localPlayer) then errMsg('Plaka değiştirmek için bir arabaya sahip olmalısın.') return end
    if getVehicleController(getPedOccupiedVehicle(localPlayer) ) ~= localPlayer then
        errMsg('Plaka sistemini açman için sürücü sahibi olman gerekmektedir.')
        return
    end
    exports["vg-plakasistemi"]:plakapanel()
end


function bicaklanmamod()
	local state = guiCheckBoxGetSelected( getControl(wndMain, 'bicaklanma') )
	if state == true then 
		errMsg('Bıçaklanma modu kapatıldı.')
		triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"knifing",false)
		else 
		sufMsg("Bıçaklanma modu açıldı.")
		triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"knifing",true)
	end
end

function setKnifeState(durum)
	if durum == true then
		triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"knifing",true)
	else
		triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"knifing",false)
	end
end
		
function farolay()
	if getPedOccupiedVehicle(localPlayer) then 
		if guiCheckBoxGetSelected(getControl(wndMain,"fartik")) == false then
			guiSetText(getControl(wndMain, 'fartik'),"Farları Kapat")
			server.setVehicleOverrideLights(getPedOccupiedVehicle(localPlayer), 2)
		else 
			guiSetText(getControl(wndMain, 'fartik'),"Farları Aç")
			server.setVehicleOverrideLights(getPedOccupiedVehicle(localPlayer), 1)
		end
	end
end

--OYUNCU PANEL 

wndMain = {
	'wnd',
	text = 'OYUNCU PANELI',
	x = 5,
	y = 150,
	width = 260,
	controls = {
		--{'br'},
		{'btn', id='question', text='Sıkça Sorulan Sorular', window=wndSSS, width=240,height=22},
		{'chk', id='olumsuzluk',text='Ölümsüzlük', onclick=olumsuzlukmodd},
		{'chk', id='bicaklanma',text='Bıçaklanma', onclick=bicaklanmamod},
		{"chk"; id='arachasarsizlik',text = "Araç Hasarsızlığı", onclick = arachasarsizlikmod},
		{"chk"; id='falloff',text = "Motordan Düşmeme", onclick = motormod},
		{'btn', id='kill', text='İntihar', onclick=killLocalPlayer},
		{'btn', id='Karakterler', window=wndSkin},
		{'btn', id='anim', text='Animasyonlar', window=wndAnim},
		{'btn', id='clothes', text='CJ Kıyafet', window=wndClothes},
		{'btn', id='walk', text='Yürüyüş Stili', window=wndWalking},
		{'btn', id='', text='Dövüş Stilleri', window=wndFighting},
		{'btn', id='setpos', text='Harita', window=wndSetPos, width=240,height=22},
		{'btn', id='', text='Ayarlar', onclick=ayarlarpanel,width=240,height=22},
		{'btn', id='', text='Motor Sesleri', onclick=motorsesleripanel, width=240,height=22},
		{'btn', id='', text='Kıyafet Kaydet', window=wndOutfits},
		{'btn', id='', text='Yer Kaydet', window=wndBookmarks},
		{'btn', id='createvehicle', text='Araba Oluştur', window=wndCreateVehicle, width=240,height=22},
		{'btn', id='repair', text='Tamir', onclick=aractamir},
		{'btn', id='flip', text='Çevir', onclick=araccevir},
		{'btn', id='color', text='Boya Paneli', onclick=boyapaneli, x=135},	
		{'btn', id='', text='Modifiye Panel',onclick=modifiyesistemi, x=10},
		{'btn', id='', text='Air Sistemi',onclick=airpanel},
		{'btn', id='', text='Neon Sistemi',onclick=neonpanel},
		{'btn', id='', text='Kamber Sistemi',onclick=kamberpanelo},
		{'btn', id='', text='Korna Sesleri',onclick=kornapanel},
		{'btn', id='', text='Kaplama Sistemi',onclick=kaplamapaneli},
		{'btn', id='', text='Plaka Sistemi',onclick=plaka},
	--	{'btn', id='', text='Tuning Sistemi',onclick=tuningpanel},
		{'btn', id='', text='Modları Yonet',onclick=modyoneticisipanel, width=240,height=22},
		{'chk', id='fartik', text='Farları Aç', onclick=farolay},
		
	},
	oncreate = mainWndShow,
	onclose = mainWndClose
}

disableBySetting =
{
	{parent=wndMain, id="antiram"},
	{parent=wndMain, id="disablewarp"},
	{parent=wndMain, id="disableknife"},
}

function errMsg(msg)
	outputChatBox(msg,255,0,0)
end

addEventHandler('onClientResourceStart', resourceRoot,function()
	fadeCamera(true)
	getPlayers()
	setJetpackMaxHeight ( 9001 )
	triggerServerEvent('onLoadedAtClient', resourceRoot)
	createWindow(wndMain)
	hideAllWindows()
	bindKey('f1', 'down', toggleFRWindow)
end)

function showMap()
	createWindow(wndSetPos)
	showCursor(true)
end

function toggleFRWindow()
	if isWindowOpen(wndMain) then
		showCursor(false)
		hideAllWindows()
		colorPicker.closeSelect()
		
		if isElement(font) then 
			destroyElement(font)
		end
	
		--exports["vg-xneonfarpanel"]:xfarpanelvisible(false)
		exports["vg-neonpanel"]:neonPanelVisible(false)
		--exports["vg-tunnigsistemi"]:tunnigpanelvisible(false)
		exports["vg-kamberpanel"]:kambervisible(false)
		exports["vg-plakasistemi"]:plakapanelvisible(false)
		exports["vg-airpanel"]:airPanelVisible(false)
		exports["vg-kornapanel"]:kornapanelvisible(false)
		exports["vg-modifiyepanel"]:modifiyevisible(false)
		exports["vg-motorsesleri"]:motorpanelvisible(false)
		exports["vg-ayarlarpanel"]:ayarlarpanelvisible(false)
		exports["vgf-modyonetme"]:modpanelvisible(false)
	
	else
		font = guiCreateFont("font.ttf",9)
		--
		if guiGetInputMode() ~= "no_binds_when_editing" then
			guiSetInputMode("no_binds_when_editing")
		end
		--
		showCursor(true)
		showAllWindows()
		--
		if localPlayer.vehicle then 
		if getVehicleOverrideLights(localPlayer.vehicle) == 2 then
			guiCheckBoxSetSelected(getControl(wndMain, 'fartik'),true)
			guiSetText(getControl(wndMain, 'fartik'),"Farları Kapat")
			else 
			guiCheckBoxSetSelected(getControl(wndMain, 'fartik'),false)
			guiSetText(getControl(wndMain, 'fartik'),"Farları Aç")
		end
		end
	end
end

addEvent("event:system:panel:visible",true)
addEventHandler("event:system:panel:visible",root,function()
	showCursor(false)
		hideAllWindows()
		colorPicker.closeSelect()
		
		if isElement(font) then 
			destroyElement(font)
		end
	
		--exports["vg-xneonfarpanel"]:xfarpanelvisible(false)
		exports["vg-neonpanel"]:neonPanelVisible(false)
		--exports["vg-tunnigsistemi"]:tunnigpanelvisible(false)
		exports["vg-kamberpanel"]:kambervisible(false)
		exports["vg-plakasistemi"]:plakapanelvisible(false)
		exports["vg-airpanel"]:airPanelVisible(false)
		exports["vg-kornapanel"]:kornapanelvisible(false)
		exports["vg-modifiyepanel"]:modifiyevisible(false)
		exports["vg-motorsesleri"]:motorpanelvisible(false)
		exports["vg-ayarlarpanel"]:ayarlarpanelvisible(false)
		exports["vgf-modyonetme"]:modpanelvisible(false)
end)



addEventHandler("onClientVehicleStartEnter",root,function(oyuncu)
	if getVehicleOverrideLights(source) == 2 then
		guiCheckBoxSetSelected(getControl(wndMain, 'fartik'),true)
		guiSetText(getControl(wndMain, 'fartik'),"Farları Kapat")
	else 
		guiCheckBoxSetSelected(getControl(wndMain, 'fartik'),false)
		guiSetText(getControl(wndMain, 'fartik'),"Farları Aç")
	end
end)
addEventHandler("onClientVehicleStartExit",root,function(oyuncu)
	if getVehicleOverrideLights(source) == 2 then
		guiCheckBoxSetSelected(getControl(wndMain, 'fartik'),true)
		guiSetText(getControl(wndMain, 'fartik'),"Farları Kapat")
	else 
		guiCheckBoxSetSelected(getControl(wndMain, 'fartik'),false)
		guiSetText(getControl(wndMain, 'fartik'),"Farları Aç")
	end
end)
--
function f1geriver()
	showCursor(true)
	showAllWindows()
end
--
function getPlayers()
	g_PlayerData = {}
	table.each(getElementsByType('player'), joinHandler)
end

function joinHandler(player)
	if (not g_PlayerData) then return end
	g_PlayerData[player or source] = { name = getPlayerName(player or source), gui = {} }
end

function quitHandler()
	if (not g_PlayerData) then return end
	local veh = getPedOccupiedVehicle(source)
	local seat = (veh and getVehicleController(veh) == localPlayer) and 0 or 1
	if seat == 0 then
		onExitVehicle(veh,0)
	end
	table.each(g_PlayerData[source].gui, destroyElement)
	g_PlayerData[source] = nil
end

function wastedHandler()
	if source == localPlayer then
		onExitVehicle()
		if g_settings["spawnmapondeath"] then
			--setTimer(showMap,2000,1)
		end
	else
		local veh = getPedOccupiedVehicle(source)
		local seat = (veh and getVehicleController(veh) == localPlayer) and 0 or 1
		if seat == 0 then
			onExitVehicle(veh,0)
		end
	end
end

local function removeForcedFade()
	removeEventHandler("onClientPreRender",root,forceFade)
	fadeCamera(true)
end

local function checkCustomSpawn()

	if type(customSpawnTable) == "table" then
		local x,y,z = unpack(customSpawnTable)
		setPlayerPosition(x,y,z,true)
		customSpawnTable = false
		setTimer(removeForcedFade,100,1)
	end

end

addEventHandler('onClientPlayerJoin', root, joinHandler)
addEventHandler('onClientPlayerQuit', root, quitHandler)
addEventHandler('onClientPlayerWasted', root, wastedHandler)
addEventHandler('onClientPlayerVehicleEnter', root, onEnterVehicle)
addEventHandler('onClientPlayerVehicleExit', root, onExitVehicle)
addEventHandler("onClientElementDestroy", root, onExitVehicle)
addEventHandler("onClientPlayerSpawn", localPlayer, checkCustomSpawn)

function getPlayerName(player)
	return g_settings["removeHex"] and player.name:gsub("#%x%x%x%x%x%x","") or player.name
end

addEventHandler('onClientResourceStop', resourceRoot,
	function()
		showCursor(false)
		setPedAnimation(localPlayer, false)
	end
)

function setVehicleGhost(sourceVehicle,value)

	  local vehicles = getElementsByType("vehicle")
	  for _,vehicle in ipairs(vehicles) do
		local vehicleGhost = hasDriverGhost(vehicle)
		if isElement(sourceVehicle) and isElement(vehicle) then
		   setElementCollidableWith(sourceVehicle,vehicle,not value)
		   setElementCollidableWith(vehicle,sourceVehicle,not value)
		end
		if value == false and vehicleGhost == true and isElement(sourceVehicle) and isElement(vehicle) then
			setElementCollidableWith(sourceVehicle,vehicle,not vehicleGhost)
			setElementCollidableWith(vehicle,sourceVehicle,not vehicleGhost)
		end
	end

end

local function onStreamIn()

	if source.type ~= "vehicle" then return end
	setVehicleGhost(source,hasDriverGhost(source))

end

local function onLocalSettingChange(key,value)

	g_PlayerData[source][key] = value

	if key == "ghostmode" then
		local sourceVehicle = getPedOccupiedVehicle(source)
		if sourceVehicle then
			setVehicleGhost(sourceVehicle,hasDriverGhost(sourceVehicle))
		end
	end

end

local function renderKnifingTag()
	if not g_PlayerData then return end
	for _,p in ipairs (getElementsByType ("player", root, true)) do
		if g_PlayerData[p] and g_PlayerData[p].knifing then
			local px,py,pz = getElementPosition(p)
			local x,y,d = getScreenFromWorldPosition (px, py, pz+1.3)
			if x and y and d < 20 then
				dxDrawText ("Bıçak Koruması", x+1, y+1, x, y, tocolor (0, 0, 0), 1, "default-bold", "center")
				dxDrawText ("Bıçak Koruması", x, y, x, y, tocolor (220, 220, 0), 1, "default-bold", "center")
			end
		end
    end
end

addEventHandler ("onClientRender", root, renderKnifingTag)

addEvent("onClientFreeroamLocalSettingChange",true)
addEventHandler("onClientFreeroamLocalSettingChange",root,onLocalSettingChange)
addEventHandler("onClientPlayerStealthKill",localPlayer,cancelKnifeEvent)
addEventHandler("onClientElementStreamIn",root,onStreamIn)

function setWarpChange(player,bool)
	if player then 
		--ayarlar.isinlanma[player] = bool
		--server.setWarpState(player,bool)
		setElementData(player,"isinlanma",bool)
	end
end

function setVehicleSitStateC(player,bool)
	if player then 
		--print(bool)
		server.setVehicleSitState(player,bool)
	end
end
--1.
CONFIG_PROPERTY_NAME1 = "Işınlanma"
addEventHandler("onClientResourceStart", resourceRoot, function ()
--	setWarpChange(localPlayer,exports["vg-ayarlarkayit"]:getProperty(CONFIG_PROPERTY_NAME1))
end)
addEvent("serius:ayarguncelle", false)
addEventHandler("serius:ayarguncelle", root, function (key, value,oyuncu)
	if key == CONFIG_PROPERTY_NAME1 then
		setWarpChange(oyuncu,value)
	end
end)
--2.
CONFIG_PROPERTY_NAME2 = "F1 Araç İçi Binme"
addEventHandler("onClientResourceStart", resourceRoot, function ()
--	setVehicleSitStateC(localPlayer,exports["vg-ayarlarkayit"]:getProperty(CONFIG_PROPERTY_NAME2))
end)
addEvent("serius:ayarguncelle", false)
addEventHandler("serius:ayarguncelle", root, function (key, value,oyuncu)
	if key == CONFIG_PROPERTY_NAME2 then
		--print(value)
		setVehicleSitStateC(oyuncu,value)
		--print(value,oyuncu)
	end
end)

function sufMsg(msg)
	--outputChatBox(msg,255,0,0)
	exports["vg-ustmesaj"]:sendClientMessage("#6b6b6b"..msg,1)
end

function errMsg(msg)
	--outputChatBox(msg,255,0,0)
	exports["vg-ustmesaj"]:sendClientMessage("#6b6b6b"..msg,2)
end


local showPlayers
local playerBlips = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
	showPlayers = "near"
	refreshPlayerBlips()
end)

function refreshPlayerBlips()
	for i, blip in pairs(playerBlips) do
		if isElement(blip) then destroyElement(blip) end
		playerBlips[i] = nil
	end
	if (showPlayers == "near") then
		for _, player in ipairs( getElementsByType("player") ) do
		if player ~= localPlayer then 
			local r,g,b = getPlayerNametagColor(player)
			playerBlips[player] = createBlipAttachedTo(player, 0, 2, r, g, b, 255, 0, 500)
			end
		end
	elseif (showPlayers) then
		for _, player in ipairs( getElementsByType("player") ) do
			local r,g,b = getPlayerNametagColor(player)
			playerBlips[player] = createBlipAttachedTo(player, 0, 2, r, g, b)
		end
	else
		local r,g,b = getPlayerNametagColor(localPlayer)
		playerBlips[localPlayer] = createBlipAttachedTo(localPlayer, 0, 2, r, g, b)
	end
end

function createBlipForPlayer(player)
	if isElement(player) then
		local r,g,b = getPlayerNametagColor(player)
		if (showPlayers == "near") then
			playerBlips[player] = createBlipAttachedTo(player, 0, 2, r, g, b, 255, 0, 500)
		elseif (showPlayers) then
			playerBlips[player] = createBlipAttachedTo(player, 0, 2, r, g, b)
		end
	end
end
addEventHandler("onClientPlayerJoin", root, function()
	setTimer(createBlipForPlayer, 1000, 1, source)
end)

addEventHandler("onClientPlayerQuit", root, function()
	if isElement(playerBlips[source]) then destroyElement(playerBlips[source]) end
end)

