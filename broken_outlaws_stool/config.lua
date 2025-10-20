-- ========= Broken Outlaws: Foldable Stool / Chair Config ========= 

DebugMode = false                                           -- set to false on live server

UseItemToSit = false                                        -- set to false if you don't want to use an item to use the foldable chair

CommandGetUp = 'standup'                                    -- command to stand up for all models (used when UseItemToSit = false)

UseCooldown = 2.5                                           -- time in seconds (cooldown)



Item = {
    {item  = "old_foldable_stool",                          -- Per-chair settings:
    label = "Old Foldable Stool",                           --  item/label   : inventory id + display (match your DB)
    CommandSit = 'sitstool1',                               --  CommandSit   : command to sit when UseItemToSit = false
    PropModel  = 'p_stoolfolding01bx',                      --  PropModel    : model name
    Scenario   = 'PROP_HUMAN_SEAT_CHAIR_MORTAR_PESTLE',     --  Scenario     : scenario name
    ZOffset    = 0.48,                                      --  ZOffset      : vertical correction (+ up / - down)
    ROffset    = 0,                                         --  ROffset      : rotation correction in degrees (0 / 90 / 180 / 270)
    FOffset    = 0.16},                                     --  FOffset      : front/back correction in meters (+ forward / - back)

    {item  = "new_foldable_stool",
    label = "New Foldable Stool",
    CommandSit = 'sitstool2',
    PropModel  = 'p_stoolfolding01x',
    Scenario   = 'PROP_HUMAN_SEAT_CHAIR_PORCH',
    ZOffset    = 0.48,
    ROffset    = 0,
    FOffset    = 0.15},

    {item  = "old_foldable_chair",
    label = "Old Foldable Chair",
    CommandSit = 'sitstool3',
    PropModel  = 'p_chairfolding02x',
    Scenario   = 'PROP_HUMAN_SEAT_CHAIR_SMOKE_ROLL',
    ZOffset    = 0.51,
    ROffset    = 180,
    FOffset    = -0.01},

    {item  = "new_foldable_chair",
    label = "New Foldable Chair",
    CommandSit = 'sitstool4',
    PropModel  = 'p_chairwhite01x',
    Scenario   = 'PROP_HUMAN_SEAT_CHAIR_TRAIN',
    ZOffset    = 0.50,
    ROffset    = 180,
    FOffset    = 0.01},

    {item  = "luxury_foldable_chair",
    label = "Luxury Foldable Chair",
    CommandSit = 'sitstool5',
    PropModel  = 'mp005_s_posse_foldingchair_01x',
    Scenario   = 'PROP_HUMAN_SEAT_CHAIR_SKETCHING',
    ZOffset    = 0.50,
    ROffset    = 180,
    FOffset    = 0.15},

    {item  = "foldable_beach_chair",
    label = "Foldable Beach Chair",
    CommandSit = 'sitstool6',
    PropModel  = 'mp005_s_posse_col_chair01x',
    Scenario   = 'PROP_HUMAN_SEAT_CHAIR_SMOKING',
    ZOffset    = 0.48,
    ROffset    = 180,
    FOffset    = -0.01},
}
