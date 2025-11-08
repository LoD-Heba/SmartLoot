-- Config.lua - Sistema de guardado de configuración
SmartLoot = SmartLoot or {}
local SL = SmartLoot

-- ===========================================
-- VALORES POR DEFECTO
-- ===========================================

SL.DefaultConfig = {
    enabled = false,
    showMessages = true,
    debugMode = false,
    showItemID = false,

    -- Categorías
    lootCloths = true,
    lootFood = false,
    lootCookingMats = true,
    lootFishing = true,
    lootQuestItems = true,

    -- Calidades
    lootRecipes = true,
    lootGreenAny = true,
    lootBlue67to80 = true,
    lootPurple67to80 = true,

    -- Opciones
    ignoreGrey = true,
    lootMoney = true
}

SL.DefaultIgnoredItems = {
    -- Receta molesta de ejemplo (ajusta según tu servidor)
    -- [44510] = true,  -- Patrón: guantes de magiatrama glacial
}

-- ===========================================
-- FUNCIONES DE CARGA Y GUARDADO
-- ===========================================

function SL:LoadConfig()
    -- Si no existe la base de datos, crearla
    if not SmartLootDB then
        SmartLootDB = {}
    end

    -- Cargar configuración
    if not SmartLootDB.config then
        SmartLootDB.config = self:CopyTable(self.DefaultConfig)
    else
        -- Mergear con valores por defecto (por si se añaden nuevas opciones)
        for key, value in pairs(self.DefaultConfig) do
            if SmartLootDB.config[key] == nil then
                SmartLootDB.config[key] = value
            end
        end
    end

    -- Cargar items ignorados
    if not SmartLootDB.ignoredItems then
        SmartLootDB.ignoredItems = self:CopyTable(self.DefaultIgnoredItems)
    end

    -- Cargar posición del botón flotante
    if not SmartLootDB.buttonPosition then
        SmartLootDB.buttonPosition = {
            point = "TOPRIGHT",
            relativeTo = "Minimap",
            relativePoint = "TOPRIGHT",
            xOffset = 5,
            yOffset = 5
        }
    end

    -- Cargar posición de la ventana principal
    if not SmartLootDB.framePosition then
        SmartLootDB.framePosition = {
            point = "CENTER",
            xOffset = 0,
            yOffset = 0
        }
    end

    -- Cargar estados de items
    if SmartLootDB.itemStates then
        for profKey, profession in pairs(self.ItemDatabase or {}) do
            if SmartLootDB.itemStates[profKey] then
                for itemID, enabled in pairs(SmartLootDB.itemStates[profKey]) do
                    if profession.items and profession.items[itemID] then
                        profession.items[itemID].enabled = enabled
                    end
                end
            end
        end
    end

    -- Aplicar configuración cargada
    self.config = SmartLootDB.config
    self.IgnoredItems = SmartLootDB.ignoredItems

    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Configuración cargada")
end

function SL:SaveConfig()
    if not SmartLootDB then
        SmartLootDB = {}
    end

    SmartLootDB.config = self.config
    SmartLootDB.ignoredItems = self.IgnoredItems

    -- Guardar posición del botón flotante
    if self.UI and self.UI.FloatingButton then
        local point, _, relativePoint, xOffset, yOffset = self.UI.FloatingButton:GetPoint()
        SmartLootDB.buttonPosition = {
            point = point or "CENTER",
            relativeTo = "Minimap",
            relativePoint = relativePoint or "CENTER",
            xOffset = xOffset or 0,
            yOffset = yOffset or -80
        }
    end

    -- Guardar posición de la ventana principal
    if self.UI and self.UI.MainFrame then
        local point, _, _, xOffset, yOffset = self.UI.MainFrame:GetPoint()
        SmartLootDB.framePosition = {
            point = point or "CENTER",
            xOffset = xOffset or 0,
            yOffset = yOffset or 0
        }
    end

    -- Guardar estados de items
    SmartLootDB.itemStates = {}
    for profKey, profession in pairs(self.ItemDatabase or {}) do
        SmartLootDB.itemStates[profKey] = {}
        if profession.items then
            for itemID, item in pairs(profession.items) do
                SmartLootDB.itemStates[profKey][itemID] = item.enabled
            end
        end
    end
end

function SL:ResetConfig()
    SmartLootDB = {
        config = self:CopyTable(self.DefaultConfig),
        ignoredItems = self:CopyTable(self.DefaultIgnoredItems),
        buttonPosition = {
            point = "CENTER",
            relativeTo = "Minimap",
            relativePoint = "CENTER",
            xOffset = 0,
            yOffset = -80
        },
        framePosition = {
            point = "CENTER",
            xOffset = 0,
            yOffset = 0
        }
    }

    self.config = SmartLootDB.config
    self.IgnoredItems = SmartLootDB.ignoredItems

    -- Recargar UI si existe
    if self.UI and self.UI.MainFrame then
        self.UI.MainFrame:ClearAllPoints()
        self.UI.MainFrame:SetPoint("CENTER", 0, 0)
    end

    if self.UI and self.UI.FloatingButton then
        self.UI.FloatingButton:ClearAllPoints()
        self.UI.FloatingButton:SetPoint("CENTER", Minimap, "CENTER", 0, -80)
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Configuración reseteada a valores por defecto")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r Usa /reload para aplicar cambios completamente")
end

-- Función auxiliar para copiar tablas
function SL:CopyTable(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for key, value in pairs(orig) do
            copy[key] = self:CopyTable(value)
        end
    else
        copy = orig
    end
    return copy
end

-- ===========================================
-- RESTAURAR POSICIONES
-- ===========================================

function SL:RestorePositions()
    -- Restaurar posición del botón flotante
    if self.UI and self.UI.FloatingButton then
        if SmartLootDB and SmartLootDB.buttonPosition then
            local pos = SmartLootDB.buttonPosition
            self.UI.FloatingButton:ClearAllPoints()
            self.UI.FloatingButton:SetPoint(pos.point or "TOPRIGHT", Minimap, pos.relativePoint or "TOPRIGHT",
                pos.xOffset or 5, pos.yOffset or 5)
        else
            -- Posición por defecto si no hay guardada
            self.UI.FloatingButton:ClearAllPoints()
            self.UI.FloatingButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 5, 5)
        end
        self.UI.FloatingButton:Show()
    end

    -- Restaurar posición de la ventana principal
    if self.UI and self.UI.MainFrame then
        if SmartLootDB and SmartLootDB.framePosition then
            local pos = SmartLootDB.framePosition
            self.UI.MainFrame:ClearAllPoints()
            self.UI.MainFrame:SetPoint(pos.point or "CENTER", pos.xOffset or 0, pos.yOffset or 0)
        end
    end
end

-- ===========================================
-- EVENTOS DE GUARDADO AUTOMÁTICO
-- ===========================================

local saveFrame = CreateFrame("Frame")
saveFrame:RegisterEvent("PLAYER_LOGOUT")
saveFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGOUT" then
        SL:SaveConfig()
    end
end)

-- Guardar cada 5 minutos (por seguridad)
local autoSaveTimer = 0
local autoSaveFrame = CreateFrame("Frame")
autoSaveFrame:SetScript("OnUpdate", function(self, elapsed)
    autoSaveTimer = autoSaveTimer + elapsed
    if autoSaveTimer >= 300 then -- 300 segundos = 5 minutos
        SL:SaveConfig()
        autoSaveTimer = 0
    end
end)
