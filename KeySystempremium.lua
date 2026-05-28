-- ==============================================================================
--         SISTEMA DE PROTEÇÃO EMBUTIDO LOWHIGH STORE - PREMIUM (LEVEL 3)
-- ==============================================================================

-- CÓDIGO FONTE DA API DO KEYAUTH (EMBUTIDO PARA EVITAR ERRO 404)
local HttpService = game:GetService("HttpService")
local KeyAuthClass = {}
KeyAuthClass.__index = KeyAuthClass

function KeyAuthClass.new(name, ownerid, secret, version)
    local self = setmetatable({}, KeyAuthClass)
    self.name = name
    self.ownerid = ownerid
    self.secret = secret
    self.version = version
    self.sessionid = nil
    self.initialized = false
    self.user_data = { subscriptions = { { level = "0" } } }
    return self
end

function KeyAuthClass:request(type, additional_args)
    local url = "https://keyauth.win/api/1.2/"
    local body = {
        ["type"] = type,
        ["name"] = self.name,
        ["ownerid"] = self.ownerid,
        ["init_version"] = self.version
    }
    if self.sessionid then body["sessionid"] = self.sessionid end
    if additional_args then
        for k, v in pairs(additional_args) do body[k] = v end
    end
    
    local success, response = pcall(function()
        return game:HttpPost(url, HttpService:JSONEncode(body), "application/json")
    end)
    
    if success then
        return HttpService:JSONDecode(response)
    end
    return nil
end

function KeyAuthClass:init()
    local res = self:request("init")
    if res and res.success then
        self.sessionid = res.sessionid
        self.initialized = true
    else
        game.Players.LocalPlayer:Kick("❌ LowHigh Store: Falha na resposta do servidor KeyAuth.")
    end
end

function KeyAuthClass:login()
    self:init()
end

function KeyAuthClass:key(key)
    if not self.initialized then self:init() end
    local res = self:request("key", {["key"] = key})
    if res and res.success then
        self.user_data = res.info
        return true, res.message
    end
    return false, res and res.message or "Erro de conexão"
end

-- =============================================
--                 INICIALIZAÇÃO DO BANCO
-- =============================================
local KeyAuthApp = KeyAuthClass.new(
    "Jeaneloy01's Application",
    "bg8cRvXsrd",
    "803735a5e270d0b55245276f24f541361b0065532fb94760c86688ac90ddb9dd", -- Sua Secret mantida
    "1.0"
)

-- Criação da Tela de Login para o Usuário digitar a Key
local CoreGui = game:GetService("CoreGui")
local guiName = "LowHigh_Login_UI"
pcall(function() if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end end)

local LoginGui = Instance.new("ScreenGui", CoreGui)
LoginGui.Name = guiName

local LoginFrame = Instance.new("Frame", LoginGui)
LoginFrame.Size = UDim2.new(0, 320, 0, 160)
LoginFrame.Position = UDim2.new(0.5, -160, 0.5, -80)
LoginFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", LoginFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", LoginFrame)
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", LoginFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Low High Store - Insira sua Key"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

local TextBox = Instance.new("TextBox", LoginFrame)
TextBox.Size = UDim2.new(0, 260, 0, 35)
TextBox.Position = UDim2.new(0.5, -130, 0.4, -10)
TextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TextBox.Text = ""
TextBox.PlaceholderText = "Cole sua Key aqui..."
TextBox.TextColor3 = Color3.fromRGB(220, 220, 220)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 12
Instance.new("UICorner", TextBox)

local Btn = Instance.new("TextButton", LoginFrame)
Btn.Size = UDim2.new(0, 120, 0, 35)
Btn.Position = UDim2.new(0.5, -60, 0.75, -5)
Btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Btn.Text = "Verificar"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 12
Instance.new("UICorner", Btn)

Btn.MouseButton1Click:Connect(function()
    Btn.Text = "Verificando..."
    local keyInput = TextBox.Text
    local status, msg = KeyAuthApp:key(keyInput)
    
    if status then
        -- BLOQUEIO EXCLUSIVO: Só passa se a Key for Level 3 (Premium)
        if KeyAuthApp.user_data.subscriptions[1].level == "3" then
            LoginGui:Destroy()
            print("Acesso TOTAL Liberado! Carregando GUI Nativa do LowHigh PREMIUM...")
            carregarScriptPremium()
        else
            game.Players.LocalPlayer:Kick("❌ LowHigh Store: Acesso NEGADO. Esta key não é do nível PREMIUM!")
        end
    else
        Btn.Text = "Key Inválida!"
        wait(1.5)
        Btn.Text = "Verificar"
    end
end)

