-- UI.lua - Interfaz gráfica mejorada por profesiones

SmartLoot = SmartLoot or {}
local SL = SmartLoot
SL.UI = {}

-- ===========================================
-- VENTANA PRINCIPAL
-- ===========================================

function SL.UI:CreateMainFrame()
    local frame = CreateFrame("Frame", "SmartLootMainFrame", UIParent)
    frame:SetSize(500, 550)
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
    title:SetText("|cFF00FF00SmartLoot|r v" .. SL.version)
    
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
        SL:SaveConfig()
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
    local professionKeys = {
        "Tailoring",
        "Leatherworking", 
        "Fishing",
        "Cooking",
        "Blacksmithing",
        "Mining",
        "Herbalism",
        "General"
    }
    
    local tabs = {}
    local contents = {}
    
    -- Crear tabs para cada profesión
    for i, key in ipairs(professionKeys) do
        local prof = SL.ItemDatabase[key]
        if prof then
            local tab = CreateFrame("Button", nil, parent)
            tab:SetSize(60, 60)
            
            -- Posición en grid
            local row = math.floor((i - 1) / 4)
            local col = (i - 1) % 4
            tab:SetPoint("TOPLEFT", 10 + (col * 120), -105 - (row * 70))
            
            -- Icono
            local icon = tab:CreateTexture(nil, "ARTWORK")
            icon:SetSize(45, 45)
            icon:SetPoint("TOP", 0, -5)
            icon:SetTexture(prof.icon)
            
            -- Nombre
            local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            text:SetPoint("BOTTOM", 0, 2)
            text:SetText(prof.name)
            
            -- Borde
            local border = tab:CreateTexture(nil, "OVERLAY")
            border:SetSize(55, 55)
            border:SetPoint("TOP", 0, -5)
            border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            border:SetBlendMode("ADD")
            border:SetAlpha(0)
            tab.border = border
            
            tabs[i] = tab
            
            -- Crear contenido
            local content = self:CreateProfessionContent(parent, key)
            contents[i] = content
        end
    end
    
    -- Tab de opciones generales
    local optionsTab = CreateFrame("Button", nil, parent)
    optionsTab:SetSize(60, 60)
    optionsTab:SetPoint("TOPLEFT", 10, -105 - (2 * 70))
    
    local optionsIcon = optionsTab:CreateTexture(nil, "ARTWORK")
    optionsIcon:SetSize(45, 45)
    optionsIcon:SetPoint("TOP", 0, -5)
    optionsIcon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    
    local optionsText = optionsTab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    optionsText:SetPoint("BOTTOM", 0, 2)
    optionsText:SetText("Opciones")
    
    local optionsBorder = optionsTab:CreateTexture(nil, "OVERLAY")
    optionsBorder:SetSize(55, 55)
    optionsBorder:SetPoint("TOP", 0, -5)
    optionsBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    optionsBorder:SetBlendMode("ADD")
    optionsBorder:SetAlpha(0)
    optionsTab.border = optionsBorder
    
    table.insert(tabs, optionsTab)
    table.insert(contents, self:CreateOptionsContent(parent))
    
    -- Tab de ignorados
    local ignoredTab = CreateFrame("Button", nil, parent)
    ignoredTab:SetSize(60, 60)
    ignoredTab:SetPoint("LEFT", optionsTab, "RIGHT", 60, 0)
    
    local ignoredIcon = ignoredTab:CreateTexture(nil, "ARTWORK")
    ignoredIcon:SetSize(45, 45)
    ignoredIcon:SetPoint("TOP", 0, -5)
    ignoredIcon:SetTexture("Interface\\Icons\\Ability_Rogue_FeignDeath")
    
    local ignoredText = ignoredTab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ignoredText:SetPoint("BOTTOM", 0, 2)
    ignoredText:SetText("Ignorados")
    
    local ignoredBorder = ignoredTab:CreateTexture(nil, "OVERLAY")
    ignoredBorder:SetSize(55, 55)
    ignoredBorder:SetPoint("TOP", 0, -5)
    ignoredBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    ignoredBorder:SetBlendMode("ADD")
    ignoredBorder:SetAlpha(0)
    ignoredTab.border = ignoredBorder
    
    table.insert(tabs, ignoredTab)
    table.insert(contents, self:CreateIgnoredContent(parent))
    
    -- Función para cambiar tabs
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
                tab.border:SetAlpha(1)
            else
                tab.border:SetAlpha(0)
            end
        end
    end
    
    -- Asignar clicks
    for i, tab in ipairs(tabs) do
        tab:SetScript("OnClick", function()
            SelectTab(i)
        end)
    end
    
    -- Seleccionar primera tab
    SelectTab(1)
end

-- ===========================================
-- CONTENIDO POR PROFESIÓN
-- ===========================================

