-- UI.lua - Interfaz profesional compatible con WoW 3.3.5a

SmartLoot = SmartLoot or {}
local SL = SmartLoot
SL.UI = {}

-- ===========================================
-- COLORES
-- ===========================================

local COLORS = {
    primary = {0, 0.8, 0.4},
    secondary = {0.2, 0.6, 1},
    success = {0, 0.8, 0.4},
    warning = {1, 0.7, 0},
    error = {1, 0.2, 0.2},
}

-- ===========================================
-- VENTANA PRINCIPAL
-- ===========================================

function SL.UI:CreateMainFrame()
    local frame = CreateFrame("Frame", "SmartLootMainFrame", UIParent)
    frame:SetSize(850, 600)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SL:SaveConfig()
    end)
    frame:Hide()
    
    self.MainFrame = frame
    
    -- Header
    self:CreateHeader(frame)
    
    -- Sidebar
    self:CreateSidebar(frame)
    
    -- Content Area
    self:CreateContentArea(frame)
    
    -- Footer
    self:CreateFooter(frame)
end

-- ===========================================
-- HEADER
-- ===========================================

function SL.UI:CreateHeader(parent)
    local header = CreateFrame("Frame", nil, parent)
    header:SetSize(parent:GetWidth() - 16, 60)
    header:SetPoint("TOP", 0, -8)
    
    -- Background
    local bg = header:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    bg:SetVertexColor(0.1, 0.1, 0.15, 0.9)
    
    -- Icon
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(40, 40)
    icon:SetPoint("LEFT", 15, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Bag_10")
    
    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 5)
    title:SetText("SmartLoot")
    title:SetTextColor(COLORS.primary[1], COLORS.primary[2], COLORS.primary[3])
    
    -- Version
    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("LEFT", icon, "RIGHT", 10, -12)
    version:SetText("v" .. SL.version)
    version:SetTextColor(0.7, 0.7, 0.7)
    
    -- Status
    local statusBg = CreateFrame("Frame", nil, header)
    statusBg:SetSize(150, 30)
    statusBg:SetPoint("RIGHT", -130, 0)
    statusBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    statusBg:SetBackdropColor(0.05, 0.05, 0.08, 0.9)
    
    local statusText = statusBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("CENTER")
    self.StatusText = statusText
    
    -- Toggle Button
    local toggleBtn = CreateFrame("Button", nil, header, "UIPanelButtonTemplate")
    toggleBtn:SetSize(80, 30)
    toggleBtn:SetPoint("RIGHT", -15, 0)
    toggleBtn:SetText("OFF")
    toggleBtn:SetScript("OnClick", function()
        SL.config.enabled = not SL.config.enabled
        self:UpdateStatus()
        SL:SaveConfig()
    end)
    self.ToggleBtn = toggleBtn
    
    -- Close Button
    local closeBtn = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -10)
    
    self:UpdateStatus()
end

function SL.UI:UpdateStatus()
    if not self.StatusText then return end
    
    local enabled = SL.config and SL.config.enabled or false
    self.StatusText:SetText(enabled and "● ACTIVADO" or "● DESACTIVADO")
    
    if enabled then
        self.StatusText:SetTextColor(COLORS.success[1], COLORS.success[2], COLORS.success[3])
    else
        self.StatusText:SetTextColor(COLORS.error[1], COLORS.error[2], COLORS.error[3])
    end
    
    if self.ToggleBtn then
        self.ToggleBtn:SetText(enabled and "ON" or "OFF")
    end
    
    if self.FloatingButton then
        self:UpdateFloatingButton()
    end
end

-- ===========================================
-- SIDEBAR
-- ===========================================

