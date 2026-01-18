--[[
    ALLVESZZ UNIVERSAL SCRIPT V3 (Premium Edition)
    Status: 
    - WallCheck Melhorado (Ignora vidros/items transparentes)
    - Anti-Tremor (Sistema de Target Lock/Sticky Aim)
    - Seletores de Cores (FOV e ESP)
    - Toggle de FOV Visual
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Sistema de Cores
local ColorList = {
    {Name = "Red", Color = Color3.fromRGB(255, 50, 50)},
    {Name = "Purple", Color = Color3.fromRGB(170, 0, 255)},
    {Name = "Blue", Color = Color3.fromRGB(0, 170, 255)},
    {Name = "Green", Color = Color3.fromRGB(50, 255, 100)}
}

-- Configurações
local Settings = {
    Aimbot = true,
    ESP = true,
    TeamCheck = false,
    WallCheck = true, -- Ativado por padrão como pedido
    AliveCheck = true,
    ShowFOV = true,
    FOVSize = 100,
    TargetPart = "Head",
    -- Índices das cores (1=Red, 2=Purple, etc)
    FOVColorIndex = 2, -- Roxo padrão
    ESPColorIndex = 1  -- Vermelho padrão
}

-- Variáveis de Controle
local LockedTarget = nil -- Para evitar tremor (Lock Aim)
local CurrentTargetPart = nil

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Thickness = 1.5
FOVCircle.Color = ColorList[Settings.FOVColorIndex].Color
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVSize

--------------------------------------------------------------------
-- GUI / INTERFACE
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AllveszzPremiumV3"
ScreenGui.Parent = game.CoreGui

local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    DarkContrast = Color3.fromRGB(25, 25, 25),
    Purple = Color3.fromRGB(170, 0, 255),
    Red = Color3.fromRGB(255, 50, 50),
    Text = Color3.fromRGB(240, 240, 240)
}

local function AddGradient(instance)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Theme.Purple),
        ColorSequenceKeypoint.new(1.00, Theme.Red)
    }
    gradient.Rotation = 45
    gradient.Parent = instance
    return gradient
end

-- Botão Flutuante
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "ToggleIcon"
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Theme.DarkContrast
OpenBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Text = "A"
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextColor3 = Theme.Text
OpenBtn.TextSize = 28
OpenBtn.AutoButtonColor = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local btnStroke = Instance.new("UIStroke", OpenBtn)
btnStroke.Thickness = 2
AddGradient(btnStroke)

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.Size = UDim2.new(0, 320, 0, 480) -- Aumentado para caber opções
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
AddGradient(MainStroke)

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.BackgroundColor3 = Theme.DarkContrast
Header.Size = UDim2.new(1, 0, 0, 50)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
local TitleText = Instance.new("TextLabel")
TitleText.Parent = Header
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Font = Enum.Font.GothamBlack
TitleText.Text = "ALLVESZZ // V3"
TitleText.TextColor3 = Theme.Text
TitleText.TextSize = 16
AddGradient(TitleText)

-- Sistema de Arraste
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
Header.InputEnded:Connect(function(input) dragging = false end)

-- Container Scrollável
local Container = Instance.new("ScrollingFrame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, 60)
Container.Size = UDim2.new(1, 0, 1, -70)
Container.ScrollBarThickness = 2
Container.CanvasSize = UDim2.new(0, 0, 1.4, 0)
local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- UI Helpers
local function CreateToggle(text, defaultVal, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = Container
    ToggleBtn.BackgroundColor3 = Theme.DarkContrast
    ToggleBtn.Size = UDim2.new(0, 280, 0, 40)
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleBtn
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 14
    
    local Status = Instance.new("Frame")
    Status.Parent = ToggleBtn
    Status.Position = UDim2.new(0.85, 0, 0.5, -8)
    Status.Size = UDim2.new(0, 16, 0, 16)
    Status.BackgroundColor3 = defaultVal and Theme.Purple or Color3.fromRGB(60,60,60)
    Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 4)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        local isEnabled = (Status.BackgroundColor3 == Theme.Purple)
        local newState = not isEnabled
        Status.BackgroundColor3 = newState and Theme.Purple or Color3.fromRGB(60,60,60)
        callback(newState)
    end)
end

