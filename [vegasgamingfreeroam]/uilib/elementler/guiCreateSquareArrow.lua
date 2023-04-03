function guiCreateSquareArrow(x,y,g,u,position,relative,parent)
    squaresayi = #gui["sq"] +1
    if not gui["sq"][squaresayi] then gui["sq"][squaresayi] = {} end
    local sq = gui["sq"][squaresayi]
    if relative  then
		px,pu = getParentSize(parent)
		x,y,g,u = x*px,y*pu,g*px,u*pu
	end


    if position == "left" then 
        img = "dosyalar/2.png"
    elseif position == "right" then 
        img = "dosyalar/3.png"
    elseif position == "top" then 
        img = "dosyalar/4.png"
    elseif position == "bottom" then   
        img = "dosyalar/1.png"
    end
    --
    if img then 
        sq.resim = guiCreateStaticImage(x,y,g,u,bosresim,relative,parent)
        renk(sq.resim,tema["sq"].squarecolor)
        guiSetAlpha(sq.resim,0.9)

        sq.arrow = guiCreateStaticImage(0,0,g,u,img,relative,sq.resim)
        renk(sq.arrow,tema["sq"].squarearrownormalcolor)
 
    --
    if not kullanilanscriptler[sourceResource] then kullanilanscriptler[sourceResource] = {} end
	if not kullanilanscriptler[sourceResource]["sq"] then kullanilanscriptler[sourceResource]["sq"] = {} end
	table.insert(kullanilanscriptler[sourceResource]["sq"], {squaresayi,sq.resim})
    --
    --geneltablo[sq.arrow] = {i=squaresayi,t="sq"}
    geneltablo[sq.arrow] = {i=squaresayi,t="sq"}
    geneltablo[sq.arrow] = {i=squaresayi,isSquare=true,square = sq.resim,arrow=sq.arrow,arrownormalcolor = tema["sq"].squarearrownormalcolor,arrowhovercolor = tema["sq"].squarearrowhovercolor}
    --isSquare = true,
     return sq.arrow
    end
    
end

