--[[
    ALLVESZ PRISON LIFE EDITION (V10)
    - Exclusivo: Prison Life
    - Skeleton ESP: Linhas R6 + Círculo Cabeça
    - Misc: Auto-Base (Reset ao virar Crim) & Anti-Arrest
    - Baseado na UI Allvesz V9
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

-- ==================================================================
-- 0. VERIFICAÇÃO DE JOGO (LOCK)
-- ==================================================================
local PrisonLifeID = 155615604
if game.PlaceId ~= PrisonLifeID then
    StarterGui:SetCore("SendNotification", {
        Title = "ACESSO NEGADO",
        Text = "Este script é EXCLUSIVO para Prison Life.",
        Duration = 10
    })
    return -- Para a execução aqui
end

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==================================================================
-- CONFIGURAÇÕES
-- ==================================================================
local ColorList = {
    {Name = "Roxo Elétrico", Color = Color3.fromRGB(160, 30, 255)},
    {Name = "Vermelho Sangue", Color = Color3.fromRGB(255, 30, 30)},
    {Name = "Azul Cyan", Color = Color3.fromRGB(30, 230, 255)},
    {Name = "Verde Tóxico", Color = Color3.fromRGB(50, 255, 80)},
    {Name = "Branco Puro", Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Laranja Fogo", Color = Color3.fromRGB(255, 140, 0)},
    {Name = "Amarelo Sol", Color = Color3.fromRGB(255, 255, 0)}
}

local Settings = {
    -- Combat
    Aimbot = false,
    WallCheck = true,
    TeamCheck = true, -- Recomendado true no PL
    AliveCheck = true,
    TargetPart = "Head",
    MinDistance = 15,
    
    -- Visuals (ESP)
    ESP_Name = false,
    ESP_Box = false,      
    ESP_Skeleton = false, -- NOVO: Esqueleto
    
    ESPColorIdx = 1,
    BoxColorIdx = 1,
    SkeletonColorIdx = 5, -- Padrão Branco
    
    -- Misc (PL Specifics)
    AutoBase = false,     -- Resetar ao virar Criminal
    AntiArrest = false,   -- Resetar ao levar Taze
    
    -- FOV
    ShowFOV = false,
    FOVSize = 120,
    FOVColorIdx = 1,
    
    DiscordLink = "https://discord.gg/SEU_LINK_AQUI"
}

local LockedTarget = nil
local VisualsCache = {} 
local HasResetForCriminal = false -- Controle do reset único

-- Limpeza
if CoreGui:FindFirstChild("AllveszPL_UI") then CoreGui.AllveszPL_UI:Destroy() end
if CoreGui:FindFirstChild("AllveszESP_PL") then CoreGui.AllveszESP_PL:Destroy() end

local function ClearDrawings()
    for _, cache in pairs(VisualsCache) do
        for _, drawing in pairs(cache) do
            if drawing and drawing.Remove then drawing:Remove() end
        end
    end
    VisualsCache = {}
end
ClearDrawings()

-- ==================================================================
-- FUNÇÕES LÓGICAS
-- ==================================================================

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Color = ColorList[Settings.FOVColorIdx].Color
FOVCircle.Radius = Settings.FOVSize

-- Wall Check
local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    local Origin = Camera.CFrame.Position
    local Direction = targetPart.Position - Origin
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local Result = Workspace:Raycast(Origin, Direction, Params)
    if Result then
        if Result.Instance:IsDescendantOf(targetPart.Parent) then return true end
        return false
    end
    return true
end

-- Get Target (Aimbot)
local function GetTarget()
    local Closest = nil
    local MinFOV = Settings.FOVSize

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            local Root = v.Character.HumanoidRootPart
            
            if Settings.AliveCheck and (not Hum or Hum.Health <= 0) then continue end
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end

            local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if MyRoot then
                local Dist3D = (MyRoot.Position - Root.Position).Magnitude
                if Dist3D < Settings.MinDistance then continue end
            end

            local Part = v.Character[Settings.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local DistFromCenter = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if DistFromCenter < MinFOV then
                    if IsVisible(Part) then
                        Closest = Part
                        MinFOV = DistFromCenter
                    end
                end
            end
        end
    end
    return Closest
end

-- Gerenciador de Desenhos
local function CreateDrawing(Type, Props)
    local D = Drawing.new(Type)
    for k, v in pairs(Props) do D[k] = v end
    return D
end

-- Lógica do Esqueleto R6
local function UpdateSkeleton(Cache, Char, Color)
    local Parts = {
        Head = Char:FindFirstChild("Head"),
        Torso = Char:FindFirstChild("Torso"),
        LArm = Char:FindFirstChild("Left Arm"),
        RArm = Char:FindFirstChild("Right Arm"),
        LLeg = Char:FindFirstChild("Left Leg"),
        RLeg = Char:FindFirstChild("Right Leg")
    }

    if not (Parts.Head and Parts.Torso and Parts.LArm and Parts.RArm and Parts.LLeg and Parts.RLeg) then
        -- Esconde tudo se faltar parte
        Cache.HeadCircle.Visible = false
        Cache.Spine.Visible = false
        Cache.LArm.Visible = false
        Cache.RArm.Visible = false
        Cache.LLeg.Visible = false
        Cache.RLeg.Visible = false
        return
    end

    local function GetScreenPos(Part)
        local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
        return Vector2.new(Pos.X, Pos.Y), OnScreen
    end

    local HPos, HOn = GetScreenPos(Parts.Head)
    local TPos, TOn = GetScreenPos(Parts.Torso)
    local LAPos, LAOn = GetScreenPos(Parts.LArm)
    local RAPos, RAOn = GetScreenPos(Parts.RArm)
    local LLPos, LLOn = GetScreenPos(Parts.LLeg)
    local RLPos, RLOn = GetScreenPos(Parts.RLeg)

    if TOn or HOn then -- Se torso ou cabeça visíveis
        -- Círculo Cabeça
        Cache.HeadCircle.Visible = true
        Cache.HeadCircle.Position = HPos
        Cache.HeadCircle.Radius = 1500 / (Camera.CFrame.Position - Parts.Head.Position).Magnitude
        Cache.HeadCircle.Color = Color

        -- Linhas
        local function SetLine(Line, P1, P2)
            Line.Visible = true
            Line.From = P1
            Line.To = P2
            Line.Color = Color
        end

        SetLine(Cache.Spine, HPos, TPos)
        SetLine(Cache.LArm, TPos, LAPos)
        SetLine(Cache.RArm, TPos, RAPos)
        SetLine(Cache.LLeg, TPos, LLPos)
        SetLine(Cache.RLeg, TPos, RLPos)
    else
        Cache.HeadCircle.Visible = false
        Cache.Spine.Visible = false
        Cache.LArm.Visible = false
        Cache.RArm.Visible = false
        Cache.LLeg.Visible = false
        Cache.RLeg.Visible = false
    end
end

local function UpdateVisuals()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            if not VisualsCache[v] then
                VisualsCache[v] = {
                    Box = CreateDrawing("Square", {Thickness = 1.5, Filled = false, ZIndex = 2}),
                    -- Elementos do Esqueleto
                    HeadCircle = CreateDrawing("Circle", {Thickness = 1.5, Filled = false, ZIndex = 2, NumSides = 12}),
                    Spine = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 1}),
                    LArm = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 1}),
                    RArm = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 1}),
                    LLeg = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 1}),
                    RLeg = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 1}),
                }
            end

            local D = VisualsCache[v]
            local Char = v.Character
            local Hum = Char and Char:FindFirstChild("Humanoid")
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")

            local Show = false
            
            if Char and Hum and Root and Hum.Health > 0 then
                if not Settings.TeamCheck or v.Team ~= LocalPlayer.Team then
                    local RootPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                    
                    if OnScreen then
                        Show = true
                        
                        -- BOX
                        if Settings.ESP_Box then
                            local BoxHeight = (Camera.CFrame.Position - Root.Position).Magnitude
                            local SizeY = 2000 / BoxHeight
                            local SizeX = SizeY / 1.5
                            local TopLeft = Vector2.new(RootPos.X - SizeX / 2, RootPos.Y - SizeY / 2)
                            
                            D.Box.Visible = true
                            D.Box.Size = Vector2.new(SizeX, SizeY)
                            D.Box.Position = TopLeft
                            D.Box.Color = ColorList[Settings.BoxColorIdx].Color
                        else
                            D.Box.Visible = false
                        end

                        -- SKELETON
                        if Settings.ESP_Skeleton then
                            UpdateSkeleton(D, Char, ColorList[Settings.SkeletonColorIdx].Color)
                        else
                            D.HeadCircle.Visible = false
                            D.Spine.Visible = false
                            D.LArm.Visible = false
                            D.RArm.Visible = false
                            D.LLeg.Visible = false
                            D.RLeg.Visible = false
                        end
                    end
                end
            end

            if not Show then
                for _, obj in pairs(D) do obj.Visible = false end
            end
        end
    end
    
    for player, drawings in pairs(VisualsCache) do
        if not Players:FindFirstChild(player.Name) then
            for _, d in pairs(drawings) do d:Remove() end
            VisualsCache[player] = nil
        end
    end