function SL.UI:CreateProfessionContent(parent, professionKey)
    local content = CreateFrame("Frame", nil, parent)
    content:SetSize(480, 300)
    content:SetPoint("TOP", 0, -250)
    content:Hide()
    
    local prof = SL.ItemDatabase[professionKey]
    if not prof then return content end
    
    -- Título de la profesión
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -5)
    title:SetText("|cFFFFFF00" .. prof.name .. "|r")
    
    -- Botón "Seleccionar Todos"
    local selectAllBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    selectAllBtn:SetSize(100, 25)
    selectAllBtn:SetPoint("TOPLEFT", 10, -30)
    selectAllBtn:SetText("Todos")
    selectAllBtn:SetScript("OnClick", function()
        for itemID, item in pairs(prof.items) do
            item.enabled = true
        end
        self:RefreshProfessionContent(professionKey)
        SL:SaveConfig()
    end)
    
    -- Botón "Deseleccionar Todos"
    local deselectAllBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    deselectAllBtn:SetSize(100, 25)
    deselectAllBtn:SetPoint("LEFT", selectAllBtn, "RIGHT", 5, 0)
    deselectAllBtn:SetText("Ninguno")
    deselectAllBtn:SetScript("OnClick", function()
        for itemID, item in pairs(prof.items) do
            item.enabled = false
        end
        self:RefreshProfessionContent(professionKey)
        SL:SaveConfig()
    end)
    
    -- Botón "Añadir Item"
    local addItemBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    addItemBtn:SetSize(100, 25)
    addItemBtn:SetPoint("LEFT", deselectAllBtn, "RIGHT", 5, 0)
    addItemBtn:SetText("+ Añadir")
    addItemBtn:SetScript("OnClick", function()
        self:ShowAddItemDialog(professionKey)
    end)
    
    -- ScrollFrame para los items
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(450, 230)
    scrollFrame:SetPoint("TOP", 0, -65)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(430, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    content.scrollChild = scrollChild
    content.professionKey = professionKey
    
    self:RefreshProfessionContent(professionKey)
    
    return content
end

function SL.UI:RefreshProfessionContent(professionKey)
    -- Buscar el content frame
    local content = nil
    for i, child in ipairs({self.MainFrame:GetChildren()}) do
        if child.professionKey == professionKey then
            content = child
            break
        end
    end
    
    if not content or not content.scrollChild then return end
    
    local scrollChild = content.scrollChild
    
    -- Limpiar items anteriores
    local children = {scrollChild:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end
    
    local prof = SL.ItemDatabase[professionKey]
    if not prof then return end
    
    local yOffset = -5
    local count = 0
    
    -- Ordenar items por nombre
    local sortedItems = {}
    for itemID, item in pairs(prof.items) do
        table.insert(sortedItems, {id = itemID, data = item})
    end
    table.sort(sortedItems, function(a, b)
        return (a.data.name or "") < (b.data.name or "")
    end)
    
    for _, itemEntry in ipairs(sortedItems) do
        local itemID = itemEntry.id
        local item = itemEntry.data
        
        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetSize(420, 25)
        row:SetPoint("TOP", 0, yOffset)
        
        -- Checkbox
        local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        cb:SetPoint("LEFT", 5, 0)
        cb:SetSize(24, 24)
        cb:SetChecked(item.enabled)
        cb:SetScript("OnClick", function(self)
            item.enabled = self:GetChecked()
            SL:SaveConfig()
        end)
        
        -- Icono del item
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        
        local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
        if itemTexture then
            icon:SetTexture(itemTexture)
        else
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        
        -- Nombre del item
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        text:SetWidth(250)
        text:SetJustifyH("LEFT")
        
        if itemLink then
            text:SetText(itemLink)
        else
            text:SetText(item.name or ("ID: " .. itemID))
        end
        
        -- Botón eliminar (solo para items custom)
        if item.custom then
            local deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            deleteBtn:SetSize(60, 20)
            deleteBtn:SetPoint("RIGHT", -5, 0)
            deleteBtn:SetText("Eliminar")
            deleteBtn:SetScript("OnClick", function()
                SL:RemoveCustomItem(professionKey, itemID)
                self:RefreshProfessionContent(professionKey)
                SL:SaveConfig()
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Item eliminado")
            end)
        end
        
        yOffset = yOffset - 30
        count = count + 1
    end
    
    if count == 0 then
        local emptyText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        emptyText:SetPoint("TOP", 0, -50)
        emptyText:SetText("|cFFAAAAAA(No hay items configurados)|r")
    end
    
    scrollChild:SetHeight(math.max(230, count * 30))
end
-- ===========================================
-- DIÁLOGO PARA AÑADIR ITEMS
-- ===========================================

function SL.UI:ShowAddItemDialog(professionKey)
    -- Si ya existe el diálogo, mostrarlo
    if self.AddItemDialog then
        self.AddItemDialog:Show()
        self.AddItemDialog.professionKey = professionKey
        return
    end
    
    -- Crear diálogo
    local dialog = CreateFrame("Frame", "SmartLootAddItemDialog", UIParent)
    dialog:SetSize(350, 200)
    dialog:SetPoint("CENTER")
    dialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:SetFrameStrata("DIALOG")
    dialog.professionKey = professionKey
    
    self.AddItemDialog = dialog
    
    -- Título
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("|cFF00FF00Añadir Item Personalizado|r")
    
    -- Instrucciones
    local instructions = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    instructions:SetPoint("TOP", 0, -45)
    instructions:SetWidth(320)
    instructions:SetJustifyH("LEFT")
    instructions:SetText("Activa 'Mostrar ID en tooltips' en Opciones,\nluego pasa el ratón sobre un item para ver su ID.")
    
    -- Label Item ID
    local labelID = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    labelID:SetPoint("TOPLEFT", 20, -90)
    labelID:SetText("Item ID:")
    
    -- EditBox para Item ID
    local editBoxID = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    editBoxID:SetSize(100, 30)
    editBoxID:SetPoint("LEFT", labelID, "RIGHT", 10, 0)
    editBoxID:SetAutoFocus(false)
    editBoxID:SetMaxLetters(10)
    editBoxID:SetNumeric(true)
    dialog.editBoxID = editBoxID
    
    -- Label Nombre (opcional)
    local labelName = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    labelName:SetPoint("TOPLEFT", 20, -125)
    labelName:SetText("Nombre (opcional):")
    
    -- EditBox para Nombre
    local editBoxName = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    editBoxName:SetSize(200, 30)
    editBoxName:SetPoint("TOPLEFT", 20, -145)
    editBoxName:SetAutoFocus(false)
    editBoxName:SetMaxLetters(50)
    dialog.editBoxName = editBoxName
    
    -- Botón Añadir
    local addBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    addBtn:SetSize(100, 30)
    addBtn:SetPoint("BOTTOMLEFT", 20, 15)
    addBtn:SetText("Añadir")
    addBtn:SetScript("OnClick", function()
        local itemID = tonumber(editBoxID:GetText())
        local itemName = editBoxName:GetText()
        
        if not itemID then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Debes ingresar un Item ID válido")
            return
        end
        
        -- Si no hay nombre, intentar obtenerlo del juego
        if not itemName or itemName == "" then
            local name = GetItemInfo(itemID)
            itemName = name or ("Item ID: " .. itemID)
        end
        
        if SL:AddCustomItem(dialog.professionKey, itemID, itemName) then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Item añadido: " .. itemName)
            self:RefreshProfessionContent(dialog.professionKey)
            SL:SaveConfig()
            editBoxID:SetText("")
            editBoxName:SetText("")
            dialog:Hide()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r El item ya existe en esta categoría")
        end
    end)
    
    -- Botón Cancelar
    local cancelBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    cancelBtn:SetSize(100, 30)
    cancelBtn:SetPoint("BOTTOMRIGHT", -20, 15)
    cancelBtn:SetText("Cancelar")
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    -- Botón cerrar
    local closeBtn = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
end

-- ===========================================
-- TAB DE OPCIONES GENERALES
-- ===========================================

function SL.UI:CreateOptionsContent(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetSize(480, 300)
    content:SetPoint("TOP", 0, -250)
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
            SL:SaveConfig()
        end)
        
        yOffset = yOffset - 30
        return cb
    end
    
    -- Título
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -5)
    title:SetText("|cFFFFFF00Opciones Generales|r")
    yOffset = yOffset - 30
    
    -- Sección: Por Calidad
    local qualityLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    qualityLabel:SetPoint("TOPLEFT", 10, yOffset)
    qualityLabel:SetText("|cFFFFFF00Recoger por Calidad:|r")
    yOffset = yOffset - 25
    
    CreateCheckbox("Recetas (todas)", "lootRecipes")
    CreateCheckbox("Items Verdes (cualquier nivel)", "lootGreenAny")
    CreateCheckbox("Items Azules (nivel 67-80)", "lootBlue67to80")
    CreateCheckbox("Items Morados (nivel 67-80)", "lootPurple67to80")
    
    yOffset = yOffset - 10
    
    -- Sección: Misiones y Monedas
    local miscLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    miscLabel:SetPoint("TOPLEFT", 10, yOffset)
    miscLabel:SetText("|cFFFFFF00Misceláneos:|r")
    yOffset = yOffset - 25
    
    CreateCheckbox("Objetos de Misiones", "lootQuestItems")
    CreateCheckbox("Monedas (Cobre, Plata, Oro)", "lootMoney")
    CreateCheckbox("Ignorar Items Grises (basura)", "ignoreGrey")
    
    yOffset = yOffset - 10
    
    -- Sección: Interfaz
    local uiLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    uiLabel:SetPoint("TOPLEFT", 10, yOffset)
    uiLabel:SetText("|cFFFFFF00Interfaz:|r")
    yOffset = yOffset - 25
    
    CreateCheckbox("Mostrar ID en tooltips", "showItemID")
    CreateCheckbox("Mostrar mensajes en chat", "showMessages")
    CreateCheckbox("Modo Debug", "debugMode")
    
    yOffset = yOffset - 20
    
    -- Botón Reset
    local resetBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetBtn:SetSize(150, 30)
    resetBtn:SetPoint("TOPLEFT", 10, yOffset)
    resetBtn:SetText("Resetear Todo")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("SMARTLOOT_RESET_CONFIRM")
    end)
    
    return content
