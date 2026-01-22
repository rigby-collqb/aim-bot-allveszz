--[[
    ALLVESZ PRISON LIFE V9.2 (ANTI-TASE FIXED)
    - Jogo: Prison Life (Place ID: 155615604)
    - Combat: Aimbot (Com Seletor de Time), Wall Check, Kill Check
    - Visual: Name ESP, 2D Box, Skeleton ESP, Tracers, Health Bar
    - Misc: Anti-Lag, Auto-Base (Criminal), Anti-Arrest (Fixed V2)
    - Dev: 17gemadin
]]

-- ==================================================================
-- VERIFICAÇÃO DE JOGO (PLACE LOCK)
-- ==================================================================
if game.PlaceId ~= 155615604 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro de Execução",
        Text = "Este script é exclusivo para Prison Life!",
        Duration = 10
    })
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==================================================================
-- CONFIGURAÇÕES & LISTAS
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

-- Lista de Times para o Target Selector
local TargetList = {
    {Name = "Qualquer Um", TeamName = "All", Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Inmates", TeamName = "Inmates", Color = Color3.fromRGB(255, 140, 0)}, -- Laranja
    {Name = "Guards", TeamName = "Guards", Color = Color3.fromRGB(0, 50, 160)}, -- Azul Escuro
    {Name = "Criminals", TeamName = "Criminals", Color = Color3.fromRGB(255, 0, 0)} -- Vermelho
}

local Settings = {
    -- Combat
    Aimbot = false,
    WallCheck = true,
    TeamCheck = true,
    AliveCheck = true,
    TargetPart = "Head",
    MinDistance = 10,
    TargetTeamIdx = 1, -- 1 = All (Padrão)
    
    -- Visuals (ESP)
    ESP_Name = false,
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_Tracer = false,
    ESP_Health = false,
    
    ESPColorIdx = 1,
    BoxColorIdx = 1,
    SkeletonColorIdx = 5,
    TracerColorIdx = 5,
    
    -- Misc Prison Life
    AutoBase = false,
    AntiArrest = false,
    ArmaPos = Vector3.new(847, 100, 2229),
    
    -- FOV
    ShowFOV = false,
    FOVSize = 80,
    FOVColorIdx = 1,
    
    DiscordLink = "https://discord.gg/SEU_LINK_AQUI"
}

local LockedTarget = nil
local VisualsCache = {}
local HasResetForBase = false
local HasReseted = false

-- Limpeza de UI Antiga e Desenhos
if CoreGui:FindFirstChild("AllveszUI_PL_V9") then CoreGui.AllveszUI_PL_V9:Destroy() end
if CoreGui:FindFirstChild("AllveszESP") then CoreGui.AllveszESP:Destroy() end

local function ClearDrawings()
    for _, cache in pairs(VisualsCache) do
        for _, drawing in pairs(cache) do
            if drawing and drawing.Remove then
                drawing:Remove()
            elseif type(drawing) == "table" then
                for _, d in pairs(drawing) do
                    if d and d.Remove then d:Remove() end
                end
            end
        end
    end
    VisualsCache = {}
end
ClearDrawings()

-- ==================================================================
-- FUNÇÕES LÓGICAS
-- ==================================================================

-- Desenho do FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Color = ColorList[Settings.FOVColorIdx].Color
FOVCircle.Radius = Settings.FOVSize

-- Função Anti-Lag
local function ActivateAntiLag()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsA("Terrain") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            if v:IsA("MeshPart") then v.TextureID = "" end
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

local function GetWeaponLinear(weaponName, targetVector)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local oldPos = root.CFrame
    local targetPos = CFrame.new(targetVector)
    local startTime = tick()

    while tick() - startTime < 1 do -- Aumentei um pouco o tempo para garantir
        local shake = Vector3.new(math.random(-5, 5)/10, 0, math.random(-5, 5)/10)
        
        -- Movimento Linear (Frente e Trás no eixo Z)
        local moveOffset = math.sin(tick() * 10) * 2 
        local linearMovement = root.CFrame.LookVector * moveOffset -- Vai na direção que o boneco olha
        
        root.CFrame = targetPos + linearMovement + shake

        pcall(function()
            local remote = Workspace:FindFirstChild("Remote") and Workspace.Remote:FindFirstChild("ItemHandler")
            local item = Workspace.Prison_ITEMS.giver:FindFirstChild(weaponName)
            if remote and item and item:FindFirstChild("ITEMPICKUP") then
                remote:InvokeServer(item.ITEMPICKUP)
            end
        end)
        RunService.RenderStepped:Wait()
    end

    root.CFrame = oldPos
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Sucesso", Text = weaponName .. " Coletada!", Duration = 2})
end

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
        if Result.Instance:IsDescendantOf(targetPart.Parent) then return true else return false end
    end
    return true
end

-- Busca de Alvo (Atualizado com Target Selector)
local function GetTarget()
    local Closest = nil
    local MinFOV = Settings.FOVSize
    
    -- Configuração do filtro de time
    local TargetTeamConfig = TargetList[Settings.TargetTeamIdx]
    local TargetSpecificTeam = TargetTeamConfig.TeamName -- "All", "Inmates", "Guards" etc.

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            local Root = v.Character.HumanoidRootPart
            
            if Settings.AliveCheck and (not Hum or Hum.Health <= 0) then continue end
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end

            -- --- FILTRO DE ALVO NOVO ---
            if TargetSpecificTeam ~= "All" then
                -- Se o time do jogador não for o selecionado, ignora
                if v.Team.Name ~= TargetSpecificTeam then
                    continue
                end
            end
            -- ---------------------------

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

local function CreateDrawing(Type, Props)
    local D = Drawing.new(Type)
    for k, v in pairs(Props) do D[k] = v end
    return D
end

local function UpdateVisuals()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            if not VisualsCache[v] then
                VisualsCache[v] = {
                    Box = CreateDrawing("Square", {Thickness = 1.5, Filled = false, ZIndex = 2}),
                    Tracer = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 1}),
                    HPBarOutline = CreateDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.new(0,0,0), ZIndex = 1}),
                    HPBarFill = CreateDrawing("Square", {Thickness = 1, Filled = true, ZIndex = 2}),
                    Skeleton = {
                        HeadCircle = CreateDrawing("Circle", {Thickness = 1.5, NumSides = 12, ZIndex = 2}),
                        Spine = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 2}),
                        LArm = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 2}),
                        RArm = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 2}),
                        LLeg = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 2}),
                        RLeg = CreateDrawing("Line", {Thickness = 1.5, ZIndex = 2})
                    }
                }
            end

            local D = VisualsCache[v]
            local Skel = D.Skeleton
            local Char = v.Character
            local Hum = Char and Char:FindFirstChild("Humanoid")
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")

            local Show = false
            
            if Char and Hum and Root and Hum.Health > 0 then
                if not Settings.TeamCheck or v.Team ~= LocalPlayer.Team then
                    local RootPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                    
                    if OnScreen then
                        Show = true
                        
                        local BoxHeight = (Camera.CFrame.Position - Root.Position).Magnitude
                        local SizeY = 2000 / BoxHeight
                        local SizeX = SizeY / 1.5
                        local TopLeft = Vector2.new(RootPos.X - SizeX / 2, RootPos.Y - SizeY / 2)

                        if Settings.ESP_Box then
                            D.Box.Visible = true
                            D.Box.Size = Vector2.new(SizeX, SizeY)
                            D.Box.Position = TopLeft
                            D.Box.Color = ColorList[Settings.BoxColorIdx].Color
                        else
                            D.Box.Visible = false
                        end

                        if Settings.ESP_Tracer then
                            D.Tracer.Visible = true
                            D.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            D.Tracer.To = Vector2.new(RootPos.X, RootPos.Y + SizeY/2)
                            D.Tracer.Color = ColorList[Settings.TracerColorIdx].Color
                        else
                            D.Tracer.Visible = false
                        end

                        if Settings.ESP_Health then
                            D.HPBarOutline.Visible = true
                            D.HPBarFill.Visible = true
                            local BarWidth = 4
                            local Offset = 6
                            local HealthPct = Hum.Health / Hum.MaxHealth
                            local BarHeight = SizeY * HealthPct
                            D.HPBarOutline.Position = Vector2.new(TopLeft.X - Offset - BarWidth, TopLeft.Y)
                            D.HPBarOutline.Size = Vector2.new(BarWidth, SizeY)
                            D.HPBarFill.Position = Vector2.new(TopLeft.X - Offset - BarWidth, TopLeft.Y + (SizeY - BarHeight))
                            D.HPBarFill.Size = Vector2.new(BarWidth, BarHeight)
                            D.HPBarFill.Color = Color3.fromHSV(HealthPct * 0.3, 1, 1)
                        else
                            D.HPBarOutline.Visible = false
                            D.HPBarFill.Visible = false
                        end

                        if Settings.ESP_Skeleton then
                            local Color = ColorList[Settings.SkeletonColorIdx].Color
                            local Head = Char:FindFirstChild("Head")
                            local Torso = Char:FindFirstChild("Torso")
                            local LA = Char:FindFirstChild("Left Arm")
                            local RA = Char:FindFirstChild("Right Arm")
                            local LL = Char:FindFirstChild("Left Leg")
                            local RL = Char:FindFirstChild("Right Leg")

                            if Head and Torso and LA and RA and LL and RL then
                                local function WorldToV2(pos)
                                    local vec, vis = Camera:WorldToViewportPoint(pos)
                                    return Vector2.new(vec.X, vec.Y), vis
                                end

                                local H_P = WorldToV2(Head.Position)
                                local T_P = WorldToV2(Torso.Position)
                                local LA_P = WorldToV2(LA.Position)
                                local RA_P = WorldToV2(RA.Position)
                                local LL_P = WorldToV2(LL.Position)
                                local RL_P = WorldToV2(RL.Position)

                                Skel.HeadCircle.Visible = true
                                Skel.HeadCircle.Position = H_P
                                Skel.HeadCircle.Radius = SizeX / 5
                                Skel.HeadCircle.Color = Color

                                local function DrawLine(LineObj, P1, P2)
                                    LineObj.Visible = true
                                    LineObj.From = P1
                                    LineObj.To = P2
                                    LineObj.Color = Color
                                end
                                DrawLine(Skel.Spine, H_P + Vector2.new(0, Skel.HeadCircle.Radius), T_P)
                                DrawLine(Skel.LArm, T_P, LA_P)
                                DrawLine(Skel.RArm, T_P, RA_P)
                                DrawLine(Skel.LLeg, T_P, LL_P)
                                DrawLine(Skel.RLeg, T_P, RL_P)
                            end
                        else
                            Skel.HeadCircle.Visible = false
                            Skel.Spine.Visible = false
                            Skel.LArm.Visible = false
                            Skel.RArm.Visible = false
                            Skel.LLeg.Visible = false
                            Skel.RLeg.Visible = false
                        end
                    end
                end
            end

            if not Show then
                D.Box.Visible = false
                D.Tracer.Visible = false
                D.HPBarOutline.Visible = false
                D.HPBarFill.Visible = false
                for _, s in pairs(D.Skeleton) do s.Visible = false end
            end
        end
    end
    
    for player, drawings in pairs(VisualsCache) do
        if not Players:FindFirstChild(player.Name) then
            for k, d in pairs(drawings) do
                if k == "Skeleton" then
                    for _, s in pairs(d) do s:Remove() end
                else
                    d:Remove()
                end
            end
            VisualsCache[player] = nil
        end
    end
