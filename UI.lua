-- UI.lua - Interfaz gráfica mejorada y responsiva

SmartLoot = SmartLoot or {}
local SL = SmartLoot
SL.UI = {}

-- ===========================================
-- VENTANA PRINCIPAL (MÁS GRANDE)
-- ===========================================

function SL.UI:CreateMainFrame()
    local frame = CreateFrame("Frame", "SmartLootMainFrame", UIParent)
    frame:SetSize(700, 600)
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
    
    -- Botón ON/OFF más grande
    local toggleBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    toggleBtn:SetSize(150, 35)
    toggleBtn:SetPoint("TOP", 0, -70)
    toggleBtn:SetText(SL.config.enabled and "DESACTIVAR" or "ACTIVAR")
    toggleBtn:SetScript("OnClick", function()
        SL.config.enabled = not SL.config.enabled
        toggleBtn:SetText(SL.config.enabled and "DESACTIVAR" or "ACTIVAR")
        DEFAULT_CHAT_FRAME:AddMessage(SL.config.enabled and "|cFF00FF00[SmartLoot]|r Activado" or "|cFFFF0000[SmartLoot]|r Desactivado")
        self:UpdateStatus()
        SL:SaveConfig()
    end)
    self.ToggleBtn = toggleBtn
    
    -- Crear panel de navegación lateral
    self:CreateSideNavigation(frame)
end

function SL.UI:UpdateStatus()
    if self.StatusText then
        if SL.config.enabled then
            self.StatusText:SetText("Estado: |cFF00FF00● ACTIVADO|r")
        else
            self.StatusText:SetText("Estado: |cFFFF0000● DESACTIVADO|r")
        end
    end
end

-- ===========================================
-- NAVEGACIÓN LATERAL
-- ===========================================

