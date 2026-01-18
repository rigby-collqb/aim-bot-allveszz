--[[
    ALLVESZZ UNIVERSAL SCRIPT V3 (FULL PROFESSIONAL EDITION)
    Theme: Red/Purple/Black
    Credits: Allveszz
    Status: Instant Lock-on (No Smoothness)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configurações de Cores (Roxo, Vermelho e Preto)
local Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    DarkContrast = Color3.fromRGB(20, 20, 20),
    Purple = Color3.fromRGB(140, 0, 255),
    Red = Color3.fromRGB(255, 0, 50),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(200, 0, 0)
}

local Settings = {
    Aimbot = true,
    ESP = true,
    TeamCheck = true,
    WallCheck = false,
    AliveCheck = true,
    FOVSize = 120,
    TargetPart = "Head"
}

-- FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 2
FOVCircle.Color = Theme.Red
FOVCircle.Transparency = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.FOVSize
FOVCircle.Filled = false

--------------------------------------------------------------------
-- INTERFACE GRÁFICA PROFISSIONAL (DESIGN COMPLETO)
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Allveszz_Pro_V3"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Função de Gradiente Profissional
local function ApplyGradient(obj)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Purple),
        ColorSequenceKeypoint.new(1, Theme.Red)
    })
    grad.Rotation = 45
    grad.Parent = obj
end

-- Botão de Abrir/Fechar (Ícone Flutuante)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Theme.DarkContrast
OpenBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.Text = "A"
OpenBtn.TextColor3 = Theme.Text
OpenBtn.TextSize = 30
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local btnStroke = Instance.new("UIStroke", OpenBtn)
btnStroke.Thickness = 3
ApplyGradient(btnStroke)

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Thickness = 2
ApplyGradient(mainStroke)

-- Header (Parte para Arrastar)
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Theme.DarkContrast
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.Text = "ALLVESZZ V3 // PRO"
Title.TextColor3 = Theme.Text
Title.TextSize = 18
ApplyGradient(Title)

-- Lógica de Arrastar (Draggable)
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
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Container de Opções
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.Position = UDim2.new(0, 10, 0, 70)
Scroll.Size = UDim2.new(1, -20, 1, -80)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 1.2, 0)
Scroll.ScrollBarThickness = 2

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Função para Criar Toggles Profissionais
local function NewToggle(name, default, callback)
    local Tgl = Instance.new("TextButton")
    Tgl.Parent = Scroll
    Tgl.Size = UDim2.new(0, 280, 0, 45)
    Tgl.BackgroundColor3 = Theme.DarkContrast
    Tgl.Text = ""
    Tgl.AutoButtonColor = false
    Instance.new("UICorner", Tgl).CornerRadius = UDim.new(0, 8)
    
    local txt = Instance.new("TextLabel")
    txt.Parent = Tgl
    txt.Size = UDim2.new(0.7, 0, 1, 0)
    txt.Position = UDim2.new(0, 15, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = name
    txt.Font = Enum.Font.GothamBold
    txt.TextColor3 = Theme.Text
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextSize = 14

    local Indicator = Instance.new("Frame")
    Indicator.Parent = Tgl
    Indicator.Position = UDim2.new(0.85, 0, 0.5, -10)
    Indicator.Size = UDim2.new(0, 20, 0, 20)
    Indicator.BackgroundColor3 = default and Theme.Red or Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    Tgl.MouseButton1Click:Connect(function()
        local s = not (Indicator.BackgroundColor3 == Theme.Red)
        Indicator.BackgroundColor3 = s and Theme.Red or Color3.fromRGB(50, 50, 50)
        callback(s)
    end)
end

-- Criando os Controles
NewToggle("INSTANT AIMBOT (MOUSE2)", Settings.Aimbot, function(v) Settings.Aimbot = v end)
NewToggle("ESP NAMETAGS", Settings.ESP, function(v) Settings.ESP = v end)
NewToggle("TEAM CHECK", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
NewToggle("WALL CHECK", Settings.WallCheck, function(v) Settings.WallCheck = v end)

-- FOV Input
local FOVFrame = Instance.new("Frame")
FOVFrame.Parent = Scroll
FOVFrame.Size = UDim2.new(0, 280, 0, 45)
FOVFrame.BackgroundColor3 = Theme.DarkContrast
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(0, 8)

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Parent = FOVFrame
FOVLabel.Size = UDim2.new(0.5, 0, 1, 0)
FOVLabel.Position = UDim2.new(0, 15, 0, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV RADIUS"
FOVLabel.Font = Enum.Font.GothamBold
FOVLabel.TextColor3 = Theme.Text
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.TextSize = 14

local FOVInput = Instance.new("TextBox")
FOVInput.Parent = FOVFrame
FOVInput.Size = UDim2.new(0.3, 0, 0.7, 0)
FOVInput.Position = UDim2.new(0.65, 0, 0.15, 0)
FOVInput.BackgroundColor3 = Theme.Background
FOVInput.Text = tostring(Settings.FOVSize)
FOVInput.TextColor3 = Theme.Purple
FOVInput.Font = Enum.Font.GothamBold
FOVInput.TextSize = 14
Instance.new("UICorner", FOVInput)

FOVInput.FocusLost:Connect(function()
    local n = tonumber(FOVInput.Text)
    if n then Settings.FOVSize = n FOVCircle.Radius = n end
end)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

--------------------------------------------------------------------
-- LÓGICA DE COMBATE (LOCK-ON INSTANTÂNEO)
--------------------------------------------------------------------

local function GetTarget()
    local dist = Settings.FOVSize
    local target = nil
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.TargetPart) then
            if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
            if Settings.AliveCheck and p.Character.Humanoid.Health <= 0 then continue end
            
            local pos, vis = Camera:WorldToViewportPoint(p.Character[Settings.TargetPart].Position)
            if vis then
                local mDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mDist < dist then
                    if Settings.WallCheck then
                        local ray = Camera:ViewportPointToRay(pos.X, pos.Y)
                        local rResult = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
                        if rResult and rResult.Instance:IsDescendantOf(p.Character) then
                            dist = mDist
                            target = p.Character[Settings.TargetPart]
                        end
                    else
                        dist = mDist
                        target = p.Character[Settings.TargetPart]
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetTarget()
        if t then
            -- GRUDAR INSTANTÂNEO (Sem suavização)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end
end)

-- ESP NAMETAGS
local ESPFolder = Instance.new("Folder", game.CoreGui)
spawn(function()
    while wait(0.5) do
        ESPFolder:ClearAllChildren()
        if Settings.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
                    local b = Instance.new("BillboardGui", ESPFolder)
                    b.Adornee = p.Character.Head
                    b.Size = UDim2.new(0, 100, 0, 40)
                    b.AlwaysOnTop = true
                    b.StudsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", b)
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.Text = p.Name
                    l.Font = Enum.Font.GothamBlack
                    l.TextColor3 = Theme.Red
                    l.TextSize = 14
                    l.TextStrokeTransparency = 0
                end
            end
        end
    end
end)

print("Allveszz V3 Professional Loaded")