end

-- ==================================================================
-- INTERFACE (UI)
-- ==================================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AllveszPL_UI"

-- --- ÍCONE "A" ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "IconA"
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0.01, 0, 0.45, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Text = "PL"
OpenBtn.Font = Enum.Font.Sarpanch
OpenBtn.TextColor3 = Color3.fromRGB(160, 30, 255)
OpenBtn.TextSize = 25
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 14)
local IconStroke = Instance.new("UIStroke", OpenBtn)
IconStroke.Color = Color3.fromRGB(160, 30, 255)
IconStroke.Thickness = 2
IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

OpenBtn.MouseEnter:Connect(function() TweenService:Create(OpenBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play() end)
OpenBtn.MouseLeave:Connect(function() TweenService:Create(OpenBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15,15,15)}):Play() end)

-- --- JANELA PRINCIPAL ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Sidebar)
Title.Text = "ALLVESZ PL V10"
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Font = Enum.Font.Sarpanch
Title.TextColor3 = Color3.fromRGB(160, 30, 255)
Title.TextSize = 22
Title.BackgroundTransparency = 1

local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1, -180, 1, -20)
Pages.Position = UDim2.new(0, 180, 0, 10)
Pages.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TabPadding = Instance.new("Frame", Sidebar)
TabPadding.Size = UDim2.new(1,0,60,0)
TabPadding.BackgroundTransparency = 1

