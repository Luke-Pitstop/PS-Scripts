--[[
@author Luke Willis
@version 1.0
@licence GPL v3
@reaper 6.82
@changelog release
@about shows all tracks
--]]

--[[ MAIN ]] --

local r = reaper
local PROJECT = 0

-----------------------------------------------------------------------

local function tryShowAllTracks()
    for i = 0, r.CountTracks(PROJECT) do
        local searchTrack = r.GetTrack(PROJECT, i)
        if not searchTrack then goto continue end
        r.SetMediaTrackInfo_Value(searchTrack, "B_SHOWINTCP", 1)
        r.SetMediaTrackInfo_Value(searchTrack, "B_SHOWINMIXER", 1)
        ::continue::
    end
    r.TrackList_AdjustWindows(false)
end

-----------------------------------------------------------------------

tryShowAllTracks()