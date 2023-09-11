--[[
@author Luke Willis
@version 1.2
@licence GPL v3
@reaper 6.82
@changelog moved visual update to end of script
@about Tries to move items down to a track that is not collapsed or hidden
--]]

--[[ SETTINGS ]] --

    local overlapThresholdSeconds = 0.5

--[[ MAIN ]] --

local r = reaper
local PROJECT = 0

-----------------------------------------------------------------------

local function isMoveLocationWithinThreshold(startingPos, targetMediaItem)
    local targetStartPos = r.GetMediaItemInfo_Value(targetMediaItem, "D_POSITION")
    local overlapAmount = (startingPos + overlapThresholdSeconds) - (targetStartPos + overlapThresholdSeconds)
    return overlapAmount > overlapThresholdSeconds or overlapAmount < (overlapThresholdSeconds * -1)
end

-----------------------------------------------------------------------

local function isValidSelection(track, mediaItem)
    local isTrackVisible = r.GetMediaTrackInfo_Value(track, "B_SHOWINTCP") == 1
    if not isTrackVisible then
        return false -- track is hidden in TCP
    end

    local parent = r.GetParentTrack(track)
    if parent then -- if it has a parent then need to check if it's collapsed
        local isParentCollapsed = r.GetMediaTrackInfo_Value(parent, "I_FOLDERCOMPACT") ~= 0
        if isParentCollapsed then
            return false -- track is collapsed
        end
    end

    -- don't move the item if an item exists on the track at the same position
    local mediaItemPos = r.GetMediaItemInfo_Value(mediaItem, "D_POSITION")
    for i = 0, r.CountTrackMediaItems(track) do
        local searchItem = r.GetTrackMediaItem(track, i)
        if searchItem then
            if not isMoveLocationWithinThreshold(mediaItemPos, searchItem) then
                return false
            end
        end
    end
    return true
end

-----------------------------------------------------------------------

local function tryMoveMediaItem(mediaItem)
    local mediaItemTrack = r.GetMediaItemTrack(mediaItem)
    local mediaItemTrackIndex = r.GetMediaTrackInfo_Value(mediaItemTrack, "IP_TRACKNUMBER")
    local i = mediaItemTrackIndex - 1 -- make it zero based
    while i < r.CountTracks(PROJECT) do
        -- if on last track of project, create new one
        if i == r.CountTracks(PROJECT) - 1 then
            local newTrackIndex = r.CountTracks(PROJECT)
            r.InsertTrackAtIndex(newTrackIndex, true)
        end

        local searchTrack = r.GetTrack(PROJECT, i + 1)
        if searchTrack then
            if isValidSelection(searchTrack, mediaItem) then
                r.MoveMediaItemToTrack(mediaItem, searchTrack)
                return
            end
        end
        i = i + 1
    end
end

-----------------------------------------------------------------------

local function tryMoveSelection()
    local i = r.CountSelectedMediaItems(PROJECT) - 1
    while i >= 0 do
        local mediaItem = r.GetSelectedMediaItem(PROJECT, i)
        tryMoveMediaItem(mediaItem)
        i = i - 1
    end
    r.TrackList_AdjustWindows(true)
end

-----------------------------------------------------------------------

tryMoveSelection()
