# Broken Outlaws – Foldable Stools & Chairs (RedM / VORP)
Sit anywhere with foldable stools/chairs.
Works by item or by command.
Supports multiple chair models, per-chair offsets, safe restarts.


## Requirements
* RedM (citizenfx), VORP Core, **vorp_inventory**

## (quick) Install
1. Copy resource to your resources folder.
2. Run `sql/item_db to add items to your database.
3. Add the PNG'S provided in folder 'PNG'S' to vorp Inventory: \resources\[VORP]\[vorp_essentials]\vorp_inventory\html\img
3. Ensure in 'server.cfg': ensure broken_outlaws_stool

## Config
* debug mode
* UseItemToSit = true → use items only;
* UseItemToSit = false → use commands only.
* CommandGetUp = 'standup'   -- to stand up
* UseCooldown = 2.5   
* CommandGetUp = 'sitstool1' -- to sit on 'Old Foldable Stool'
* CommandGetUp = 'sitstool2' -- to sit on 'New Foldable Stool'
* CommandGetUp = 'sitstool3' -- to sit on 'Old Foldable Chair'
* CommandGetUp = 'sitstool4' -- to sit on 'New Foldable Chair'
* CommandGetUp = 'sitstool5' -- to sit on 'Luxury Foldable Chair'
* CommandGetUp = 'sitstool6' -- to sit on 'Foldable Beach Chair'

## Scenarios (you can look for more but they need to be for male and felmale - change it in the config)
- PROP_HUMAN_SEAT_CHAIR_MORTAR_PESTLE   -- Old Foldable Chair
- PROP_HUMAN_SEAT_CHAIR_PORCH           -- New Foldable Chair
- PROP_HUMAN_SEAT_CHAIR_SMOKE_ROLL      -- Old Foldable Stool
- PROP_HUMAN_SEAT_CHAIR_TRAIN           -- Foldable Beach Chair
- PROP_HUMAN_SEAT_CHAIR_SKETCHING       -- Luxury Foldable Chair
- PROP_HUMAN_SEAT_CHAIR_SMOKING         -- New Foldable Stool

## Credits
* Author: **IIIDUTCHIII - Broken Outlaws Roleplay**