end

-- ==================================================================
-- INTERFACE (UI)
-- ==================================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AllveszUI_PL_V9"

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "IconA"
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0.01, 0, 0.45, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Text = "𝒜"
OpenBtn.Font = Enum.Font.Sarpanch
OpenBtn.TextColor3 = Color3.fromRGB(160, 30, 255)
OpenBtn.TextSize = 35
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 14)
local IconStroke = Instance.new("UIStroke", OpenBtn)
IconStroke.Color = Color3.fromRGB(160, 30, 255)
IconStroke.Thickness = 2
IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

OpenBtn.MouseEnter:Connect(function() TweenService:Create(OpenBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play() end)
OpenBtn.MouseLeave:Connect(function() TweenService:Create(OpenBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15,15,15)}):Play() end)

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
Title.Text = "PRISON LIFE V9"
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Font = Enum.Font.Sarpanch
Title.TextColor3 = Color3.fromRGB(160, 30, 255)
Title.TextSize = 22
Title.BackgroundTransparency = 1

local MyProfile = Instance.new("Frame", Sidebar)
MyProfile.Size = UDim2.new(0.9, 0, 0, 50)
MyProfile.Position = UDim2.new(0.05, 0, 0.88, 0)
MyProfile.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", MyProfile)

local MyImg = Instance.new("ImageLabel", MyProfile)
MyImg.Size = UDim2.new(0, 34, 0, 34)
MyImg.Position = UDim2.new(0, 8, 0.5, -17)
MyImg.BackgroundColor3 = Color3.fromRGB(10,10,10)
MyImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
Instance.new("UICorner", MyImg).CornerRadius = UDim.new(1,0)

