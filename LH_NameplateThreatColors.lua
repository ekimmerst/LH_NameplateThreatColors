local addonName = ...
local Addon = {}
LH_NameplateThreatColors = Addon
local events = CreateFrame("Frame")
local active, bars = {}, {}
local elapsed = 0
local function GetOptions()
    LH_NameplateThreatColorsDB = type(LH_NameplateThreatColorsDB) == "table" and LH_NameplateThreatColorsDB or {}
    local options = LH_NameplateThreatColorsDB
    if type(options.enabled) ~= "boolean" then options.enabled = true end
    if options.role ~= "tank" and options.role ~= "dps" then options.role = "auto" end
    return options
end
function Addon:IsEnabled() return GetOptions().enabled end
function Addon:GetRole() return GetOptions().role end
local colors = { green = {0, 0.85, 0.15}, gray = {0.5, 0.5, 0.5}, orange = {1, 0.5, 0}, red = {1, 0.1, 0.1} }
local function Read(fn, ...)
    if not fn then return nil end
    local ok, value = pcall(fn, ...)
    if ok and not (issecretvalue and issecretvalue(value)) then return value end
end
local function IsTank()
    local role = LH_NameplateThreatColorsDB and LH_NameplateThreatColorsDB.role or "auto"
    if role ~= "auto" then return role == "tank" end
    role = Read(UnitGroupRolesAssigned, "player")
    if role and role ~= "NONE" then return role == "TANK" end
    local spec = Read(GetSpecialization)
    return spec and Read(GetSpecializationRole, spec) == "TANK" or false
end
local function HasLivingPet()
    return Read(UnitExists, "pet") == true
        and Read(UnitIsDeadOrGhost, "pet") == false
end
local function DesiredColor(unit)
    if not Addon:IsEnabled() then return nil end
    local hasPet = HasLivingPet()
    if not hasPet and Read(IsInGroup) ~= true then return nil end
    local _, class = UnitClass("player")
    local hunterPet = hasPet and class == "HUNTER"
    if not Read(UnitExists, unit)
        or Read(UnitIsPlayer, unit) ~= false
        or Read(UnitCanAttack, "player", unit) ~= true
        or Read(UnitIsDeadOrGhost, unit) ~= false then return nil end
    -- A kill reserved for another player always takes priority over threat colors.
    if Read(UnitIsTapDenied, unit) == true then return colors.gray end
    if not UnitThreatSituation then return nil end
    local ok, status = pcall(UnitThreatSituation, "player", unit)
    if not ok or (issecretvalue and issecretvalue(status)) then return nil end
    if status ~= nil and type(status) ~= "number" then return nil end
    if hunterPet then
        if status == 2 or status == 3 then return colors.red end
        if status == 1 then return colors.orange end
        return colors.green
    end
    if not IsTank() then
        if status == 2 or status == 3 then return colors.red end
        return status == 1 and colors.orange or colors.green
    end
    if status == 3 then return colors.green end
    if status == 2 then return colors.orange end
    local target = unit .. "target"
    if Read(UnitExists, target) and Read(UnitIsUnit, target, "player") == false then
        if Read(UnitInParty, target) or Read(UnitInRaid, target) then return colors.red end
        local raid = Read(IsInRaid)
        for i = 1, (raid and 40 or 4) do
            local pet = (raid and "raidpet" or "partypet") .. i
            if Read(UnitIsUnit, target, pet) then return colors.red end
        end
    end
end
local function Paint(bar, data, color)
    data.writing = true
    bar:SetStatusBarColor(color[1], color[2], color[3], color[4])
    data.writing = false
end
local function UpdateBar(bar, data)
    local color = data.unit and DesiredColor(data.unit)
    if color then
        Paint(bar, data, color)
        data.changed = true
    elseif data.changed then
        Paint(bar, data, data.original)
        data.changed = false
    end
end
local function Release(unit)
    local bar = active[unit]
    if not bar then return end
    local data = bars[bar]
    data.unit = nil
    UpdateBar(bar, data)
    active[unit] = nil
end
local function Track(unit)
    if not Addon:IsEnabled() then return end
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(unit)
    local frame = plate and plate.UnitFrame
    local bar = frame and (frame.healthBar or
        (frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar))
    if not bar then return end
    local data = bars[bar]
    if not data then
        data = { original = {bar:GetStatusBarColor()} }
        bars[bar] = data
        hooksecurefunc(bar, "SetStatusBarColor", function(_, r, g, b, a)
            if data.writing then return end
            -- Record Blizzard's latest color for exact restoration.
            data.original = {r, g, b, a}
            data.changed = false
            UpdateBar(bar, data)
        end)
    end
    if data.unit and data.unit ~= unit then Release(data.unit) end
    data.unit = unit
    active[unit] = bar
    UpdateBar(bar, data)
end
local function UpdateAll()
    for _, bar in pairs(active) do UpdateBar(bar, bars[bar]) end
end
local function Discover()
    for unit in pairs(active) do Release(unit) end
    if not Addon:IsEnabled() then return end
    if not (C_NamePlate and C_NamePlate.GetNamePlateForUnit) then return end
    for i = 1, 40 do Track("nameplate" .. i) end
end

function Addon:SetEnabled(enabled)
    GetOptions().enabled = enabled == true
    elapsed = 0
    Discover()
    if self.RefreshSettings then self:RefreshSettings() end
end
function Addon:SetRole(role)
    if role ~= "auto" and role ~= "tank" and role ~= "dps" then return end
    GetOptions().role = role
    if self:IsEnabled() then UpdateAll() end
    if self.RefreshSettings then self:RefreshSettings() end
end
for _, event in ipairs({"ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD",
    "NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED", "GROUP_ROSTER_UPDATE",
    "PLAYER_ROLES_ASSIGNED", "PLAYER_SPECIALIZATION_CHANGED",
    "UNIT_THREAT_SITUATION_UPDATE", "UNIT_THREAT_LIST_UPDATE", "UNIT_TARGET",
    "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "UNIT_FACTION", "UNIT_PET"}) do
    events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event, unit)
    if event == "ADDON_LOADED" then
        if unit ~= addonName then return end
        GetOptions()
        Discover()
    elseif not Addon:IsEnabled() then return
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        Discover()
    elseif event == "NAME_PLATE_UNIT_ADDED" then Track(unit)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then Release(unit)
    else UpdateAll() end
end)
events:SetScript("OnUpdate", function(_, delta)
    if not Addon:IsEnabled() then elapsed = 0; return end
    elapsed = elapsed + delta
    if elapsed < 0.2 then return end
    elapsed = 0
    UpdateAll()
end)
SLASH_LH_NAMEPLATETHREATCOLORS1 = "/lh_nameplatethreatcolors"
SlashCmdList.LH_NAMEPLATETHREATCOLORS = function(message)
    local mode = (message or ""):lower():match("^%s*(.-)%s*$")
    if mode == "tank" or mode == "dps" or mode == "auto" then
        Addon:SetRole(mode)
    elseif mode == "on" or mode == "off" then
        Addon:SetEnabled(mode == "on")
        print(Addon:IsEnabled() and "LH_NameplateThreatColors: Enabled." or "LH_NameplateThreatColors: Disabled.")
        return
    elseif mode == "" and Addon.category then
        Settings.OpenToCategory(Addon.category:GetID())
        return
    end
    print("LH_NameplateThreatColors: /lh_nameplatethreatcolors on | off | auto | tank | dps. Mode: "
        .. (LH_NameplateThreatColorsDB and LH_NameplateThreatColorsDB.role or "auto")
        .. "; detected: " .. (IsTank() and "Tank" or "DPS/Healer"))
end
