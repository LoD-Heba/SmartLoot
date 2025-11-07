-- UI.lua - Interfaz gráfica de SmartLoot

SmartLoot = SmartLoot or {}
local SL = SmartLoot
SL.UI = {}

-- ===========================================
-- VENTANA PRINCIPAL
-- ===========================================

function SL.UI:CreateMainFrame()
    local frame = CreateFrame("Frame", "SmartLootMainFrame", UIParent)
    frame:SetSize(400, 500)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    self.MainFrame = frame
    
    -- Título
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("|cFF00FF00SmartLoot|r Configuration")
    
    -- Botón cerrar
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    
    -- Estado
    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusText:SetPoint("TOP", 0, -40)
    self.StatusText = statusText
    self:UpdateStatus()
    
    -- Botón ON/OFF
    local toggleBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    toggleBtn:SetSize(120, 30)
    toggleBtn:SetPoint("TOP", 0, -65)
    toggleBtn:SetText(SL.config.enabled and "Desactivar" or "Activar")
    toggleBtn:SetScript("OnClick", function()
        SL.config.enabled = not SL.config.enabled
        toggleBtn:SetText(SL.config.enabled and "Desactivar" or "Activar")
        DEFAULT_CHAT_FRAME:AddMessage(SL.config.enabled and "|cFF00FF00[SmartLoot]|r Activado" or "|cFFFF0000[SmartLoot]|r Desactivado")
        self:UpdateStatus()
    end)
    self.ToggleBtn = toggleBtn
    
    -- Crear tabs
    self:CreateTabs(frame)
end

function SL.UI:UpdateStatus()
    if self.StatusText then
        if SL.config.enabled then
            self.StatusText:SetText("Estado: |cFF00FF00Activado|r")
        else
            self.StatusText:SetText("Estado: |cFFFF0000Desactivado|r")
        end
    end
end

-- ===========================================
-- SISTEMA DE TABS
-- ===========================================

function SL.UI:CreateTabs(parent)
    local tabs = {}
    
    -- Tab 1: Categorías
    local tab1 = CreateFrame("Button", nil, parent)
    tab1:SetSize(100, 30)
    tab1:SetPoint("TOPLEFT", 10, -100)
    tab1:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    tab1:SetText("Categorías")
    tab1:SetNormalFontObject("GameFontNormal")
    tabs[1] = tab1
    
    -- Tab 2: Calidades
    local tab2 = CreateFrame("Button", nil, parent)
    tab2:SetSize(100, 30)
    tab2:SetPoint("LEFT", tab1, "RIGHT", 5, 0)
    tab2:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    tab2:SetText("Calidades")
    tab2:SetNormalFontObject("GameFontNormal")
    tabs[2] = tab2
    
    -- Tab 3: Items Ignorados
    local tab3 = CreateFrame("Button", nil, parent)
    tab3:SetSize(100, 30)
    tab3:SetPoint("LEFT", tab2, "RIGHT", 5, 0)
    tab3:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    tab3:SetText("Ignorados")
    tab3:SetNormalFontObject("GameFontNormal")
    tabs[3] = tab3
    
    -- Contenedores para cada tab
    local content1 = self:CreateCategoriesContent(parent)
    local content2 = self:CreateQualitiesContent(parent)
    local content3 = self:CreateIgnoredContent(parent)
    
    local contents = {content1, content2, content3}
    
    -- Función para cambiar de tab
    local function SelectTab(index)
        for i, content in ipairs(contents) do
            if i == index then
                content:Show()
            else
                content:Hide()
            end
        end
        
        for i, tab in ipairs(tabs) do
            if i == index then
                tab:SetNormalFontObject("GameFontHighlight")
            else
                tab:SetNormalFontObject("GameFontNormal")
            end
        end
    end
    
    tab1:SetScript("OnClick", function() SelectTab(1) end)
    tab2:SetScript("OnClick", function() SelectTab(2) end)
    tab3:SetScript("OnClick", function() SelectTab(3) end)
    
    -- Mostrar tab 1 por defecto
    SelectTab(1)
end

-- ===========================================
-- TAB 1: CATEGORÍAS
-- ===========================================