local MyName = Instance.new("TextLabel", MyProfile)
MyName.Text = LocalPlayer.Name
MyName.Position = UDim2.new(0, 50, 0, 0)
MyName.Size = UDim2.new(0, 100, 1, 0)
MyName.BackgroundTransparency = 1
MyName.TextColor3 = Color3.fromRGB(200, 200, 200)
MyName.Font = Enum.Font.GothamBold
MyName.TextSize = 11
MyName.TextXAlignment = Enum.TextXAlignment.Left

local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1, -180, 1, -20)
Pages.Position = UDim2.new(0, 180, 0, 10)
Pages.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TabPadding = Instance.new("Frame", Sidebar)
TabPadding.Size = UDim2.new(1,0,0,60)
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
local TabMisc = CreateTab("MISC")
local TabCredits = CreateTab("CRÉDITOS")
TabCombat.Visible = true

local function AddToggle(Parent, Text, Default, Callback)
    local Frame = Instance.new("TextButton", Parent)
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.Text = ""
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = Text
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 13
    
    local Checkbox = Instance.new("Frame", Frame)
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(0.92, -20, 0.5, -10)
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
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = Text
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 13
    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(0, 60, 0, 24)
    Box.Position = UDim2.new(0.92, -60, 0.5, -12)
    Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Box.TextColor3 = Color3.fromRGB(160, 30, 255)
    Box.Font = Enum.Font.GothamBold
    Box.Text = tostring(Default)
    Box.TextSize = 13
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    Box.FocusLost:Connect(function() local n = tonumber(Box.Text); if n then Callback(n) end end)
end

