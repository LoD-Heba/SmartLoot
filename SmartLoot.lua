-- SmartLoot.lua
-- Addon para WoW 3.3.5 que recoge automáticamente solo items específicos

local frame = CreateFrame("Frame")
local addonName = "SmartLoot"

-- ===========================================
-- CONFIGURACIÓN
-- ===========================================

-- Lista de items por ID
local itemIDsToLoot = {
    -- PAÑOS
    [2589] = true,  -- Paño de lino / Linen Cloth
    [2592] = true,  -- Paño de lana / Wool Cloth
    [4306] = true,  -- Paño de seda / Silk Cloth
    [4338] = true,  -- Tejido de magiatrama / Mageweave Cloth
    [14047] = true, -- Paño de runa / Runecloth
    [33470] = true, -- Telaescarcha / Frostweave Cloth
}

local config = {
    enabled = true,
    showMessages = true,
    debugMode = true,
}

-- ===========================================
-- FUNCIONES PRINCIPALES
-- ===========================================

local function SmartLootCorpse()
    if not config.enabled then 
        return 
    end
    
    local numItems = GetNumLootItems()
    
    if config.debugMode then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r Detectados " .. numItems .. " items en el loot")
    end
    
    if numItems == 0 then 
        return 
    end
    
    -- Recorrer todos los items
    for slot = numItems, 1, -1 do  -- De atrás hacia adelante para evitar problemas
        local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked = GetLootSlotInfo(slot)
        local itemLink = GetLootSlotLink(slot)
        local shouldLoot = false
        
        if config.debugMode then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r Slot " .. slot .. ": " .. (lootName or "nil") .. " | currencyID: " .. tostring(currencyID) .. " | locked: " .. tostring(locked))
        end
        
        -- NO LOOTEAR si está bloqueado
        if locked then
            if config.debugMode then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Slot " .. slot .. " está bloqueado, saltando")
            end
        -- MONEDAS: Si NO es item (no tiene itemLink) pero tiene nombre, es dinero
        elseif not itemLink and lootName and not currencyID then
            shouldLoot = true
            if config.showMessages then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD700[SmartLoot]|r Recogido: " .. lootName)
            end
            LootSlot(slot)
        -- ITEMS NORMALES: Solo si está en nuestra lista
        elseif itemLink then
            local itemID = tonumber(string.match(itemLink, "item:(%d+)"))
            
            if config.debugMode then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r   Item ID: " .. (itemID or "nil") .. " | En lista: " .. tostring(itemIDsToLoot[itemID] or false))
            end
            
            -- SOLO recoger si está en la lista
            if itemID and itemIDsToLoot[itemID] then
                shouldLoot = true
                LootSlot(slot)
                if config.showMessages then
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Recogido: " .. itemLink)
                end
            else
                if config.debugMode then
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600[SmartLoot]|r   IGNORADO (no está en la lista)")
                end
            end
        end
    end
end

-- ===========================================
-- COMANDOS
-- ===========================================

local function HandleCommand(msg)
    msg = string.lower(msg or "")
    msg = string.gsub(msg, "^%s*(.-)%s*$", "%1") -- trim
    
    if msg == "on" then
        config.enabled = true
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Activado")
        
    elseif msg == "off" then
        config.enabled = false
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Desactivado")
        
    elseif msg == "debug" then
        config.debugMode = not config.debugMode
        local status = config.debugMode and "Activado" or "Desactivado"
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Debug: " .. status)
        
    elseif msg == "test" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Ejecutando loot manual...")
        SmartLootCorpse()
        
    elseif msg == "list" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Items configurados:")
        for itemID, _ in pairs(itemIDsToLoot) do
            local itemName = GetItemInfo(itemID)
            if itemName then
                DEFAULT_CHAT_FRAME:AddMessage("  - " .. itemName .. " (ID: " .. itemID .. ")")
            end
        end
        
    elseif msg == "help" or msg == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00=== SmartLoot ===|r")
        DEFAULT_CHAT_FRAME:AddMessage("/sl on/off - Activar/Desactivar")
        DEFAULT_CHAT_FRAME:AddMessage("/sl debug - Modo debug")
        DEFAULT_CHAT_FRAME:AddMessage("/sl test - Loot manual")
        DEFAULT_CHAT_FRAME:AddMessage("/sl list - Ver items")
        
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Comando inválido. Usa /sl help")
    end
end

SLASH_SMARTLOOT1 = "/smartloot"
SLASH_SMARTLOOT2 = "/sl"
SlashCmdList["SMARTLOOT"] = HandleCommand

-- ===========================================
-- EVENTOS
-- ===========================================

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("LOOT_OPENED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "SmartLoot" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Cargado correctamente. Usa /sl help")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r Debug activado. Usa /sl debug para desactivar")
        
    elseif event == "LOOT_OPENED" then
        -- Pequeño delay para asegurar que el loot esté completamente cargado
        if config.enabled then
            -- Usar OnUpdate en vez de C_Timer para WoW 3.3.5
            local waitFrame = CreateFrame("Frame")
            local elapsed = 0
            waitFrame:SetScript("OnUpdate", function(self, delta)
                elapsed = elapsed + delta
                if elapsed >= 0.1 then
                    SmartLootCorpse()
                    waitFrame:SetScript("OnUpdate", nil)
                end
            end)
        end
    end
end)

-- ===========================================
-- Hook para detección alternativa
-- ===========================================

-- Backup: Hook a la función nativa de loot
local originalLootFrame_OnShow = LootFrame_OnShow
function LootFrame_OnShow(self)
    if originalLootFrame_OnShow then
        originalLootFrame_OnShow(self)
    end
    
    if config.enabled then
        -- Usar OnUpdate para delay
        local waitFrame = CreateFrame("Frame")
        local elapsed = 0
        waitFrame:SetScript("OnUpdate", function(self, delta)
            elapsed = elapsed + delta
            if elapsed >= 0.15 then
                SmartLootCorpse()
                waitFrame:SetScript("OnUpdate", nil)
            end
        end)
    end
end