function SL.UI:CreateCategoriesContent(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetSize(380, 350)
    content:SetPoint("TOPLEFT", 10, -135)
    
    local yOffset = -10
    
    -- Función helper para crear checkbox
    local function CreateCheckbox(label, configKey)
        local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 10, yOffset)
        cb:SetSize(24, 24)
        cb:SetChecked(SL.config[configKey])
        
        local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        text:SetText(label)
        
        cb:SetScript("OnClick", function(self)
            SL.config[configKey] = self:GetChecked()
        end)
        
        yOffset = yOffset - 30
        return cb
    end
    
    local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 10, -5)
    label:SetText("|cFFFFFF00Categorías de Items:|r")
    yOffset = yOffset - 25
    
    CreateCheckbox("Paños (Linen, Wool, Silk, etc.)", "lootCloths")
    CreateCheckbox("Comida y Bebida", "lootFood")
    CreateCheckbox("Materiales de Cocina", "lootCookingMats")
    CreateCheckbox("Objetos de Pesca", "lootFishing")
    CreateCheckbox("Objetos de Misiones", "lootQuestItems")
    
    yOffset = yOffset - 20
    local label2 = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label2:SetPoint("TOPLEFT", 10, yOffset)
    label2:SetText("|cFFFFFF00Opciones Generales:|r")
    yOffset = yOffset - 25
    
    CreateCheckbox("Recoger Monedas (Cobre, Plata, Oro)", "lootMoney")
    CreateCheckbox("Ignorar Items Grises (basura)", "ignoreGrey")
    CreateCheckbox("Mostrar ID en tooltips", "showItemID")
    CreateCheckbox("Mostrar mensajes en chat", "showMessages")
    
    return content
end

-- ===========================================
-- TAB 2: CALIDADES
-- ===========================================

function SL.UI:CreateQualitiesContent(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetSize(380, 350)
    content:SetPoint("TOPLEFT", 10, -135)
    content:Hide()
    
    local yOffset = -10
    
    local function CreateCheckbox(label, configKey)
        local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 10, yOffset)
        cb:SetSize(24, 24)
        cb:SetChecked(SL.config[configKey])
        
        local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        text:SetText(label)
        
        cb:SetScript("OnClick", function(self)
            SL.config[configKey] = self:GetChecked()
        end)
        
        yOffset = yOffset - 30
        return cb
    end
    
    local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 10, -5)
    label:SetText("|cFFFFFF00Filtros por Calidad:|r")
    yOffset = yOffset - 25
    
    CreateCheckbox("Recetas (todas)", "lootRecipes")
    CreateCheckbox("Items Verdes (cualquier nivel)", "lootGreenAny")
    CreateCheckbox("Items Azules (nivel 67-80)", "lootBlue67to80")
    CreateCheckbox("Items Morados (nivel 67-80)", "lootPurple67to80")
    
    -- Información adicional
    yOffset = yOffset - 40
    local info = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    info:SetPoint("TOPLEFT", 10, yOffset)
    info:SetWidth(360)
    info:SetJustifyH("LEFT")
    info:SetText("|cFFAAAAAA Calidades en WoW:\n" ..
                 " 0 = Pobre (Gris)\n" ..
                 " 1 = Común (Blanco)\n" ..
                 " 2 = Poco común (Verde)\n" ..
                 " 3 = Raro (Azul)\n" ..
                 " 4 = Épico (Morado)\n" ..
                 " 5 = Legendario (Naranja)|r")
    
    return content
end

-- ===========================================
-- TAB 3: ITEMS IGNORADOS
-- ===========================================

