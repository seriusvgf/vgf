function requesGradientShader(filled)
	local woF = not filled and ""
	return [[
        bool textureLoad = false;
        bool textureRotated = false;
        texture sourceTexture;
        float rotation = 0;
        float4 colorFrom = float4(1,1,1,1);
        float4 colorTo = float4(1,1,1,1);
        bool colorOverwritten = true;
        #define PI 3.1415926535897932384626433832795

        SamplerState tSampler{
            Texture = sourceTexture;
            MinFilter = Linear;
            MagFilter = Linear;
            MipFilter = Linear;
        };
        
        float4 gradientShader(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
            float4 result = textureLoad?tex2D(tSampler,textureRotated?tex.yx:tex)*color:color;
            float rad = rotation/180*PI;
            float rotSin = sin(rad);
            float rotCos = cos(rad);
            tex -= 0.5;
            float2 kValue = float2(tex.x*rotCos-tex.y*rotSin,tex.x*rotSin+tex.y*rotCos)+0.5;
            float4 colorCalculated = colorFrom+(colorTo-colorFrom)*(kValue.x);
            result.rgb = colorOverwritten?colorCalculated.rgb:(colorCalculated.rgb*result.rgb);
            result.a *= colorCalculated.a;
            return result;
        }
        
        technique Gradient{
            pass P0{
                SeparateAlphaBlendEnable = true;
                SrcBlendAlpha = One;
                DestBlendAlpha = InvSrcAlpha;
                PixelShader = compile ps_2_0 gradientShader();
            }
        }
    ]]
end
--
function fromcolor(color,relative)
	local b = color%256
	color = (color-b)/256
	local g = color%256
	color = (color-g)/256
	local r = color%256
	color = (color-r)/256
	local a = color%256
	if relative then
		return r/255,g/255,b/255,a/255
	end
	return r,g,b,a
end
--
local gradientRectlangeShaders = {};
--
function dxDrawGradientRectangle(x, y, width, height, colorFrom, colorTo, rotation,alpha,isFilled)
    --
    local rotation = rotation or 0
    local isFilled = isFilled or false;
    local rgba = { bitExtract(colorFrom, 0, 8), bitExtract(colorFrom, 8, 8), bitExtract(colorFrom, 16, 8), bitExtract(colorFrom, 24, 8) };
    local key = table.concat(rgba, '') 
    --
    if (not gradientRectlangeShaders[key]) then 
        gradientRectlangeShaders[key] = {
            shader = dxCreateShader(requesGradientShader(isFilled)),
            lastTick = getTickCount(),
        };
    end 
    --
    dxSetShaderValue(gradientRectlangeShaders[key].shader,"colorFrom",fromcolor(colorFrom,true))
    dxSetShaderValue(gradientRectlangeShaders[key].shader,"colorTo",fromcolor(colorTo,true))
    dxSetShaderValue(gradientRectlangeShaders[key].shader,"rotation",rotation)
    --
    gradientRectlangeShaders[key].lastTick = getTickCount();
    --
    dxDrawImage(x, y, width, height, gradientRectlangeShaders[key].shader, 0, 0, 0,tocolor(255,255,255,alpha));
end
--
setTimer(function()
    for k,v in pairs(gradientRectlangeShaders) do 
        if (not v.lastTick or (v.lastTick + 10000) < getTickCount()) then 
            if (v.shader and isElement(v.shader)) then 
                destroyElement(v.shader);
            end 
            gradientRectlangeShaders[k] = nil;
        end 
    end 
end, 10000, 0);
--
addEventHandler('onClientResourceStop', resourceRoot, function()
    for k,v in pairs(gradientRectlangeShaders) do 
        if (v.shader and isElement(v.shader)) then 
            destroyElement(v.shader);
        end 
        gradientRectlangeShaders[k] = nil;
    end 
end);
--
