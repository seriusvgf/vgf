
function requestBlurShader(withoutFilled)
	local woF = not withoutFilled and ""
	return [[
		//---------------------------------------------------------------------
		// blurV settings
		//---------------------------------------------------------------------
		texture gTexture;
		float2 gTextureSize;
		float blurLevel = 1;
		float alpha = 1;
		
		//---------------------------------------------------------------------
		// Include some common stuff
		//---------------------------------------------------------------------
		float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
		
		//-----------------------------------------------------------------------------
		// Static data
		//-----------------------------------------------------------------------------
		static const float Kernel[13] = {-6, -5,     -4,     -3,     -2,     -1,     0,      1,      2,      3,      4,      5,      6};
		static const float Weights[13] = {      0.002216,       0.008764,       0.026995,       0.064759,       0.120985,       0.176033,       0.199471,       0.176033,       0.120985,       0.064759,       0.026995,       0.008764,       0.002216};
		
		//---------------------------------------------------------------------
		// Sampler for the main texture
		//---------------------------------------------------------------------
		sampler2D Sampler0 = sampler_state
		{
			Texture         = (gTexture);
			MinFilter       = Linear;
			MagFilter       = Linear;
			MipFilter       = Linear;
			AddressU        = Mirror;
			AddressV        = Mirror;
		};
		
		//---------------------------------------------------------------------
		// Structure of data sent to the vertex shader
		//---------------------------------------------------------------------
		struct VSInput
		{
			float3 Position : POSITION0;
			float4 Diffuse : COLOR0;
			float2 TexCoord : TEXCOORD0;
		};
		
		//---------------------------------------------------------------------
		// Structure of data sent to the pixel shader ( from the vertex shader )
		//---------------------------------------------------------------------
		struct PSInput
		{
			float4 Position : POSITION0;
			float4 Diffuse : COLOR0;
			float2 TexCoord: TEXCOORD0;
		};
		
		
		//------------------------------------------------------------------------------------------
		// VertexShaderFunction
		//  1. Read from VS structure
		//  2. Process
		//  3. Write to PS structure
		//------------------------------------------------------------------------------------------
		PSInput VertexShaderFunction(VSInput VS)
		{
			PSInput PS = (PSInput)0;
		
			// Calculate screen pos of vertex
			PS.Position = mul( float4(VS.Position,1),gWorldViewProjection );
		
			// Pass through color and tex coord
			PS.Diffuse = VS.Diffuse;
			PS.TexCoord = VS.TexCoord;
		
			return PS;
		}
		
		//------------------------------------------------------------------------------------------
		// PixelShaderFunction
		//  1. Read from PS structure
		//  2. Process
		//  3. Return pixel color
		//------------------------------------------------------------------------------------------
		float4 PixelShaderFunction(PSInput PS) : COLOR0
		{	
			float4 Color = 0;
			float4 Texel = tex2D(Sampler0, PS.TexCoord);
		
			float2 coord;
			coord.y = PS.TexCoord.y;
		
			for(int i = 0; i < 13; ++i)
			{
				coord.x = PS.TexCoord.x + (blurLevel * Kernel[i])/gTextureSize.x;
				Color += tex2D(Sampler0, coord.xy) * Weights[i];
			}
		
			Color = Color * PS.Diffuse;
			Color.a = alpha;
			return Color;
		}
		
		//------------------------------------------------------------------------------------------
		// Techniques
		//------------------------------------------------------------------------------------------
		technique fxBlurh
		{
			pass P0
			{
				VertexShader = compile vs_2_0 VertexShaderFunction();
				PixelShader  = compile ps_2_0 PixelShaderFunction();
			}
		}
		
		// Fallback
		technique fallback
		{
			pass P0
			{
				// Just draw normally
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

local graphics_elements = {}
graphics_elements.shader_blur = dxCreateShader(requestBlurShader())
graphics_elements.screen_source = dxCreateScreenSource( guiGetScreenSize( ) )
addEventHandler('onClientRender', root, function()
	dxUpdateScreenSource(graphics_elements.screen_source)
end)

function getGraphicsElement(name)
	return graphics_elements[name]
end

--
local shaders = {}
local function getShader(shader_name)
	shaders[shader_name] = isElement(shaders[shader_name]) and shaders[shader_name] or getGraphicsElement(shader_name)
	return isElement(shaders[shader_name]) and shaders[shader_name]
end
--
function getScreenSource()
    return getGraphicsElement('screen_source')
end
--
local defaultBlurLevel = 2

function getBlurTexture(texture, blurLevel, alpha)
	local blurShader = getShader('shader_blur')
	dxSetShaderValue(blurShader, 'gTexture', texture)
	dxSetShaderValue(blurShader, 'gTextureSize', { dxGetMaterialSize(texture) })
	dxSetShaderValue(blurShader, 'blurLevel', blurLevel or defaultBlurLevel)
	dxSetShaderValue(blurShader, 'alpha', alpha)
	return blurShader
end