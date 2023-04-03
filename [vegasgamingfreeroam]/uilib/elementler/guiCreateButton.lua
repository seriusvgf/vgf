function guiCreateButton(x,y,g,u,yazi,relative,parent)
	bsayi = #gui["b"] +1
	if not gui["b"][bsayi] then gui["b"][bsayi] = {} end
	local b = gui["b"][bsayi]
	if relative  then
		px,pu=getParentSize(parent)
		x,y,g,u=x*px,y*pu,g*px,u*pu
	end
	b.resim = guiCreateStaticImage(x,y,g,u,bosresim,false,parent) 
	elementerenkver(b.resim,"181818")
    --
    b.kenarlar = {
		ortaust = guiCreateStaticImage(1, 0, g - 2, 1,bosresim,false,b.resim),
		ortaalt = guiCreateStaticImage(1, u-1, g - 2, 1,bosresim,false,b.resim),
		sol = guiCreateStaticImage(0, 1, 1, u-2,bosresim,false,b.resim),
		sag = guiCreateStaticImage(g-1, 1, 1, u-2,bosresim,false,b.resim)		
	}
    --
	for i,v in pairs(b.kenarlar) do
		elementerenkver(v,tema["b"].buttonkenarnormalcolor)
		guiSetProperty(v, "AlwaysOnTop", "True")
	    guiSetAlpha(v,0.7)
	end
    --
    b.label = guiCreateLabel(0,0,g,u,yazi,false,b.resim)
    guiLabelSetHorizontalAlign(b.label, "center") 
	guiLabelSetVerticalAlign(b.label, "center")
    guiSetAlpha(b.label,0.7)
	guiSetFont(b.label,tema["b"].fonts.Roboto or "default-bold-small")
	
    --
	if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["b"] then kullanilanscriptler[sourceResource]["b"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["b"], {bsayi,b.resim})
	--
    geneltablo[b.label] = {i=bsayi,t="b"}
    geneltablo[b.label]={i=bsayi,isButton=true,renkler={normal = tema["b"].buttonkenarnormalcolor,hover = tema["b"].buttonkenarhovercolor}}
	return b.label 
end

function guiSetButtonHoverColor(element,hex)
	if hex then 
		local sira = getGuiElement(element)
		if not sira then return end
		if sira.isButton then 
			sira.renkler.hover = hex
		end
	end
end

function guiGetButtonHoverColor(element)
	local sira = getGuiElement(element)
	if not sira then return end
	if sira.isButton then 
		return sira.renkler.hover 
	end
end