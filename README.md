# LH_NameplateThreatColors

Version: 1.1.0. WoW Forever Beta (Interface 16001).

Colors Blizzard nameplate health bars for attackable NPCs while you are in a party or raid, or have a living pet. When solo without a living pet, Blizzard's original colors are retained regardless of role mode.

NPCs whose kills do not count for you because another player has tagged them appear gray while grouped or accompanied by a living pet. Gray takes priority over threat colors. When solo without a living pet, Blizzard's original colors also apply to these NPCs.

## Threat colors

Hunters with a living pet use these colors regardless of role mode, including while solo: red when the player has aggro, orange for high player threat without aggro, and green otherwise, including when the pet has aggro. Without a pet, or with a dead pet, normal role rules apply.

| Situation | Tank | DPS/Healer |
| --- | --- | --- |
| Secure aggro on you | Green | Red |
| Aggro on you, but threatened | Orange | Red |
| High threat without aggro | Red if attacking a group member or group pet; otherwise original color | Orange |
| No aggro on you | Red if attacking a group member or group pet; otherwise original color | Green |

Threat levels come from the client's threat API. In tank mode, uninvolved NPCs retain their original colors.

Automatic role selection first uses your assigned group role, then your specialization role when available. If no tank role is detected, DPS/Healer rules apply. Class alone does not determine the role.

## Commands

Open WoW Settings > AddOns > LH Tweaks > LH NameplateThreatColors, or type `/lh_nameplatethreatcolors`, to configure the addon. The native page provides an **Enable threat colors** checkbox and **Role mode** dropdown (Automatic, Tank, DPS / Healer). Both settings are saved per character in the existing `LH_NameplateThreatColorsDB` table. The new activation flag defaults to enabled, and existing role selections are retained.

Disabling immediately restores the latest colors requested by Blizzard, including alpha, and stops inspecting threat data. The saved role remains intact. Reenabling discovers visible nameplates, including plates created while disabled. The role dropdown is unavailable while disabled. Blizzard's Defaults for this category restores enabled mode and Automatic role selection.

- `/lh_nameplatethreatcolors on`: enable threat colors.
- `/lh_nameplatethreatcolors off`: disable the feature and restore Blizzard colors.
- `/lh_nameplatethreatcolors tank`: force tank mode.
- `/lh_nameplatethreatcolors dps`: force DPS/Healer mode.
- `/lh_nameplatethreatcolors auto`: select the role automatically (default).
- `/lh_nameplatethreatcolors`: open the native options page.

The role mode is saved per character in `LH_NameplateThreatColorsDB`. Enemy nameplates must be enabled. If the beta restricts threat data as secret values, affected bars retain their original colors. The addon does not change nameplate settings.

## Installation and upgrade

Place the complete `LH_NameplateThreatColors` folder in your game's `Interface/AddOns` folder, including LH_NameplateThreatColors.toc, LH_NameplateThreatColors.lua, Settings.lua and Media. Install and enable LH_Tweaks as well. Fully restart WoW and enable **LH NameplateThreatColors**, grouped under **LH Tweaks** in the addon list. Upgrading to 1.1.0 needs a full restart because the TOC loads a new file and adds grouping/icon metadata.

Media/Icon.png and Media/Icon.tga are exact copies of LH_Tweaks' shared gold LH artwork, using Spoken's chamfered gold frame as the reference. There is no runtime Spoken dependency.

When upgrading from NameplateThreatColors, replace the old folder and fully restart WoW. Do not enable both versions together. The former `/nptc` command is replaced by `/lh_nameplatethreatcolors`.

To retain your role setting, close WoW and back up each character's `WTF/Account/<account>/<realm>/<character>/SavedVariables/NameplateThreatColors.lua` file. Copy it to `LH_NameplateThreatColors.lua` in the same SavedVariables folder, then change `NameplateThreatColorsDB` to `LH_NameplateThreatColorsDB` inside the copy. Migrate before first using the renamed addon; do not overwrite an existing `LH_NameplateThreatColors.lua` containing settings you want to keep. Without migration, the addon defaults to automatic role selection.

## In-game checks

Check solo play, joining and leaving groups, role changes, secure and threatened aggro, losing aggro to a group member, living/dead pets and recycled nameplates. Open the native options page, disable with colored plates visible and confirm that Blizzard colors immediately return. Reenable, change each role mode, use Defaults and check saved settings after `/reload`. Native rendering and real engine secret-value behavior remain pending in game.

## Automated verification

`.settings-test.py` passed Lua 5.1 simulations for native module registration, the role dropdown, defaults, saved role/activation values, chat/UI synchronization, immediate restoration of the latest original color and alpha, hook reuse, newly discovered plates, group/pet/solo rules, tank/DPS colors, tap priority and restricted-threat fallback. Shared icon files are verified byte-for-byte against LH_Tweaks; `git diff --check` passed. Run `python LH_NameplateThreatColors/.settings-test.py` from the AddOns folder with Lupa available in `LH_Tweaks/.test-runtime`.

## Changelog

### 1.1.0 - 2026-10-21

- Added native LH NameplateThreatColors settings under LH Tweaks with an activation checkbox and Automatic/Tank/DPS-Healer role dropdown.
- Added an enabled-by-default per-character activation flag while preserving existing saved roles. Disabling restores original colors immediately; reenabling discovers visible plates.
- Added `/lh_nameplatethreatcolors on|off`; the command without arguments opens settings. Existing role commands remain available and synchronize the native dropdown.
- Added the shared LH icon and native AddOn list grouping under LH Tweaks.

### 1.0.1 - 2026-10-21

- Renamed NameplateThreatColors to LH_NameplateThreatColors, including the folder, Lua/TOC files, metadata, chat prefix and saved-variable table.
- Changed the chat command to `/lh_nameplatethreatcolors`.
- Translated documentation and chat messages into English.
- Added instructions for transferring the per-character role setting.

## Required core addon

Install and enable **LH_Tweaks** alongside this addon. LH_Tweaks is the shared LiteHawk configuration host and must load first. CurseForge releases must list LH_Tweaks as a required dependency so the client installs it automatically.