local function CreateTab(Name)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = Name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local Page = Instance.new("ScrollingFrame", Pages)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    local PList = Instance.new("UIListLayout", Page)
    PList.Padding = UDim.new(0, 8)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages:GetChildren()) do v.Visible = false end
        for _,v in pairs(Sidebar:GetChildren()) do 
            if v:IsA("TextButton") then 
                v.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                v.TextColor3 = Color3.fromRGB(150, 150, 150)
            end 
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return Page
end

local TabCombat = CreateTab("COMBATE")
local TabVisual = CreateTab("VISUAL")
local TabMisc = CreateTab("PL MISC")
local TabCredits = CreateTab("CRÉDITOS")
TabCombat.Visible = true

-- Helpers UI
local function AddToggle(Parent, Text, Default, Callback)
    local Frame = Instance.new("TextButton", Parent)
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.Text = ""
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = Text; Label.Position = UDim2.new(0, 12, 0, 0); Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1; Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.TextSize = 13
    local Checkbox = Instance.new("Frame", Frame)
    Checkbox.Size = UDim2.new(0, 20, 0, 20); Checkbox.Position = UDim2.new(0.92, -20, 0.5, -10)
    Checkbox.BackgroundColor3 = Default and Color3.fromRGB(160, 30, 255) or Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)
    local State = Default
    Frame.MouseButton1Click:Connect(function()
        State = not State
        Checkbox.BackgroundColor3 = State and Color3.fromRGB(160, 30, 255) or Color3.fromRGB(40, 40, 40)
        Callback(State)
    end)
end

