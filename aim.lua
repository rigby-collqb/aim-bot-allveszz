--[[
    ALLVESZZ UNIVERSAL SCRIPT V2 (Premium Edition)
    Theme: Red/Purple/Black
    Credits: Allveszz
    Status: Aimbot Instantâneo (No-Smoothness)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Cores do Tema
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    DarkContrast = Color3.fromRGB(25, 25, 25),
    Purple = Color3.fromRGB(170, 0, 255),
    Red = Color3.fromRGB(255, 50, 50),
    Text = Color3.fromRGB(240, 240, 240)
}

-- Configurações
local Settings = {
    Aimbot = true,
    ESP = true,
    TeamCheck = false,
    WallCheck = false,
    AliveCheck = true,
    FOVSize = 100,
    TargetPart = "Head"
}

-- Variáveis de Controle
local Holding = false
local AimTarget = nil

-- FOV Circle (Usando Drawing API para performance)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 1.5
FOVCircle.Color = Theme.Purple
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVSize

--------------------------------------------------------------------
-- GUI / INTERFACE (DESIGN PROFISSIONAL)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AllveszzPremium"
ScreenGui.Parent = game.CoreGui

-- Efeito de Gradiente Global
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

-- 1. Botão Ícone (Flutuante)
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

-- 2. Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.Size = UDim2.new(0, 300, 0, 380)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Borda da Janela
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
AddGradient(MainStroke)

-- Título
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
TitleText.Text = "ALLVESZZ // UNIVERSAL"
TitleText.TextColor3 = Theme.Text
TitleText.TextSize = 16
AddGradient(TitleText) -- Texto gradiente

-- Arrastar Janela
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
Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Container dos Botões
local Container = Instance.new("ScrollingFrame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, 60)
Container.Size = UDim2.new(1, 0, 1, -70)
Container.ScrollBarThickness = 2
Container.CanvasSize = UDim2.new(0, 0, 1.2, 0) -- Espaço extra

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Função Criadora de Toggles Estilizados
local function CreateToggle(text, refName, defaultVal, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = Container
    ToggleBtn.BackgroundColor3 = Theme.DarkContrast
    ToggleBtn.Size = UDim2.new(0, 260, 0, 40)
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
        local newState = not (Status.BackgroundColor3 == Theme.Purple)
        Status.BackgroundColor3 = newState and Theme.Purple or Color3.fromRGB(60,60,60)
        
        -- Efeito visual extra no botão
        if newState then
            Status.BackgroundColor3 = Theme.Red
            wait(0.1)
            Status.BackgroundColor3 = Theme.Purple
        end
        callback(newState)
    end)
end

-- Slider de FOV (Input Box estilizado)
local function CreateFOVInput()
    local BoxFrame = Instance.new("Frame")
    BoxFrame.Parent = Container
    BoxFrame.BackgroundColor3 = Theme.DarkContrast
    BoxFrame.Size = UDim2.new(0, 260, 0, 40)
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

-- Criando os Controles
CreateToggle("AIMBOT ENABLED", "aim_tog", Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggle("ESP NAMES", "esp_tog", Settings.ESP, function(v) Settings.ESP = v end)
CreateToggle("TEAM CHECK", "team_tog", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
CreateToggle("WALL CHECK", "wall_tog", Settings.WallCheck, function(v) Settings.WallCheck = v end)
CreateToggle("ALIVE CHECK", "alive_tog", Settings.AliveCheck, function(v) Settings.AliveCheck = v end)
CreateFOVInput()

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--------------------------------------------------------------------
-- LÓGICA DO AIMBOT & ESP
--------------------------------------------------------------------

-- Função de ESP (BillboardGui)
local ESP_Folder = Instance.new("Folder", game.CoreGui)
ESP_Folder.Name = "Allveszz_ESP_Folder"

local function UpdateESP()
    -- Limpa ESPs antigos
    ESP_Folder:ClearAllChildren()
    
    if not Settings.ESP then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Checks
            if Settings.AliveCheck and player.Character.Humanoid.Health <= 0 then continue end
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

            local Head = player.Character.Head
            
            local bb = Instance.new("BillboardGui")
            bb.Parent = ESP_Folder
            bb.Adornee = Head
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
            -- Cor Vermelha para inimigos, branca padrão
            nameLabel.TextColor3 = (player.Team ~= LocalPlayer.Team) and Theme.Red or Color3.new(1,1,1)
            nameLabel.TextStrokeTransparency = 0.5
        end
    end
end

-- Lógica de Aimbot Centralizado
local function GetClosestToCenter()
    local closestDist = math.huge
    local target = nil
    
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.TargetPart) then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            
            if Settings.AliveCheck and hum.Health <= 0 then continue end
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

            local partPos, onScreen = Camera:WorldToViewportPoint(char[Settings.TargetPart].Position)
            
            if onScreen then
                local dist = (Vector2.new(partPos.X, partPos.Y) - Center).Magnitude
                
                -- Verifica se está dentro do FOV e é o mais próximo
                if dist < Settings.FOVSize and dist < closestDist then
                    -- Wall Check
                    if Settings.WallCheck then
                        local origin = Camera.CFrame.Position
                        local dir = (char[Settings.TargetPart].Position - origin).Unit * (dist + 5) -- pequeno buffer
                        local params = RaycastParams.new()
                        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        
                        local result = Workspace:Raycast(origin, dir, params)
                        if result and result.Instance:IsDescendantOf(char) then
                            closestDist = dist
                            target = char[Settings.TargetPart]
                        end
                    else
                        closestDist = dist
                        target = char[Settings.TargetPart]
                    end
                end
            end
        end
    end
    return target
end

-- Loops Principais
RunService.RenderStepped:Connect(function()
    -- Manter FOV no centro
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Settings.FOVSize
    
    -- Aimbot (HARD LOCK / SEM SUAVIZAÇÃO)
    if Settings.Aimbot then
        local target = GetClosestToCenter()
        if target then
            -- Removemos o Lerp para "grudar" instantaneamente
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- Atualiza o ESP a cada meio segundo para não lagar
spawn(function()
    while wait(0.5) do
        pcall(UpdateESP)
    end
end)

print("Allveszz V2 Loaded (Instant Lock Mode)")