local function CreateColorButton(text, colorIndexKey, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Container
    Btn.BackgroundColor3 = Theme.DarkContrast
    Btn.Size = UDim2.new(0, 280, 0, 40)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Parent = Btn
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 14

    local ColorDisplay = Instance.new("TextLabel")
    ColorDisplay.Parent = Btn
    ColorDisplay.Position = UDim2.new(0.5, 0, 0, 0)
    ColorDisplay.Size = UDim2.new(0.45, 0, 1, 0)
    ColorDisplay.Font = Enum.Font.GothamBold
    ColorDisplay.Text = ColorList[Settings[colorIndexKey]].Name
    ColorDisplay.TextColor3 = ColorList[Settings[colorIndexKey]].Color
    ColorDisplay.TextXAlignment = Enum.TextXAlignment.Right
    ColorDisplay.BackgroundTransparency = 1
    ColorDisplay.TextSize = 14

    Btn.MouseButton1Click:Connect(function()
        Settings[colorIndexKey] = Settings[colorIndexKey] + 1
        if Settings[colorIndexKey] > #ColorList then Settings[colorIndexKey] = 1 end
        
        local newColorData = ColorList[Settings[colorIndexKey]]
        ColorDisplay.Text = newColorData.Name
        ColorDisplay.TextColor3 = newColorData.Color
        callback(newColorData.Color)
    end)
end

local function CreateFOVInput()
    local BoxFrame = Instance.new("Frame")
    BoxFrame.Parent = Container
    BoxFrame.BackgroundColor3 = Theme.DarkContrast
    BoxFrame.Size = UDim2.new(0, 280, 0, 40)
    Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = BoxFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Font = Enum.Font.GothamBold
    Label.Text = "FOV Radius"
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 14
    
    local Input = Instance.new("TextBox")
    Input.Parent = BoxFrame
    Input.BackgroundTransparency = 1
    Input.Position = UDim2.new(0.6, 0, 0, 0)
    Input.Size = UDim2.new(0.35, 0, 1, 0)
    Input.Font = Enum.Font.GothamBold
    Input.Text = tostring(Settings.FOVSize)
    Input.TextColor3 = Theme.Red
    Input.TextSize = 14
    
    Input.FocusLost:Connect(function()
        local num = tonumber(Input.Text)
        if num then
            Settings.FOVSize = num
            FOVCircle.Radius = num
        end
    end)
end

-- --- CRIANDO OS BOTÕES ---
CreateToggle("AIMBOT", Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggle("WALL CHECK (Melhorado)", Settings.WallCheck, function(v) Settings.WallCheck = v end)
CreateToggle("SHOW FOV CIRCLE", Settings.ShowFOV, function(v) 
    Settings.ShowFOV = v 
    FOVCircle.Visible = v
end)
CreateFOVInput()
CreateColorButton("FOV COLOR", "FOVColorIndex", function(c) FOVCircle.Color = c end)
CreateColorButton("ESP COLOR", "ESPColorIndex", function(c) end) -- Atualiza no loop do ESP
CreateToggle("ESP NAMES", Settings.ESP, function(v) Settings.ESP = v end)
CreateToggle("TEAM CHECK", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
CreateToggle("ALIVE CHECK", Settings.AliveCheck, function(v) Settings.AliveCheck = v end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--------------------------------------------------------------------
-- LÓGICA DO SCRIPT
--------------------------------------------------------------------

-- Wall Check Inteligente
-- Verifica se a parede é transparente ou se é o próprio alvo
local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    
    local result = Workspace:Raycast(origin, direction, params)
    
    if result then
        -- Se bater no alvo ou descendente do alvo, é visível
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        
        -- Correção: Se bater em vidro ou algo transparente (ex: cercas vazadas), considera visível
        if result.Instance.Transparency > 0.3 or not result.Instance.CanCollide then
            return true
        end
        
        return false -- Tem parede sólida na frente
    end
    
    return true -- Nada na frente
end

local function GetTarget()
    -- Lógica Anti-Tremor (Target Lock)
    -- Se já temos um alvo, verificamos se ele ainda é válido antes de procurar outro
    if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChild("Humanoid") then
        local hum = LockedTarget.Parent.Humanoid
        local pos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
        local distToCenter = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
        
        -- Condições para MANTER o alvo atual:
        -- 1. Vivo
        -- 2. Dentro do FOV
        -- 3. Visível (WallCheck)
        -- 4. Na tela
        if (hum.Health > 0) and (distToCenter <= Settings.FOVSize) and onScreen and IsVisible(LockedTarget) then
            return LockedTarget
        end
    end

    -- Se o alvo antigo não serve mais, procura um novo (o mais próximo do centro)
    local closestDist = math.huge
    local target = nil
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.TargetPart) then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            
            if Settings.AliveCheck and hum.Health <= 0 then continue end
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

            local part = char[Settings.TargetPart]
            local partPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local dist = (Vector2.new(partPos.X, partPos.Y) - Center).Magnitude
                
                if dist < Settings.FOVSize and dist < closestDist then
                    if IsVisible(part) then
                        closestDist = dist
                        target = part
                    end
                end
            end
        end
    end
    
    LockedTarget = target -- Atualiza o alvo travado
    return target
end

-- Loop de Aimbot
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Visible = Settings.ShowFOV -- Atualiza visibilidade
    
    if Settings.Aimbot then
        local target = GetTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    else
        LockedTarget = nil -- Reseta se desligar o aimbot
    end
end)

-- Loop de ESP
local ESP_Folder = Instance.new("Folder", game.CoreGui)
ESP_Folder.Name = "ESP_Folder_V3"

spawn(function()
    while wait(0.5) do
        ESP_Folder:ClearAllChildren()
        if not Settings.ESP then continue end

        local currentColor = ColorList[Settings.ESPColorIndex].Color

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if Settings.AliveCheck and player.Character.Humanoid.Health <= 0 then continue end
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

                local bb = Instance.new("BillboardGui")
                bb.Parent = ESP_Folder
                bb.Adornee = player.Character.Head
                bb.Size = UDim2.new(0, 100, 0, 50)
                bb.StudsOffset = Vector3.new(0, 2, 0)
                bb.AlwaysOnTop = true

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = bb
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.Text = player.Name
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14
                nameLabel.TextColor3 = currentColor -- Usa a cor selecionada
                nameLabel.TextStrokeTransparency = 0.5
            end
        end
    end
end)

print("Allveszz V3 Loaded - Anti-Jitter & Smart WallCheck")