local function AddInput(Parent, Text, Default, Callback)
    local Frame = Instance.new("Frame", Parent)
    Frame.Size = UDim2.new(1, 0, 0, 40); Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = Text; Label.Position = UDim2.new(0, 12, 0, 0); Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1; Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.TextSize = 13
    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(0, 60, 0, 24); Box.Position = UDim2.new(0.92, -60, 0.5, -12)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Box.TextColor3 = Color3.fromRGB(160, 30, 255)
    Box.Font = Enum.Font.GothamBold; Box.Text = tostring(Default); Box.TextSize = 13
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    Box.FocusLost:Connect(function() local n = tonumber(Box.Text); if n then Callback(n) end end)
end

local function AddColorPicker(Parent, Text, ListIndex, Callback)
    local Btn = Instance.new("TextButton", Parent)
    Btn.Size = UDim2.new(1, 0, 0, 40); Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel", Btn)
    Label.Text = Text; Label.Position = UDim2.new(0, 12, 0, 0); Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.BackgroundTransparency = 1; Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.TextSize = 13
    local Preview = Instance.new("Frame", Btn)
    Preview.Size = UDim2.new(0, 100, 0, 24); Preview.Position = UDim2.new(0.92, -100, 0.5, -12)
    Preview.BackgroundColor3 = ColorList[Settings[ListIndex]].Color
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)
    local NameLbl = Instance.new("TextLabel", Preview)
    NameLbl.Size = UDim2.new(1,0,1,0); NameLbl.BackgroundTransparency = 1
    NameLbl.Text = ColorList[Settings[ListIndex]].Name; NameLbl.Font = Enum.Font.GothamBold; NameLbl.TextSize = 10; NameLbl.TextColor3 = Color3.new(0,0,0)
    Btn.MouseButton1Click:Connect(function()
        Settings[ListIndex] = Settings[ListIndex] + 1
        if Settings[ListIndex] > #ColorList then Settings[ListIndex] = 1 end
        local info = ColorList[Settings[ListIndex]]
        Preview.BackgroundColor3 = info.Color
        NameLbl.Text = info.Name
        if Callback then Callback(info.Color) end
    end)
end

local function AddLabel(Parent, Text)
    local Lbl = Instance.new("TextLabel", Parent)
    Lbl.Size = UDim2.new(1,0,0,25); Lbl.BackgroundTransparency = 1; Lbl.Text = Text
    Lbl.TextColor3 = Color3.fromRGB(100, 100, 100); Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 12
end

