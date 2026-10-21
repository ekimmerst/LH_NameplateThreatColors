local addonName = ...
local Addon = LH_NameplateThreatColors
local variables = {"LH_NameplateThreatColors_enabled", "LH_NameplateThreatColors_role"}

function Addon:RefreshSettings()
    if self.notifying or not Settings or not Settings.NotifyUpdate then return end
    self.notifying = true
    for _, variable in ipairs(variables) do Settings.NotifyUpdate(variable) end
    self.notifying = false
end

local function Build(category, layout)
    Addon.category = category
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Nameplate threat colors"))
    local enabled = Settings.RegisterProxySetting(category, variables[1], "boolean", "Enable threat colors", true,
        function() return Addon:IsEnabled() end,
        function(value) Addon:SetEnabled(value) end)
    local parent = Settings.CreateCheckbox(category, enabled,
        "Color attackable NPC health bars in combat while grouped or accompanied by a living pet. Outside combat, Blizzard's latest colors are retained. Saved per character.")
    local role = Settings.RegisterProxySetting(category, variables[2], "string", "Role mode", "auto",
        function() return Addon:GetRole() end,
        function(value) Addon:SetRole(value) end)
    local function Options()
        local container = Settings.CreateControlTextContainer()
        container:Add("auto", "Automatic", "Use the assigned group role, then the specialization role when available. Otherwise use DPS/Healer rules.")
        container:Add("tank", "Tank", "Green for secure aggro, orange for threatened aggro, red when a group member or group pet has aggro. Uninvolved NPCs keep their original color.")
        container:Add("dps", "DPS / Healer", "Red when you have aggro, orange for high threat without aggro, green otherwise.")
        return container:GetData()
    end
    local control = Settings.CreateDropdown(category, role, Options,
        "Choose the threat-color role. Hunters with a living pet always use DPS/Healer colors, regardless of this selection. Tapped NPCs take gray priority. Solo play without a living pet retains Blizzard colors. Saved per character; retained while disabled.")
    control:SetParentInitializer(parent, function() return Addon:IsEnabled() end)
end

LH_Tweaks:RegisterModule(addonName, "LH NameplateThreatColors", Build)
