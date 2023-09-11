--[[
@author Luke Willis
@version 1.0
@licence GPL v3
@reaper 6.82
@changelog
@about shows or hides all folder tracks in project
--]]

--[[ MAIN ]] --

local r = reaper
local PROJECT = 0

-----------------------------------------------------------------------

local function getToggleStatus()
    -- check if any folders are expanded
    local currentToggleStatus = 0
    for i = 0, r.CountTracks(PROJECT) - 1 do
        local track = r.GetTrack(PROJECT, i)
        if not track then goto continue end
        local isTrackFolder = r.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
        if not isTrackFolder then goto continue end
        local isTrackFolderCompact = r.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT") ~= 0
        if not isTrackFolderCompact then
            currentToggleStatus = 1
            break
        end
        ::continue::
    end
    if currentToggleStatus == 1 then return 2 end
    return 0
end

-----------------------------------------------------------------------

local function tryToggleFolderTracks()
    local toggleStatus = getToggleStatus()
    for i = 0, r.CountTracks(PROJECT) - 1 do
        local track = r.GetTrack(PROJECT, i)
        if not track then goto continue end
        local isTrackFolder = r.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
        if not isTrackFolder then goto continue end
        r.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", toggleStatus)
        ::continue::
    end
    r.TrackList_AdjustWindows(true)
end

-----------------------------------------------------------------------

tryToggleFolderTracks()