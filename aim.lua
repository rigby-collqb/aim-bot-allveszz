--[[
    ALLVESZ UNIVERSAL SCRIPT V8 (DEFINITIVE EDITION)
    - Ícone: Letra "A" Estilizada (Sem bugs de imagem)
    - Combat: Aimbot, Wall Check, Team Check, Kill Check
    - Visual: ESP, FOV, Cores Personalizáveis
    - Misc: Anti-Lag Extremo
    - UI: Dashboard V2
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
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
    {Name = "Laranja Fogo", Color = Color3.fromRGB(255, 140, 0)}
}

local Settings = {
    Aimbot = false,
    WallCheck = true,     -- NOVO
    TeamCheck = false,
    AliveCheck = true,
    TargetPart = "Head",
    
    ESP = false,
    ESPColorIdx = 1,      -- NOVO
    
    ShowFOV = false,
    FOVSize = 120,        -- NOVO (Ajustável)
    FOVColorIdx = 1,      -- NOVO
    
    DiscordLink = "https://discord.gg/SEU_LINK_AQUI"
}

local LockedTarget = nil

-- Limpeza de UI Antiga
if CoreGui:FindFirstChild("AllveszUI_V8") then CoreGui.AllveszUI_V8:Destroy() end
if CoreGui:FindFirstChild("AllveszESP") then CoreGui.AllveszESP:Destroy() end

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

-- Wall Check (Raycast)
local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    
    local Origin = Camera.CFrame.Position
    local Direction = targetPart.Position - Origin
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local Result = Workspace:Raycast(Origin, Direction, Params)
    
    if Result then
        -- Se bater em algo, verifica se é parte do alvo
        if Result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        else
            return false -- Bateu numa parede
        end
    end
    return true
end

-- Busca de Alvo
local function GetTarget()
    local Closest = nil
    local MinDist = Settings.FOVSize

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            
            -- Checks
            if Settings.AliveCheck and (not Hum or Hum.Health <= 0) then continue end
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end

            local Part = v.Character[Settings.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                
                -- Verifica Distância E Visibilidade (WallCheck)
                if Dist < MinDist then
                    if IsVisible(Part) then
                        Closest = Part
                        MinDist = Dist
                    end
                end
            end
        end
    end
    return Closest
end

-- ==================================================================
-- INTERFACE (UI)
-- ==================================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AllveszUI_V8"

-- --- ÍCONE "A" ESTILIZADO ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "IconA"
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0.01, 0, 0.45, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Text = "𝒜"
OpenBtn.Font = Enum.Font.Sarpanch -- Fonte Estilosa
OpenBtn.TextColor3 = Color3.fromRGB(160, 30, 255)
OpenBtn.TextSize = 35
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 14)

local IconStroke = Instance.new("UIStroke", OpenBtn)
IconStroke.Color = Color3.fromRGB(160, 30, 255)
IconStroke.Thickness = 2
IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Animaçãozinha do botão
OpenBtn.MouseEnter:Connect(function() 
    TweenService:Create(OpenBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play() 
end)
OpenBtn.MouseLeave:Connect(function() 
    TweenService:Create(OpenBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15,15,15)}):Play() 
end)

-- --- JANELA PRINCIPAL ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

-- Título
local Title = Instance.new("TextLabel", Sidebar)
Title.Text = "ALLVESZ V8"
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Font = Enum.Font.Sarpanch
Title.TextColor3 = Color3.fromRGB(160, 30, 255)
Title.TextSize = 24
Title.BackgroundTransparency = 1

-- Perfil Player (Canto Inferior)
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

-- Container de Páginas
local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1, -180, 1, -20)
Pages.Position = UDim2.new(0, 180, 0, 10)
Pages.BackgroundTransparency = 1

-- Função de Criar Abas
local TabList = Instance.new("UIListLayout", Sidebar)
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TabPadding = Instance.new("Frame", Sidebar) -- Espaço topo
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

