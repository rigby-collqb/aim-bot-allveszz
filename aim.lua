--[[
    UNIVERSAL AIMBOT SCRIPT
    Credits: Allveszz
    
    Instruções:
    1. Salve este código em um arquivo (ex: main.lua) no seu GitHub.
    2. Pegue o link "Raw" do arquivo.
    3. Execute com: loadstring(game:HttpGet("SEU_LINK_RAW_AQUI"))()
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configurações Iniciais
local Settings = {
    AimbotEnabled = false,
    FOV = 100,
    TeamCheck = false,
    WallCheck = false,
    AliveCheck = true,
    Smoothness = 0.5, -- Quanto menor, mais rápido (0 a 1)
    TargetPart = "Head" -- Parte do corpo para mirar
}

local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Color = Color3.fromRGB(255, 255, 255)
FOV_Circle.Thickness = 1
FOV_Circle.NumSides = 60
FOV_Circle.Radius = Settings.FOV
FOV_Circle.Filled = false
FOV_Circle.Visible = false

--------------------------------------------------------------------
-- CRIAÇÃO DA INTERFACE (GUI) - Feita à mão para ser Universal
--------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AllveszzUniversalGUI"
ScreenGui.Parent = game.CoreGui

-- Botão de Abrir/Fechar (Ícone)
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenButton.Position = UDim2.new(0.1, 0, 0.1, 0)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Text = "A"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 24.000
OpenButton.AutoButtonColor = false

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(1, 0)
UICornerBtn.Parent = OpenButton

-- Janela Principal (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.Size = UDim2.new(0, 250, 0, 320)
MainFrame.Visible = false -- Começa fechado

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

-- Título / Créditos
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Allveszz Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18.000

-- Função para arrastar a janela (Draggable)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Função auxiliar para criar botões
local layoutOrder = 0
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Espaçador para o título
local Spacer = Instance.new("Frame")
Spacer.Parent = MainFrame
Spacer.BackgroundTransparency = 1
Spacer.Size = UDim2.new(1,0,0,35)
Spacer.LayoutOrder = -1

local function CreateToggle(name, text, default, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = name
    ToggleBtn.Parent = MainFrame
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
    ToggleBtn.Size = UDim2.new(0, 220, 0, 35)
    ToggleBtn.Font = Enum.Font.GothamSemibold
    ToggleBtn.Text = text .. ": " .. (default and "ON" or "OFF")
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 14.000
    ToggleBtn.LayoutOrder = layoutOrder
    layoutOrder = layoutOrder + 1

    local UICornerToggle = Instance.new("UICorner")
    UICornerToggle.CornerRadius = UDim.new(0, 6)
    UICornerToggle.Parent = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()
        local newState = not (ToggleBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 0))
        ToggleBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
        ToggleBtn.Text = text .. ": " .. (newState and "ON" or "OFF")
        callback(newState)
    end)
end

-- Criando as Opções
CreateToggle("ToggleAimbot", "Ativar Aimbot", Settings.AimbotEnabled, function(s) Settings.AimbotEnabled = s end)
CreateToggle("ToggleTeam", "Team Check", Settings.TeamCheck, function(s) Settings.TeamCheck = s end)
CreateToggle("ToggleWall", "Wall Check", Settings.WallCheck, function(s) Settings.WallCheck = s end)
CreateToggle("ToggleAlive", "Alive Check", Settings.AliveCheck, function(s) Settings.AliveCheck = s end)
CreateToggle("ToggleFOVDraw", "Mostrar FOV", false, function(s) FOV_Circle.Visible = s end)

-- Slider simples para FOV (Input Box)
local FOVBox = Instance.new("TextBox")
FOVBox.Parent = MainFrame
FOVBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVBox.Size = UDim2.new(0, 220, 0, 35)
FOVBox.Font = Enum.Font.GothamSemibold
FOVBox.PlaceholderText = "FOV (Ex: 100)"
FOVBox.Text = "FOV: " .. Settings.FOV
FOVBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVBox.TextSize = 14.000
FOVBox.LayoutOrder = layoutOrder

local UICornerFOV = Instance.new("UICorner")
UICornerFOV.CornerRadius = UDim.new(0, 6)
UICornerFOV.Parent = FOVBox

FOVBox.FocusLost:Connect(function()
    local num = tonumber(FOVBox.Text)
    if num then
        Settings.FOV = num
        FOV_Circle.Radius = num
        FOVBox.Text = "FOV: " .. num
    else
        FOVBox.Text = "FOV: " .. Settings.FOV
    end
end)

-- Lógica do Botão Abrir/Fechar
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--------------------------------------------------------------------
-- LÓGICA DO AIMBOT
--------------------------------------------------------------------

local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = Workspace:Raycast(origin, direction, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return false
end

local function GetClosestPlayer()
    local closestDist = math.huge
    local target = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild(Settings.TargetPart) and char:FindFirstChild("Humanoid") then
                
                -- Checks
                if Settings.AliveCheck and char.Humanoid.Health <= 0 then continue end
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
                
                local headPos, onScreen = Camera:WorldToViewportPoint(char[Settings.TargetPart].Position)
                
                if onScreen then
                    local mouseDist = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(headPos.X, headPos.Y)).Magnitude
                    
                    if mouseDist < Settings.FOV and mouseDist < closestDist then
                        if IsVisible(char[Settings.TargetPart]) then
                            closestDist = mouseDist
                            target = char[Settings.TargetPart]
                        end
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    -- Atualiza posição do círculo do FOV
    FOV_Circle.Position = UserInputService:GetMouseLocation()
    
    if Settings.AimbotEnabled then
        local target = GetClosestPlayer()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothness)
        end
    end
end)

print("Allveszz Universal Script Loaded")