end

-- ===========================================
-- TAB DE ITEMS IGNORADOS
-- ===========================================

function SL.UI:CreateIgnoredContent(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetSize(480, 300)
    content:SetPoint("TOP", 0, -250)
    content:Hide()
    
    -- Título
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -5)
    title:SetText("|cFFFFFF00Items Ignorados|r")
    
    -- Instrucciones
    local instructions = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    instructions:SetPoint("TOP", 0, -30)
    instructions:SetWidth(450)
    instructions:SetJustifyH("LEFT")
    instructions:SetText("Estos items NUNCA serán recogidos, incluso si cumplen otras condiciones.\n\n" ..
                        "|cFFFFFFFFPara agregar:|r Usa /sl ignore <ID>\n" ..
                        "|cFFFFFFFFPara eliminar:|r Click en el botón 'X' o usa /sl unignore <ID>")
    
    -- Ejemplo
    local example = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    example:SetPoint("TOP", 0, -95)
    example:SetWidth(450)
    example:SetJustifyH("LEFT")
    example:SetTextColor(0.7, 0.7, 0.7)
    example:SetText("Ejemplo: Si una receta molesta cae mucho, obtén su ID con 'Mostrar ID en tooltips'\ny usa /sl ignore 44510 para ignorarla permanentemente.")
    
    -- ScrollFrame para la lista
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(450, 130)
    scrollFrame:SetPoint("TOP", 0, -135)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(430, 1)
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
        row:SetSize(420, 25)
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
        else
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        
        -- Nombre del item
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        text:SetWidth(300)
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
            SL:SaveConfig()
        end)
        
        yOffset = yOffset - 30
        count = count + 1
    end
    
    if count == 0 then
        local emptyText = self.IgnoredScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        emptyText:SetPoint("TOP", 0, -30)
        emptyText:SetText("|cFFAAAAAA(No hay items ignorados)|r")
        
        local hint = self.IgnoredScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        hint:SetPoint("TOP", 0, -60)
        hint:SetWidth(400)
        hint:SetText("|cFFAAAAAAUsa /sl ignore <ID> para añadir items|r")
    end
    
    -- Ajustar tamaño del scroll child
    self.IgnoredScrollChild:SetHeight(math.max(130, count * 30))
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
    
    btn:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    
    btn:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SL:SaveConfig()
    end)
    
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
            if SL.UI.ToggleBtn then
                SL.UI.ToggleBtn:SetText(SL.config.enabled and "Desactivar" or "Activar")
            end
            SL:SaveConfig()
        end
    end)
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("|cFF00FF00SmartLoot|r")
        GameTooltip:AddLine("Estado: " .. (SL.config.enabled and "|cFF00FF00Activado|r" or "|cFFFF0000Desactivado|r"), 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Click izq: Abrir menú", 1, 1, 1)
        GameTooltip:AddLine("Click der: ON/OFF rápido", 1, 1, 1)
        GameTooltip:AddLine("Arrastrar: Mover botón", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    self.FloatingButton = btn
end

-- ===========================================
-- POPUP DE CONFIRMACIÓN PARA RESET
-- ===========================================

StaticPopupDialogs["SMARTLOOT_RESET_CONFIRM"] = {
    text = "¿Estás seguro de que quieres resetear TODA la configuración de SmartLoot?\n\nEsto incluye:\n- Todas las opciones\n- Items personalizados\n- Items ignorados\n- Posiciones guardadas",
    button1 = "Sí, Resetear",
    button2 = "Cancelar",
    OnAccept = function()
        SmartLoot:ResetConfig()
        if SmartLoot.UI and SmartLoot.UI.MainFrame then
            SmartLoot.UI.MainFrame:Hide()
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r Usa /reload para aplicar cambios")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

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

-- Inicializar UI cuando el jugador entre
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    SL.UI:Initialize()
end)