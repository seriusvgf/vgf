function guiCreateEdit(x,y,g,u,yazi,icon,iconayarlar,relative,parent)
	esayi = #gui["e"] +1
	if not gui["e"][esayi] then gui["e"][esayi] = {} end
	local e = gui["e"][esayi]
    --
	if relative  then
		px,pu = getParentSize(parent)
		x,y,g,u = x*px,y*pu,g*px,u*pu
	end
    --
    e.active = false
    e.gui = _guiCreateEdit(-1000, -1000, 0, 0, yazi, false, false)

    e.resim = guiCreateStaticImage(x,y,g,u,bosresim,false,parent) 
	elementerenkver(e.resim,"181818")
    --
    if icon then 
        ayarlar = iconayarlar 
        if ayarlar then 
            if ayarlar.ix and ayarlar.iy and ayarlar.iw and ayarlar.ih and ayarlar.ifile then 
                e.icon = guiCreateStaticImage(ayarlar.ix,ayarlar.iy,ayarlar.iw,ayarlar.ih,ayarlar.ifile,false,e.resim) 
            end
            if ayarlar.ialpha then 
                guiSetAlpha(e.icon,ayarlar.ialpha)
            end
        end

        e.label = guiCreateLabel(25,-0.5,g,u,yazi,false,e.resim)
        guiLabelSetVerticalAlign(e.label, "center")
        guiSetAlpha(e.label,0.7)
        guiSetFont(e.label,tema["e"].fonts.Roboto or "default-bold-small")
    else
        e.label = guiCreateLabel(5,0,g,u,yazi,false,e.resim)
        guiLabelSetVerticalAlign(e.label, "center")
        guiSetAlpha(e.label,0.7)
        guiSetFont(e.label,tema["e"].fonts.Roboto or "default-bold-small")
    end
    --
    e.kenarlar = {
		ortaust = guiCreateStaticImage(1, 0, g - 2, 1,bosresim,false,e.resim),
		ortaalt = guiCreateStaticImage(1, u-1, g - 2, 1,bosresim,false,e.resim),
		sol = guiCreateStaticImage(0, 1, 1, u-2,bosresim,false,e.resim),
		sag = guiCreateStaticImage(g-1, 1, 1, u-2,bosresim,false,e.resim)		
	}
    --
	for i,v in pairs(e.kenarlar) do
		elementerenkver(v,tema["e"].editkenarnormalcolor)
		guiSetProperty(v, "AlwaysOnTop", "True")
	    guiSetAlpha(v,0.7)
	end
    --
    geneltablo[e.label] = {i=esayi,t="e"}
    geneltablo[e.resim] = {i=esayi,t="e"}
    geneltablo[e.label]={i=esayi,isEditbox=true,renkler={normal = tema["e"].editkenarnormalcolor,hover = tema["e"].editkenarhovercolor}}
    --
    return e.label
end
--
setTimer(function()
    if gui["e"] then 
        for i, v in pairs(gui["e"]) do 
           if v.active then 

           end
        end
    end 
end,5,0)

