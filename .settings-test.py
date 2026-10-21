from pathlib import Path
import sys

addon = Path(__file__).resolve().parent
core = addon.parent / 'LH_Tweaks'
sys.path.insert(0, str(core / '.test-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime()
lua.execute('''
frames={};SlashCmdList={};queries=0;hookCount=0;secret={}
grouped=true;livingPet=false;petDead=false;class='WARRIOR';assigned='NONE';specRole='DAMAGER'
status=3;tapped=false;dead=false;attackable=true;isPlayer=false;targetGroup=false;targetPet=false
function print() end
function issecretvalue(v) return v==secret end
local M={}
function M:SetScript(k,v) self.scripts[k]=v end
function M:RegisterEvent() end
function M:GetStatusBarColor() return unpack(self.color) end
function M:SetStatusBarColor(r,g,b,a) self.color={r,g,b,a} end
function CreateFrame(kind,name,parent)
 local f=setmetatable({scripts={},parent=parent,color={.2,.3,.4,.7}},{__index=M})
 frames[#frames+1]=f;return f
end
function hooksecurefunc(frame,key,fn)
 hookCount=hookCount+1;local original=frame[key]
 frame[key]=function(self,...) original(self,...);fn(self,...) end
end
function newPlate(nested)
 local bar=CreateFrame('StatusBar')
 return {UnitFrame=nested and {HealthBarsContainer={healthBar=bar}} or {healthBar=bar}},bar
end
plates={};plates.nameplate1,health=newPlate(false)
C_NamePlate={GetNamePlateForUnit=function(unit) return plates[unit] end}
function UnitExists(unit)
 if unit=='pet' then return livingPet end
 if unit=='nameplate1target' then return targetGroup or targetPet end
 return plates[unit]~=nil
end
function UnitIsPlayer() return isPlayer end
function UnitIsDeadOrGhost(unit) return unit=='pet' and petDead or dead end
function UnitCanAttack() return attackable end
function UnitIsTapDenied() return tapped end
function UnitClass() return 'Class',class end
function UnitThreatSituation() queries=queries+1;return status end
function IsInGroup() return grouped end
function IsInRaid() return false end
function UnitGroupRolesAssigned() return assigned end
function GetSpecialization() return 1 end
function GetSpecializationRole() return specRole end
function UnitInParty() return targetGroup end
function UnitInRaid() return false end
function UnitIsUnit(_,other) return targetPet and other=='partypet1' end
registry={};notices={};Settings={}
function Settings.RegisterVerticalLayoutSubcategory(parent,title)
 local c={parent=parent,title=title};function c:GetID() return self.title end
 local l={rows={}};function l:AddInitializer(row) table.insert(self.rows,row) end;c.layout=l;return c,l
end
function Settings.RegisterAddOnCategory(c) registered=c end
function Settings.RegisterProxySetting(c,v,kind,label,default,get,set)
 local s={category=c,default=default,get=get,set=set};registry[v]=s;return s
end
local function addControl(c,s)
 local row={setting=s}
 function row:SetParentInitializer(parent,predicate) self.parent=parent;self.canModify=predicate end
 c.layout:AddInitializer(row);return row
end
function Settings.CreateCheckbox(c,s,t) return addControl(c,s) end
function Settings.CreateDropdown(c,s,options,t) local row=addControl(c,s);row.options=options;return row end
function Settings.CreateControlTextContainer()
 local container={data={}}
 function container:Add(value,label,tooltip) table.insert(self.data,{value=value,label=label,tooltip=tooltip}) end
 function container:GetData() return self.data end
 return container
end
function Settings.NotifyUpdate(v) notices[v]=(notices[v] or 0)+1 end
function Settings.OpenToCategory(id) opened=id end
function CreateSettingsListSectionHeaderInitializer(t) return {header=t} end
LH_Tweaks={modules={}}
LH_NameplateThreatColorsDB={role='tank'}
function assertColor(r,g,b,a)
 assert(health.color[1]==r and health.color[2]==g and health.color[3]==b,'Unexpected threat color')
 if a then assert(health.color[4]==a,'Original alpha lost') end
end
''')
source = (core / 'LH_Tweaks.lua').read_text()
registration = source.split('function Hub:RegisterModule(id, title, build)')[1].split('\nfunction Hub:RestoreDefaults')[0]
lua.execute('local Hub=LH_Tweaks\nfunction Hub:RegisterModule(id, title, build)' + registration)
source = (core / 'Settings.lua').read_text()
registration = source.split('function Hub:RegisterModulePage(id)')[1].split('\nlocal function RegisterSettings')[0]
lua.execute('local Hub=LH_Tweaks\nfunction Hub:RegisterModulePage(id)' + registration)
lua.execute((addon / 'LH_NameplateThreatColors.lua').read_text(), 'LH_NameplateThreatColors')
lua.execute('driver=frames[#frames]')
lua.execute((addon / 'Settings.lua').read_text(), 'LH_NameplateThreatColors')
lua.execute('''
local function fire(event,unit) driver.scripts.OnEvent(driver,event,unit) end
local function update() driver.scripts.OnUpdate(driver,.2) end
assert(LH_Tweaks.modules.LH_NameplateThreatColors and not registered)
fire('ADDON_LOADED','LH_NameplateThreatColors')
assert(LH_NameplateThreatColorsDB.role=='tank' and LH_NameplateThreatColorsDB.enabled)
assertColor(0,.85,.15);assert(hookCount==1)
LH_Tweaks.category={};LH_Tweaks:RegisterModulePage('LH_NameplateThreatColors')
local c=registered
assert(c.parent==LH_Tweaks.category and c.title=='LH NameplateThreatColors')
local enabled,role=registry.LH_NameplateThreatColors_enabled,registry.LH_NameplateThreatColors_role
assert(enabled.default==true and role.default=='auto' and role.get()=='tank')
local dropdown=c.layout.rows[3]
assert(dropdown.parent==c.layout.rows[2] and dropdown.canModify())
local choices=dropdown.options();assert(#choices==3 and choices[1].value=='auto' and choices[3].value=='dps')
SlashCmdList.LH_NAMEPLATETHREATCOLORS();assert(opened==c:GetID())
status=2;update();assertColor(1,.5,0)
status=0;targetGroup=true;update();assertColor(1,.1,.1)
targetGroup=false;targetPet=true;update();assertColor(1,.1,.1)
targetPet=false;update();assertColor(.2,.3,.4,.7)
role.set('dps');status=3;update();assertColor(1,.1,.1)
status=1;update();assertColor(1,.5,0)
status=0;update();assertColor(0,.85,.15)
tapped=true;update();assertColor(.5,.5,.5)
tapped=false;status=secret;update();assertColor(.2,.3,.4,.7)
status=3;role.set('auto');assigned='TANK';update();assertColor(0,.85,.15)
assigned='NONE';specRole='TANK';update();assertColor(0,.85,.15)
assigned='HEALER';update();assertColor(1,.1,.1)
-- Disabling immediately restores the latest Blizzard color, including alpha.
health:SetStatusBarColor(.6,.7,.8,.9);assertColor(1,.1,.1)
enabled.set(false);assertColor(.6,.7,.8,.9)
assert(not dropdown.canModify() and role.get()=='auto')
local reads=queries;fire('UNIT_THREAT_LIST_UPDATE','nameplate1');update();assert(queries==reads)
health:SetStatusBarColor(.1,.2,.3,.4);assertColor(.1,.2,.3,.4)
-- Re-enable reuses hooks and discovers a nested-layout plate added while disabled.
plates.nameplate2,second=newPlate(true)
fire('NAME_PLATE_UNIT_ADDED','nameplate2');assert(hookCount==1)
SlashCmdList.LH_NAMEPLATETHREATCOLORS(' ON ');assert(hookCount==2 and enabled.get())
assertColor(1,.1,.1)
SlashCmdList.LH_NAMEPLATETHREATCOLORS('tank');assert(role.get()=='tank' and notices.LH_NameplateThreatColors_role>0)
assertColor(0,.85,.15)
-- Hunter/pet and solo behavior are unchanged by role selection.
grouped=false;livingPet=false;update();assertColor(.1,.2,.3,.4)
livingPet=true;class='HUNTER';status=3;update();assertColor(1,.1,.1)
status=1;update();assertColor(1,.5,0)
status=0;update();assertColor(0,.85,.15)
petDead=true;update();assertColor(.1,.2,.3,.4)
petDead=false;grouped=true;dead=true;update();assertColor(.1,.2,.3,.4)
dead=false;isPlayer=true;update();assertColor(.1,.2,.3,.4)
isPlayer=false;attackable=false;update();assertColor(.1,.2,.3,.4)
attackable=true;fire('NAME_PLATE_UNIT_REMOVED','nameplate1');assertColor(.1,.2,.3,.4)
fire('NAME_PLATE_UNIT_ADDED','nameplate1');assertColor(0,.85,.15);assert(hookCount==2)
enabled.set(false);role.set('dps');fire('PLAYER_LOGIN')
assert(not enabled.get() and role.get()=='dps' and health.color[4]==.4)
-- Native defaults restore enabled/auto only for this category.
LH_MP5DB={enabled=false}
for _,s in pairs(registry) do if s.category==c then s.set(s.default) end end
assert(enabled.get() and role.get()=='auto' and not LH_MP5DB.enabled)
SlashCmdList.LH_NAMEPLATETHREATCOLORS('off');SlashCmdList.LH_NAMEPLATETHREATCOLORS('on extra')
assert(not enabled.get());role.set('invalid');assert(role.get()=='auto')
fire('ADDON_LOADED','LH_NameplateThreatColors');assert(not enabled.get())
''')
for ext in ('png', 'tga'):
    assert (addon / f'Media/Icon.{ext}').read_bytes() == (core / f'Icon.{ext}').read_bytes()
toc = (addon / 'LH_NameplateThreatColors.toc').read_text()
assert '## Group: LH_Tweaks' in toc and 'Settings.lua' in toc
print('PASS: host integration, role dropdown/defaults, saved modes, immediate restoration including alpha, hook reuse, group/pet/tank/DPS colors, secret fallback, plate lifecycle and shared icons')
