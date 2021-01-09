--[[
 * ReaScript Name: Swap Project Marker Names with Subtitles
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

function main()
	for i = 0, count_markers_and_regions - 1 do
		local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut =  reaper.EnumProjectMarkers( i )
		
		local subtitleName = reaper.NF_GetSWSMarkerRegionSub(i)

		-- only convert for regions
		if isrgnOut == true then
			if subtitleName == "" then
				reaper.NF_SetSWSMarkerRegionSub(nameOut, i)
				reaper.SetProjectMarkerByIndex2(0, i, isrgnOut, posOut, rgnendOut, markrgnindexnumberOut, "", 0, 1)
			else
				reaper.NF_SetSWSMarkerRegionSub(nameOut, i)
				reaper.SetProjectMarkerByIndex2(0, i, isrgnOut, posOut, rgnendOut, markrgnindexnumberOut, subtitleName, 0, 0)
			end
		end

		i = i + 1
	end

end -- end main()

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

count_markers_and_regions = reaper.CountProjectMarkers(0)

main()

reaper.Undo_EndBlock("Revert Marker/Subtitle Name", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.NF_UpdateSWSMarkerRegionSubWindow()

reaper.PreventUIRefresh(-1)
