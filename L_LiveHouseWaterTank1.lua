--
-- LiveHouse Water Tank Sensor
--
-- Works with Ultrasonic Distance Sensor to calculate % Capacity and Volume in Litres
--
-- Created by Antony Winn
--
-- https://www.livehouseautomation.com.au

local WATERTANK_SID = "urn:livehouse-automation:serviceId:WaterTankSensor1"
local DISTANCE_SID = "urn:micasaverde-com:serviceId:DistanceSensor1"
local WATERMETER_SID = "urn:micasaverde-com:serviceId:WaterMetering1"

-- Default Values
local SURFACE_AREA = 28000
local MAX_LEVEL = 30
local MIN_LEVEL = 200
local DEBUG_MODE = 0
local PARENT_DEVICE = 0
local DISTANCE_DEVICE = 0

-------------------------------------------
-- Utility Functions
-------------------------------------------

local function infoLog(text)
    local id = PARENT_DEVICE or "unknown"
    luup.log("LiveHouse Water Tank #" .. id .. " " .. text)
end

local function debugLog(text)
    if (DEBUG_MODE == "1") then
        infoLog("DEBUG " .. text)
    end
end

-- Get variable value and init if value is nil
function getVariableOrInit(lul_device, serviceId, variableName, defaultValue)
    local value = luup.variable_get(serviceId, variableName, lul_device)
    debugLog("Variable " .. variableName .. " = " .. tostring(value))
    if (value == nil) then
        debugLog("Setting default value for " .. variableName .. " to " .. defaultValue)
        luup.variable_set(serviceId, variableName, defaultValue, lul_device)
        value = defaultValue
    end
    return value
end

local function round(value, digits)
    shift = 10 ^ digits
    result = math.floor(value * shift + 0.5) / shift
    return result
end

local function calculateTankVolume(distance)
    local volume
    distance = tonumber(distance)

    if (distance > MIN_LEVEL) then
        distance = MIN_LEVEL
    end
    if (distance < MAX_LEVEL) then
        distance = MAX_LEVEL
    end
    volume = (SURFACE_AREA * (MIN_LEVEL - distance)) / 1000
    volume = round(volume, 0)
    debugLog("Usable Tank Volume  = " .. tostring(volume) .. " litres")
    luup.variable_set(WATERMETER_SID, "Volume", volume, lul_device)
end

local function calculateTankCapacity(distance)
    local capacity
    distance = tonumber(distance)

    if (distance > MIN_LEVEL) then
        distance = MIN_LEVEL
    end
    if (distance < MAX_LEVEL) then
        distance = MAX_LEVEL
    end
    capacity = ((MIN_LEVEL - distance) / (MIN_LEVEL - MAX_LEVEL)) * 100
    capacity = round(capacity, 0)
    debugLog("Tank Capacity  = " .. tostring(capacity) .. " %")
    luup.variable_set(WATERTANK_SID, "PercentFull", capacity, lul_device)
end

-------------------------------------------
-- Callbacks
-------------------------------------------
--   * lul_device is a number that is the device ID
--   * lul_service is the service ID (string?)
--   * lul_variable is the variable name (string?)
--   * lul_value_old / lul_value_new are the values

function CurrentDistanceCallback(lul_device, lul_service, lul_variable, lul_value_old, lul_value_new)
    debugLog(
        "CurrentDistanceCallback: Executing after CurrentDistance changed from " ..
            lul_value_old .. " to " .. lul_value_new
    )
    calculateTankVolume(lul_value_new)
    calculateTankCapacity(lul_value_new)
end

-------------------------------------------
-- Startup
-------------------------------------------

-- Init plugin instance

function initPluginInstance(lul_device)
    -- Get debug mode
    DEBUG_MODE = getVariableOrInit(lul_device, WATERTANK_SID, "Debug", DEBUG_MODE)

    PARENT_DEVICE = lul_device

    debugLog("initPluginInstance Function")

    SURFACE_AREA = tonumber(getVariableOrInit(lul_device, WATERTANK_SID, "SurfaceArea", SURFACE_AREA))
    MAX_LEVEL = tonumber(getVariableOrInit(lul_device, WATERTANK_SID, "MaxLevel", MAX_LEVEL))
    MIN_LEVEL = tonumber(getVariableOrInit(lul_device, WATERTANK_SID, "MinLevel", MIN_LEVEL))
    DISTANCE_DEVICE = tonumber(getVariableOrInit(lul_device, WATERTANK_SID, "DistanceDeviceID", DISTANCE_DEVICE))
end

function startup(lul_device)
    infoLog("Water Tank Sensor Logic reporting for duty.")
    -- Init
    initPluginInstance(lul_device)

    -- Watch the Distance Value to see if it's been updated
    debugLog("Watching CurrentDistance on " .. DISTANCE_DEVICE)
    luup.variable_watch("CurrentDistanceCallback", DISTANCE_SID, "CurrentDistance", DISTANCE_DEVICE)

    return true
end