function SL.UI:CreateIgnoredContent(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetSize(380, 350)
    content:SetPoint("TOPLEFT", 10, -135)
    content:Hide()
    
    -- Instrucciones
    local instructions = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    instructions:SetPoint("TOP", 0, -5)
    instructions:SetWidth(360)
    instructions:SetJustifyH("LEFT")
    instructions:SetText("|cFFFFFF00Gestión de Items Ignorados:|r\n\n" ..
                        "Puedes ignorar items específicos para que SmartLoot nunca los recoja.\n\n" ..
                        "|cFFFFFFFFPara agregar:|r Activa 'Mostrar ID en tooltips' en la pestaña Categorías, " ..
                        "luego usa /sl ignore <ID>\n\n" ..
                        "|cFFFFFFFFPara eliminar:|r Usa /sl unignore <ID> o haz click en el botón 'X'")
    
    -- ScrollFrame para la lista
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(350, 200)
    scrollFrame:SetPoint("TOP", 0, -120)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(330, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    self.IgnoredScrollChild = scrollChild
    
    -- Botón para refrescar lista
    local refreshBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    refreshBtn:SetSize(100, 25)
    refreshBtn:SetPoint("BOTTOM", 0, 10)
    refreshBtn:SetText("Refrescar")
    refreshBtn:SetScript("OnClick", function()
        self:RefreshIgnoredList()
    end)
    
    self:RefreshIgnoredList()
    
    return content
end

function SL.UI:RefreshIgnoredList()
    if not self.IgnoredScrollChild then return end
    
    -- Limpiar lista anterior
    local children = {self.IgnoredScrollChild:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end
    
    -- Crear nueva lista
    local yOffset = -5
    local count = 0
    
    for itemID, _ in pairs(SL.IgnoredItems) do
        local itemName, itemLink = GetItemInfo(itemID)
        
        local row = CreateFrame("Frame", nil, self.IgnoredScrollChild)
        row:SetSize(320, 25)
        row:SetPoint("TOP", 0, yOffset)
        
        -- Icono del item
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", 5, 0)
        
        if itemLink then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
            if itemTexture then
                icon:SetTexture(itemTexture)
            end
        end
        
        -- Nombre del item
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        text:SetWidth(220)
        text:SetJustifyH("LEFT")
        
        if itemLink then
            text:SetText(itemLink)
        else
            text:SetText("|cFFFF0000ID: " .. itemID .. " (desconocido)|r")
        end
        
        -- Botón eliminar
        local deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        deleteBtn:SetSize(40, 20)
        deleteBtn:SetPoint("RIGHT", -5, 0)
        deleteBtn:SetText("X")
        deleteBtn:SetScript("OnClick", function()
            SL.IgnoredItems[itemID] = nil
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Item desbloqueado: " .. (itemName or itemID))
            self:RefreshIgnoredList()
        end)
        
        yOffset = yOffset - 30
        count = count + 1
    end
    
    if count == 0 then
        local emptyText = self.IgnoredScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        emptyText:SetPoint("TOP", 0, -50)
        emptyText:SetText("|cFFAAAAAA(No hay items ignorados)|r")
    end
    
    -- Ajustar tamaño del scroll child
    self.IgnoredScrollChild:SetHeight(math.max(200, count * 30))
end

-- ===========================================
-- BOTÓN FLOTANTE
-- ===========================================

function SL.UI:CreateFloatingButton()
    local btn = CreateFrame("Button", "SmartLootFloatingButton", UIParent)
    btn:SetSize(32, 32)
    btn:SetPoint("CENTER", Minimap, "CENTER", 0, -80)
    btn:SetMovable(true)
    btn:EnableMouse(true)
    btn:RegisterForDrag("LeftButton")
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    local texture = btn:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\Icons\\INV_Misc_Bag_10")
    
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetPoint("CENTER")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    btn:SetScript("OnDragStart", btn.StartMoving)
    btn:SetScript("OnDragStop", btn.StopMovingOrSizing)
    
    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if SL.UI.MainFrame:IsShown() then
                SL.UI.MainFrame:Hide()
            else
                SL.UI.MainFrame:Show()
            end
        elseif button == "RightButton" then
            SL.config.enabled = not SL.config.enabled
            DEFAULT_CHAT_FRAME:AddMessage(SL.config.enabled and "|cFF00FF00[SmartLoot]|r Activado" or "|cFFFF0000[SmartLoot]|r Desactivado")
            SL.UI:UpdateStatus()
            SL.UI.ToggleBtn:SetText(SL.config.enabled and "Desactivar" or "Activar")
        end
    end)
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("|cFF00FF00SmartLoot|r")
        GameTooltip:AddLine("Click izq: Abrir/Cerrar", 1, 1, 1)
        GameTooltip:AddLine("Click der: ON/OFF", 1, 1, 1)
        GameTooltip:AddLine("Arrastrar: Mover", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    self.FloatingButton = btn
end

-- ===========================================
-- INICIALIZACIÓN
-- ===========================================

function SL.UI:Initialize()
    self:CreateMainFrame()
    self:CreateFloatingButton()
end

function SL.UI:Show()
    if self.MainFrame then
        self.MainFrame:Show()
    end
end

function SL.UI:Hide()
    if self.MainFrame then
        self.MainFrame:Hide()
    end
end

-- Inicializar UI cuando el addon cargue
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    SL.UI:Initialize()
end)