function SL.UI:CreateSidebar(parent)
    local sidebar = CreateFrame("Frame", nil, parent)
    sidebar:SetSize(180, parent:GetHeight() - 130)
    sidebar:SetPoint("TOPLEFT", 8, -70)
    sidebar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    sidebar:SetBackdropColor(0.1, 0.1, 0.15, 0.9)
    
    -- ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, sidebar, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(155, sidebar:GetHeight() - 20)
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(145, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    -- Categories
    local categories = {
        {type = "header", text = "PROFESIONES"},
        {key = "Tailoring", name = "Sastrería", icon = "Interface\\Icons\\Trade_Tailoring"},
        {key = "Leatherworking", name = "Peletería", icon = "Interface\\Icons\\Trade_LeatherWorking"},
        {key = "Fishing", name = "Pesca", icon = "Interface\\Icons\\Trade_Fishing"},
        {key = "Cooking", name = "Cocina", icon = "Interface\\Icons\\INV_Misc_Food_15"},
        {key = "Blacksmithing", name = "Herrería", icon = "Interface\\Icons\\Trade_BlackSmithing"},
        {key = "Mining", name = "Minería", icon = "Interface\\Icons\\Trade_Mining"},
        {key = "Herbalism", name = "Herboristería", icon = "Interface\\Icons\\Trade_Herbalism"},
        {key = "General", name = "General", icon = "Interface\\Icons\\INV_Misc_Bag_08"},
        {type = "separator"},
        {type = "header", text = "CONFIGURACIÓN"},
        {key = "options", name = "Opciones", icon = "Interface\\Icons\\INV_Misc_Gear_01"},
        {key = "ignored", name = "Ignorados", icon = "Interface\\Icons\\Ability_Rogue_FeignDeath"},
    }
    
    local buttons = {}
    local yOffset = -5
    
    for _, cat in ipairs(categories) do
        if cat.type == "header" then
            local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            header:SetPoint("TOPLEFT", 5, yOffset)
            header:SetText(cat.text)
            header:SetTextColor(0.7, 0.7, 0.7)
            yOffset = yOffset - 25
        elseif cat.type == "separator" then
            local line = scrollChild:CreateTexture(nil, "ARTWORK")
            line:SetSize(135, 1)
            line:SetPoint("TOP", 0, yOffset)
            line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            line:SetVertexColor(0.5, 0.5, 0.5, 0.8)
            yOffset = yOffset - 15
        else
            local btn = self:CreateNavButton(scrollChild, cat)
            btn:SetPoint("TOP", 0, yOffset)
            btn.categoryKey = cat.key
            table.insert(buttons, btn)
            yOffset = yOffset - 38
        end
    end
    
    scrollChild:SetHeight(math.abs(yOffset) + 10)
    
    self.NavButtons = buttons
    self.Sidebar = sidebar
end

function SL.UI:CreateNavButton(parent, category)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(135, 34)
    
    -- Background
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    bg:SetVertexColor(0, 0, 0, 0)
    btn.bg = bg
    
    -- Icon
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 8, 0)
    icon:SetTexture(category.icon)
    
    -- Text
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    text:SetText(category.name)
    text:SetWidth(90)
    text:SetJustifyH("LEFT")
    btn.text = text
    
    -- Hover
    btn:SetScript("OnEnter", function(self)
        if not self.selected then
            bg:SetVertexColor(0.15, 0.15, 0.2, 1)
        end
    end)
    
    btn:SetScript("OnLeave", function(self)
        if not self.selected then
            bg:SetVertexColor(0, 0, 0, 0)
        end
    end)
    
    return btn
end

function SL.UI:SelectCategory(key)
    -- Update buttons
    for _, btn in ipairs(self.NavButtons or {}) do
        local isSelected = btn.categoryKey == key
        btn.selected = isSelected
        
        if isSelected then
            btn.bg:SetVertexColor(0.1, 0.4, 0.2, 0.8)
            btn.text:SetTextColor(COLORS.primary[1], COLORS.primary[2], COLORS.primary[3])
        else
            btn.bg:SetVertexColor(0, 0, 0, 0)
            btn.text:SetTextColor(1, 1, 1)
        end
    end
    
    -- Show content
    if self.Contents then
        for k, content in pairs(self.Contents) do
            content:Hide()
        end
        if self.Contents[key] then
            self.Contents[key]:Show()
        end
    end
end

-- ===========================================
-- CONTENT AREA
-- ===========================================

