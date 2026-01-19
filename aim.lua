--[[
    ALLVESZ UNIVERSAL SCRIPT V7 (ULTIMATE UI)
    - Interface: Dashboard Moderno com Abas
    - Perfil: Mostra foto de quem executa
    - Créditos: Mostra foto do criador (17gemadin)
    - Funcionalidades: Aimbot, ESP, FOV, Anti-Lag
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
-- CONFIGURAÇÕES & VARIÁVEIS
-- ==================================================================
local Settings = {
    Aimbot = false,
    ESP = false,
    ShowFOV = false,
    FOVSize = 100,
    TeamCheck = false,
    AliveCheck = true,
    TargetPart = "Head",
    DiscordLink = "https://discord.gg/SEU_LINK_AQUI" -- Coloque seu link aqui
}

local LockedTarget = nil
local CurrentTab = nil

-- Limpeza de UI Antiga
if CoreGui:FindFirstChild("AllveszUI") then CoreGui.AllveszUI:Destroy() end
if CoreGui:FindFirstChild("AllveszESP") then CoreGui.AllveszESP:Destroy() end

-- ==================================================================
-- FUNÇÕES DE LÓGICA (AIMBOT, ESP, ANTI-LAG)
-- ==================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(160, 30, 255)
FOVCircle.Filled = false
FOVCircle.NumSides = 64

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

local function GetTarget()
    local Closest = nil
    local MinDist = Settings.FOVSize
    local Mouse = LocalPlayer:GetMouse()

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            if Settings.AliveCheck and (not Hum or Hum.Health <= 0) then continue end
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end

            local Part = v.Character[Settings.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if Dist < MinDist then
                    Closest = Part
                    MinDist = Dist
                end
            end
        end
    end
    return Closest
end

-- ==================================================================
-- CRIAÇÃO DA UI (INTERFACE MODERNA)
-- ==================================================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AllveszUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Ícone Flutuante (Caveira)
local OpenBtn = Instance.new("ImageButton", ScreenGui)
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.01, 0, 0.45, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Image = "rbxassetid://133138891060283"
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(160, 30, 255)
OpenStroke.Thickness = 2

-- Frame Principal
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Barra Lateral (Sidebar)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SideTitle = Instance.new("TextLabel", Sidebar)
SideTitle.Text = "ALLVESZ"
SideTitle.Font = Enum.Font.GothamBlack
SideTitle.TextSize = 22
SideTitle.TextColor3 = Color3.fromRGB(160, 30, 255)
SideTitle.Size = UDim2.new(1, 0, 0, 50)
SideTitle.BackgroundTransparency = 1

-- Perfil do Usuário (Quem executou)
local UserProfile = Instance.new("Frame", Sidebar)
UserProfile.Size = UDim2.new(0.9, 0, 0, 50)
UserProfile.Position = UDim2.new(0.05, 0, 0.88, 0)
UserProfile.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", UserProfile).CornerRadius = UDim.new(0, 8)

local UserImg = Instance.new("ImageLabel", UserProfile)
UserImg.Size = UDim2.new(0, 36, 0, 36)
UserImg.Position = UDim2.new(0, 6, 0.5, -18)
UserImg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", UserImg).CornerRadius = UDim.new(1, 0)
-- Pega a foto do LocalPlayer
UserImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

local UserName = Instance.new("TextLabel", UserProfile)
UserName.Text = LocalPlayer.Name
UserName.Size = UDim2.new(0, 80, 0, 20)
UserName.Position = UDim2.new(0, 50, 0.5, -10)
UserName.BackgroundTransparency = 1
UserName.TextColor3 = Color3.fromRGB(200, 200, 200)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 11
UserName.TextXAlignment = Enum.TextXAlignment.Left

-- Container de Páginas
local Pages = Instance.new("Frame", MainFrame)
Pages.Name = "Pages"
Pages.Size = UDim2.new(1, -170, 1, -20)
Pages.Position = UDim2.new(0, 170, 0, 10)
Pages.BackgroundTransparency = 1

-- ==================================================================
-- SISTEMA DE ABAS
-- ==================================================================
local TabContainer = Instance.new("UIListLayout", Sidebar)
TabContainer.SortOrder = Enum.SortOrder.LayoutOrder
TabContainer.Padding = UDim.new(0, 5)
TabContainer.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Espaço para pular o título
local Padding = Instance.new("Frame", Sidebar)
Padding.Size = UDim2.new(1, 0, 0, 60)
Padding.BackgroundTransparency = 1
Padding.LayoutOrder = -1

local function CreateTab(Name, IconID)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = Name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local PageFrame = Instance.new("ScrollingFrame", Pages)
    PageFrame.Name = Name.."Page"
    PageFrame.Size = UDim2.new(1, 0, 1, 0)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 2
    
    local List = Instance.new("UIListLayout", PageFrame)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Padding = UDim.new(0, 8)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
        for _, v in pairs(Sidebar:GetChildren()) do 
            if v:IsA("TextButton") then 
                v.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                v.TextColor3 = Color3.fromRGB(150, 150, 150)
            end 
        end
        PageFrame.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    return PageFrame
end

local TabCombat = CreateTab("COMBATE")
local TabVisual = CreateTab("VISUAL")
local TabMisc = CreateTab("MISC")
local TabCredits = CreateTab("CRÉDITOS")

-- Inicializar primeira aba
TabCombat.Visible = true

-- ==================================================================
-- COMPONENTES DA UI (Botões e Toggles)
-- ==================================================================
local function AddToggle(Parent, Text, Callback)
    local Btn = Instance.new("TextButton", Parent)
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Btn)
    Label.Text = Text
    Label.Font = Enum.Font.GothamBold
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Status = Instance.new("Frame", Btn)
    Status.Size = UDim2.new(0, 20, 0, 20)
    Status.Position = UDim2.new(0.9, -10, 0.5, -10)
    Status.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Status).CornerRadius = UDim.new(1, 0)
    
    local Toggled = false
    Btn.MouseButton1Click:Connect(function()
        Toggled = not Toggled
        if Toggled then
            TweenService:Create(Status, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(160, 30, 255)}):Play()
        else
            TweenService:Create(Status, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        end
        Callback(Toggled)
    end)
end

local function AddButton(Parent, Text, Callback)
    local Btn = Instance.new("TextButton", Parent)
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(160, 30, 255)
    Btn.Text = Text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBlack
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(Callback)
end

-- > ABA COMBATE
AddToggle(TabCombat, "Ativar Aimbot", function(v) Settings.Aimbot = v end)
AddToggle(TabCombat, "Kill Check (Ignorar Mortos)", function(v) Settings.AliveCheck = v end)
AddToggle(TabCombat, "Team Check", function(v) Settings.TeamCheck = v end)

-- > ABA VISUAL
AddToggle(TabVisual, "ESP Nomes", function(v) Settings.ESP = v end)
AddToggle(TabVisual, "Mostrar FOV", function(v) Settings.ShowFOV = v end)

-- > ABA MISC
AddButton(TabMisc, "DESTRUIR LAG (FPS BOOST)", ActivateAntiLag)

-- > ABA CRÉDITOS (AQUI ESTÁ A LÓGICA DO 17GEMADIN)
local CreditCard = Instance.new("Frame", TabCredits)
CreditCard.Size = UDim2.new(1, 0, 0, 150)
CreditCard.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", CreditCard)

local CreatorImg = Instance.new("ImageLabel", CreditCard)
CreatorImg.Size = UDim2.new(0, 80, 0, 80)
CreatorImg.Position = UDim2.new(0.5, -40, 0.1, 0)
CreatorImg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", CreatorImg).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", CreatorImg).Color = Color3.fromRGB(160, 30, 255)
Instance.new("UIStroke", CreatorImg).Thickness = 2

