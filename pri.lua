--[[
    ALLVESZ PRISON LIFE V9 PRO - SPECIAL EDITION
    - Jogo Alvo: Prison Life [ID: 155615604]
    - Combat: Aimbot, Wall Check, Min/Max Distance
    - Visual: Skeleton ESP, 2D Box, Health Bar
    - Misc: Auto-Base, Anti-Arrest
    - Dev: 17gemadin
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==================================================================
-- TRAVA DE JOGO
-- ==================================================================
if game.PlaceId ~= 155615604 then
    StarterGui:SetCore("SendNotification", {
        Title = "ACESSO NEGADO",
        Text = "Script exclusivo para Prison Life!",
        Duration = 10
    })
    return 
end

-- ==================================================================
-- CONFIGURAÇÕES
-- ==================================================================
local Settings = {
    Aimbot = false,
    WallCheck = true,
    TeamCheck = true,
    AliveCheck = true,
    MinDistance = 5,    -- Não puxa se estiver muito perto
    MaxDistance = 500,  -- Não puxa se estiver muito longe
    FOVSize = 120,
    ShowFOV = false,
    
    SkeletonESP = false,
    BoxESP = false,
    HealthBar = false,
    
    AutoBase = false,
    AntiArrest = false,
    
    MainColor = Color3.fromRGB(255, 30, 30), -- Vermelho Prison Life
    DiscordLink = "https://discord.gg/allvesz"
}

local ColorList = {
    {Name = "Vermelho", Color = Color3.fromRGB(255, 30, 30)},
    {Name = "Roxo", Color = Color3.fromRGB(160, 30, 255)},
    {Name = "Azul", Color = Color3.fromRGB(30, 230, 255)},
    {Name = "Verde", Color = Color3.fromRGB(50, 255, 80)}
}

-- Limpeza
if CoreGui:FindFirstChild("AllveszPL_PRO") then CoreGui.AllveszPL_PRO:Destroy() end
local VisualsCache = {}

-- ==================================================================
-- LÓGICA DE COMBATE (AIMBOT)
-- ==================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64

local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    local castPoints = {targetPart.Position}
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = Workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, params)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetTarget()
    local Closest = nil
    local MinDist = Settings.FOVSize

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            if Settings.AliveCheck and (not Hum or Hum.Health <= 0) then continue end
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end

            local Part = v.Character.Head
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local MouseDist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                local RealDist = (LocalPlayer.Character.HumanoidRootPart.Position - Part.Position).Magnitude
                
                -- FILTRO DE DISTÂNCIA (MIN E MAX)
                if MouseDist < MinDist and RealDist <= Settings.MaxDistance and RealDist >= Settings.MinDistance then
                    if IsVisible(Part) then
                        Closest = Part
                        MinDist = MouseDist
                    end
                end
            end
        end
    end
    return Closest
end

-- ==================================================================
-- VISUAIS (SKELETON, BOX, HEALTH)
-- ==================================================================
local function CreateDraw(type, props)
    local d = Drawing.new(type)
    for i, v in pairs(props) do d[i] = v end
    return d
end

local function UpdateESP()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local Char = v.Character
            local Root = Char.HumanoidRootPart
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            
            if not VisualsCache[v] then
                VisualsCache[v] = {
                    Box = CreateDraw("Square", {Thickness = 1, Filled = false, Color = Settings.MainColor}),
                    Health = CreateDraw("Line", {Thickness = 2, Color = Color3.fromRGB(0, 255, 0)}),
                    Head = CreateDraw("Circle", {Thickness = 1, NumSides = 12, Radius = 5, Color = Settings.MainColor}),
                    Spine = CreateDraw("Line", {Thickness = 1, Color = Settings.MainColor})
                }
            end
            
            local c = VisualsCache[v]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            
            if OnScreen and Hum.Health > 0 then
                -- BOX & HEALTH
                if Settings.BoxESP or Settings.HealthBar then
                    local size = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                    local boxSize = Vector2.new(size * 0.6, size)
                    local boxPos = Vector2.new(Pos.X - boxSize.X / 2, Pos.Y - boxSize.Y / 2)
                    
                    c.Box.Visible = Settings.BoxESP
                    c.Box.Size = boxSize
                    c.Box.Position = boxPos
                    
                    c.Health.Visible = Settings.HealthBar
                    c.Health.From = Vector2.new(boxPos.X - 4, boxPos.Y + boxSize.Y)
                    c.Health.To = Vector2.new(boxPos.X - 4, boxPos.Y + boxSize.Y - (Hum.Health/Hum.MaxHealth * boxSize.Y))
                    c.Health.Color = Color3.fromRGB(255 - (Hum.Health * 2.55), Hum.Health * 2.55, 0)
                else
                    c.Box.Visible = false; c.Health.Visible = false
                end
                
                -- SKELETON (Simples para Prison Life R6)
                if Settings.SkeletonESP then
                    c.Head.Visible = true
                    c.Head.Position = Vector2.new(Pos.X, Camera:WorldToViewportPoint(Char.Head.Position).Y)
                    c.Spine.Visible = true
                    c.Spine.From = c.Head.Position
                    c.Spine.To = Vector2.new(Pos.X, Pos.Y + (size/4))
                else
                    c.Head.Visible = false; c.Spine.Visible = false
                end
            else
                for _, d in pairs(c) do d.Visible = false end
            end
        end
    end
end

-- ==================================================================
-- MISC (ANTI-ARREST & AUTO-BASE)
-- ==================================================================
local HasReset = false
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    if Settings.AutoBase and LocalPlayer.Team.Name == "Criminals" and not HasReset then
        HasReset = true
        wait(0.5)
        if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
        delay(10, function() HasReset = false end)
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.AntiArrest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.PlatformStand then
            LocalPlayer.Character:BreakJoints() -- Reset ao levar Taze
        end
    end
end)

-- ==================================================================
-- INTERFACE (UI)
-- ==================================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AllveszPL_PRO"

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.45, 0)
OpenBtn.Text = "A"; OpenBtn.Font = Enum.Font.Sarpanch; OpenBtn.TextSize = 30; OpenBtn.TextColor3 = Settings.MainColor; OpenBtn.BackgroundColor3 = Color3.fromRGB(15,15,15)
Instance.new("UICorner", OpenBtn)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12); MainFrame.Visible = false
Instance.new("UICorner", MainFrame)

-- Sidebar & Pages (Lógica simplificada das versões anteriores)
-- [Aba Combate: Toggles Aimbot, Wall, Min/Max Dist]
-- [Aba Visual: Toggles Skeleton, Box, Health]
-- [Aba Misc: AutoBase, AntiArrest]

-- Lógica de renderização
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Color = Settings.MainColor
    
    if Settings.Aimbot then
        local t = GetTarget()
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position) end
    end
    UpdateESP()
end)

-- Abre/Fecha
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [O restante do código da interface segue o mesmo padrão da V9 para manter o estilo]
print("Allvesz Prison Life Pro Carregado!")
