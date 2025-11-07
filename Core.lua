-- Core.lua - Archivo principal de SmartLoot
-- Este archivo maneja la lógica central del addon

SmartLoot = SmartLoot or {}
local SL = SmartLoot

-- ===========================================
-- VARIABLES GLOBALES
-- ===========================================

SL.version = "2.0"
SL.frame = CreateFrame("Frame")

-- Configuración por defecto
SL.config = {
    enabled = false,
    showMessages = true,
    debugMode = false,
    showItemID = false,  -- NUEVO: Mostrar ID de items en tooltip
    
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
    lootMoney = true,
}

-- Lista de items ignorados (NUEVO)
SL.IgnoredItems = SL.IgnoredItems or {}

-- ===========================================
-- FUNCIONES DE LOOT
-- ===========================================

function SL:ShouldLootByCategory(itemID)
    if self.config.lootCloths and self.ItemCategories.Cloths[itemID] then
        return true, "Paño"
    end
    if self.config.lootFood and self.ItemCategories.Food[itemID] then
        return true, "Comida"
    end
    if self.config.lootCookingMats and self.ItemCategories.CookingMats[itemID] then
        return true, "Mat. Cocina"
    end
    if self.config.lootFishing and self.ItemCategories.Fishing[itemID] then
        return true, "Pesca"
    end
    return false, nil
end

function SL:ShouldLootByQuality(itemLink, lootQuality)
    if not itemLink then return false end
    
    -- Ignorar grises si está activado
    if self.config.ignoreGrey and lootQuality == 0 then
        return false, "Gris (ignorado)"
    end
    
    local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType = GetItemInfo(itemLink)
    
    -- OBJETOS DE MISIÓN
    if self.config.lootQuestItems then
        if itemSubType == "Quest" or string.find(itemType or "", "Quest") then
            return true, "Misión"
        end
    end
    
    -- RECETAS
    if self.config.lootRecipes then
        if itemType == "Recipe" or string.find(itemName or "", "Recipe:") or string.find(itemName or "", "Receta:") then
            return true, "Receta"
        end
    end
    
    -- VERDES
    if self.config.lootGreenAny and itemRarity == 2 then
        return true, "Verde"
    end
    
    -- AZULES 67-80
    if self.config.lootBlue67to80 and itemRarity == 3 then
        if itemLevel >= 67 and itemLevel <= 80 then
            return true, "Azul 67-80"
        end
    end
    
    -- MORADOS 67-80
    if self.config.lootPurple67to80 and itemRarity == 4 then
        if itemLevel >= 67 and itemLevel <= 80 then
            return true, "Morado 67-80"
        end
    end
    
    return false, nil
end

function SL:SmartLootCorpse()
    if not self.config.enabled then 
        return 
    end
    
    local numItems = GetNumLootItems()
    
    if self.config.debugMode then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r Detectados " .. numItems .. " items")
    end
    
    if numItems == 0 then 
        return 
    end
    
    for slot = numItems, 1, -1 do
        local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked = GetLootSlotInfo(slot)
        local itemLink = GetLootSlotLink(slot)
        
        if locked then
            -- Ignorar bloqueados
        elseif itemLink then
            local itemID = tonumber(string.match(itemLink, "item:(%d+)"))
            
            -- VERIFICAR SI ESTÁ EN LISTA DE IGNORADOS
            if self.IgnoredItems[itemID] then
                if self.config.debugMode then
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Ignorado: " .. itemLink)
                end
            else
                local shouldLoot = false
                local reason = ""
                
                -- Verificar por categoría
                local catCheck, catReason = self:ShouldLootByCategory(itemID)
                if catCheck then
                    shouldLoot = true
                    reason = catReason
                else
                    -- Verificar por calidad
                    local qualCheck, qualReason = self:ShouldLootByQuality(itemLink, lootQuality)
                    if qualCheck then
                        shouldLoot = true
                        reason = qualReason
                    end
                end
                
                if shouldLoot then
                    LootSlot(slot)
                    if self.config.showMessages then
                        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r " .. itemLink .. " |cFF888888(" .. reason .. ")|r")
                    end
                end
            end
        elseif lootName and self.config.lootMoney then
            -- Monedas
            LootSlot(slot)
            if self.config.showMessages then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD700[SmartLoot]|r " .. lootName)
            end
        end
    end
end

-- ===========================================
-- TOOLTIP - MOSTRAR ID DE ITEMS
-- ===========================================

local function AddItemIDToTooltip(tooltip, data)
    if not SL.config.showItemID then return end
    
    -- Obtener el item del tooltip
    local _, itemLink = tooltip:GetItem()
    if itemLink then
        local itemID = tonumber(string.match(itemLink, "item:(%d+)"))
        if itemID then
            -- Verificar si está ignorado
            local ignoredText = SL.IgnoredItems[itemID] and " |cFFFF0000[IGNORADO]|r" or ""
            tooltip:AddLine("|cFF00FFFFItem ID:|r " .. itemID .. ignoredText, 1, 1, 1)
            tooltip:Show()
        end
    end
end