function SL.UI:CreateSideNavigation(parent)
    -- Panel lateral
    local sidePanel = CreateFrame("Frame", nil, parent)
    sidePanel:SetSize(150, 465)
    sidePanel:SetPoint("TOPLEFT", 10, -120)
    sidePanel:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    sidePanel:SetBackdropColor(0, 0, 0, 0.5)
    sidePanel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    -- Título del panel
    local sideTitle = sidePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sideTitle:SetPoint("TOP", 0, -8)
    sideTitle:SetText("|cFFFFFF00CATEGORÍAS|r")
    
    -- Lista de profesiones
    local professions = {
        {key = "Tailoring", name = "Sastrería", icon = "Interface\\Icons\\Trade_Tailoring"},
        {key = "Leatherworking", name = "Peletería", icon = "Interface\\Icons\\Trade_LeatherWorking"},
        {key = "Fishing", name = "Pesca", icon = "Interface\\Icons\\Trade_Fishing"},
        {key = "Cooking", name = "Cocina", icon = "Interface\\Icons\\INV_Misc_Food_15"},
        {key = "Blacksmithing", name = "Herrería", icon = "Interface\\Icons\\Trade_BlackSmithing"},
        {key = "Mining", name = "Minería", icon = "Interface\\Icons\\Trade_Mining"},
        {key = "Herbalism", name = "Herboristería", icon = "Interface\\Icons\\Trade_Herbalism"},
        {key = "General", name = "General", icon = "Interface\\Icons\\INV_Misc_Bag_08"},
    }
    
    local buttons = {}
    local yOffset = -30
    
    for i, prof in ipairs(professions) do
        local btn = CreateFrame("Button", nil, sidePanel)
        btn:SetSize(140, 35)
        btn:SetPoint("TOP", 0, yOffset)
        
        -- Background del botón
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
        bg:SetAlpha(0)
        btn.bg = bg
        
        -- Icono
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", 8, 0)
        icon:SetTexture(prof.icon)
        
        -- Texto
        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        text:SetText(prof.name)
        btn.text = text
        
        btn.professionKey = prof.key
        table.insert(buttons, btn)
        
        yOffset = yOffset - 40
    end
    
    -- Separador
    yOffset = yOffset - 5
    local separator = sidePanel:CreateTexture(nil, "ARTWORK")
    separator:SetSize(130, 1)
    separator:SetPoint("TOP", 0, yOffset)
    separator:SetColorTexture(0.5, 0.5, 0.5, 0.8)
    
    yOffset = yOffset - 15
    
    -- Botones especiales
    local specialButtons = {
        {name = "Opciones", icon = "Interface\\Icons\\INV_Misc_Gear_01", content = "options"},
        {name = "Ignorados", icon = "Interface\\Icons\\Ability_Rogue_FeignDeath", content = "ignored"},
    }
    
    for i, special in ipairs(specialButtons) do
        local btn = CreateFrame("Button", nil, sidePanel)
        btn:SetSize(140, 35)
        btn:SetPoint("TOP", 0, yOffset)
        
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
        bg:SetAlpha(0)
        btn.bg = bg
        
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", 8, 0)
        icon:SetTexture(special.icon)
        
        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        text:SetText(special.name)
        btn.text = text
        
        btn.contentType = special.content
        table.insert(buttons, btn)
        
        yOffset = yOffset - 40
    end
    
    -- Área de contenido
    local contentArea = CreateFrame("Frame", nil, parent)
    contentArea:SetSize(520, 465)
    contentArea:SetPoint("TOPLEFT", sidePanel, "TOPRIGHT", 10, 0)
    contentArea:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    contentArea:SetBackdropColor(0, 0, 0, 0.3)
    contentArea:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    self.ContentArea = contentArea
    self.NavButtons = buttons
    
    -- Crear todos los contenidos
    self.Contents = {}
    for _, prof in ipairs(professions) do
        self.Contents[prof.key] = self:CreateProfessionContent(contentArea, prof.key)
    end
    self.Contents["options"] = self:CreateOptionsContent(contentArea)
    self.Contents["ignored"] = self:CreateIgnoredContent(contentArea)
    
    -- Función para seleccionar contenido
    local function SelectContent(key)
        -- Ocultar todos los contenidos
        for k, content in pairs(self.Contents) do
            content:Hide()
        end
        
        -- Mostrar el seleccionado
        if self.Contents[key] then
            self.Contents[key]:Show()
        end
        
        -- Actualizar botones
        for _, btn in ipairs(buttons) do
            local isSelected = (btn.professionKey == key) or (btn.contentType == key)
            btn.bg:SetAlpha(isSelected and 0.3 or 0)
            if isSelected then
                btn.text:SetFontObject("GameFontHighlight")
            else
                btn.text:SetFontObject("GameFontNormal")
            end
        end
    end
    
    -- Asignar clicks
    for _, btn in ipairs(buttons) do
        btn:SetScript("OnClick", function(self)
            local key = self.professionKey or self.contentType
            SelectContent(key)
        end)
        
        btn:SetScript("OnEnter", function(self)
            if not ((self.professionKey and self.professionKey == self.selectedKey) or 
                    (self.contentType and self.contentType == self.selectedKey)) then
                self.bg:SetAlpha(0.15)
            end
        end)
        
        btn:SetScript("OnLeave", function(self)
            if not ((self.professionKey and self.professionKey == self.selectedKey) or 
                    (self.contentType and self.contentType == self.selectedKey)) then
                self.bg:SetAlpha(0)
            end
        end)
    end
    
    -- Seleccionar primera profesión por defecto
    SelectContent("Tailoring")
end

-- ===========================================
-- CONTENIDO POR PROFESIÓN
-- ===========================================

