--[[
    Allvesz UNIVERSAL SCRIPT V5 (GOD MODE + ANTI-LAG EDITION)
    Credits: Allvesz (O Criador)
    
    Update Logs:
    - Ícone de Caveira Corrigido (Asset ID Nativo)
    - Anti-Lag "Destruidor" adicionado
    - ESP Reescrito (Não pisca, não some)
    - FOV Corrigido
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Limpeza preventiva de UI antiga
if CoreGui:FindFirstChild("AllveszGodMode") then
    CoreGui.AllveszGodMode:Destroy()
end

if CoreGui:FindFirstChild("AllveszESP") then
    CoreGui.AllveszESP:Destroy()
end

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
    WallCheck = true,
    AliveCheck = true,
    ShowFOV = true,
    FOVSize = 120,
    TargetPart = "Head",
    FOVColorIndex = 2, -- Roxo
    ESPColorIndex = 1,  -- Vermelho
    AntiLag = false
}

-- Variáveis Globais
local LockedTarget = nil
local ESPContainer = {} -- Tabela para gerenciar ESP sem flickering

-- FOV Circle (Usando Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Thickness = 2
FOVCircle.Color = ColorList[Settings.FOVColorIndex].Color
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVSize

--------------------------------------------------------------------
-- SISTEMA ANTI-LAG (OTIMIZAÇÃO EXTREMA)
--------------------------------------------------------------------
local function ActivateAntiLag()
    -- Notificação
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Anti-Lag",
        Text = "Otimizando... Aguarde a travada.",
        Duration = 3
    })
    
    wait(0.1) -- Pequeno delay para a UI não congelar antes da notificação
    
    -- 1. Otimização de Iluminação
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 2
    
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
            v.Enabled = false
        end
    end

    -- 2. Otimização do Terreno
    if workspace:FindFirstChild("Terrain") then
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 1
    end

    -- 3. Otimização de Partes e Materiais
    -- Usamos GetDescendants para pegar tudo. Pode travar por 1-2 segundos.
    for _, v in pairs(workspace:GetDescendants()) do
        -- Ignora o jogador local para não ficar feio pra você
        if v:IsDescendantOf(LocalPlayer.Character) then continue end
        
        if v:IsA("BasePart") and not v:IsA("Terrain") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
            -- v.TopSurface = Enum.SurfaceType.Smooth -- (Depreciado, mas útil em jogos antigos)
            
            -- Se for MeshPart, remove a textura para ganhar MUITO FPS
            if v:IsA("MeshPart") then
                v.TextureID = "" 
            end
            
        elseif v:IsA("Decal") or v:IsA("Texture") then
            -- Remove logos, sujeira no chão, detalhes de parede
            v.Transparency = 1
            
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Sucesso",
        Text = "FPS Boost Ativado!",
        Duration = 3
    })
end

--------------------------------------------------------------------
-- INTERFACE (UI) SUPER PREMIUM
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AllveszGodMode"
ScreenGui.Parent = CoreGui -- Usar CoreGui protege contra alguns jogos que limpam PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Theme = {
    Bg = Color3.fromRGB(12, 12, 12),
    Item = Color3.fromRGB(25, 25, 25),
    Purple = Color3.fromRGB(170, 0, 255),
    Red = Color3.fromRGB(255, 40, 40),
    Text = Color3.fromRGB(255, 255, 255)
}

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

-- MARCA D'ÁGUA
local Watermark = Instance.new("TextLabel")
Watermark.Parent = ScreenGui
Watermark.BackgroundTransparency = 1
Watermark.Position = UDim2.new(0.85, -20, 0.95, -20)
Watermark.Size = UDim2.new(0.15, 0, 0.05, 0)
Watermark.Font = Enum.Font.GothamBlack
Watermark.Text = "ALLVESZ // V5"
Watermark.TextColor3 = Theme.Text
Watermark.TextSize = 18
Watermark.TextTransparency = 0.5
Watermark.TextXAlignment = Enum.TextXAlignment.Right

-- BOTÃO ÍCONE (CAVEIRA CORRIGIDA)
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "SkullIcon"
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Theme.Item
OpenBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)

-- ID DO ROBLOX FUNCIONAL PARA CAVEIRA
OpenBtn.Image = "rbxassetid://10469032608" -- Ícone de Caveira Estilizada

OpenBtn.ScaleType = Enum.ScaleType.Fit
OpenBtn.ImageColor3 = Color3.new(1, 1, 1)
OpenBtn.AutoButtonColor = true

local btnCorner = Instance.new("UICorner", OpenBtn)
btnCorner.CornerRadius = UDim.new(0, 10)

local btnStroke = Instance.new("UIStroke", OpenBtn)
btnStroke.Thickness = 2
btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local btnGradient = Instance.new("UIGradient")
btnGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(170, 0, 255)), 
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 40, 40))
}
btnGradient.Rotation = 45
btnGradient.Parent = btnStroke

-- JANELA PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.Size = UDim2.new(0, 320, 0, 480) -- Aumentei um pouco para caber o botão novo
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
AddGradient(MainStroke)

