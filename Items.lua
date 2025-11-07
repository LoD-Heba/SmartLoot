-- Items.lua - Definición de categorías de items

SmartLoot = SmartLoot or {}
SmartLoot.ItemCategories = {
    -- PAÑOS
    Cloths = {
        [2589] = true,  -- Paño de lino / Linen Cloth
        [2592] = true,  -- Paño de lana / Wool Cloth
        [4306] = true,  -- Paño de seda / Silk Cloth
        [4338] = true,  -- Tejido de magiatrama / Mageweave Cloth
        [14047] = true, -- Paño de runa / Runecloth
        [33470] = true, -- Telaescarcha / Frostweave Cloth
    },
    
    -- COMIDA Y BEBIDA
    Food = {
        [117] = true,   -- Tough Jerky / Cecina dura
        [2287] = true,  -- Haunch of Meat
        [4599] = true,  -- Cured Ham Steak
        [8952] = true,  -- Roasted Quail
        [21023] = true, -- Dirge's Kickin' Chimaerok Chops
    },
    
    -- MATERIALES DE COCINA
    CookingMats = {
        [2678] = true,  -- Herb Baked Egg
        [2934] = true,  -- Rugged Leather
        [12208] = true, -- Tender Wolf Meat
        [12037] = true, -- Mystery Meat
        [27674] = true, -- Ravager Egg
        [35562] = true, -- Bear Flank
        [43013] = true, -- Chilled Meat
    },
    
    -- OBJETOS DE PESCA
    Fishing = {
        [6289] = true,  -- Raw Longjaw Mud Snapper
        [6291] = true,  -- Raw Brilliant Smallfish
        [6308] = true,  -- Raw Bristle Whisker Catfish
        [6317] = true,  -- Raw Loch Frenzy
        [21071] = true, -- Raw Sagefish
        [27422] = true, -- Barbed Gill Trout
        [41800] = true, -- Deep Sea Monsterbelly
        [41802] = true, -- Glacial Salmon
    },
}