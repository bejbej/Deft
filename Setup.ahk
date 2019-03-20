StartUp() {
    InitializePositions()
    
    ;listen for WM_DISPLAYCHANGE - handles resolution changes
    OnMessage(0x007E, "InitializePositions")

    ;listen for WM_SETTINGCHANGE - handles task bar moving/resizing
    OnMessage(0x001A, "InitializePositions")

    ;clean up global variables every 15 minutes
    SetTimer, CleanUp, 900000

    CleanUp:
        PeriodicCleanUp()
        return
}

InitializePositions() {
    global

    local count
    SysGet, count, MonitorCount

    Loop, %count% {
        _monitor%A_Index% := GetMonitorDimensions(A_Index)
        _position%A_Index%_%_positionLeft% := CreateLeftPosition(A_Index)
        _position%A_Index%_%_positionTop% := CreateTopPosition(A_Index)
        _position%A_Index%_%_positionRight% := CreateRightPosition(A_Index)
        _position%A_Index%_%_positionBottom% := CreateBottomPosition(A_Index)
        _position%A_Index%_%_positionTopLeft% := CreateTopLeftPosition(A_Index)
        _position%A_Index%_%_positionBottomLeft% := CreateBottomLeftPosition(A_Index)
        _position%A_Index%_%_positionTopRight% := CreateTopRightPosition(A_Index)
        _position%A_Index%_%_positionBottomRight% := CreateBottomRightPosition(A_Index)
        _position%A_Index%_%_positionHome% := CreateHomePosition(A_Index)
    }
}

GetMonitorDimensions(monitor) {
    SysGet, dimension, MonitorWorkArea, %monitor%
    dimensions = %dimensionLeft%,%dimensionRight%,%dimensionTop%,%dimensionBottom%
    return %dimensions%
}

