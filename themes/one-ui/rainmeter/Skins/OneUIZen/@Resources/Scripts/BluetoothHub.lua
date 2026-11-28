local view
local empty = {}

function Initialize()
    view = dofile(SKIN:GetVariable('@') .. 'Scripts\\Panel.lua').new(SKIN)
    Parse()
end

function Update()
    return 0
end

function Parse()
    local source = SKIN:GetMeasure('MeasureBtCmd')
    local raw = source and source:GetStringValue() or ''
    local connected, count, unknown = raw:match('COUNT=(%d+)|(%d+)|(%d+)')
    local rows = {}
    for idx,name,conn,batt in raw:gmatch('DEV(%d)=([^|\r\n]+)|(-?%d+)|(-?%d+)') do
        rows[tonumber(idx)] = {name=name, connected=tonumber(conn), battery=tonumber(batt)}
    end

    local status = raw:find('STATUS=ERROR',1,true) and 'UiBluetoothError'
        or raw == '' and 'UiBluetoothLoading'
        or not count and 'UiBluetoothError'
        or tonumber(count) == 0 and 'LblNoDevices' or nil
    local visible = 0
    for _, device in pairs(rows) do if device.name then visible = visible + 1 end end
    local height = visible > 0 and 119 + (visible - 1) * 46 or 126
    view:set('MeterCard','H',tostring(height))
    view:set('MeterCard','Shape',string.format('Rectangle 2,2,302,%d,28 | Fill Color %s | StrokeWidth 1 | Stroke Color %s',
        height - 4, view:color('Surface'), view:color('Border')))
    view:label('MeterCount', count and ((unknown == '0' and connected or '?') .. ' / ' .. count) or '--')
    view:label('MeterMessage', status and SKIN:GetVariable(status) or ' ')
    view:set('MeterMessage','Hidden',status and '0' or '1')
    for i = 1,3 do
        local device = rows[i] or empty
        local charge = device.battery and device.battery >= 0 and device.battery <= 100
        local connection = device.connected == 1 and 'LblConnected' or device.connected == 0 and 'LblPaired' or 'UiConnectionUnknown'
        view:label('MeterDevice' .. i, device.name or ' ')
        view:label('MeterStatus' .. i, device.name and SKIN:GetVariable(connection) or ' ')
        view:label('MeterCharge' .. i, charge and (device.battery .. '%') or (device.name and '--' or ' '))
        for _, prefix in ipairs({'MeterRow','MeterDevice','MeterStatus','MeterCharge'}) do
            view:set(prefix .. i, 'Hidden', device.name and '0' or '1')
        end
    end
    SKIN:Bang('!UpdateMeter','*')
    SKIN:Bang('!Redraw')
end
