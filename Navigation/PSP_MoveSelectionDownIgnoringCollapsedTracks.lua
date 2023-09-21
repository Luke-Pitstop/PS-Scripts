--[[
@author Luke Willis
@version 1.3
@licence GPL v3
@reaper 6.82
@changelog first item on new track selection will now be only selected item
--]]

local r = reaper
local PROJECT = 0
local success = false

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
    -- ascend tracks downwards to check for valid tracks to select
    while i < r.CountTracks(PROJECT) do
        local searchTrack = r.GetTrack(PROJECT, i + 1)
        if searchTrack then
            if isValidSelection(searchTrack) then
                r.SetTrackSelected(trackToMove, false)
                r.SetTrackSelected(searchTrack, true)
                if success == false then success = true end
                return true
            end
        end
        i = i + 1
    end
    -- if it failed we want to leave the selection where it is
    return false
end

-----------------------------------------------------------------------

local function trySelectFirstItemOnNewSelectionTrack()
    if not success then return end;
    local firstTrack = r.GetSelectedTrack(PROJECT, 0)
    if not firstTrack then return end;

    local numFirstTrackItems = r.CountTrackMediaItems(firstTrack)
    local numSelectedMediaItems = r.CountSelectedMediaItems(PROJECT)
    if numFirstTrackItems == 0 then return end;
    local firstItem = r.GetTrackMediaItem(firstTrack, 0)
    if not firstItem then return end
    if numSelectedMediaItems > 0 then
        -- need to deselect what we have already
        r.Main_OnCommand(40289, 0)
    end
    r.SetMediaItemSelected(firstItem, true)
    r.TrackList_AdjustWindows(false)
end

-----------------------------------------------------------------------

local function tryAdjustSelection()
    local i = r.CountSelectedTracks(PROJECT) - 1
    while i >= 0 do
        local track = r.GetSelectedTrack(PROJECT, i)
        tryMoveTrackSelection(track)
        i = i - 1
    end
    r.Main_OnCommand(40914, 0) -- set first selected track as last touched track
    if r.CountSelectedTracks(PROJECT) > 0 then
        r.SetMixerScroll(r.GetSelectedTrack(PROJECT, 0))
    end
    trySelectFirstItemOnNewSelectionTrack()
end

-----------------------------------------------------------------------

tryAdjustSelection()


