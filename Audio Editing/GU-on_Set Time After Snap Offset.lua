--[[
 * ReaScript Name: GU-on Set Time After Snap Offset
 * Author: GU-on
 * Licence: GPL v3
 * REAPER: 6.27
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-04-14)
	+ Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

ext_name = "GU_SetTimeAfterSnapOffset"
ext_save = ""

local r = reaper
local ctx = r.ImGui_CreateContext('Set Time After Snap Offset', 300, 60)
local is_complete = false

function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

function Main(x)
	for i, item in ipairs(init_sel_items) do
		reaper.SetMediaItemSelected( item, false )
	end
	
	for i, item in ipairs(init_sel_items) do
		reaper.SetMediaItemSelected( item, true )
		item_snapoffset = r.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
		item_length = r.GetMediaItemInfo_Value(item, "D_LENGTH")
		
		-- r.ApplyNudge(project, nudgeflag, nudgewhat, nudgeunits, value, reverse, copies)
		r.ApplyNudge(0, 0, 3, 1, (item_length - item_snapoffset), true, 0)
		
		r.ApplyNudge(0, 0, 3, 1, x, false, 0)
		reaper.SetMediaItemSelected( item, false )
	end
	
	for i, item in ipairs(init_sel_items) do
		reaper.SetMediaItemSelected( item, true )
	end
end

-- Get Ext State

if r.HasExtState(ext_name, "saved_val") then
	ext_save = r.GetExtState(ext_name, "saved_val")
else
	ext_save = 0
end

-- Check if items are selected
count_sel_items = r.CountSelectedMediaItems(0)

if count_sel_items > 0 then
	r.ImGui_SetKeyboardFocusHere(ctx)
	function loop()
		local rv

		if (r.ImGui_IsCloseRequested(ctx) or is_complete) then
			r.ImGui_DestroyContext(ctx)
		return
		end

		r.ImGui_SetNextWindowPos(ctx, 0, 0)
		r.ImGui_SetNextWindowSize(ctx, r.ImGui_GetDisplaySize(ctx))
		r.ImGui_Begin(ctx, 'wnd', nil, r.ImGui_WindowFlags_NoDecoration())
		
		if (r.ImGui_IsAnyItemActive(ctx) ~= true) then
			reaper.ImGui_SetKeyboardFocusHere(ctx)
			text = ext_save
		end

		if (r.ImGui_Button(ctx, 'Apply') or r.ImGui_IsKeyPressed(ctx, 13)) then
			r.PreventUIRefresh(1)
			r.Undo_BeginBlock() -- Begining of the undo block. 
			
			init_sel_items =  {}
			SaveSelectedItems(init_sel_items)
			Main(text)
			
			r.Undo_EndBlock("Set time after snap offset", - 1) -- End of the undo block. 
			r.UpdateArrange()
			r.PreventUIRefresh(-1)
			
			r.SetExtState(ext_name, "saved_val", tostring(text), true)
			is_complete = true
		end
		
		rv, text = r.ImGui_InputText(ctx, 'seconds', text, r.ImGui_InputTextFlags_CharsDecimal())
	  
		r.ImGui_End(ctx)
		
		r.defer(loop)
	end
	r.defer(loop)

end