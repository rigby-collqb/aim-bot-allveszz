--[[
    ALLVESZZ UNIVERSAL SCRIPT V4 (GOD MODE EDITION)
    Credits: ALLVESZZ (O Criador)
    
    Update Logs:
    - Wall Check Rigoroso (Não vara parede nem grade sólida)
    - Ícone de Caveira (Headshot)
    - UI Animada com TweenService
    - Marca d'água Permanente
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Sistema de Cores
local ColorList = {
    {Name = "Blood Red", Color = Color3.fromRGB(255, 30, 30)},
    {Name = "Electric Purple", Color = Color3.fromRGB(160, 30, 255)},
    {Name = "Cyan Blue", Color = Color3.fromRGB(30, 230, 255)},
    {Name = "Toxic Green", Color = Color3.fromRGB(50, 255, 80)}
}

-- Configurações
local Settings = {
    Aimbot = true,
    ESP = true,
    TeamCheck = false,
    WallCheck = true, -- Agora RIGOROSO
    AliveCheck = true,
    ShowFOV = true,
    FOVSize = 120,
    TargetPart = "Head",
    FOVColorIndex = 2, -- Roxo
    ESPColorIndex = 1  -- Vermelho
}

-- Variáveis Globais
local LockedTarget = nil

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Thickness = 1.5
FOVCircle.Color = ColorList[Settings.FOVColorIndex].Color
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVSize

--------------------------------------------------------------------
-- INTERFACE (UI) SUPER PREMIUM
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AllveszzGodMode"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Theme = {
    Bg = Color3.fromRGB(12, 12, 12),
    Item = Color3.fromRGB(25, 25, 25),
    Purple = Color3.fromRGB(170, 0, 255),
    Red = Color3.fromRGB(255, 40, 40),
    Text = Color3.fromRGB(255, 255, 255)
}

-- Gradiente Funções
local function AddGradient(obj)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Theme.Purple),
        ColorSequenceKeypoint.new(1.0, Theme.Red)
    }
    g.Rotation = 45
    g.Parent = obj
    return g
end

-- MARCA D'ÁGUA (CRÉDITOS EXPOSTOS)
local Watermark = Instance.new("TextLabel")
Watermark.Parent = ScreenGui
Watermark.BackgroundTransparency = 1
Watermark.Position = UDim2.new(0.85, -20, 0.95, -20)
Watermark.Size = UDim2.new(0.15, 0, 0.05, 0)
Watermark.Font = Enum.Font.GothamBlack
Watermark.Text = "ALLVESZZ // SCRIPT"
Watermark.TextColor3 = Theme.Text
Watermark.TextSize = 18
Watermark.TextTransparency = 0.5
Watermark.TextXAlignment = Enum.TextXAlignment.Right

-- BOTÃO ÍCONE (CAVEIRA)
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "SkullIcon"
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Theme.Item
OpenBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
-- ID de Caveira/Headshot
OpenBtn.Image = "rbxassetid://300666687" -- Skull Icon clássico
OpenBtn.ImageColor3 = Theme.Purple
OpenBtn.AutoButtonColor = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)
local btnStroke = Instance.new("UIStroke", OpenBtn)
btnStroke.Thickness = 2
AddGradient(btnStroke)

-- Efeito de clique no ícone
OpenBtn.MouseButton1Click:Connect(function()
    local targetPos = UDim2.new(0.5, -160, 0.5, -225)
    local mainFrame = ScreenGui:FindFirstChild("MainFrame")
    
    if mainFrame.Visible then
        -- Animação de Fechar
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function() mainFrame.Visible = false end)
    else
        -- Animação de Abrir
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundTransparency = 1
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 450), BackgroundTransparency = 0.05})
        tween:Play()
    end
end)

-- JANELA PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
AddGradient(MainStroke)