function SL.UI:CreateContentArea(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetSize(parent:GetWidth() - 215, parent:GetHeight() - 130)
    content:SetPoint("TOPLEFT", 195, -70)
    content:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    content:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
    
    self.ContentArea = content
    self.Contents = {}
    
    -- Create all contents
    local professions = {"Tailoring", "Leatherworking", "Fishing", "Cooking", "Blacksmithing", "Mining", "Herbalism", "General"}
    for _, prof in ipairs(professions) do
        self.Contents[prof] = self:CreateProfessionContent(content, prof)
    end
    self.Contents["options"] = self:CreateOptionsContent(content)
    self.Contents["ignored"] = self:CreateIgnoredContent(content)
    
    -- Setup navigation
    for _, btn in ipairs(self.NavButtons or {}) do
        btn:SetScript("OnClick", function(self)
            SL.UI:SelectCategory(self.categoryKey)
        end)
    end
    
    -- Select first category
    self:SelectCategory("Tailoring")
end

-- ===========================================
-- PROFESSION CONTENT
-- ===========================================

function SL.UI:CreateProfessionContent(parent, profKey)
    local content = CreateFrame("Frame", nil, parent)
    content:SetAllPoints()
    content:Hide()
    
    local prof = SL.ItemDatabase[profKey]
    if not prof then return content end
    
    -- Header
    local header = CreateFrame("Frame", nil, content)
    header:SetSize(parent:GetWidth() - 40, 50)
    header:SetPoint("TOP", 0, -15)
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36, 36)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture(prof.icon)
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText(prof.name)
    title:SetTextColor(COLORS.primary[1], COLORS.primary[2], COLORS.primary[3])
    
    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetSize(parent:GetWidth() - 60, 2)
    line:SetPoint("BOTTOM", 0, 0)
    line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    line:SetVertexColor(COLORS.primary[1] * 0.5, COLORS.primary[2] * 0.5, COLORS.primary[3] * 0.5, 0.6)
    
    -- Action buttons
    local btnContainer = CreateFrame("Frame", nil, content)
    btnContainer:SetSize(parent:GetWidth() - 40, 35)
    btnContainer:SetPoint("TOP", 0, -75)
    
    local selectAllBtn = CreateFrame("Button", nil, btnContainer, "UIPanelButtonTemplate")
    selectAllBtn:SetSize(110, 28)
    selectAllBtn:SetPoint("LEFT", 0, 0)
    selectAllBtn:SetText("Marcar Todos")
    selectAllBtn:SetScript("OnClick", function()
        for itemID, item in pairs(prof.items) do
            item.enabled = true
        end
        self:RefreshProfessionContent(profKey)
        SL:SaveConfig()
    end)
    
    local deselectAllBtn = CreateFrame("Button", nil, btnContainer, "UIPanelButtonTemplate")
    deselectAllBtn:SetSize(130, 28)
    deselectAllBtn:SetPoint("LEFT", selectAllBtn, "RIGHT", 5, 0)
    deselectAllBtn:SetText("Desmarcar Todos")
    deselectAllBtn:SetScript("OnClick", function()
        for itemID, item in pairs(prof.items) do
            item.enabled = false
        end
        self:RefreshProfessionContent(profKey)
        SL:SaveConfig()
    end)
    
    local addBtn = CreateFrame("Button", nil, btnContainer, "UIPanelButtonTemplate")
    addBtn:SetSize(110, 28)
    addBtn:SetPoint("LEFT", deselectAllBtn, "RIGHT", 5, 0)
    addBtn:SetText("+ Añadir Item")
    addBtn:SetScript("OnClick", function()
        self:ShowAddItemDialog(profKey)
    end)
    
    -- ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(parent:GetWidth() - 50, parent:GetHeight() - 145)
    scrollFrame:SetPoint("TOP", 0, -120)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(parent:GetWidth() - 70, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    content.scrollChild = scrollChild
    content.professionKey = profKey
    
    self:RefreshProfessionContent(profKey)
    
    return content
end

function SL.UI:RefreshProfessionContent(profKey)
    local content = self.Contents[profKey]
    if not content or not content.scrollChild then return end
    
    local scrollChild = content.scrollChild
    
    -- Clear
    local children = {scrollChild:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end
    
    local prof = SL.ItemDatabase[profKey]
    if not prof then return end
    
    -- Sort items
    local sortedItems = {}
    for itemID, item in pairs(prof.items) do
        table.insert(sortedItems, {id = itemID, data = item})
    end
    table.sort(sortedItems, function(a, b)
        return (a.data.name or "") < (b.data.name or "")
    end)
    
    local yOffset = -10
    local count = 0
    
    for _, entry in ipairs(sortedItems) do
        local itemID = entry.id
        local item = entry.data
        
        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetSize(scrollChild:GetWidth(), 36)
        row:SetPoint("TOP", 0, yOffset)
        
        -- Background
        if count % 2 == 0 then
            local bg = row:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            bg:SetVertexColor(0.1, 0.1, 0.15, 0.4)
        end
        
        -- Checkbox
        local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        cb:SetPoint("LEFT", 10, 0)
        cb:SetSize(24, 24)
        cb:SetChecked(item.enabled)
        cb:SetScript("OnClick", function(self)
            item.enabled = self:GetChecked()
            SL:SaveConfig()
        end)
        
        -- Icon
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(28, 28)
        icon:SetPoint("LEFT", cb, "RIGHT", 10, 0)
        
        local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
        if itemTexture then
            icon:SetTexture(itemTexture)
        else
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        
        -- Name
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
        text:SetWidth(350)
        text:SetJustifyH("LEFT")
        if itemLink then
            text:SetText(itemLink)
        else
            text:SetText(item.name or ("|cFFFF0000ID: " .. itemID .. "|r"))
        end
        
        -- Delete button for custom items
        if item.custom then
            local deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            deleteBtn:SetSize(70, 24)
            deleteBtn:SetPoint("RIGHT", -10, 0)
            deleteBtn:SetText("Eliminar")
            deleteBtn:SetScript("OnClick", function()
                SL:RemoveCustomItem(profKey, itemID)
                self:RefreshProfessionContent(profKey)
                SL:SaveConfig()
            end)
        end
        
        yOffset = yOffset - 38
        count = count + 1
    end
    
    if count == 0 then
        local emptyText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        emptyText:SetPoint("CENTER", 0, -50)
        emptyText:SetText("|cFF888888No hay items configurados|r")
    end
    
    scrollChild:SetHeight(math.max(350, count * 38 + 20))
end

-- ===========================================
-- ADD ITEM DIALOG (continúa en siguiente parte...)
-- ===========================================

function SL.UI:ShowAddItemDialog(profKey)
    if self.AddItemDialog then
        self.AddItemDialog:Show()
        self.AddItemDialog.professionKey = profKey
        self.AddItemDialog.editBoxID:SetText("")
        self.AddItemDialog.editBoxName:SetText("")
        self.AddItemDialog.editBoxID:SetFocus()
        return
    end
    
    local dialog = CreateFrame("Frame", "SmartLootAddItemDialog", UIParent)
    dialog:SetSize(420, 260)
    dialog:SetPoint("CENTER")
    dialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    dialog:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:SetFrameStrata("DIALOG")
    dialog.professionKey = profKey
    
    self.AddItemDialog = dialog
    
    -- Title
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("|cFF00FF00Añadir Item Personalizado|r")
    
    -- Instructions
    local instructions = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    instructions:SetPoint("TOP", 0, -55)
    instructions:SetWidth(380)
    instructions:SetJustifyH("LEFT")
    instructions:SetText("1. Activa 'Mostrar ID en tooltips' en Opciones\n2. Pasa el ratón sobre el item\n3. Copia el ID y pégalo aquí")
    
    -- Item ID input
    local labelID = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelID:SetPoint("TOPLEFT", 30, -120)
    labelID:SetText("Item ID:")
    
    local editBoxID = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    editBoxID:SetSize(120, 35)
    editBoxID:SetPoint("LEFT", labelID, "RIGHT", 10, 0)
    editBoxID:SetAutoFocus(false)
    editBoxID:SetMaxLetters(10)
    editBoxID:SetNumeric(true)
    dialog.editBoxID = editBoxID
    
    -- Item Name input
    local labelName = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelName:SetPoint("TOPLEFT", 30, -160)
    labelName:SetText("Nombre (opcional):")
    
    local editBoxName = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    editBoxName:SetSize(250, 35)
    editBoxName:SetPoint("TOPLEFT", 30, -180)
    editBoxName:SetAutoFocus(false)
    editBoxName:SetMaxLetters(50)
    dialog.editBoxName = editBoxName
    
    -- Buttons
    local addBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    addBtn:SetSize(110, 32)
    addBtn:SetPoint("BOTTOMLEFT", 30, 20)
    addBtn:SetText("Añadir")
    addBtn:SetScript("OnClick", function()
        local itemID = tonumber(editBoxID:GetText())
        local itemName = editBoxName:GetText()
        
        if not itemID then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r Ingresa un Item ID válido")
            return
        end
        
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
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SmartLoot]|r El item ya existe")
        end
    end)
    dialog.addBtn = addBtn
    
    local cancelBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    cancelBtn:SetSize(110, 32)
    cancelBtn:SetPoint("BOTTOMRIGHT", -30, 20)
    cancelBtn:SetText("Cancelar")
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    local closeBtn = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    
    editBoxID:SetFocus()
end

-- ===========================================
-- OPTIONS CONTENT
-- ===========================================

function SL.UI:CreateOptionsContent(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetAllPoints()
    content:Hide()
    
    -- Header
    local header = CreateFrame("Frame", nil, content)
    header:SetSize(parent:GetWidth() - 40, 50)
    header:SetPoint("TOP", 0, -15)
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36, 36)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("Opciones Generales")
    title:SetTextColor(COLORS.primary[1], COLORS.primary[2], COLORS.primary[3])
    
    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetSize(parent:GetWidth() - 60, 2)
    line:SetPoint("BOTTOM", 0, 0)
    line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    line:SetVertexColor(COLORS.primary[1] * 0.5, COLORS.primary[2] * 0.5, COLORS.primary[3] * 0.5, 0.6)
    
    -- ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(parent:GetWidth() - 50, parent:GetHeight() - 90)
    scrollFrame:SetPoint("TOP", 0, -75)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(parent:GetWidth() - 70, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    local yOffset = -10
    
    local function CreateCheckbox(label, description, configKey)
        local container = CreateFrame("Frame", nil, scrollChild)
        container:SetSize(scrollChild:GetWidth() - 20, 50)
        container:SetPoint("TOP", 0, yOffset)
        
        local cb = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
        cb:SetPoint("LEFT", 15, 5)
        cb:SetSize(26, 26)
        cb:SetChecked(SL.config[configKey])
        
        local text = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        text:SetPoint("LEFT", cb, "RIGHT", 10, 8)
        text:SetText(label)
        
        if description then
            local desc = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            desc:SetPoint("TOPLEFT", cb, "RIGHT", 10, -10)
            desc:SetWidth(scrollChild:GetWidth() - 80)
            desc:SetJustifyH("LEFT")
            desc:SetTextColor(0.7, 0.7, 0.7)
            desc:SetText(description)
        end
        
        cb:SetScript("OnClick", function(self)
            SL.config[configKey] = self:GetChecked()
            SL:SaveConfig()
        end)
        
        yOffset = yOffset - 55
        return cb
    end
    
    local function CreateSectionTitle(text)
        local title = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", 15, yOffset)
        title:SetText(text)
        title:SetTextColor(COLORS.primary[1], COLORS.primary[2], COLORS.primary[3])
        
        local line = scrollChild:CreateTexture(nil, "ARTWORK")
        line:SetSize(scrollChild:GetWidth() - 30, 1)
        line:SetPoint("TOPLEFT", 15, yOffset - 20)
        line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        line:SetVertexColor(COLORS.primary[1] * 0.5, COLORS.primary[2] * 0.5, COLORS.primary[3] * 0.5, 0.5)
        
        yOffset = yOffset - 35
    end
    
    -- Quality Filters
    CreateSectionTitle("FILTROS POR CALIDAD")
    CreateCheckbox("Recetas", "Recoger todas las recetas automáticamente", "lootRecipes")
    CreateCheckbox("Items Verdes", "Recoger todos los items de calidad verde", "lootGreenAny")
    CreateCheckbox("Items Azules (67-80)", "Recoger items azules entre nivel 67 y 80", "lootBlue67to80")
    CreateCheckbox("Items Morados (67-80)", "Recoger items morados entre nivel 67 y 80", "lootPurple67to80")
    
    yOffset = yOffset - 10
    
    -- Special Types
    CreateSectionTitle("TIPOS ESPECIALES")
    CreateCheckbox("Objetos de Misiones", "Recoger automáticamente items de misiones", "lootQuestItems")
    CreateCheckbox("Monedas", "Recoger cobre, plata y oro", "lootMoney")
    CreateCheckbox("Ignorar Items Grises", "No recoger items de calidad gris (basura)", "ignoreGrey")
    
    yOffset = yOffset - 10
    
    -- Interface
    CreateSectionTitle("INTERFAZ Y NOTIFICACIONES")
    CreateCheckbox("Mostrar ID en Tooltips", "Ver ID de items al pasar el ratón", "showItemID")
    CreateCheckbox("Mensajes en Chat", "Mostrar mensajes cuando se recoge un item", "showMessages")
    CreateCheckbox("Modo Debug", "Información detallada de depuración", "debugMode")
    
    yOffset = yOffset - 10
    
    -- Quality reference
    CreateSectionTitle("REFERENCIA DE CALIDADES")
    local qualityInfo = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    qualityInfo:SetPoint("TOPLEFT", 15, yOffset)
    qualityInfo:SetWidth(scrollChild:GetWidth() - 30)
    qualityInfo:SetJustifyH("LEFT")
    qualityInfo:SetText(
        "|cFF9D9D9D0 - Pobre (Gris)|r\n" ..
        "|cFFFFFFFF1 - Común (Blanco)|r\n" ..
        "|cFF1EFF002 - Poco común (Verde)|r\n" ..
        "|cFF0070DD3 - Raro (Azul)|r\n" ..
        "|cFFA335EE4 - Épico (Morado)|r\n" ..
        "|cFFFF80005 - Legendario (Naranja)|r"
    )
    yOffset = yOffset - 150
    
    -- Reset button
    local resetBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    resetBtn:SetSize(220, 35)
    resetBtn:SetPoint("TOP", 0, yOffset)
    resetBtn:SetText("Resetear Configuración")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("SMARTLOOT_RESET_CONFIRM")
    end)
    
    yOffset = yOffset - 50
    
    scrollChild:SetHeight(math.abs(yOffset) + 20)
    
    return content
end

-- ===========================================
-- IGNORED ITEMS CONTENT
-- ===========================================

function SL.UI:CreateIgnoredContent(parent)
    local content = CreateFrame("Frame", nil, parent)
    content:SetAllPoints()
    content:Hide()
    
    -- Header
    local header = CreateFrame("Frame", nil, content)
    header:SetSize(parent:GetWidth() - 40, 50)
    header:SetPoint("TOP", 0, -15)
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36, 36)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture("Interface\\Icons\\Ability_Rogue_FeignDeath")
    
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("Items Ignorados")
    title:SetTextColor(COLORS.primary[1], COLORS.primary[2], COLORS.primary[3])
    
    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetSize(parent:GetWidth() - 60, 2)
    line:SetPoint("BOTTOM", 0, 0)
    line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    line:SetVertexColor(COLORS.primary[1] * 0.5, COLORS.primary[2] * 0.5, COLORS.primary[3] * 0.5, 0.6)
    
    -- Info box
    local infoBox = CreateFrame("Frame", nil, content)
    infoBox:SetSize(parent:GetWidth() - 40, 85)
    infoBox:SetPoint("TOP", 0, -75)
    infoBox:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    infoBox:SetBackdropColor(0.1, 0.3, 0.5, 0.3)
    
    local infoIcon = infoBox:CreateTexture(nil, "ARTWORK")
    infoIcon:SetSize(40, 40)
    infoIcon:SetPoint("LEFT", 15, 0)
    infoIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    
    local infoText = infoBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    infoText:SetPoint("LEFT", infoIcon, "RIGHT", 15, 0)
    infoText:SetWidth(infoBox:GetWidth() - 80)
    infoText:SetJustifyH("LEFT")
    infoText:SetText(
        "|cFFFFFFFFCómo añadir items:|r\n" ..
        "1. Activa 'Mostrar ID en tooltips' en Opciones\n" ..
        "2. Pasa el ratón sobre el item\n" ..
        "3. Usa: |cFF00FF00/sl ignore <ID>|r"
    )
    
    -- ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(parent:GetWidth() - 50, parent:GetHeight() - 220)
    scrollFrame:SetPoint("TOP", 0, -170)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(parent:GetWidth() - 70, 1)
    scrollFrame:SetScrollChild(scrollChild)
    
    self.IgnoredScrollChild = scrollChild
    
    -- Refresh button
    local refreshBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    refreshBtn:SetSize(130, 32)
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
    
    local children = {self.IgnoredScrollChild:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end
    
    local sortedIgnored = {}
    for itemID, _ in pairs(SL.IgnoredItems) do
        table.insert(sortedIgnored, itemID)
    end
    table.sort(sortedIgnored)
    
    local yOffset = -10
    local count = 0
    
    for _, itemID in ipairs(sortedIgnored) do
        local itemName, itemLink = GetItemInfo(itemID)
        
        local row = CreateFrame("Frame", nil, self.IgnoredScrollChild)
        row:SetSize(self.IgnoredScrollChild:GetWidth(), 36)
        row:SetPoint("TOP", 0, yOffset)
        
        if count % 2 == 0 then
            local bg = row:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
            bg:SetVertexColor(0.1, 0.1, 0.15, 0.4)
        end
        
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(28, 28)
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
        
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
        text:SetWidth(350)
        text:SetJustifyH("LEFT")
        if itemLink then
            text:SetText(itemLink)
        else
            text:SetText("|cFFFF6600ID: " .. itemID .. " |cFF999999(desconocido)|r")
        end
        
        local deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        deleteBtn:SetSize(90, 24)
        deleteBtn:SetPoint("RIGHT", -10, 0)
        deleteBtn:SetText("Desbloquear")
        deleteBtn:SetScript("OnClick", function()
            SL.IgnoredItems[itemID] = nil
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Item desbloqueado: " .. (itemName or ("ID: " .. itemID)))
            self:RefreshIgnoredList()
            SL:SaveConfig()
        end)
        
        yOffset = yOffset - 38
        count = count + 1
    end
    
    if count == 0 then
        local emptyIcon = self.IgnoredScrollChild:CreateTexture(nil, "ARTWORK")
        emptyIcon:SetSize(64, 64)
        emptyIcon:SetPoint("TOP", 0, -60)
        emptyIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        emptyIcon:SetAlpha(0.3)
        
        local emptyText = self.IgnoredScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        emptyText:SetPoint("TOP", 0, -130)
        emptyText:SetTextColor(0.7, 0.7, 0.7, 0.6)
        emptyText:SetText("No hay items ignorados")
        
        local hint = self.IgnoredScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        hint:SetPoint("TOP", 0, -160)
        hint:SetWidth(400)
        hint:SetJustifyH("CENTER")
        hint:SetTextColor(0.7, 0.7, 0.7, 0.6)
        hint:SetText("Usa |cFF00FF00/sl ignore <ID>|r para añadir items")
    end
    
    self.IgnoredScrollChild:SetHeight(math.max(250, count * 38 + 20))
end

-- ===========================================
-- FOOTER
-- ===========================================

function SL.UI:CreateFooter(parent)
    local footer = CreateFrame("Frame", nil, parent)
    footer:SetSize(parent:GetWidth() - 16, 35)
    footer:SetPoint("BOTTOM", 0, 8)
    
    local bg = footer:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    bg:SetVertexColor(0.1, 0.1, 0.15, 0.9)
    
    local line = footer:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 10, 0)
    line:SetPoint("TOPRIGHT", -10, 0)
    line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    line:SetVertexColor(0.5, 0.5, 0.5, 0.6)
    
    local helpText = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    helpText:SetPoint("LEFT", 15, 0)
    helpText:SetTextColor(0.7, 0.7, 0.7)
    helpText:SetText("Usa |cFF00FF00/sl help|r para ver todos los comandos")
    
    local versionText = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    versionText:SetPoint("RIGHT", -15, 0)
    versionText:SetTextColor(0.7, 0.7, 0.7)
    versionText:SetText("SmartLoot v" .. SL.version .. " by LoD-heba")
