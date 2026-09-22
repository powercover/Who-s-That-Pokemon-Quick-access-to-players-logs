# Who's That Pokemon?

World of Warcraft addon by **powercover**. Right-click a player unit frame to copy that character’s Warcraft Logs raid or Mythic+ page.

Compatible with **12.1.0** and **12.1.5**.

## Usage

Right-click any player (yourself, party, raid, target, focus, friends list, guild), a premade group listing (group leader), or an LFG applicant. Two options appear:

- **Open Raid Logs** — current raid parses (The Venomous Abyss)
- **Open M+ Logs** — current Mythic+ season (Season 2)

A popup shows the URL already selected. Press **Ctrl+C** to copy; the window closes automatically.

## Notes

Addons cannot open the system browser. Who's That Pokemon? copies the link instead.

Warcraft Logs zone IDs are set at the top of `WhosThatPokemon.lua` (`WCL_RAID_ZONE` and `WCL_MPLUS_ZONE`). Update those when a new raid tier or M+ season starts.