local function AddColorPicker(Parent, Text, ListIndex, Callback)
    local Btn = Instance.new("TextButton", Parent)
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel", Btn)
    Label.Text = Text
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 13
    local Preview = Instance.new("Frame", Btn)
    Preview.Size = UDim2.new(0, 100, 0, 24)
    Preview.Position = UDim2.new(0.92, -100, 0.5, -12)
    Preview.BackgroundColor3 = ColorList[Settings[ListIndex]].Color
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)
    local NameLbl = Instance.new("TextLabel", Preview)
    NameLbl.Size = UDim2.new(1,0,1,0)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = ColorList[Settings[ListIndex]].Name
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 10
    NameLbl.TextColor3 = Color3.new(0,0,0)
    Btn.MouseButton1Click:Connect(function()
        Settings[ListIndex] = Settings[ListIndex] + 1
        if Settings[ListIndex] > #ColorList then Settings[ListIndex] = 1 end
        local info = ColorList[Settings[ListIndex]]
        Preview.BackgroundColor3 = info.Color
        NameLbl.Text = info.Name
        if Callback then Callback(info.Color) end
    end)
end

-- --- NOVA FUNÇÃO: TARGET SELECTOR ---
local function AddTargetSelector(Parent)
    local Btn = Instance.new("TextButton", Parent)
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Btn)
    Label.Text = "Target (Alvo)"
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 13
    
    local Preview = Instance.new("Frame", Btn)
    Preview.Size = UDim2.new(0, 100, 0, 24)
    Preview.Position = UDim2.new(0.92, -100, 0.5, -12)
    Preview.BackgroundColor3 = TargetList[Settings.TargetTeamIdx].Color
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)
    
    local NameLbl = Instance.new("TextLabel", Preview)
    NameLbl.Size = UDim2.new(1,0,1,0)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = TargetList[Settings.TargetTeamIdx].Name
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 9
    NameLbl.TextColor3 = Color3.new(0,0,0) -- Texto preto pra contraste

    Btn.MouseButton1Click:Connect(function()
        Settings.TargetTeamIdx = Settings.TargetTeamIdx + 1
        if Settings.TargetTeamIdx > #TargetList then Settings.TargetTeamIdx = 1 end
        
        local info = TargetList[Settings.TargetTeamIdx]
        Preview.BackgroundColor3 = info.Color
        NameLbl.Text = info.Name
    end)
