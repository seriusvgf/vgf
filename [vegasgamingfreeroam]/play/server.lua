local dogusalanlari = {
    {1479.17480, -1680.72388, 17.90625,180},
}
--
function customSpawnPlayer(player)
    local x,y,z,r = unpack(dogusalanlari[math.random(1,#dogusalanlari)])
    if player and isElement(player) then 
        spawnPlayer(player,x+math.random(-3,3),y+math.random(-3,3),z,r,0,0,0)
        setPedStat(player,21,100)
        setPedStat(player,23,100)
        setElementHealth(player,100)
        setPedArmor(player,100)
        fadeCamera(player, true)
        setCameraTarget(player, player)
        setPlayerBlurLevel(player, 0)
        toggleControl(player, 'action', false) 
    end
end
--
addEventHandler('onResourceStart',resourceRoot,function()
    players = getElementsByType('player')
    for i=1,#players do 
        local oyuncu = players[i]
        customSpawnPlayer(oyuncu)
    end
    setPlayerBlurLevel(root, 0)
end)
--
addEventHandler('onPlayerJoin',root,function()
    customSpawnPlayer(source)
end)
--
addEventHandler('onPlayerWasted',root,function()
    setTimer(function(player) customSpawnPlayer(player)  end,1000,1,source)
end)
--