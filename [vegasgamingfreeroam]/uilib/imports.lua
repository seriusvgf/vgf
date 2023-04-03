local isim = getResourceName(getThisResource())
local functions = {
	["create"] = {
        ["guiCreateWindow"] = {
            " function guiCreateWindow(...) return exports."..isim..":guiCreateWindow(...)end",
			" function guiWindowIsMovable(...) return exports."..isim..":guiWindowIsMovable(...)end",
			" function guiWindowIsSizable(...) return exports."..isim..":guiWindowIsSizable(...)end",
			" function guiWindowSetMovable(...) return exports."..isim..":guiWindowSetMovable(...)end",
			" function guiWindowSetSizable(...) return exports."..isim..":guiWindowSetSizable(...)end",
			" function guiWindowSetCloseVisible(...) return exports."..isim..":guiWindowSetCloseVisible(...)end",
			" function guiWindowGetCloseVisible(...) return exports."..isim..":guiWindowGetCloseVisible(...)end",
			
        },
		["guiCreateLoadingBar"] = {
            " function guiCreateLoadingBar(...) return exports."..isim..":guiCreateLoadingBar(...)end",
        },
		["guiCreateSquareArrow"] = {
            " function guiCreateSquareArrow(...) return exports."..isim..":guiCreateSquareArrow(...)end",
        },

		
        ["guiCreateLabel"] = {
            " function guiCreateLabel(...) return exports."..isim..":guiCreateLabel(...)end",
			" function guiLabelGetColor(...) return exports."..isim..":guiLabelGetColor(...)end",
			" function guiLabelGetFontHeight(...) return exports."..isim..":guiLabelGetFontHeight(...)end",
			" function guiLabelGetTextExtent(...) return exports."..isim..":guiLabelGetTextExtent(...)end",
			" function guiLabelSetColor(...) return exports."..isim..":guiLabelSetColor(...)end",
			" function guiLabelSetHorizontalAlign(...) return exports."..isim..":guiLabelSetHorizontalAlign(...)end",
			" function guiLabelSetVerticalAlign(...) return exports."..isim..":guiLabelSetVerticalAlign(...)end",
        },
        ["guiCreateButton"]={
			" function guiCreateButton(...)return exports."..isim..":guiCreateButton(...)end",
			" function guiSetButtonHoverColor(...)return exports."..isim..":guiSetButtonHoverColor(...)end",
			" function guiGetButtonHoverColor(...)return exports."..isim..":guiGetButtonHoverColor(...)end",
		},
        ["guiCreateCheckBox"]={
			" function guiCreateCheckBox(...)return exports."..isim..":guiCreateCheckBox(...)end",
			" function guiCheckBoxGetSelected(...)return exports."..isim..":guiCheckBoxGetSelected(...)end",
			" function guiCheckBoxSetSelected(...)return exports."..isim..":guiCheckBoxSetSelected(...)end",
			" function guiCheckBoxGetSelectedColor(...)return exports."..isim..":guiCheckBoxGetSelectedColor(...)end",
			" function guiCheckBoxSetSelectedColor(...)return exports."..isim..":guiCheckBoxSetSelectedColor(...)end",
		},
		["guiCreateRadioButton"]={
			" function guiCreateRadioButton(...)return exports."..isim..":guiCreateRadioButton(...)end",
			" function guiRadioButtonGetSelected(...)return exports."..isim..":guiRadioButtonGetSelected(...)end",
			" function guiRadioButtonSetSelected(...)return exports."..isim..":guiRadioButtonSetSelected(...)end",
			" function guiRadioButtonGetSelectedColor(...)return exports."..isim..":guiRadioButtonGetSelectedColor(...)end",
			" function guiRadioButtonSetSelectedColor(...)return exports."..isim..":guiRadioButtonSetSelectedColor(...)end",
		},
		
		["guiCreateEdit"]={
			" function guiCreateEdit(...)return exports."..isim..":guiCreateEdit(...)end",
			" function guiEditGetCaretIndex(...)return exports."..isim..":guiEditGetCaretIndex(...)end",
			" function guiEditGetMaxLength(...)return exports."..isim..":guiEditGetMaxLength(...)end",
			" function guiEditIsMasked(...)return exports."..isim..":guiEditIsMasked(...)end",
			" function guiEditIsReadOnly(...)return exports."..isim..":guiEditIsReadOnly(...)end",
			" function guiEditSetCaretIndex(...)return exports."..isim..":guiEditSetCaretIndex(...)end",
			" function guiEditSetMasked(...)return exports."..isim..":guiEditSetMasked(...)end",
			" function guiEditSetMaxLength(...)return exports."..isim..":guiEditSetMaxLength(...)end",
			" function guiEditSetReadOnly(...)return exports."..isim..":guiEditSetReadOnly(...)end",
		},
		["guiCreateMemo"]={
			" function guiCreateMemo(...)return exports."..isim..":guiCreateMemo(...)end",
			" function guiMemoGetCaretIndex(...)return exports."..isim..":guiMemoGetCaretIndex(...)end",
			" function guiMemoGetVerticalScrollPosition(...)return exports."..isim..":guiMemoGetVerticalScrollPosition(...)end",
			" function guiMemoSetVerticalScrollPosition(...)return exports."..isim..":guiMemoSetVerticalScrollPosition(...)end",
			" function guiMemoIsReadOnly(...)return exports."..isim..":guiMemoIsReadOnly(...)end",
			" function guiMemoSetCaretIndex(...)return exports."..isim..":guiMemoSetCaretIndex(...)end",
			" function guiMemoSetReadOnly(...)return exports."..isim..":guiMemoSetReadOnly(...)end",
		},
		["guiCreateGridList"]={
			" function guiCreateGridList(...)return exports."..isim..":guiCreateGridList(...)end",
		},
		["guiCreateTabPanel"]={
			" function guiCreateTabPanel(...)return exports."..isim..":guiCreateTabPanel(...)end",
			" function guiCreateTab(...)return exports."..isim..":guiCreateTab(...)end",
			" function guiSetSelectedTab(...)return exports."..isim..":guiSetSelectedTab(...)end",
			" function guiGetSelectedTab(...)return exports."..isim..":guiGetSelectedTab(...)end",
			" function guiDeleteTab(...)return exports."..isim..":guiDeleteTab(...)end",
			" function guiTabSetHorizontalAlign(...)return exports."..isim..":guiTabSetHorizontalAlign(...)end",

			
		},
		["guiCreateScrollBar"]={
			" function guiCreateScrollBar(...)return exports."..isim..":guiCreateScrollBar(...)end",
			" function guiScrollBarGetScrollPosition(...)return exports."..isim..":guiScrollBarGetScrollPosition(...)end",
			" function guiScrollBarSetScrollPosition(...)return exports."..isim..":guiScrollBarSetScrollPosition(...)end",
		},
		["guiCreateSwitchButton"]={
			" function guiCreateSwitchButton(...)return exports."..isim..":guiCreateSwitchButton(...)end",
			" function guiSwitchButtonGetState(...)return exports."..isim..":guiSwitchButtonGetState(...)end",
			" function guiSwitchButtonSetState(...)return exports."..isim..":guiSwitchButtonSetState(...)end",
			" function guiSwitchButtonGetText(...)return exports."..isim..":guiSwitchButtonGetText(...)end",
			" function guiSwitchButtonSetText(...)return exports."..isim..":guiSwitchButtonSetText(...)end",
		},
		["guiCreateProgressBar"]={
			" function guiCreateProgressBar(...)return exports."..isim..":guiCreateProgressBar(...)end",
			" function guiProgressBarGetProgress(...)return exports."..isim..":guiProgressBarGetProgress(...)end",
			" function guiProgressBarSetProgress(...)return exports."..isim..":guiProgressBarSetProgress(...)end",
			" function guiProgressBarGetMode(...)return exports."..isim..":guiProgressBarGetMode(...)end",
			" function guiProgressBarSetMode(...)return exports."..isim..":guiProgressBarSetMode(...)end",
			" function guiProgressBarGetStyle(...)return exports."..isim..":guiProgressBarGetStyle(...)end",
			" function guiProgressBarSetStyle(...)return exports."..isim..":guiProgressBarSetStyle(...)end",
		},
		["guiCreateComboBox"]={
			" function guiCreateComboBox(...)return exports."..isim..":guiCreateComboBox(...)end",
			" function guiComboBoxAddItem(...)return exports."..isim..":guiComboBoxAddItem(...)end",
			" function guiComboBoxClear(...)return exports."..isim..":guiComboBoxClear(...)end",
			" function guiComboBoxGetItemCount(...)return exports."..isim..":guiComboBoxGetItemCount(...)end",
			" function guiComboBoxGetItemText(...)return exports."..isim..":guiComboBoxGetItemText(...)end",
			" function guiComboBoxGetSelected(...)return exports."..isim..":guiComboBoxGetSelected(...)end",
			" function guiComboBoxIsOpen(...)return exports."..isim..":guiComboBoxIsOpen(...)end",
			" function guiComboBoxRemoveItem(...)return exports."..isim..":guiComboBoxRemoveItem(...)end",
			" function guiComboBoxSetItemText(...)return exports."..isim..":guiComboBoxSetItemText(...)end",
			" function guiComboBoxSetOpen(...)return exports."..isim..":guiComboBoxSetOpen(...)end",
			" function guiComboBoxSetSelected(...)return exports."..isim..":guiComboBoxSetSelected(...)end",
		},
    },
    ["utils"] = {
		" function guiGetPosition(...)return exports."..isim..":guiGetPosition(...) end",
		" function guiSetPosition(...)return exports."..isim..":guiSetPosition(...)end",
		" function guiGetSize(...)return exports."..isim..":guiGetSize(...)end",
		" function guiSetSize(...)return exports."..isim..":guiSetSize(...)end",
		" function guiSetText(...)return exports."..isim..":guiSetText(...)end",
		" function guiGetText(...)return exports."..isim..":guiGetText(...)end",
		" function guiSetEnabled(...)return exports."..isim..":guiSetEnabled(...)end",
		" function guiSetVisible(...)return exports."..isim..":guiSetVisible(...)end",
		" function guiGetVisible(...)return exports."..isim..":guiGetVisible(...)end",
		" function destroyElement(...)return exports."..isim..":destroyElement(...)end",
		" function guiGetFont(...)return exports."..isim..":guiGetFont(...)end",
		" function guiSetFont(...)return exports."..isim..":guiSetFont(...)end",
		" function customCreateFontDX(...)return exports."..isim..":customCreateFontDX(...)end",
		" function customCreateFontGui(...)return exports."..isim..":customCreateFontGui(...)end",
		" function dxDrawRoundedRectangle(...)return exports."..isim..":dxDrawRoundedRectangle(...)end",
		" function getScreenSource(...)return exports."..isim..":getScreenSource(...)end",
		" function dxDrawGradientRectangle(...)return exports."..isim..":dxDrawGradientRectangle(...)end",
		" function getBlurTexture(...)return exports."..isim..":getBlurTexture(...)end",
		" function customCreateLoaderBar(...)return exports."..isim..":customCreateLoaderBar(...)end",
		" function getFontAwesomeIcon(...)return exports."..isim..":getFontAwesomeIcon(...)end",
		" function RGBToHex(...)return exports."..isim..":RGBToHex(...)end",
		" function hex2rgb(...)return exports."..isim..":hex2rgb(...)end",
		" function rgb2hex(...)return exports."..isim..":rgb2hex(...)end",
		" function renk(...)return exports."..isim..":renk(...)end",
		" function reMap(...)return exports."..isim..":reMap(...)end",
		" function resp(...)return exports."..isim..":resp(...)end",
		" function respc(...)return exports."..isim..":respc(...)end",
		" function getResponsiveMultipler(...)return exports."..isim..":getResponsiveMultipler(...)end",
		
    },
}
function getLoadUI(...)
	local f = ""
	local isim = {...} 
	if #isim > 0 then 
		if #isim == 1 then
			local isim = isim[1] 
			if isim ~= "utils" and functions["create"][isim] then 
			
				for i,v in pairs(functions["create"][isim]) do
					f = f..v 
				end	
				
				for i,v in pairs(functions["utils"]) do 
					f = f..v 
				end
				
				return f	
			end	
			return f
		else 
			for i,v in pairs(isim) do 
				if functions["create"][v] then 
					for i,v in pairs(functions["create"][v]) do
						f = f..v 
					end	
				end	
			end
			for i,v in pairs(functions["utils"]) do
				f = f..v 
			end
			return f 
		end	
	else 
		for i,v in pairs(functions["create"]) do
			if i ~= "guilist" then
				for i,s in pairs(v) do
					f = f..s 
				end	
			end	
		end
		for i,v in pairs(functions["utils"]) do
			f = f..v
		end
		return f 
	end
end