-- Título Gigante
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.new(0,0,0)
Header.BackgroundTransparency = 0.5
Header.Size = UDim2.new(1, 0, 0, 60)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, 0, 0.7, 0)
Title.Position = UDim2.new(0, 0, 0.15, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.Text = "ALLVESZZ"
Title.TextColor3 = Theme.Text
Title.TextSize = 24
AddGradient(Title)

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = Header
SubTitle.Size = UDim2.new(1, 0, 0.3, 0)
SubTitle.Position = UDim2.new(0, 0, 0.7, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.Code
SubTitle.Text = "PREMIUM UNIVERSAL // V4"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.TextSize = 11

-- Sistema de Arrastar
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

-- Container
local Container = Instance.new("ScrollingFrame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, 70)
Container.Size = UDim2.new(1, 0, 1, -80)
Container.ScrollBarThickness = 3
Container.CanvasSize = UDim2.new(0, 0, 1.5, 0)

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper Toggle
local function CreateToggle(text, defaultVal, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Container
    Btn.BackgroundColor3 = Theme.Item
    Btn.Size = UDim2.new(0, 290, 0, 38)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Btn
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = text
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 13
    
    local Indicator = Instance.new("Frame")
    Indicator.Parent = Btn
    Indicator.Position = UDim2.new(0.88, 0, 0.5, -6)
    Indicator.Size = UDim2.new(0, 12, 0, 12)
    Indicator.BackgroundColor3 = defaultVal and Theme.Purple or Color3.fromRGB(50,50,50)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    -- Stroke no indicador
    local indStroke = Instance.new("UIStroke", Indicator)
    indStroke.Thickness = 1
    indStroke.Color = Color3.fromRGB(80,80,80)

    Btn.MouseButton1Click:Connect(function()
        local isOn = (Indicator.BackgroundColor3 == Theme.Purple)
        local newState = not isOn
        
        -- Animação Simples
        if newState then
            Indicator.BackgroundColor3 = Theme.Purple
            indStroke.Color = Theme.Red
        else
            Indicator.BackgroundColor3 = Color3.fromRGB(50,50,50)
            indStroke.Color = Color3.fromRGB(80,80,80)
        end
        callback(newState)
    end)
end

-- Helper Color Picker
local function CreateColorSelector(text, key, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Container
    Btn.BackgroundColor3 = Theme.Item
    Btn.Size = UDim2.new(0, 290, 0, 38)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Btn
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = text
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 13
    
    local Preview = Instance.new("TextLabel")
    Preview.Parent = Btn
    Preview.BackgroundTransparency = 1
    Preview.Position = UDim2.new(0.5, 0, 0, 0)
    Preview.Size = UDim2.new(0.45, 0, 1, 0)
    Preview.Font = Enum.Font.GothamBlack
    Preview.Text = ColorList[Settings[key]].Name
    Preview.TextColor3 = ColorList[Settings[key]].Color
    Preview.TextXAlignment = Enum.TextXAlignment.Right
    Preview.TextSize = 12

    Btn.MouseButton1Click:Connect(function()
        Settings[key] = Settings[key] + 1
        if Settings[key] > #ColorList then Settings[key] = 1 end
        
        local newData = ColorList[Settings[key]]
        Preview.Text = newData.Name
        Preview.TextColor3 = newData.Color
        callback(newData.Color)
    end)
end

-- Input de FOV
local function CreateFOVInput()
    local Frame = Instance.new("Frame")
    Frame.Parent = Container
    Frame.BackgroundColor3 = Theme.Item
    Frame.Size = UDim2.new(0, 290, 0, 38)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "FOV SIZE"
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 13
    
    local Box = Instance.new("TextBox")
    Box.Parent = Frame
    Box.BackgroundTransparency = 1
    Box.Position = UDim2.new(0.7, 0, 0, 0)
    Box.Size = UDim2.new(0.25, 0, 1, 0)
    Box.Font = Enum.Font.GothamBold
    Box.Text = tostring(Settings.FOVSize)
    Box.TextColor3 = Theme.Red
    Box.TextSize = 13
    
    Box.FocusLost:Connect(function()
        local n = tonumber(Box.Text)
        if n then 
            Settings.FOVSize = n
            FOVCircle.Radius = n
        end
    end)
end

-- Criando Botões
CreateToggle("ATIVAR AIMBOT", Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggle("WALL CHECK (RIGOROSO)", Settings.WallCheck, function(v) Settings.WallCheck = v end)
CreateFOVInput()
CreateToggle("DESENHAR FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v; FOVCircle.Visible = v end)
CreateColorSelector("COR DO FOV", "FOVColorIndex", function(c) FOVCircle.Color = c end)
CreateToggle("ESP NOMES", Settings.ESP, function(v) Settings.ESP = v end)
CreateColorSelector("COR DO ESP", "ESPColorIndex", function(c) end) -- Loop trata isso
CreateToggle("CHECK DE TIME", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)

--------------------------------------------------------------------
-- LÓGICA DO AIMBOT REFORÇADA (WALLCHECK FIX)
--------------------------------------------------------------------

local function IsPathClear(targetPart)
    if not Settings.WallCheck then return true end
    
    local Origin = Camera.CFrame.Position
    local Direction = targetPart.Position - Origin
    
    -- Raycast Parameters RIGOROSOS
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    -- Ignora o jogador local e a câmera, mas detecta TODO o resto
    Params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    Params.IgnoreWater = false -- Água bloqueia bala? Depende, mas vamos deixar false.
    
    local Result = Workspace:Raycast(Origin, Direction, Params)
    
    if Result then
        -- Se o raio bateu em algo
        if Result.Instance:IsDescendantOf(targetPart.Parent) then
            -- Se bateu no inimigo, tá limpo
            return true
        else
            -- Se bateu em qualquer outra coisa (parede, grade, chão)
            -- Bloqueia IMEDIATAMENTE.
            return false 
        end
    end
    
    return true
end

local function GetTarget()
    -- Prioriza o alvo que já estamos travados (Anti-Tremor)
    if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChild("Humanoid") then
        local Hum = LockedTarget.Parent.Humanoid
        if Hum.Health > 0 and IsPathClear(LockedTarget) then
            local pos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if onScreen and dist <= Settings.FOVSize then
                return LockedTarget
            end
        end
    end

    local Closest = nil
    local MinDist = math.huge
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.TargetPart) then
            local Char = v.Character
            local Hum = Char:FindFirstChild("Humanoid")
            
            -- Checks básicos
            if Settings.AliveCheck and Hum.Health <= 0 then continue end
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
            
            local Part = Char[Settings.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Center).Magnitude
                
                if Dist < Settings.FOVSize and Dist < MinDist then
                    -- Wall Check na seleção do alvo
                    if IsPathClear(Part) then
                        MinDist = Dist
                        Closest = Part
                    end
                end
            end
        end
    end
    
    LockedTarget = Closest
    return Closest
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOVSize
    
    if Settings.Aimbot then
        local T = GetTarget()
        if T then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, T.Position)
        end
    else
        LockedTarget = nil
    end
end)

--------------------------------------------------------------------
-- ESP OTIMIZADO
--------------------------------------------------------------------
local ESPGroup = Instance.new("Folder", game.CoreGui)
ESPGroup.Name = "AllveszzESP"

spawn(function()
    while wait(0.5) do
        ESPGroup:ClearAllChildren()
        if not Settings.ESP then continue end
        
        local CorAtual = ColorList[Settings.ESPColorIndex].Color
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                if Settings.AliveCheck and v.Character.Humanoid.Health <= 0 then continue end
                if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
                
                local bb = Instance.new("BillboardGui")
                bb.Parent = ESPGroup
                bb.Adornee = v.Character.Head
                bb.Size = UDim2.new(0, 100, 0, 50)
                bb.StudsOffset = Vector3.new(0, 2, 0)
                bb.AlwaysOnTop = true
                
                local txt = Instance.new("TextLabel")
                txt.Parent = bb
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = v.Name
                txt.TextColor3 = CorAtual
                txt.Font = Enum.Font.GothamBlack
                txt.TextSize = 12
                txt.TextStrokeTransparency = 0.5
            end
        end
    end
end)

-- Notificação de Carregamento
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "ALLVESZZ V4",
    Text = "Script Carregado com Sucesso!",
    Duration = 5
})