end
-- ------------------------------------

local function AddButton(Parent, Text, Color, Callback)
    local Btn = Instance.new("TextButton", Parent)
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color or Color3.fromRGB(25, 25, 25)
    Btn.Text = Text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        if Callback then Callback() end
    end)
end

local function AddLabel(Parent, Text)
    local Lbl = Instance.new("TextLabel", Parent)
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = Text
    Lbl.TextColor3 = Color3.fromRGB(120, 120, 120)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 12
end

-- COMBAT
AddToggle(TabCombat, "Ativar Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddTargetSelector(TabCombat) -- NOVO BOTÃO TARGET
AddToggle(TabCombat, "Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end)
AddInput(TabCombat, "Distância Mínima", Settings.MinDistance, function(v) Settings.MinDistance = v end)
AddToggle(TabCombat, "Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
AddInput(TabCombat, "Tamanho do FOV", Settings.FOVSize, function(v) Settings.FOVSize = v; FOVCircle.Radius = v end)

-- VISUAL
AddLabel(TabVisual, "--- VISUALS ---")
AddToggle(TabVisual, "Ativar Nomes", Settings.ESP_Name, function(v) Settings.ESP_Name = v end)
AddColorPicker(TabVisual, "Cor do Nome", "ESPColorIdx", nil)

AddToggle(TabVisual, "Box 2D", Settings.ESP_Box, function(v) Settings.ESP_Box = v end)
AddColorPicker(TabVisual, "Cor da Box", "BoxColorIdx", nil)

AddToggle(TabVisual, "Skeleton (Esqueleto)", Settings.ESP_Skeleton, function(v) Settings.ESP_Skeleton = v end)
AddColorPicker(TabVisual, "Cor do Esqueleto", "SkeletonColorIdx", nil)

AddToggle(TabVisual, "Tracers", Settings.ESP_Tracer, function(v) Settings.ESP_Tracer = v end)
AddColorPicker(TabVisual, "Cor da Linha", "TracerColorIdx", nil)

AddToggle(TabVisual, "Barra de Vida", Settings.ESP_Health, function(v) Settings.ESP_Health = v end)

AddLabel(TabVisual, "--- OUTROS ---")
AddToggle(TabVisual, "Desenhar Círculo FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)
AddColorPicker(TabVisual, "Cor do FOV", "FOVColorIdx", function(c) FOVCircle.Color = c end)

-- MISC (PRISON LIFE)
AddLabel(TabMisc, "--- AUTOMAÇÃO ---")
AddToggle(TabMisc, "Auto-Base", Settings.AutoBase, function(v) Settings.AutoBase = v end)
AddLabel(TabMisc, " * Reseta 1x ao virar Criminal para pegar armas.")

AddToggle(TabMisc, "Anti-Arrest (Taser Fix)", Settings.AntiArrest, function(v) Settings.AntiArrest = v end)
AddLabel(TabMisc, " * Morre instantaneamente se cair no chão (Taser).")

AddLabel(TabMisc, "--- TELEPORTES ---")
AddButton(TabMisc, "Pegar M4a1 (GAME PASS)", Color3.fromRGB(30, 30, 30), function()
    GetWeaponLinear("M4A1", Settings.ArmaPos)
end)

AddButton(TabMisc, "Pegar Mp5", Color3.fromRGB(30, 30, 30), function()
    GetWeaponLinear("MP5", Vector3.new(813, 100, 2229))
end)

AddButton(TabMisc, "Pegar Remington 870", Color3.fromRGB(30, 30, 30), function()
    GetWeaponLinear("Remington 870", Vector3.new(820, 100, 2229))
end)

AddLabel(TabMisc, "--- SISTEMA ---")
AddButton(TabMisc, "DESTRUIR LAG (FPS BOOST)", Color3.fromRGB(180, 0, 0), ActivateAntiLag)

-- CREDITOS
local CreditCard = Instance.new("Frame", TabCredits)
CreditCard.Size = UDim2.new(1, 0, 0, 160)
CreditCard.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", CreditCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", CreditCard).Color = Color3.fromRGB(160, 30, 255)
Instance.new("UIStroke", CreditCard).Thickness = 1
local Banner = Instance.new("Frame", CreditCard)
Banner.Size = UDim2.new(1, 0, 0, 60)
Banner.BackgroundColor3 = Color3.fromRGB(160, 30, 255)
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 8)
local Cover = Instance.new("Frame", Banner)
Cover.Size = UDim2.new(1,0,0,10)
Cover.Position = UDim2.new(0,0,1,-10)
Cover.BackgroundColor3 = Color3.fromRGB(160, 30, 255)
Cover.BorderSizePixel = 0
local DevImg = Instance.new("ImageLabel", CreditCard)
DevImg.Size = UDim2.new(0, 80, 0, 80)
DevImg.Position = UDim2.new(0, 20, 0, 20)
DevImg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", DevImg).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", DevImg).Color = Color3.fromRGB(25, 25, 25)
Instance.new("UIStroke", DevImg).Thickness = 4
spawn(function() pcall(function() local uid = Players:GetUserIdFromNameAsync("17gemadin"); DevImg.Image = Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) end)
local DevName = Instance.new("TextLabel", CreditCard)
DevName.Text = "17gemadin"
DevName.Position = UDim2.new(0, 110, 0, 65)
DevName.Size = UDim2.new(0, 200, 0, 25)
DevName.Font = Enum.Font.GothamBlack
DevName.TextSize = 22
DevName.TextColor3 = Color3.fromRGB(255, 255, 255)
DevName.TextXAlignment = Enum.TextXAlignment.Left
DevName.BackgroundTransparency = 1
local Role = Instance.new("TextLabel", CreditCard)
Role.Text = "Dono / Desenvolvedor"
Role.Position = UDim2.new(0, 110, 0, 90)
Role.Size = UDim2.new(0, 200, 0, 20)
Role.Font = Enum.Font.Gotham
Role.TextSize = 14
Role.TextColor3 = Color3.fromRGB(150, 150, 150)
Role.TextXAlignment = Enum.TextXAlignment.Left
Role.BackgroundTransparency = 1

-- ==================================================================
-- LOOP PRINCIPAL (ANTI-ARREST & COMBATE)
-- ==================================================================

local SafeDistance = 15 

-- Loop Independente para Anti-Arrest
RunService.Heartbeat:Connect(function()
    -- Verifica configurações básicas e existência do personagem
    if Settings.AntiArrest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        
        -- 1. REGRA: Só funciona se você for Criminal (pedido do usuário)
        if LocalPlayer.Team.Name ~= "Criminals" then
            return -- Para o código aqui se não for criminal
        end

        local MyPos = LocalPlayer.Character.HumanoidRootPart.Position
        local Hum = LocalPlayer.Character.Humanoid
        
        -- 2. Verifica se foi atingido pelo Taser (Caindo ou Sentado forçado)
        if Hum.PlatformStand or (Hum.Sit and not Hum.SeatPart) then
            LocalPlayer.Character:BreakJoints() -- Reset imediato
        end

        -- 3. Verifica policiais PERIGOSOS (Segurando algema)
        for _, v in pairs(Players:GetPlayers()) do
            -- Checa se é Guarda e se está vivo
            if v.Team and (v.Team.Name == "Guards" or v.Team.Name == "Police") and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                
                local Distance = (MyPos - v.Character.HumanoidRootPart.Position).Magnitude
                
                -- AQUI ESTAVA O ERRO: Removemos a verificação da Backpack.
                -- Agora verifica APENAS se "Handcuffs" está dentro do Character (mão do boneco)
                local HoldingHandcuffs = v.Character:FindFirstChild("Handcuffs") 

                -- Se estiver perto E o policial estiver SEGURANDO a algema
                if Distance < SafeDistance and HoldingHandcuffs then
                    LocalPlayer.Character:BreakJoints() -- Mata antes de ser preso
                    break
                end
            end
        end
    end
end)

-- Controle do Botão do Menu
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Loop de Renderização (Aimbot e ESP)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Visible = Settings.ShowFOV

    if Settings.Aimbot then
        LockedTarget = GetTarget()
        if LockedTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.Position)
        end
    end

    UpdateVisuals()

    local Char = LocalPlayer.Character
    local Hum = Char and Char:FindFirstChild("Humanoid")
    
    if Char and Hum and Hum.Health > 0 then
        -- AUTO-BASE
        if Settings.AutoBase then
    -- Verifica se o time existe ANTES de ler o nome
    if LocalPlayer.Team and LocalPlayer.Team.Name == "Criminals" then
        if not HasReseted then
            HasReseted = true
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end
    else
        HasReseted = false
    end
