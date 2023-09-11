--[[
@author Luke Willis
@version 1.0
@licence GPL v3
@reaper 6.82
@changelog release
@about Tries to duplicate items down to a track that is not collapsed or hidden
--]]

--[[ MAIN ]] --

local r = reaper
local PROJECT = 0

-----------------------------------------------------------------------

local function isTargetOccupiedByItem(startingMediaItem, targetMediaItem)
    local startingPos = r.GetMediaItemInfo_Value(startingMediaItem, "D_POSITION")
    local startingLen = r.GetMediaItemInfo_Value(startingMediaItem, "D_LENGTH")
    local targetPos = r.GetMediaItemInfo_Value(targetMediaItem, "D_POSITION")
    local targetLen = r.GetMediaItemInfo_Value(targetMediaItem, "D_LENGTH")

    local topOverlap = targetPos >= startingPos and targetPos < startingPos + startingLen
    local botOverlap = targetPos < startingPos and targetPos + targetLen > startingPos
    return topOverlap or botOverlap
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
    for i = 0, r.CountTrackMediaItems(track) do
        local searchItem = r.GetTrackMediaItem(track, i)
        if searchItem then
            if isTargetOccupiedByItem(mediaItem, searchItem) then
                return false
            end
        end
    end
    return true
end

-----------------------------------------------------------------------

local function duplicateMediaItemToTrack(item, track)
    local pos = r.GetMediaItemInfo_Value(item, "D_POSITION")
    r.SetEditCurPos(pos, false, false)
    r.SetOnlyTrackSelected(track)
    r.Main_OnCommand(40698, 0) -- copy items
    r.Main_OnCommand(42398, 0) -- paste items
    r.SetEditCurPos(pos, false, false)
end

-----------------------------------------------------------------------

local function isItemOnTopTrack(mediaItem)
    local mediaItemTrack = r.GetMediaItemTrack(mediaItem)
    local mediaItemTrackIndex = r.GetMediaTrackInfo_Value(mediaItemTrack, "IP_TRACKNUMBER")
    return mediaItemTrackIndex <= 1
end

-----------------------------------------------------------------------

local function tryDuplicateMediaItem(mediaItem)
    local mediaItemTrack = r.GetMediaItemTrack(mediaItem)
    local mediaItemTrackIndex = r.GetMediaTrackInfo_Value(mediaItemTrack, "IP_TRACKNUMBER")
    local i = mediaItemTrackIndex - 1 -- make it zero based
    while i >= 1 do
        local searchTrack = r.GetTrack(PROJECT, i - 1)
        if searchTrack then
            if isValidSelection(searchTrack, mediaItem) then
                duplicateMediaItemToTrack(mediaItem, searchTrack)
                return
            end
        end
        i = i - 1
    end
end

-----------------------------------------------------------------------

local function tryDuplicateSelection()
    for i = 0, r.CountSelectedMediaItems(PROJECT) - 1 do
        local mediaItem = r.GetSelectedMediaItem(PROJECT, i)
        if isItemOnTopTrack(mediaItem) then return end
        tryDuplicateMediaItem(mediaItem)
    end
    r.TrackList_AdjustWindows(true)
end

-----------------------------------------------------------------------

tryDuplicateSelection()