end

-- ===========================================
-- FLOATING BUTTON
-- ===========================================

function SL.UI:CreateFloatingButton()
    local btn = CreateFrame("Button", "SmartLootFloatingButton", UIParent)
    btn:SetSize(38, 38)
    btn:SetPoint("CENTER", Minimap, "CENTER", 0, -80)
    btn:SetMovable(true)
    btn:EnableMouse(true)
    btn:RegisterForDrag("LeftButton")
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetFrameStrata("MEDIUM")
    
    -- Background
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    bg:SetVertexColor(0.05, 0.05, 0.08, 0.9)
    
    -- Icon
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Bag_10")
    
    -- Border
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(50, 50)
    border:SetPoint("CENTER")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    -- Status indicator
    local statusDot = btn:CreateTexture(nil, "OVERLAY")
    statusDot:SetSize(10, 10)
    statusDot:SetPoint("TOPRIGHT", -2, -2)
    statusDot:SetTexture("Interface\\TARGETINGFRAME\\UI-RaidTargetingIcons")
    self.FloatingStatusDot = statusDot
    
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
            SL.UI:UpdateStatus()
            SL:SaveConfig()
        end
    end)
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cFF00FF00SmartLoot|r", 1, 1, 1)
        GameTooltip:AddLine("v" .. SL.version, 0.7, 0.7, 0.7)
        GameTooltip:AddLine(" ")
        
        local statusColor = SL.config.enabled and "|cFF00FF00" or "|cFFFF0000"
        local statusText = SL.config.enabled and "ACTIVADO" or "DESACTIVADO"
        GameTooltip:AddDoubleLine("Estado:", statusColor .. statusText .. "|r", 1, 1, 1, 1, 1, 1)
        
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFFFFFClick Izquierdo:|r Abrir/Cerrar", 1, 1, 1)
        GameTooltip:AddLine("|cFFFFFFFFClick Derecho:|r ON/OFF", 1, 1, 1)
        GameTooltip:AddLine("|cFFFFFFFFArrastrar:|r Mover", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    self.FloatingButton = btn
    self:UpdateFloatingButton()
end

function SL.UI:UpdateFloatingButton()
    if not self.FloatingButton or not self.FloatingStatusDot then return end
    
    local enabled = SL.config and SL.config.enabled or false
    self.FloatingStatusDot:SetTexCoord(enabled and 0 or 0.25, enabled and 0.25 or 0.5, 0, 1)
end

-- ===========================================
-- POPUP CONFIRMATIONS
-- ===========================================

StaticPopupDialogs["SMARTLOOT_RESET_CONFIRM"] = {
    text = "|cFFFF0000¿RESETEAR CONFIGURACIÓN?|r\n\n" ..
           "Se eliminará:\n" ..
           "• Todas las opciones\n" ..
           "• Items personalizados\n" ..
           "• Lista de ignorados\n" ..
           "• Posiciones guardadas\n\n" ..
           "|cFFFFFF00Esta acción no se puede deshacer|r",
    button1 = "Sí, Resetear",
    button2 = "Cancelar",
    OnAccept = function()
        SmartLoot:ResetConfig()
        if SmartLoot.UI and SmartLoot.UI.MainFrame then
            SmartLoot.UI.MainFrame:Hide()
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Configuración reseteada")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[SmartLoot]|r Usa /reload para aplicar cambios")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- ===========================================
-- INITIALIZATION
-- ===========================================

function SL.UI:Initialize()
    self:CreateMainFrame()
    self:CreateFloatingButton()
    
    -- Restore positions after UI is created
    if SL.RestorePositions then
        SL:RestorePositions()
    end
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

-- Initialize UI on player login
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    SL.UI:Initialize()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SmartLoot]|r Interfaz cargada correctamente")
end)