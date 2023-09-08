--[[
@author Luke Willis
@version 1.1
@licence GPL v3
@reaper 6.81
--]]

local r = reaper
local PROJECT = 0

-----------------------------------------------------------------------

local function isValidSelection(track)
    local isTrackAlreadySelected = r.IsTrackSelected(track)

    if isTrackAlreadySelected then
        return false
    end

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
    return true
end

-----------------------------------------------------------------------

local function tryMoveTrackSelection(trackToMove)
    local trackToMoveIndex = r.GetMediaTrackInfo_Value(trackToMove, "IP_TRACKNUMBER")
    local i = trackToMoveIndex - 1 -- make it zero based
    -- ascend tracks upwards to check for valid tracks to select
    while i < r.CountTracks(PROJECT) do
        local searchTrack = r.GetTrack(PROJECT, i + 1)
        if searchTrack then
            if isValidSelection(searchTrack) then
                r.SetTrackSelected(trackToMove, false)
                r.SetTrackSelected(searchTrack, true)
                return true
            end
        end
        i = i + 1
    end
    -- if it failed we want to leave the selection where it is
    return false
end

-----------------------------------------------------------------------

local function tryAdjustSelection()
    local i = r.CountSelectedTracks(PROJECT) - 1
    while i >= 0 do
        local track = r.GetSelectedTrack(PROJECT, i)
        tryMoveTrackSelection(track)
        i = i - 1
    end
end

-----------------------------------------------------------------------

tryAdjustSelection()


