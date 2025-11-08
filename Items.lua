-- Items.lua - Definición de items por profesión

SmartLoot = SmartLoot or {}
SmartLoot.ItemDatabase = {
    -- ===========================================
    -- SASTRERÍA (TAILORING)
    -- ===========================================
    Tailoring = {
        name = "Sastrería",
        icon = "Interface\\Icons\\Trade_Tailoring",
        items = {
            -- Paños
            [2589] = {name = "Paño de lino", enabled = true, default = true},
            [2592] = {name = "Paño de lana", enabled = true, default = true},
            [4306] = {name = "Paño de seda", enabled = true, default = true},
            [4338] = {name = "Tejido de magiatrama", enabled = true, default = true},
            [14047] = {name = "Paño de runa", enabled = true, default = true},
            [33470] = {name = "Telaescarcha", enabled = true, default = true},
            -- Otros materiales (ejemplos)
            [14227] = {name = "Seda de araña de escarcha", enabled = false, default = false},
            [14256] = {name = "Tela Felcloth", enabled = false, default = false},
        },
    },
    
    -- ===========================================
    -- PELETERÍA (LEATHERWORKING)
    -- ===========================================
    Leatherworking = {
        name = "Peletería",
        icon = "Interface\\Icons\\Trade_LeatherWorking",
        items = {
            [2934] = {name = "Cuero resistente", enabled = false, default = false},
            [4304] = {name = "Cuero grueso", enabled = false, default = false},
            [2318] = {name = "Cuero ligero", enabled = false, default = false},
            [2319] = {name = "Cuero medio", enabled = false, default = false},
            [4234] = {name = "Cuero pesado", enabled = false, default = false},
            [8170] = {name = "Cuero endurecido", enabled = false, default = false},
            [15417] = {name = "Cuero de Desolace", enabled = false, default = false},
            [25649] = {name = "Piel de nudo", enabled = false, default = false},
            [33568] = {name = "Cuero boreal", enabled = false, default = false},
        },
    },
    
    -- ===========================================
    -- PESCA (FISHING)
    -- ===========================================
    Fishing = {
        name = "Pesca",
        icon = "Interface\\Icons\\Trade_Fishing",
        items = {
            [6289] = {name = "Pargo de fango crudo", enabled = true, default = true},
            [6291] = {name = "Pececillo brillante crudo", enabled = true, default = true},
            [6308] = {name = "Siluro de bigote crudo", enabled = true, default = true},
            [6317] = {name = "Frenesí del lago crudo", enabled = true, default = true},
            [21071] = {name = "Pez sabio crudo", enabled = true, default = true},
            [27422] = {name = "Trucha de agallas", enabled = true, default = true},
            [41800] = {name = "Monstruobeso de mar", enabled = true, default = true},
            [41802] = {name = "Salmón glacial", enabled = true, default = true},
            [41801] = {name = "Musselback Sculpin", enabled = true, default = true},
            [41803] = {name = "Rockfin Grouper", enabled = true, default = true},
        },
    },
    
    -- ===========================================
    -- COCINA (COOKING)
    -- ===========================================
    Cooking = {
        name = "Cocina",
        icon = "Interface\\Icons\\INV_Misc_Food_15",
        items = {
            [2678] = {name = "Huevo horneado", enabled = true, default = true},
            [12208] = {name = "Carne tierna de lobo", enabled = true, default = true},
            [12037] = {name = "Carne misteriosa", enabled = true, default = true},
            [27674] = {name = "Huevo de devastador", enabled = true, default = true},
            [35562] = {name = "Flanco de oso", enabled = true, default = true},
            [43013] = {name = "Carne helada", enabled = true, default = true},
            [43012] = {name = "Colmillo de Rhino", enabled = true, default = true},
        },
    },
    
    -- ===========================================
    -- HERRERÍA (BLACKSMITHING)
    -- ===========================================
    Blacksmithing = {
        name = "Herrería",
        icon = "Interface\\Icons\\Trade_BlackSmithing",
        items = {
            [2840] = {name = "Barra de cobre", enabled = false, default = false},
            [2842] = {name = "Barra de plata", enabled = false, default = false},
            [3575] = {name = "Barra de hierro", enabled = false, default = false},
            [3577] = {name = "Barra de oro", enabled = false, default = false},
            [3859] = {name = "Barra de acero", enabled = false, default = false},
            [12359] = {name = "Barra de torio", enabled = false, default = false},
        },
    },
    
    -- ===========================================
    -- MINERÍA (MINING)
    -- ===========================================
    Mining = {
        name = "Minería",
        icon = "Interface\\Icons\\Trade_Mining",
        items = {
            [2770] = {name = "Mineral de cobre", enabled = false, default = false},
            [2771] = {name = "Mineral de estaño", enabled = false, default = false},
            [2772] = {name = "Mineral de hierro", enabled = false, default = false},
            [3858] = {name = "Mineral de mithril", enabled = false, default = false},
            [10620] = {name = "Mineral de torio", enabled = false, default = false},
            [23424] = {name = "Mineral de fel iron", enabled = false, default = false},
            [36909] = {name = "Mineral de cobalto", enabled = false, default = false},
            [36912] = {name = "Mineral de saronita", enabled = false, default = false},
        },
    },
    
    -- ===========================================
    -- HIERBAS (HERBALISM)
    -- ===========================================
    Herbalism = {
        name = "Herboristería",
        icon = "Interface\\Icons\\Trade_Herbalism",
        items = {
            [765] = {name = "Raíz de plata", enabled = false, default = false},
            [785] = {name = "Mageroyal", enabled = false, default = false},
            [2447] = {name = "Peacebloom", enabled = false, default = false},
            [3820] = {name = "Stranglekelp", enabled = false, default = false},
            [13464] = {name = "Golden Sansam", enabled = false, default = false},
            [36901] = {name = "Goldclover", enabled = false, default = false},
            [36907] = {name = "Talandra's Rose", enabled = false, default = false},
        },
    },
    
    -- ===========================================
    -- GENERAL
    -- ===========================================
    General = {
        name = "General",
        icon = "Interface\\Icons\\INV_Misc_Bag_08",
        items = {
            -- Aquí el jugador puede añadir items personalizados
            -- Por defecto está vacío
        },
    },
}

-- Función para obtener todos los items de una profesión
function SmartLoot:GetProfessionItems(professionKey)
    if self.ItemDatabase[professionKey] then
        return self.ItemDatabase[professionKey].items
    end
    return {}
end

-- Función para añadir item personalizado
function SmartLoot:AddCustomItem(professionKey, itemID, itemName)
    if not self.ItemDatabase[professionKey] then
        return false
    end
    
    if not self.ItemDatabase[professionKey].items[itemID] then
        self.ItemDatabase[professionKey].items[itemID] = {
            name = itemName or ("Item ID: " .. itemID),
            enabled = true,
            default = false,
            custom = true
        }
        return true
    end
    return false
end

-- Función para eliminar item personalizado
function SmartLoot:RemoveCustomItem(professionKey, itemID)
    if not self.ItemDatabase[professionKey] then
        return false
    end
    
    local item = self.ItemDatabase[professionKey].items[itemID]
    if item and item.custom then
        self.ItemDatabase[professionKey].items[itemID] = nil
        return true
    end
    return false
end