-- --- POPULANDO UI ---
AddToggle(TabCombat, "Ativar Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddToggle(TabCombat, "Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end)
AddToggle(TabCombat, "Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
AddInput(TabCombat, "Distância Segura", Settings.MinDistance, function(v) Settings.MinDistance = v end)
AddInput(TabCombat, "Tamanho FOV", Settings.FOVSize, function(v) Settings.FOVSize = v; FOVCircle.Radius = v end)

AddToggle(TabVisual, "Nomes (ESP)", Settings.ESP_Name, function(v) Settings.ESP_Name = v end)
AddColorPicker(TabVisual, "Cor do Nome", "ESPColorIdx", nil)
AddToggle(TabVisual, "Box 2D", Settings.ESP_Box, function(v) Settings.ESP_Box = v end)
AddColorPicker(TabVisual, "Cor da Box", "BoxColorIdx", nil)
AddToggle(TabVisual, "Esqueleto R6", Settings.ESP_Skeleton, function(v) Settings.ESP_Skeleton = v end) -- NOVO
AddColorPicker(TabVisual, "Cor Esqueleto", "SkeletonColorIdx", nil) -- NOVO
AddToggle(TabVisual, "Desenhar FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)

AddLabel(TabMisc, "--- EXTRAS PRISON LIFE ---")
AddToggle(TabMisc, "Auto-Base (Criminal)", Settings.AutoBase, function(v) 
    Settings.AutoBase = v 
    if not v then HasResetForCriminal = false end
end)
AddLabel(TabMisc, " * Reseta 1x ao virar Criminal para pegar armas.")

AddToggle(TabMisc, "Anti-Arrest (Taze)", Settings.AntiArrest, function(v) Settings.AntiArrest = v end)
AddLabel(TabMisc, " * Reseta se for paralisado por Taser.")

local function ActivateAntiLag()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 end
    end
end
local BtnLag = Instance.new("TextButton", TabMisc)
BtnLag.Size = UDim2.new(1,0,0,40); BtnLag.BackgroundColor3 = Color3.fromRGB(180,0,0); BtnLag.Text = "REMOVER LAG"; BtnLag.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", BtnLag).CornerRadius = UDim.new(0,6)
BtnLag.MouseButton1Click:Connect(ActivateAntiLag)

-- CRÉDITOS
local CreditFrame = Instance.new("Frame", TabCredits)
CreditFrame.Size = UDim2.new(1,0,0,100); CreditFrame.BackgroundColor3 = Color3.fromRGB(20,20,20); Instance.new("UICorner", CreditFrame)
local DevTxt = Instance.new("TextLabel", CreditFrame); DevTxt.Size = UDim2.new(1,0,1,0); DevTxt.BackgroundTransparency = 1; DevTxt.Text = "Feito por 17gemadin\nVersão Prison Life"; DevTxt.TextColor3 = Color3.new(1,1,1); DevTxt.Font = Enum.Font.GothamBold; DevTxt.TextSize = 18

-- ==================================================================
-- LOGICAS ESPECÍFICAS (AUTO BASE & ANTI ARREST)
-- ==================================================================

-- Detecta Mudança de Time (Auto Base)
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    if Settings.AutoBase then
        if LocalPlayer.Team and LocalPlayer.Team.Name == "Criminals" then
            if not HasResetForCriminal then
                -- Aguarda personagem carregar para resetar
                task.wait(0.5)
                if LocalPlayer.Character then
                    LocalPlayer.Character:BreakJoints()
                    HasResetForCriminal = true
                end
            end
        else
            HasResetForCriminal = false -- Reseta a flag se mudar de time (ex: voltar a ser preso)
        end
    end
end)

-- Monitoramento do Personagem (Anti Arrest)
RunService.RenderStepped:Connect(function()
    -- UI & Visuals Loop
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Visible = Settings.ShowFOV
    
    if Settings.Aimbot then
        LockedTarget = GetTarget()
        if LockedTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.Position)
        end
    end
    
    UpdateVisuals()

    -- Anti Arrest Logic
    if Settings.AntiArrest and LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum then
            -- No Prison Life, ser "tazado" geralmente ativa PlatformStand ou muda o estado
            if Hum.PlatformStand == true or Hum:GetState() == Enum.HumanoidStateType.PlatformStanding then
                LocalPlayer.Character:BreakJoints()
            end
            
            -- Checagem extra: Script "Tased" que o jogo adiciona
            if LocalPlayer.Character:FindFirstChild("Tased") then
                LocalPlayer.Character:BreakJoints()
            end
        end
    end
    
    -- ESP Nomes (Legado)
    if Settings.ESP_Name then
        local ESPFolder = CoreGui:FindFirstChild("AllveszESP_PL") or Instance.new("Folder", CoreGui)
        ESPFolder.Name = "AllveszESP_PL"
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local Hum = v.Character:FindFirstChild("Humanoid")
                local IsEnemy = (not Settings.TeamCheck or v.Team ~= LocalPlayer.Team)
                if (Hum and Hum.Health > 0) and IsEnemy then
                    local BB = ESPFolder:FindFirstChild(v.Name) or Instance.new("BillboardGui", ESPFolder)
                    BB.Name = v.Name; BB.Adornee = v.Character.Head; BB.Size = UDim2.new(0,100,0,50); BB.AlwaysOnTop = true
                    local Txt = BB:FindFirstChild("L") or Instance.new("TextLabel", BB); Txt.Name="L"; Txt.Size=UDim2.new(1,0,1,0); Txt.BackgroundTransparency=1; Txt.Text=v.Name; Txt.TextColor3=ColorList[Settings.ESPColorIdx].Color; Txt.TextStrokeTransparency=0.5
                else
                    if ESPFolder:FindFirstChild(v.Name) then ESPFolder[v.Name]:Destroy() end
                end
            end
        end
    else
        if CoreGui:FindFirstChild("AllveszESP_PL") then CoreGui.AllveszESP_PL:ClearAllChildren() end
    end
end)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

StarterGui:SetCore("SendNotification", {
    Title = "Allvesz PL V10",
    Text = "Carregado! Abra com o botão 'PL'.",
    Duration = 5
})
