--[[
@author Luke Willis
@version 1.1
@licence GPL v3
@reaper 6.82
@changelog fixed issue where it was referencing incorrect index
@about Tries to duplicate items down to a track that is not collapsed or hidden
--]]

--[[ MAIN ]] --

local r = reaper
local PROJECT = 0

-----------------------------------------------------------------------

local function getNewState(selectedTrackIndex) -- 1 = show. 0 hide
    local nextTrack = r.GetTrack(PROJECT, selectedTrackIndex + 1)
    if not nextTrack then return 0 end
    local currentState = r.GetMediaTrackInfo_Value(nextTrack, "B_SHOWINTCP")
    if currentState == 0 then return 1 end
    return 0
end

-----------------------------------------------------------------------

local function updateChildrenVisiblity(parent, newState)
    local parentDepth = r.GetTrackDepth(parent)
    local parentIndex = r.GetMediaTrackInfo_Value(parent, "IP_TRACKNUMBER") - 1
    for i = parentIndex + 1, r.CountTracks(PROJECT) - 1 do
        local searchTrack = r.GetTrack(PROJECT, i)
        local searchTrackDepth = r.GetTrackDepth(searchTrack)
        if parentDepth == searchTrackDepth then return end
        r.SetMediaTrackInfo_Value(searchTrack, "B_SHOWINTCP", newState)
        r.SetMediaTrackInfo_Value(searchTrack, "B_SHOWINMIXER", newState)
    end
end

-----------------------------------------------------------------------

local function tryToggleVisibility()
    for i = 0, r.CountSelectedTracks(PROJECT) - 1 do
        local track = r.GetSelectedTrack(PROJECT, i)
        local isFolder = r.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
        if isFolder then
            local trackIndex = r.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER") - 1
            updateChildrenVisiblity(track, getNewState(trackIndex))
            r.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
        end
    end
    r.TrackList_AdjustWindows(false)
end

-----------------------------------------------------------------------
tryToggleVisibility()