TabCombat.Visible = true -- Inicia na aba combate

-- --- COMPONENTES (Toggle, Slider, ColorPicker) ---

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
    
    Box.FocusLost:Connect(function()
        local n = tonumber(Box.Text)
        if n then Callback(n) end
    end)
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
        Callback(info.Color)
    end)
end

local function AddButton(Parent, Text, Color, Callback)
    local Btn = Instance.new("TextButton", Parent)
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color
    Btn.Text = Text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBlack
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(Callback)
end

-- --- POPULANDO AS ABAS ---

-- Combat
AddToggle(TabCombat, "Ativar Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddToggle(TabCombat, "Wall Check (Não mira através da parede)", Settings.WallCheck, function(v) Settings.WallCheck = v end)
AddToggle(TabCombat, "Kill Check (Ignorar Mortos)", Settings.AliveCheck, function(v) Settings.AliveCheck = v end)
AddToggle(TabCombat, "Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
AddInput(TabCombat, "Tamanho do FOV (Padrão 120)", Settings.FOVSize, function(v) 
    Settings.FOVSize = v
    FOVCircle.Radius = v 
end)

-- Visual
AddToggle(TabVisual, "ESP Nomes (Wallhack)", Settings.ESP, function(v) Settings.ESP = v end)
AddColorPicker(TabVisual, "Cor do ESP", "ESPColorIdx", function(c) end)
AddToggle(TabVisual, "Desenhar Círculo FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)
AddColorPicker(TabVisual, "Cor do FOV", "FOVColorIdx", function(c) FOVCircle.Color = c end)

-- Misc
AddButton(TabMisc, "DESTRUIR LAG (FPS BOOST MAX)", Color3.fromRGB(180, 0, 0), ActivateAntiLag)

-- Credits (DESIGN MELHORADO)
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
local Cover = Instance.new("Frame", Banner) -- Tapa a parte de baixo arredondada
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

-- Lógica para pegar imagem do 17gemadin
spawn(function()
    pcall(function()
        local uid = Players:GetUserIdFromNameAsync("17gemadin")
        DevImg.Image = Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
end)

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

local CopyDisc = Instance.new("TextButton", CreditCard)
CopyDisc.Text = "Copiar Discord"
CopyDisc.Size = UDim2.new(0, 120, 0, 30)
CopyDisc.Position = UDim2.new(0.95, -120, 0.85, -30)
CopyDisc.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
CopyDisc.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyDisc.Font = Enum.Font.GothamBold
Instance.new("UICorner", CopyDisc)

CopyDisc.MouseButton1Click:Connect(function()
    setclipboard(Settings.DiscordLink)
    CopyDisc.Text = "Copiado!"
    wait(2)
    CopyDisc.Text = "Copiar Discord"
end)


-- ==================================================================
-- LOOP PRINCIPAL (AIMBOT, ESP UPDATE)
-- ==================================================================

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

RunService.RenderStepped:Connect(function()
    -- Atualizar FOV Circle
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Visible = Settings.ShowFOV
    -- A cor já atualiza no callback do botão

    -- AIMBOT
    if Settings.Aimbot then
        LockedTarget = GetTarget() -- Agora usa WallCheck interno
        if LockedTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.Position)
        end
    end

    -- ESP
    if Settings.ESP then
        local ESPFolder = CoreGui:FindFirstChild("AllveszESP") or Instance.new("Folder", CoreGui)
        ESPFolder.Name = "AllveszESP"
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local Hum = v.Character:FindFirstChild("Humanoid")
                
                -- Checagem de Vida e Time
                local IsAlive = (Hum and Hum.Health > 0)
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
                    Txt.TextColor3 = ColorList[Settings.ESPColorIdx].Color -- COR DO ESP ATUALIZADA
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
end)

-- Notificação
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Allvesz V8",
    Text = "Script Carregado!",
    Duration = 5
})
