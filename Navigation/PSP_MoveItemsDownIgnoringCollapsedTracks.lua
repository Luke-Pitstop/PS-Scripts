--[[
@author Luke Willis
@version 1.0
@licence GPL v3
@reaper 6.81
@changelog

Changelog:
    Release
--]]

local r = reaper
local PROJECT = 0

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
            local searchItemPos = r.GetMediaItemInfo_Value(searchItem, "D_POSITION")
            if mediaItemPos == searchItemPos then
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
        local searchTrack = r.GetTrack(PROJECT, i + 1)
        if searchTrack then
            if isValidSelection(searchTrack, mediaItem) then
                r.MoveMediaItemToTrack(mediaItem, searchTrack)
                r.TrackList_AdjustWindows(true)
                return true
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
end

-----------------------------------------------------------------------

tryMoveSelection()