-- Hook a los tooltips
GameTooltip:HookScript("OnTooltipSetItem", AddItemIDToTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", AddItemIDToTooltip)

-- ===========================================
-- COMANDOS (ACTUALIZADO)
-- ===========================================

function SL:HandleCommand(msg)
    msg = string.lower(msg or "")
    msg = string.gsub(msg, "^%s*(.-)%s*$", "%1")
    
    local args = {}
    for word in string.gmatch(msg, "%S+") do
        table.insert(args, word)
    end
    
    local cmd = args[1] or ""
    
    if cmd == "on" then
        self.config.enabled = true
        self.UI:Show()
        self.UI:UpdateStatus()
        self:SaveConfig()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Activado")
        
    elseif cmd == "off" then
        self.config.enabled = false
        self.UI:Hide()
        self.UI:UpdateStatus()
        self:SaveConfig()
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Desactivado")
        
    elseif cmd == "toggle" or cmd == "" then
        if self.UI.MainFrame:IsShown() then
            self.UI.MainFrame:Hide()
        else
            self.UI.MainFrame:Show()
        end
        
    elseif cmd == "ignore" then
        local itemID = tonumber(args[2])
        if itemID then
            self.IgnoredItems[itemID] = true
            local itemName = GetItemInfo(itemID) or "ID: " .. itemID
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Item ignorado: " .. itemName)
            self.UI:RefreshIgnoredList()
            self:SaveConfig()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Uso: /sl ignore <itemID>")
        end
        
    elseif cmd == "unignore" then
        local itemID = tonumber(args[2])
        if itemID and self.IgnoredItems[itemID] then
            self.IgnoredItems[itemID] = nil
            local itemName = GetItemInfo(itemID) or "ID: " .. itemID
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Item desbloqueado: " .. itemName)
            self.UI:RefreshIgnoredList()
            self:SaveConfig()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Item no encontrado")
        end
        
    elseif cmd == "showid" then
        self.config.showItemID = not self.config.showItemID
        local status = self.config.showItemID and "Activado" or "Desactivado"
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Mostrar ID: " .. status)
        self:SaveConfig()
        
    elseif cmd == "debug" then
        self.config.debugMode = not self.config.debugMode
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Debug: " .. (self.config.debugMode and "SI" or "NO"))
        self:SaveConfig()
        
    elseif cmd == "reset" then
        self:ResetConfig()
        
    elseif cmd == "save" then
        self:SaveConfig()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Configuración guardada manualmente")
        
    elseif cmd == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00=== SmartLoot v" .. self.version .. " ===|r")
        DEFAULT_CHAT_FRAME:AddMessage("/sl on - Activar y abrir")
        DEFAULT_CHAT_FRAME:AddMessage("/sl off - Desactivar y cerrar")
        DEFAULT_CHAT_FRAME:AddMessage("/sl toggle - Abrir/cerrar")
        DEFAULT_CHAT_FRAME:AddMessage("/sl ignore <id> - Ignorar item")
        DEFAULT_CHAT_FRAME:AddMessage("/sl unignore <id> - Dejar de ignorar")
        DEFAULT_CHAT_FRAME:AddMessage("/sl showid - Ver IDs en tooltips")
        DEFAULT_CHAT_FRAME:AddMessage("/sl debug - Modo debug")
        DEFAULT_CHAT_FRAME:AddMessage("/sl reset - Resetear configuración")
        DEFAULT_CHAT_FRAME:AddMessage("/sl save - Guardar manualmente")
        
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Comando inválido. Usa /sl help")
    end
end

-- ===========================================
-- EVENTOS (ACTUALIZADO)
-- ===========================================

SL.frame:RegisterEvent("ADDON_LOADED")
SL.frame:RegisterEvent("LOOT_OPENED")
SL.frame:RegisterEvent("PLAYER_LOGIN")

SL.frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "SmartLoot" then
        -- Cargar configuración guardada
        SL:LoadConfig()
        
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r v" .. SL.version .. " Cargado")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r Usa /sl help para comandos")
        
    elseif event == "PLAYER_LOGIN" then
        -- Restaurar posiciones guardadas
        SL:RestorePositions()
        
    elseif event == "LOOT_OPENED" then
        if SL.config.enabled then
            local waitFrame = CreateFrame("Frame")
            local elapsed = 0
            waitFrame:SetScript("OnUpdate", function(self, delta)
                elapsed = elapsed + delta
                if elapsed >= 0.1 then
                    SL:SmartLootCorpse()
                    waitFrame:SetScript("OnUpdate", nil)
                end
            end)
        end
    end
end)

-- Hook alternativo
local originalLootFrame_OnShow = LootFrame_OnShow
function LootFrame_OnShow(self)
    if originalLootFrame_OnShow then
        originalLootFrame_OnShow(self)
    end
    
    if SmartLoot.config.enabled then
        local waitFrame = CreateFrame("Frame")
        local elapsed = 0
        waitFrame:SetScript("OnUpdate", function(self, delta)
            elapsed = elapsed + delta
            if elapsed >= 0.15 then
                SmartLoot:SmartLootCorpse()
                waitFrame:SetScript("OnUpdate", nil)
            end
        end)
    end
end