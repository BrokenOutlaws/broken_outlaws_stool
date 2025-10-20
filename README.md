# 🪑Broken Outlaws — Multi-Stool/Chair (RedM/VORP)🪑

Sit anywhere with style. This resource adds six portable, foldable stools/chairs that players can deploy and sit on—either via chat commands or inventory items—fully configurable per model with sane safety checks and cleanup.

## Framework:
RedM (RDR3) • Dependencies: vorp_core, vorp_inventory
Resource name: broken_outlaws_stool

## ✨ Features

Two usage modes
Command Mode: /sitstool1 … /sitstool6, /standup
Item Mode: use inventory items (registers usable items dynamically)
Per-chair config (model, scenario, Z/rotation/front offsets)
Safety checks: blocks use while dead, swimming, in vehicles, or mounted
Cooldown to prevent spam (client + server side)
Auto cleanup: removes stray/attached chair props near the player
Restart-safe: clears scenarios and attached props on (re)start/stop
Debug mode: verbose logs for quick troubleshooting
SQL + Icons: ready-to-import items + six 96×96 PNGs

## 📦 Requirements

RedM (rdr3)
VORP Core (vorp_core)
VORP Inventory (vorp_inventory)
oxmysql (server uses @oxmysql/lib/MySQL.lua)

## 🔧 Installation

Place the resource
resources/[broken_outlaws]/broken_outlaws_stool
Add to your server cfg (ensure order)
ensure vorp_core
ensure vorp_inventory
ensure broken_outlaws_stool
Import items (SQL) & add icons
Run the SQL below (adjust to your schema/columns).
Put the six PNG icons (96×96) where your inventory expects them and map their filenames (see SQL example).
Configure in config.lua (see next section).

## ⚙️ Configuration (config.lua)
```lua
DebugMode     = false      -- Verbose logs for testing
UseItemToSit  = false      -- true: Item Mode | false: Command Mode
CommandGetUp  = 'standup'  -- Command to stand up in Command Mode
UseCooldown   = 2.5        -- Seconds (server + client)

Item = {
  -- Per-chair example:
  {
    item       = "old_foldable_stool",      -- Inventory item name
    label      = "Old Foldable Stool",      -- Display label
    CommandSit = "sitstool1",               -- Command (Command Mode)
    PropModel  = "p_stoolfolding01bx",      -- World model
    Scenario   = "PROP_HUMAN_SEAT_CHAIR_MORTAR_PESTLE",
    ZOffset    = 0.48,                      -- Up/Down
    ROffset    = 0,                         -- Yaw correction (°)
    FOffset    = 0.16                       -- Forward/Back (m)
  },
  -- … five more presets included out of the box
}


Tip: Use ZOffset, ROffset, and FOffset to perfectly align the ped on each seat.
```

## 🕹 Usage

Command Mode (UseItemToSit = false)
Sit: /sitstool1 … /sitstool6 (one per configured chair)
Stand: /<CommandGetUp> (default /standup)
Item Mode (UseItemToSit = true)
Use the inventory item (e.g., Old Foldable Stool) to toggle sit/stand.
Inventory closes automatically after use.

## 🙌 Credits

Team Broken Outlaws — design, testing, & polish
Community members who helped test positions & scenarios

## 📜 License

Use on your RedM server(s). Please keep the author credit in the manifest. Do not resell as-is.