-- Lógica de Abrir/Fechar
OpenBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function() MainFrame.Visible = false end)
    else
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 480), BackgroundTransparency = 0.05})
        tween:Play()
    end
end)

-- Título
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
Title.Text = "Allvesz"
Title.TextColor3 = Theme.Text
Title.TextSize = 24
AddGradient(Title)

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = Header
SubTitle.Size = UDim2.new(1, 0, 0.3, 0)
SubTitle.Position = UDim2.new(0, 0, 0.7, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.Code
SubTitle.Text = "GOD MODE // V5"
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
Container.CanvasSize = UDim2.new(0, 0, 1.6, 0) -- Aumentado para scroll

local Layout = Instance.new("UIListLayout")
Layout.Parent = Container
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Toggle Helper
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
    
    local indStroke = Instance.new("UIStroke", Indicator)
    indStroke.Thickness = 1
    indStroke.Color = Color3.fromRGB(80,80,80)

    Btn.MouseButton1Click:Connect(function()
        local isOn = (Indicator.BackgroundColor3 == Theme.Purple)
        local newState = not isOn
        
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

-- Color Helper
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

-- Input FOV
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

-- Botão de Ação (Para Anti-Lag)
local function CreateActionButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Container
    Btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20) -- Cor diferente para destaque
    Btn.Size = UDim2.new(0, 290, 0, 38)
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBlack
    Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local str = Instance.new("UIStroke", Btn)
    str.Color = Color3.fromRGB(255, 40, 40)
    str.Thickness = 1
    str.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    Btn.MouseButton1Click:Connect(callback)
end

-- CRIANDO OS BOTÕES
CreateToggle("ATIVAR AIMBOT", Settings.Aimbot, function(v) Settings.Aimbot = v end)
CreateToggle("WALL CHECK (RIGOROSO)", Settings.WallCheck, function(v) Settings.WallCheck = v end)
CreateFOVInput()
CreateToggle("DESENHAR FOV", Settings.ShowFOV, function(v) Settings.ShowFOV = v; FOVCircle.Visible = v end)
CreateColorSelector("COR DO FOV", "FOVColorIndex", function(c) FOVCircle.Color = c end)
CreateToggle("ESP NOMES (PERSISTENTE)", Settings.ESP, function(v) Settings.ESP = v end)
CreateColorSelector("COR DO ESP", "ESPColorIndex", function(c) end)
CreateToggle("CHECK DE TIME", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)

-- BOTÃO NOVO: ANTI-LAG
CreateActionButton("DESTRUIR LAG (FPS BOOST)", function()
    ActivateAntiLag()
end)


--------------------------------------------------------------------
-- LÓGICA DO AIMBOT
--------------------------------------------------------------------
local function IsPathClear(targetPart)
    if not Settings.WallCheck then return true end
    local Origin = Camera.CFrame.Position
    local Direction = targetPart.Position - Origin
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    Params.IgnoreWater = false
    local Result = Workspace:Raycast(Origin, Direction, Params)
    if Result then
        if Result.Instance:IsDescendantOf(targetPart.Parent) then return true end
        return false 
    end
    return true
end

local function GetTarget()
    if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChild("Humanoid") then
        local Hum = LockedTarget.Parent.Humanoid
        if Hum.Health > 0 and IsPathClear(LockedTarget) then
            local pos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if onScreen and dist <= Settings.FOVSize then return LockedTarget end
        end
    end

    local Closest = nil
    local MinDist = math.huge
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.TargetPart) then
            local Char = v.Character
            local Hum = Char:FindFirstChild("Humanoid")
            if Settings.AliveCheck and Hum and Hum.Health <= 0 then continue end
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
            
            local Part = Char[Settings.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Center).Magnitude
                if Dist < Settings.FOVSize and Dist < MinDist then
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

--------------------------------------------------------------------
-- ESP OTIMIZADO (SEM PISCAR)
--------------------------------------------------------------------
local ESPFolder = Instance.new("Folder", CoreGui)
ESPFolder.Name = "AllveszESP"

local function UpdateESP()
    if not Settings.ESP then 
        ESPFolder:ClearAllChildren()
        return 
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") then
            -- Verificações
            if Settings.AliveCheck and v.Character.Humanoid.Health <= 0 then 
                if ESPFolder:FindFirstChild(v.Name) then ESPFolder[v.Name]:Destroy() end
                continue 
            end
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then 
                if ESPFolder:FindFirstChild(v.Name) then ESPFolder[v.Name]:Destroy() end
                continue 
            end

            -- Cria ou Atualiza
            local BB = ESPFolder:FindFirstChild(v.Name)
            if not BB then
                BB = Instance.new("BillboardGui")
                BB.Name = v.Name
                BB.Parent = ESPFolder
                BB.Size = UDim2.new(0, 100, 0, 50)
                BB.StudsOffset = Vector3.new(0, 2, 0)
                BB.AlwaysOnTop = true
                
                local txt = Instance.new("TextLabel")
                txt.Parent = BB
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = v.Name
                txt.Font = Enum.Font.GothamBlack
                txt.TextSize = 12
                txt.TextStrokeTransparency = 0.5
                txt.Name = "Label"
            end
            
            -- Sincronizar Adornee e C
