# LH_NameplateThreatColors

Version: 1.0.1. WoW Forever Beta (Interface 16001).

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

- `/lh_nameplatethreatcolors tank`: force tank mode.
- `/lh_nameplatethreatcolors dps`: force DPS/Healer mode.
- `/lh_nameplatethreatcolors auto`: select the role automatically (default).
- `/lh_nameplatethreatcolors`: show the saved mode and detected role.

The role mode is saved per character in `LH_NameplateThreatColorsDB`. Enemy nameplates must be enabled. If the beta restricts threat data as secret values, affected bars retain their original colors. The addon does not change nameplate settings.

## Installation and upgrade

Place the `LH_NameplateThreatColors` folder in your game's `Interface/AddOns` folder. It must contain `LH_NameplateThreatColors.toc` and `LH_NameplateThreatColors.lua`. Restart WoW and enable **LH_NameplateThreatColors** in the addon list.

When upgrading from NameplateThreatColors, replace the old folder and fully restart WoW. Do not enable both versions together. The former `/nptc` command is replaced by `/lh_nameplatethreatcolors`.

To retain your role setting, close WoW and back up each character's `WTF/Account/<account>/<realm>/<character>/SavedVariables/NameplateThreatColors.lua` file. Copy it to `LH_NameplateThreatColors.lua` in the same SavedVariables folder, then change `NameplateThreatColorsDB` to `LH_NameplateThreatColorsDB` inside the copy. Migrate before first using the renamed addon; do not overwrite an existing `LH_NameplateThreatColors.lua` containing settings you want to keep. Without migration, the addon defaults to automatic role selection.

## In-game checks

Check solo play, joining and leaving groups, role changes, secure and threatened aggro, losing aggro to a group member, living/dead pets and recycled nameplates. In-game verification of this rename remains pending.

## Changelog

### 1.0.1 - 2026-10-21

- Renamed NameplateThreatColors to LH_NameplateThreatColors, including the folder, Lua/TOC files, metadata, chat prefix and saved-variable table.
- Changed the chat command to `/lh_nameplatethreatcolors`.
- Translated documentation and chat messages into English.
- Added instructions for transferring the per-character role setting.

## Required core addon

Install and enable **LH_Tweaks** alongside this addon. LH_Tweaks is the shared LiteHawk configuration host and must load first. CurseForge releases must list LH_Tweaks as a required dependency so the client installs it automatically.