GetMonitorDimension(monitor, dimension) {
    global
    
    local parts
    StringSplit, parts, _monitor%monitor%, `,

    local value := parts%dimension%
    return %value%
}

GetMonitorCount() {
    SysGet, count, MonitorCount
    return %count%
}

GetCurrentMonitor() {
    WinGetPos, x, y, width, height, A
    x += Floor(width / 2)
    y += Floor(height / 2)
    return GetMonitorAt(x, y)
}

GetAdjacentMonitor(relationToCurrent) {
    count := GetMonitorCount()
    current := GetCurrentMonitor()
    adjacent := current + relationToCurrent
    
    if (adjacent > count) {
        return 1
    }
    else if (adjacent < 1) {
        return count
    }
    else {
        return %adjacent%
    }   
}

GetMonitorAt(x, y) {
    count := GetMonitorCount()

    Loop, %count% {
        SysGet, monitor, Monitor, %A_Index%

        if (x >= monitorLeft && x <= monitorRight && y >= monitorTop && y <= monitorBottom) {
            return %A_Index%
        }
    }

    return 1
}

GetWidth(monitor) {
    left := GetLeft(monitor)
    right := GetRight(monitor)
    width := right - left
    return %width%
}

GetHeight(monitor) {
    top := GetMonitorDimension(monitor, 3)
    bottom := GetMonitorDimension(monitor, 4)
    height := bottom - top
    return %height%
}

GetLeft(monitor) {
    left := GetMonitorDimension(monitor, 1)
    return %left%
}

GetRight(monitor) {
    right := GetMonitorDimension(monitor, 2)
    return %right%
}

GetTop(monitor) {
    top := GetMonitorDimension(monitor, 3)
    return %top%
}

GetBottom(monitor) {
    bottom := GetMonitorDimension(monitor, 4)
    return %bottom%
}

GetCurrentPositionIndex() {
    global

    local positionIndex := 0
    local monitor := GetCurrentMonitor()
    local position := GetCurrentPosition()
        
    Loop %_positionCount% {
        if (position == _position%monitor%_%A_Index%) {
            return %A_Index%
        }
    }
    
    return 0
}

GetCurrentPosition() {
    WinGetPos, left, top, width, height, A
    position = %left%,%top%,%width%,%height%
    return %position%
}

GetAdjacentPosition(relationToCurrent) {
    WinGetPos, left, top, width, height, A

    current := GetCurrentMonitor()
    adjacent := GetAdjacentMonitor(relationToCurrent)

    leftRatio := (left - GetLeft(current)) / GetWidth(current)
    topRatio := (top - GetTop(current)) / GetHeight(current)
    widthRatio := width / GetWidth(current)
    heightRatio := height / GetHeight(current)

    left := GetLeft(adjacent) + Floor(GetWidth(adjacent) * leftRatio)
    top := GetTop(adjacent) + Floor(GetHeight(adjacent) * topRatio)
    width := Floor(GetWidth(adjacent) * widthRatio)
    height := Floor(GetHeight(adjacent) * heightRatio)

    position = %left%,%top%,%width%,%height%
    return %position%
}

CreateHomePosition(monitor) {
    fullWidth := GetWidth(monitor)
    fullHeight := GetHeight(monitor)
    width := Floor(fullWidth * .9)
    height := Floor(fullHeight * .9)
    left := Floor(GetLeft(monitor) + (fullWidth * .05))
    top := Floor(GetTop(monitor) + (fullHeight * .05))
    position = %left%,%top%,%width%,%height%
    return position
}

CreateLeftPosition(monitor) {
    width := HalfWidth(monitor)
    height := FullHeight(monitor)
    left := Left(monitor)
    top := Top(monitor)
    position = %left%,%top%,%width%,%height%
    return position    
}

CreateTopPosition(monitor) {
    width := FullWidth(monitor)
    height := HalfHeight(monitor)
    left := Left(monitor)
    top := Top(monitor)
    position = %left%,%top%,%width%,%height%
    return position    
}

CreateRightPosition(monitor) {
    width := HalfWidth(monitor)
    height := FullHeight(monitor)
    left := Right(monitor)
    top := Top(monitor)
    position = %left%,%top%,%width%,%height%
    return position    
}

CreateBottomPosition(monitor) {
    width := FullWidth(monitor)
    height := HalfHeight(monitor)
    left := Left(monitor)
    top := Bottom(monitor)
    position = %left%,%top%,%width%,%height%
    return position    
}

CreateTopLeftPosition(monitor) {
    width := HalfWidth(monitor)
    height := HalfHeight(monitor)
    left := Left(monitor)
    top := Top(monitor)
    position = %left%,%top%,%width%,%height%
    return position
}

CreateTopRightPosition(monitor) {
    width := HalfWidth(monitor)
    height := HalfHeight(monitor)
    left := Right(monitor)
    top := Top(monitor)
    position = %left%,%top%,%width%,%height%
    return position
}

CreateBottomRightPosition(monitor) {
    width := HalfWidth(monitor)
    height := HalfHeight(monitor)
    left := Right(monitor)
    top := Bottom(monitor)
    position = %left%,%top%,%width%,%height%
    return position
}

CreateBottomLeftPosition(monitor) {
    width := HalfWidth(monitor)
    height := HalfHeight(monitor)
    left := Left(monitor)
    top := Bottom(monitor)
    position = %left%,%top%,%width%,%height%
    return position
}


FullWidth(monitor) {
    global _paddingLeft, _paddingRight
    width := GetWidth(monitor)
    return Floor(width - _paddingLeft - _paddingRight)
}

HalfWidth(monitor) {
    global _paddingLeft, _paddingRight
    width := GetWidth(monitor)
    return Floor((width / 2) - _paddingLeft - _paddingRight)
}

FullHeight(monitor) {
    global _paddingTop, _paddingBottom
    height := GetHeight(monitor)
    return Floor(height - _paddingTop - _paddingBottom)
}

HalfHeight(monitor) {
    global _paddingTop, _paddingBottom
    height := GetHeight(monitor)
    return Floor((height / 2) - _paddingTop - _paddingBottom)
}

Top(monitor) {
    global _paddingTop
    top := GetTop(monitor)
    return Floor(top + _paddingTop)
}

Bottom(monitor) {
    global _paddingTop
    height := GetHeight(monitor)
    top := GetTop(monitor)
    return Floor(top + (height / 2) + _paddingTop)
}

Left(monitor) {
    global _paddingLeft
    left := GetLeft(monitor)
    return Floor(left + _paddingLeft)
}

Right(monitor) {
    global _paddingLeft
    width := GetWidth(monitor)
    left := GetLeft(monitor)
    return Floor(left + (width / 2) + _paddingLeft)
}

StoreUndoLocation() {
    global

    if (!GetCurrentPositionIndex()) {
        local id := WinExist("A")
        _undo%id% := GetCurrentPosition()

        if (!InStr(_undoIds, id)) {
            _undoIds .= id . ","
        }
    }
}

PeriodicCleanUp() {
    global _undoIds
    StringSplit, parts, _undoIds, `,
    _undoIds := ""

    Loop %parts0% {
        id := parts%A_Index%
        find := "ahk_id " . id
        
        if (WinExist(find)) {
            _undoIds .= id . ","
        }
        else if (id != "") {
            VarSetCapacity(_undo%id%, 0)
        }
    }
}