function SL.UI:CreateProfessionContent(parent, professionKey)
    local content = CreateFrame("Frame", nil, parent)
    content:SetAllPoints()
    content:Hide()
    
    local prof = SL.ItemDatabase[professionKey]
    if not prof then return content end
    
    -- Encabezado con icono y título
    local header = CreateFrame("Frame", nil, content)
    header:SetSize(500, 50)
    header:SetPoint("TOP", 0, -10)
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(40, 40)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture(prof.icon)
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText(prof.name)
    
    -- Botones de acción
    local btnY = -70
    
    local selectAllBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    selectAllBtn:SetSize(110, 25)
    selectAllBtn:SetPoint("TOPLEFT", 15, btnY)
    selectAllBtn:SetText("Marcar Todos")
    selectAllBtn:SetScript("OnClick", function()
        for itemID, item in pairs(prof.items) do
            item.enabled = true
        end
        self:RefreshProfessionContent(professionKey)
        SL:SaveConfig()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Todos marcados en " .. prof.name)
    end)
    
    local deselectAllBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    deselectAllBtn:SetSize(130, 25)
    deselectAllBtn:SetPoint("LEFT", selectAllBtn, "RIGHT", 5, 0)
    deselectAllBtn:SetText("Desmarcar Todos")
    deselectAllBtn:SetScript("OnClick", function()
        for itemID, item in pairs(prof.items) do
            item.enabled = false
        end
        self:RefreshProfessionContent(professionKey)
        SL:SaveConfig()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Todos desmarcados en " .. prof.name)
    end)
    
    local addItemBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    addItemBtn:SetSize(120, 25)
    addItemBtn:SetPoint("LEFT", deselectAllBtn, "RIGHT", 5, 0)
    addItemBtn:SetText("+ Añadir Item")
    addItemBtn:SetScript("OnClick", function()
        self:ShowAddItemDialog(professionKey)
    end)
    
    -- ScrollFrame para los items (MÁS GRANDE)
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(490, 350)
    scrollFrame:SetPoint("TOP", 0, -105)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(470, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    content.scrollChild = scrollChild
    content.professionKey = professionKey
    
    self:RefreshProfessionContent(professionKey)
    
    return content
end

function SL.UI:RefreshProfessionContent(professionKey)
    -- Buscar el content frame
    local content = self.Contents[professionKey]
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
        row:SetSize(460, 30)
        row:SetPoint("TOP", 0, yOffset)
        
        -- Background alternado
        if count % 2 == 0 then
            local bg = row:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        end
        
        -- Checkbox
        local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        cb:SetPoint("LEFT", 5, 0)
        cb:SetSize(26, 26)
        cb:SetChecked(item.enabled)
        cb:SetScript("OnClick", function(self)
            item.enabled = self:GetChecked()
            SL:SaveConfig()
        end)
        
        -- Icono del item
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        
        local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
        if itemTexture then
            icon:SetTexture(itemTexture)
        else
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        
        -- Nombre del item (con link si está disponible)
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        text:SetWidth(300)
        text:SetJustifyH("LEFT")
        
        if itemLink then
            text:SetText(itemLink)
        else
            text:SetText(item.name or ("|cFFFF0000ID: " .. itemID .. "|r"))
        end
        
        -- Botón eliminar (solo para items custom)
        if item.custom then
            local deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            deleteBtn:SetSize(70, 22)
            deleteBtn:SetPoint("RIGHT", -5, 0)
            deleteBtn:SetText("Eliminar")
            deleteBtn:SetScript("OnClick", function()
                SL:RemoveCustomItem(professionKey, itemID)
                self:RefreshProfessionContent(professionKey)
                SL:SaveConfig()
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Item eliminado: " .. (itemName or itemID))
            end)
        end
        
        yOffset = yOffset - 32
        count = count + 1
    end
    
    if count == 0 then
        local emptyText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        emptyText:SetPoint("TOP", 0, -100)
        emptyText:SetText("|cFFAAAAAA(No hay items configurados)|r")
        
        local hint = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        hint:SetPoint("TOP", 0, -130)
        hint:SetWidth(400)
        hint:SetText("|cFFAAAAAAUsa el botón '+ Añadir Item' para agregar items personalizados|r")
    end
    
    scrollChild:SetHeight(math.max(350, count * 32 + 10))
end

-- ===========================================
-- DIÁLOGO PARA AÑADIR ITEMS
-- ===========================================

function SL.UI:ShowAddItemDialog(professionKey)
    -- Si ya existe el diálogo, mostrarlo
    if self.AddItemDialog then
        self.AddItemDialog:Show()
        self.AddItemDialog.professionKey = professionKey
        self.AddItemDialog.editBoxID:SetText("")
        self.AddItemDialog.editBoxName:SetText("")
        self.AddItemDialog.editBoxID:SetFocus()
        return
    end
    
    -- Crear diálogo
    local dialog = CreateFrame("Frame", "SmartLootAddItemDialog", UIParent)
    dialog:SetSize(400, 250)
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
    title:SetPoint("TOP", 0, -20)
    title:SetText("|cFF00FF00Añadir Item Personalizado|r")
    
    -- Instrucciones
    local instructions = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    instructions:SetPoint("TOP", 0, -55)
    instructions:SetWidth(370)
    instructions:SetJustifyH("LEFT")
    instructions:SetText("1. Activa 'Mostrar ID en tooltips' en Opciones\n2. Pasa el ratón sobre el item que quieres añadir\n3. Copia el ID que aparece y pégalo aquí")
    
    -- Label Item ID
    local labelID = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelID:SetPoint("TOPLEFT", 30, -115)
    labelID:SetText("Item ID:")
    
    -- EditBox para Item ID
    local editBoxID = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    editBoxID:SetSize(120, 35)
    editBoxID:SetPoint("TOPLEFT", 110, -110)
    editBoxID:SetAutoFocus(false)
    editBoxID:SetMaxLetters(10)
    editBoxID:SetNumeric(true)
    editBoxID:SetScript("OnEnterPressed", function(self)
        dialog.editBoxName:SetFocus()
    end)
    dialog.editBoxID = editBoxID
    
    -- Label Nombre (opcional)
    local labelName = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelName:SetPoint("TOPLEFT", 30, -155)
    labelName:SetText("Nombre (opcional):")
    
    -- EditBox para Nombre
    local editBoxName = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    editBoxName:SetSize(250, 35)
    editBoxName:SetPoint("TOPLEFT", 30, -175)
    editBoxName:SetAutoFocus(false)
    editBoxName:SetMaxLetters(50)
    editBoxName:SetScript("OnEnterPressed", function()
        -- Ejecutar añadir cuando se presiona Enter
        dialog.addBtn:Click()
    end)
    dialog.editBoxName = editBoxName
    
    -- Botón Añadir
    local addBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    addBtn:SetSize(120, 35)
    addBtn:SetPoint("BOTTOMLEFT", 30, 20)
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
    dialog.addBtn = addBtn
    
    -- Botón Cancelar
    local cancelBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    cancelBtn:SetSize(120, 35)
    cancelBtn:SetPoint("BOTTOMRIGHT", -30, 20)
    cancelBtn:SetText("Cancelar")
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    -- Botón cerrar
    local closeBtn = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    
    -- Hacer foco en el primer campo
    editBoxID:SetFocus()
end

-- ===========================================
-- TAB DE OPCIONES GENERALES
-- ===========================================

function SL.UI:CreateOptionsContent(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetAllPoints()
    content:Hide()
    
    -- Título
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Opciones Generales")
    
    -- ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(490, 380)
    scrollFrame:SetPoint("TOP", 0, -60)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(470, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    local yOffset = -10
    
    local function CreateCheckbox(label, description, configKey)
        local container = CreateFrame("Frame", nil, scrollChild)
        container:SetSize(460, 45)
        container:SetPoint("TOP", 0, yOffset)
        
        local cb = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 10, -5)
        cb:SetSize(26, 26)
        cb:SetChecked(SL.config[configKey])
        
        local text = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", cb, "RIGHT", 5, 8)
        text:SetText(label)
        
        if description then
            local desc = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            desc:SetPoint("TOPLEFT", cb, "RIGHT", 5, -8)
            desc:SetWidth(420)
            desc:SetJustifyH("LEFT")
            desc:SetTextColor(0.7, 0.7, 0.7)
            desc:SetText(description)
        end
        
        cb:SetScript("OnClick", function(self)
            SL.config[configKey] = self:GetChecked()
            SL:SaveConfig()
        end)
        
        yOffset = yOffset - 50
        return cb
    end
    
    local function CreateSectionHeader(text)
        local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("TOPLEFT", 10, yOffset)
        header:SetText("|cFFFFFF00" .. text .. "|r")
        yOffset = yOffset - 30
    end
    
    local function CreateSeparator()
        local line = scrollChild:CreateTexture(nil, "ARTWORK")
        line:SetSize(450, 1)
        line:SetPoint("TOP", 0, yOffset)
        line:SetColorTexture(0.5, 0.5, 0.5, 0.5)
        yOffset = yOffset - 15
    end
    
    -- Sección: Filtros por Calidad
    CreateSectionHeader("FILTROS POR CALIDAD")
    CreateCheckbox("Recetas", "Recoger todas las recetas automáticamente", "lootRecipes")
    CreateCheckbox("Items Verdes", "Recoger todos los items de calidad verde (poco común)", "lootGreenAny")
    CreateCheckbox("Items Azules (67-80)", "Recoger items azules de nivel 67 a 80", "lootBlue67to80")
    CreateCheckbox("Items Morados (67-80)", "Recoger items morados de nivel 67 a 80", "lootPurple67to80")
    
    CreateSeparator()
    
    -- Sección: Tipos Especiales
    CreateSectionHeader("TIPOS ESPECIALES")
    CreateCheckbox("Objetos de Misiones", "Recoger automáticamente items de misiones", "lootQuestItems")
    CreateCheckbox("Monedas", "Recoger cobre, plata y oro automáticamente", "lootMoney")
    CreateCheckbox("Ignorar Items Grises", "No recoger items de calidad gris (basura)", "ignoreGrey")
    
    CreateSeparator()
    
    -- Sección: Interfaz
    CreateSectionHeader("INTERFAZ Y NOTIFICACIONES")
    CreateCheckbox("Mostrar ID en Tooltips", "Muestra el ID de items al pasar el ratón (útil para añadir items)", "showItemID")
    CreateCheckbox("Mensajes en Chat", "Mostrar mensajes cuando se recoge un item", "showMessages")
    CreateCheckbox("Modo Debug", "Mostrar información detallada de depuración", "debugMode")
    
    CreateSeparator()
    yOffset = yOffset - 10
    
    -- Información adicional
    local info = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    info:SetPoint("TOP", 0, yOffset)
    info:SetWidth(450)
    info:SetJustifyH("LEFT")
    info:SetText("|cFFFFFF00Calidades en World of Warcraft:|r\n\n" ..
                 "|cFF9D9D9D0 - Pobre (Gris)|r\n" ..
                 "|cFFFFFFFF1 - Común (Blanco)|r\n" ..
                 "|cFF1EFF002 - Poco común (Verde)|r\n" ..
                 "|cFF0070DD3 - Raro (Azul)|r\n" ..
                 "|cFFA335EE4 - Épico (Morado)|r\n" ..
                 "|cFFFF80005 - Legendario (Naranja)|r")
    yOffset = yOffset - 140
    
    CreateSeparator()
    yOffset = yOffset - 10
    
    -- Botón Reset
    local resetBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    resetBtn:SetSize(200, 35)
    resetBtn:SetPoint("TOP", 0, yOffset)
    resetBtn:SetText("Resetear Toda la Configuración")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("SMARTLOOT_RESET_CONFIRM")
    end)
    
    yOffset = yOffset - 50
    
    scrollChild:SetHeight(math.abs(yOffset) + 20)
    
    return content
end

-- ===========================================
-- TAB DE ITEMS IGNORADOS
-- ===========================================

function SL.UI:CreateIgnoredContent(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetAllPoints()
    content:Hide()
    
    -- Título
    local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Items Ignorados")
    
    -- Descripción
    local description = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    description:SetPoint("TOP", 0, -55)
    description:SetWidth(480)
    description:SetJustifyH("LEFT")
    description:SetText("Los items en esta lista NUNCA serán recogidos, incluso si cumplen con otros filtros.\n" ..
                       "Útil para ignorar recetas molestas u objetos específicos que no quieres.")
    
    -- Caja de información
    local infoBox = CreateFrame("Frame", nil, content)
    infoBox:SetSize(480, 80)
    infoBox:SetPoint("TOP", 0, -105)
    infoBox:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    infoBox:SetBackdropColor(0.1, 0.1, 0.2, 0.8)
    infoBox:SetBackdropBorderColor(0.4, 0.4, 0.6, 1)
    
    local infoText = infoBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    infoText:SetPoint("CENTER")
    infoText:SetWidth(450)
    infoText:SetJustifyH("LEFT")
    infoText:SetText("|cFFFFFF00Cómo añadir items:|r\n" ..
                    "1. Activa 'Mostrar ID en tooltips' en Opciones\n" ..
                    "2. Pasa el ratón sobre el item que quieres ignorar\n" ..
                    "3. Usa el comando: |cFF00FF00/sl ignore <ID>|r")
    
    -- ScrollFrame para la lista
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(490, 240)
    scrollFrame:SetPoint("TOP", 0, -195)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(470, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    self.IgnoredScrollChild = scrollChild
    
    -- Botón refrescar
    local refreshBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    refreshBtn:SetSize(120, 30)
    refreshBtn:SetPoint("BOTTOM", 0, 15)
    refreshBtn:SetText("Refrescar Lista")
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
    
    -- Ordenar items ignorados
    local sortedIgnored = {}
    for itemID, _ in pairs(SL.IgnoredItems) do
        table.insert(sortedIgnored, itemID)
    end
    table.sort(sortedIgnored)
    
    for _, itemID in ipairs(sortedIgnored) do
        local itemName, itemLink = GetItemInfo(itemID)
        
        local row = CreateFrame("Frame", nil, self.IgnoredScrollChild)
        row:SetSize(460, 32)
        row:SetPoint("TOP", 0, yOffset)
        
        -- Background alternado
        if count % 2 == 0 then
            local bg = row:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        end
        
        -- Icono del item
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", 10, 0)
        
        if itemLink then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
            if itemTexture then
                icon:SetTexture(itemTexture)
            else
                icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
        else
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        
        -- Nombre del item
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        text:SetWidth(320)
        text:SetJustifyH("LEFT")
        
        if itemLink then
            text:SetText(itemLink)
        else
            text:SetText("|cFFFF6600ID: " .. itemID .. " |cFF999999(nombre desconocido)|r")
        end
        
        -- Botón eliminar
        local deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        deleteBtn:SetSize(80, 24)
        deleteBtn:SetPoint("RIGHT", -10, 0)
        deleteBtn:SetText("Desbloquear")
        deleteBtn:SetScript("OnClick", function()
            SL.IgnoredItems[itemID] = nil
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Item desbloqueado: " .. (itemName or ("ID: " .. itemID)))
            self:RefreshIgnoredList()
            SL:SaveConfig()
        end)
        
        yOffset = yOffset - 34
        count = count + 1
    end
    
    if count == 0 then
        local emptyIcon = self.IgnoredScrollChild:CreateTexture(nil, "ARTWORK")
        emptyIcon:SetSize(64, 64)
        emptyIcon:SetPoint("TOP", 0, -40)
        emptyIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        emptyIcon:SetAlpha(0.3)
        
        local emptyText = self.IgnoredScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        emptyText:SetPoint("TOP", 0, -110)
        emptyText:SetText("|cFFAAAAAA(No hay items ignorados)|r")
        
        local hint = self.IgnoredScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        hint:SetPoint("TOP", 0, -140)
        hint:SetWidth(400)
        hint:SetJustifyH("CENTER")
        hint:SetText("|cFFAAAAAAUsa |cFF00FF00/sl ignore <ID>|cFFAAAAAA para añadir items|r")
    end
    
    -- Ajustar tamaño del scroll child
    self.IgnoredScrollChild:SetHeight(math.max(240, count * 34 + 10))
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
            local status = SL.config.enabled and "|cFF00FF00Activado|r" or "|cFFFF0000Desactivado|r"
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r " .. status)
            SL.UI:UpdateStatus()
            if SL.UI.ToggleBtn then
                SL.UI.ToggleBtn:SetText(SL.config.enabled and "DESACTIVAR" or "ACTIVAR")
            end
            SL:SaveConfig()
        end
    end)
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("|cFF00FF00SmartLoot|r v" .. SL.version)
        GameTooltip:AddLine("Estado: " .. (SL.config.enabled and "|cFF00FF00● Activado|r" or "|cFFFF0000● Desactivado|r"), 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("|cFFFFFFFFClick izquierdo:|r Abrir/Cerrar menú", 1, 1, 1)
        GameTooltip:AddLine("|cFFFFFFFFClick derecho:|r ON/OFF rápido", 1, 1, 1)
        GameTooltip:AddLine("|cFFFFFFFFArrastrar:|r Mover botón", 0.7, 0.7, 0.7)
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
    text = "|cFFFF0000¿RESETEAR TODA LA CONFIGURACIÓN?|r\n\nEsto eliminará:\n• Todas las opciones configuradas\n• Items personalizados añadidos\n• Lista de items ignorados\n• Posiciones guardadas\n\n|cFFFFFF00Esta acción NO se puede deshacer.|r",
    button1 = "Sí, Resetear Todo",
    button2 = "Cancelar",
    OnAccept = function()
        SmartLoot:ResetConfig()
        if SmartLoot.UI and SmartLoot.UI.MainFrame then
            SmartLoot.UI.MainFrame:Hide()
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Configuración reseteada")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r Usa /reload para aplicar todos los cambios")
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