end

    -- LÓGICA DO ESP DE NOMES
    if Settings.ESP_Name then
        local ESPFolder = CoreGui:FindFirstChild("AllveszESP") or Instance.new("Folder", CoreGui)
        ESPFolder.Name = "AllveszESP"
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local HumE = v.Character:FindFirstChild("Humanoid")
                local IsAlive = (HumE and HumE.Health > 0)
                local IsEnemy = (not Settings.TeamCheck or v.Team ~= LocalPlayer.Team)
                
                if (not Settings.AliveCheck or IsAlive) and IsEnemy then
                    local BB = ESPFolder:FindFirstChild(v.Name) or Instance.new("BillboardGui", ESPFolder)
                    BB.Name = v.Name
                    BB.Adornee = v.Character.Head
                    BB.Size = UDim2.new(0, 100, 0, 50)
                    BB.AlwaysOnTop = true
                    
                    local Txt = BB:FindFirstChild("Label") or Instance.new("TextLabel", BB)
                    Txt.Name = "Label"
                    Txt.Text = v.Name
                    Txt.Size = UDim2.new(1, 0, 1, 0)
                    Txt.BackgroundTransparency = 1
                    Txt.TextColor3 = ColorList[Settings.ESPColorIdx].Color
                    Txt.Font = Enum.Font.GothamBold
                    Txt.TextStrokeTransparency = 0.5
                else
                    if ESPFolder:FindFirstChild(v.Name) then ESPFolder[v.Name]:Destroy() end
                end
            end
        end
    else
        if CoreGui:FindFirstChild("AllveszESP") then CoreGui.AllveszESP:ClearAllChildren() end
    end
    end
end) -- FECHAMENTO CORRETO DO RENDERSTEPPED

-- Notificação de Sucesso
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Prison Life V9.2",
    Text = "Anti-Tase Fixed & Ready!",
    Duration = 5
})
