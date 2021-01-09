--[[
 * ReaScript Name: Unselect Muted Items in Selection
 * Author: GU-on
 * Licence: GPL v3
 * REAPER: 6.19
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-01-09)
	+ Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

function main()

  -- INITIALIZE loop through selected items
  for i, item in ipairs(init_sel_items) do
  local item_mute = reaper.GetMediaItemInfo_Value(item, "B_MUTE")
    if item_mute == 1 then
      reaper.SetMediaItemSelected(item, false)
    end
  end
end

-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  main()

  reaper.Undo_EndBlock("Unselect Muted Items in Selection", - 1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end