-- Tenta pegar a foto do 17gemadin pelo ID
spawn(function()
    pcall(function()
        local id = Players:GetUserIdFromNameAsync("17gemadin")
        CreatorImg.Image = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
end)

local CreatorName = Instance.new("TextLabel", CreditCard)
CreatorName.Text = "Allvesz / 17gemadin"
CreatorName.Size = UDim2.new(1, 0, 0, 20)
CreatorName.Position = UDim2.new(0, 0, 0.65, 0)
CreatorName.Font = Enum.Font.GothamBlack
CreatorName.TextColor3 = Color3.fromRGB(255, 255, 255)
CreatorName.TextSize = 16
CreatorName.BackgroundTransparency = 1

local DiscordBtn = Instance.new("TextButton", CreditCard)
DiscordBtn.Size = UDim2.new(0.8, 0, 0, 30)
DiscordBtn.Position = UDim2.new(0.1, 0, 0.8, 0)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Cor do Discord
DiscordBtn.Text = "COPIAR DISCORD"
DiscordBtn.TextColor3 = Color3.new(1,1,1)
DiscordBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", DiscordBtn)

DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard(Settings.DiscordLink)
    DiscordBtn.Text = "COPIADO!"
    wait(2)
    DiscordBtn.Text = "COPIAR DISCORD"
end)


-- ==================================================================
-- INTERATIVIDADE (Abrir/Fechar)
-- ==================================================================
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Draggable (Arrastar)
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


-- ==================================================================
-- LOOP PRINCIPAL (RODA O SCRIPT)
-- ==================================================================
RunService.RenderStepped:Connect(function()
    -- Atualiza Círculo FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Visible = Settings.ShowFOV

    -- Aimbot
    if Settings.Aimbot then
        LockedTarget = GetTarget()
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
                -- Se AliveCheck estiver ativo, verifica se tem vida
                if not Settings.AliveCheck or (Hum and Hum.Health > 0) then
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
                    Txt.TextColor3 = Color3.fromRGB(255, 30, 30)
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

-- Notificação Inicial
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Allvesz UI",
    Text = "Script V7 Carregado com Sucesso!",
    Duration = 5
})