-- ==============================================================================
--         FUNÇÃO PRINCIPAL DO SEU SCRIPT (SÓ ABRE SE A KEY FOR CORRETA)
-- ==============================================================================
function carregarScriptPremium()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Stats = game:GetService("Stats")
    local ContentProvider = game:GetService("ContentProvider") 
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    local isMobile = UserInputService.TouchEnabled

    -- Pré-carregamento das imagens
    local ImageURIs = {
        "rbxthumb://type=Asset&id=125256544092304&w=150&h=150", 
        "rbxthumb://type=Asset&id=128137609286733&w=150&h=150", 
        "rbxthumb://type=Asset&id=90674527474660&w=150&h=150",  
        "rbxthumb://type=Asset&id=70777727722441&w=150&h=150"   
    }
    pcall(function() ContentProvider:PreloadAsync(ImageURIs) end)

    _G.AimbotEnabled = false
    _G.SilentAimEnabled = false
    _G.AimbotType = "Aimbot Legit"
    _G.SilentAimType = "Silent Legit"
    _G.TeamCheck = false 
    _G.WallCheck = false
    _G.Smoothness = 1 
    _G.MaxDistance = 3000 
    _G.PredictionEnabled = true 
    _G.BulletSpeed = 2500 
    _G.BulletDrop = 0 
    _G.ShowFOV = false
    _G.FOV = 100
    _G.CurrentPing = 0.1

    _G.HitboxEnabled = false; _G.HitboxSize = 5; _G.HitboxTeamCheck = false; _G.HitboxColor = Color3.fromRGB(255, 0, 0) 
    _G.MagnetKill = false; _G.MagnetTeamCheck = false; _G.MagnetFOVEnabled = false; _G.MagnetFOV = 100; _G.MagnetMaxDistance = 500
    _G.ESP_Box = false; _G.ESP_BoxType = "Box Corner"; _G.ESP_FillBox = false; _G.ESP_HealthBar = false; _G.ESP_HealthType = "Top" 
    _G.ESP_Tracers = false; _G.ESP_LineType = "Bottom"; _G.ESP_Name = false; _G.ESP_Distance = false; _G.ESP_TeamCheck = false
    _G.ESP_Skeleton = false; _G.ESP_Thickness = 8; _G.ESP_MaxDistance = 3000 

    local ESP_Table = {}
    local CachedTarget, CachedAimbotPos, CachedSilentPos, CachedSilentPart, ActiveSlider = nil, nil, nil, nil, nil

    local guiNameUI = "LowHigh_Admin_UI"
    pcall(function()
        if CoreGui:FindFirstChild(guiNameUI) then CoreGui[guiNameUI]:Destroy() end
    end)

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = guiNameUI
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true 

    local Theme = {Bg = Color3.fromRGB(15, 15, 15), Sidebar = Color3.fromRGB(10, 10, 10), Accent = Color3.fromRGB(255, 0, 0), Text = Color3.fromRGB(220, 220, 220), DarkText = Color3.fromRGB(150, 150, 150), ToggleOff = Color3.fromRGB(25, 25, 25)}

    local OpenButton = Instance.new("TextButton", ScreenGui)
    OpenButton.Size = UDim2.new(0, 45, 0, 45); OpenButton.Position = UDim2.new(0.05, 0, 0.05, 0); OpenButton.BackgroundColor3 = Theme.Bg; OpenButton.Text = "LH"; OpenButton.TextColor3 = Theme.Accent; OpenButton.Font = Enum.Font.GothamBold; OpenButton.Visible = isMobile; OpenButton.Active = true; OpenButton.Draggable = true; Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", OpenButton).Color = Theme.Accent

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 550, 0, 350); MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175); MainFrame.BackgroundColor3 = Theme.Bg; MainFrame.Active = true; MainFrame.Draggable = true; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8); MainFrame.Visible = not isMobile

    local CloseButton = Instance.new("TextButton", MainFrame)
    CloseButton.Size = UDim2.new(0, 30, 0, 30); CloseButton.Position = UDim2.new(1, -30, 0, 0); CloseButton.BackgroundTransparency = 1; CloseButton.Text = "X"; CloseButton.TextColor3 = Theme.DarkText; CloseButton.Font = Enum.Font.GothamBold; CloseButton.TextSize = 14; CloseButton.ZIndex = 10

    CloseButton.MouseButton1Click:Connect(function() MainFrame.Visible = false; if isMobile then OpenButton.Visible = true end end)
    OpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenButton.Visible = false end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
            if isMobile then OpenButton.Visible = not MainFrame.Visible end
        end
    end)

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 60, 1, 0); Sidebar.BackgroundColor3 = Theme.Sidebar; Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
    
    local MyLogo = Instance.new("ImageLabel", Sidebar)
    MyLogo.Size = UDim2.new(0, 60, 0, 60); MyLogo.Position = UDim2.new(0.5, -30, 0, 8); MyLogo.Image = "rbxthumb://type=Asset&id=125256544092304&w=150&h=150"; MyLogo.BackgroundTransparency = 1; MyLogo.ScaleType = Enum.ScaleType.Stretch; Instance.new("UICorner", MyLogo)

    local TabsContainer = Instance.new("Frame", Sidebar)
    TabsContainer.Size = UDim2.new(1, 0, 1, -85); TabsContainer.Position = UDim2.new(0, 0, 0, 85); TabsContainer.BackgroundTransparency = 1
    local TabsLayout = Instance.new("UIListLayout", TabsContainer); TabsLayout.FillDirection = Enum.FillDirection.Vertical; TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabsLayout.Padding = UDim.new(0, 20)

    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, -70, 0, 60); Header.Position = UDim2.new(0, 70, 0, 0); Header.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", Header)
    Title.Position = UDim2.new(0, 10, 0, 12); Title.Size = UDim2.new(0, 200, 0, 20); Title.Text = "Low High Premium"; Title.TextColor3 = Theme.Accent; Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1

    local SubTitle = Instance.new("TextLabel", Header)
    SubTitle.Position = UDim2.new(0, 10, 0, 32); SubTitle.Size = UDim2.new(0, 200, 0, 15); SubTitle.Text = "improve your aim in game"; SubTitle.TextColor3 = Color3.fromRGB(255, 255, 255); SubTitle.Font = Enum.Font.Gotham; SubTitle.TextSize = 11; SubTitle.TextXAlignment = Enum.TextXAlignment.Left; SubTitle.BackgroundTransparency = 1

    local StatusLabel = Instance.new("TextLabel", Header)
    StatusLabel.Position = UDim2.new(1, -165, 0, 32); StatusLabel.Size = UDim2.new(0, 150, 0, 15); StatusLabel.Text = "PREMIUM VITALÍCIO"; StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255); StatusLabel.Font = Enum.Font.Gotham; StatusLabel.TextSize = 11; StatusLabel.TextXAlignment = Enum.TextXAlignment.Right; StatusLabel.BackgroundTransparency = 1

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Size = UDim2.new(1, -80, 1, -70); PageContainer.Position = UDim2.new(0, 70, 0, 60); PageContainer.BackgroundTransparency = 1

    local Pages, TabData = {}, {}

    local function CreateTab(Name, ImageID, TamanhoX, TamanhoY)
        local TabWrapper = Instance.new("Frame", TabsContainer); TabWrapper.Size = UDim2.new(1, 0, 0, 42); TabWrapper.BackgroundTransparency = 1
        local HitboxBtn = Instance.new("TextButton", TabWrapper); HitboxBtn.Size = UDim2.new(1, 0, 1, 0); HitboxBtn.BackgroundTransparency = 1; HitboxBtn.Text = ""; HitboxBtn.ZIndex = 5
        local TabIcon = Instance.new("ImageLabel", TabWrapper); TabIcon.Size = UDim2.new(0, TamanhoX, 0, TamanhoY); TabIcon.Position = UDim2.new(0.5, -TamanhoX/2, 0.5, -TamanhoY/2); TabIcon.BackgroundTransparency = 1; TabIcon.Image = "rbxthumb://type=Asset&id=" .. tostring(ImageID) .. "&w=150&h=150"; TabIcon.ScaleType = Enum.ScaleType.Stretch; TabIcon.ImageColor3 = Theme.DarkText
        local TabIndicator = Instance.new("Frame", TabWrapper); TabIndicator.Size = UDim2.new(0, 3, 0.8, 0); TabIndicator.Position = UDim2.new(0, 0, 0.1, 0); TabIndicator.BackgroundColor3 = Theme.Accent; TabIndicator.Visible = false

        local Page = Instance.new("Frame", PageContainer); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false
        local LeftCol = Instance.new("ScrollingFrame", Page); LeftCol.Size = UDim2.new(0.48, 0, 1, 0); LeftCol.BackgroundTransparency = 1; LeftCol.ScrollBarThickness = 0
        local LeftLayout = Instance.new("UIListLayout", LeftCol); LeftLayout.Padding = UDim.new(0, 8)
        local RightCol = Instance.new("ScrollingFrame", Page); RightCol.Size = UDim2.new(0.48, 0, 1, 0); RightCol.Position = UDim2.new(0.52, 0, 0, 0); RightCol.BackgroundTransparency = 1; RightCol.ScrollBarThickness = 0
        local RightLayout = Instance.new("UIListLayout", RightCol); RightLayout.Padding = UDim.new(0, 8)

        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() LeftCol.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 120) end)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() RightCol.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 120) end)

        HitboxBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do p.Visible = false end
            for _, data in pairs(TabData) do data.Icon.ImageColor3 = Theme.DarkText; data.Indicator.Visible = false end
            Page.Visible = true; TabIcon.ImageColor3 = Color3.new(1, 1, 1); TabIndicator.Visible = true
        end)
        table.insert(Pages, Page); table.insert(TabData, {Icon = TabIcon, Indicator = TabIndicator})
        return LeftCol, RightCol
    end

    local function CreateSectionLabel(Parent, Text)
        local Lbl = Instance.new("TextLabel", Parent); Lbl.Size = UDim2.new(1, -15, 0, 25); Lbl.BackgroundTransparency = 1; Lbl.Text = Text; Lbl.TextColor3 = Color3.fromRGB(255, 255, 255); Lbl.Font = Enum.Font.GothamBold; Lbl.TextSize = 12; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function CreateToggle(Parent, Name, Default, Callback)
        local Frame = Instance.new("Frame", Parent); Frame.Size = UDim2.new(1, -15, 0, 22); Frame.BackgroundTransparency = 1
        local Label = Instance.new("TextLabel", Frame); Label.Text = Name; Label.Size = UDim2.new(1, -35, 1, 0); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Theme.Text; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left
        local Checkbox = Instance.new("TextButton", Frame); Checkbox.Size = UDim2.new(0, 16, 0, 16); Checkbox.Position = UDim2.new(1, -20, 0.5, -8); Checkbox.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff; Checkbox.Text = ""; Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)
        local CheckIcon = Instance.new("TextLabel", Checkbox); CheckIcon.Size = UDim2.new(1, 0, 1, 0); CheckIcon.BackgroundTransparency = 1; CheckIcon.Text = "✓"; CheckIcon.TextColor3 = Color3.new(1,1,1); CheckIcon.Font = Enum.Font.GothamBold; CheckIcon.TextSize = 12; CheckIcon.Visible = Default
        Checkbox.MouseButton1Click:Connect(function() Default = not Default; Checkbox.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff; CheckIcon.Visible = Default; Callback(Default) end)
    end

    local function CreateDropdown(Parent, Name, Options, DefaultIndex, Callback)
        local Frame = Instance.new("Frame", Parent); Frame.Size = UDim2.new(1, -15, 0, 40); Frame.BackgroundTransparency = 1; Frame.ClipsDescendants = true 
        local Label = Instance.new("TextLabel", Frame); Label.Text = Name; Label.Size = UDim2.new(1, 0, 0, 16); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Theme.Text; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left
        local MainBtn = Instance.new("TextButton", Frame); MainBtn.Size = UDim2.new(1, 0, 0, 20); MainBtn.Position = UDim2.new(0, 0, 0, 18); MainBtn.BackgroundColor3 = Theme.ToggleOff; MainBtn.Text = "  " .. Options[DefaultIndex]; MainBtn.TextColor3 = Theme.Text; MainBtn.Font = Enum.Font.Gotham; MainBtn.TextSize = 10; MainBtn.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", MainBtn)
        local Arrow = Instance.new("TextLabel", MainBtn); Arrow.Size = UDim2.new(0, 20, 1, 0); Arrow.Position = UDim2.new(1, -25, 0, 0); Arrow.BackgroundTransparency = 1; Arrow.Text = "▼"; Arrow.TextColor3 = Theme.DarkText; Arrow.Font = Enum.Font.GothamBold; Arrow.TextSize = 9
        local DropContainer = Instance.new("Frame", Frame); DropContainer.Size = UDim2.new(1, 0, 0, #Options * 20); DropContainer.Position = UDim2.new(0, 0, 0, 40); DropContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", DropContainer)
        local IsOpen = false
        MainBtn.MouseButton1Click:Connect(function() IsOpen = not IsOpen; Arrow.Text = IsOpen and "▲" or "▼"; Frame.Size = IsOpen and UDim2.new(1, -15, 0, 40 + (#Options * 20) + 2) or UDim2.new(1, -15, 0, 40) end)
        for i, opt in pairs(Options) do
            local OptBtn = Instance.new("TextButton", DropContainer); OptBtn.Size = UDim2.new(1, 0, 0, 20); OptBtn.BackgroundTransparency = 1; OptBtn.Text = "  " .. opt; OptBtn.TextColor3 = (i == DefaultIndex) and Theme.Accent or Theme.Text; OptBtn.Font = Enum.Font.Gotham; OptBtn.TextSize = 10; OptBtn.TextXAlignment = Enum.TextXAlignment.Left
            OptBtn.MouseButton1Click:Connect(function() IsOpen = false; Arrow.Text = "▼"; Frame.Size = UDim2.new(1, -15, 0, 40); MainBtn.Text = "  " .. opt; Callback(opt) end)
        end
    end

    local function CreateSlider(Parent, Name, Min, Max, Default, Callback, Suffix)
        Suffix = Suffix or ""; local Frame = Instance.new("Frame", Parent); Frame.Size = UDim2.new(1, -15, 0, 38); Frame.BackgroundTransparency = 1 
        local Label = Instance.new("TextLabel", Frame); Label.Text = Name; Label.Size = UDim2.new(0.7, 0, 0, 15); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Theme.Text; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left
        local ValInput = Instance.new("TextBox", Frame); ValInput.Text = tostring(Default) .. Suffix; ValInput.Size = UDim2.new(0.3, 0, 0, 15); ValInput.Position = UDim2.new(0.7, -5, 0, 0); ValInput.BackgroundTransparency = 1; ValInput.Font = Enum.Font.Gotham; ValInput.TextColor3 = Theme.DarkText; ValInput.TextSize = 11; ValInput.TextXAlignment = Enum.TextXAlignment.Right
        local SliderBg = Instance.new("Frame", Frame); SliderBg.Size = UDim2.new(1, 0, 0, 10); SliderBg.Position = UDim2.new(0, 0, 0, 22); SliderBg.BackgroundColor3 = Color3.fromRGB(8, 8, 8); Instance.new("UICorner", SliderBg)
        local Fill = Instance.new("Frame", SliderBg); Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", Fill)
        local Trigger = Instance.new("TextButton", SliderBg); Trigger.Size = UDim2.new(1, 0, 1, 0); Trigger.BackgroundTransparency = 1; Trigger.Text = ""
        Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ActiveSlider = {Bg = SliderBg, Fill = Fill, Min = Min, Max = Max, ValLabel = ValInput, Callback = Callback, Suffix = Suffix} end end)
    end

    local L1, R1 = CreateTab("AIM", 128137609286733, 14, 26)  
    local L2, R2 = CreateTab("ESP", 90674527474660, 28, 14)   
    local L3, R3 = CreateTab("MISC", 70777727722441, 22, 22)  

    -- Lógica de Abas
    CreateSectionLabel(L1, "Combat")
    CreateToggle(L1, "Enable Aimbot", false, function(v) _G.AimbotEnabled = v end)
    CreateToggle(L1, "Enable Silent Aim", false, function(v) _G.SilentAimEnabled = v end)
    CreateToggle(L1, "Aimbot Team Check", false, function(v) _G.TeamCheck = v end)
    CreateSlider(L1, "Max Distance", 1, 3000, 3000, function(v) _G.MaxDistance = v end)

    CreateSectionLabel(R1, "Aimbot Settings")
    CreateDropdown(R1, "Type Aimbot", {"Aimbot Legit", "Aimbot Rage"}, 1, function(val) _G.AimbotType = val end)
    CreateDropdown(R1, "Type Silent Aim", {"Silent Legit", "Silent Rage"}, 1, function(val) _G.SilentAimType = val end)
    CreateToggle(R1, "Enable FOV", false, function(v) _G.ShowFOV = v end)
    CreateSlider(R1, "FOV Radius", 0, 500, 100, function(v) _G.FOV = v end)

    CreateSectionLabel(L2, "ESP Elements")
    CreateToggle(L2, "Esp Box", false, function(v) _G.ESP_Box = v end)
    CreateToggle(L2, "Esp Vida", false, function(v) _G.ESP_HealthBar = v end)
    CreateToggle(L2, "Esp Name", false, function(v) _G.ESP_Name = v end)

    CreateSectionLabel(L3, "Hitbox Expander")
    CreateToggle(L3, "Enable Hitbox", false, function(v) _G.HitboxEnabled = v end)
    CreateSlider(L3, "Hitbox Size", 1, 100, 5, function(v) _G.HitboxSize = v end)

    TabData[1].Icon.ImageColor3 = Color3.new(1,1,1); TabData[1].Indicator.Visible = true; Pages[1].Visible = true

    -- Lógica Principal (Aimbot/Silent/ESP/Hitbox Loops)
    local FOVCircle = Drawing.new("Circle")
    RunService:BindToRenderStep("EliteHubMain", Enum.RenderPriority.Camera.Value + 1, function()
        FOVCircle.Visible = _G.ShowFOV; FOVCircle.Radius = _G.FOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Color = Color3.new(1,1,1); FOVCircle.Thickness = 1

        -- Loop de Hitbox Expandida
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
                local HitboxPart = v.Character:FindFirstChild("UpperTorso") or v.Character:FindFirstChild("Torso")
                if HitboxPart and _G.HitboxEnabled and v.Character.Humanoid.Health > 0 then
                    HitboxPart.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize); HitboxPart.Transparency = 0.7; HitboxPart.CanCollide = false
                elseif HitboxPart then
                    HitboxPart.Size = Vector3.new(2, 2, 1); HitboxPart.Transparency = 0; HitboxPart.CanCollide = true
                end
            end
        end

        -- Render do Aimbot Suave
        local function GetClosestPlayer()
            local Target, MaxDist = nil, _G.FOV
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    local AimPart = v.Character:FindFirstChild("Head") or v.Character:FindFirstChild("HumanoidRootPart")
                    local IsTeammate = (LocalPlayer.Team ~= nil and v.Team ~= nil and LocalPlayer.Team == v.Team)

                    if not AimPart or (_G.TeamCheck and IsTeammate) then continue end
                    local RealDist = (Camera.CFrame.Position - AimPart.Position).Magnitude
                    if RealDist > _G.MaxDistance then continue end
                    
                    local SP, OnS = Camera:WorldToScreenPoint(AimPart.Position)
                    if OnS then
                        local Dist = (Vector2.new(SP.X, SP.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if Dist < MaxDist then
                            Target = v; MaxDist = Dist
                        end
                    end
                end
            end
            return Target
        end

        if _G.AimbotEnabled then
            CachedTarget = GetClosestPlayer()
            if CachedTarget and CachedTarget.Character and CachedTarget.Character:FindFirstChild("Head") then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, CachedTarget.Character.Head.Position), _G.Smoothness)
            end
        end
    end)
    
    -- Silent Aim Hooks
    local OldIndex
    OldIndex = hookmetamethod(game, "__index", function(self, Index)
        if self == Mouse and _G.SilentAimEnabled and Index == "Hit" then
            if CachedTarget and CachedTarget.Character and CachedTarget.Character:FindFirstChild("Head") then
                return CachedTarget.Character.Head.CFrame
            end
        end
        return OldIndex(self, Index)
    end)
end
