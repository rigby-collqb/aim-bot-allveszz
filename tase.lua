local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

local function mostrarNotificacao()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "AntiTaseAlert"
    sg.DisplayOrder = 999 -- Garante que fique por cima de tudo
    sg.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 40)
    frame.Position = UDim2.new(0.5, -110, 0.1, 0) -- Aparece no topo para não atrapalhar
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    
    -- Arredondar cantos (opcional, deixa mais moderno)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = ToolToRadius and ToolToRadius(8) or UDim.new(0, 8)
    corner.Parent = frame

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = "⚡ ANTI-TASER EXECUTADO"
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.Parent = frame

    Debris:AddItem(sg, 2.5)
end

local function resetarChar(character, humanoid)
    if humanoid.Health > 0 then
        mostrarNotificacao()
        -- Tenta matar pela vida, se falhar, quebra as juntas
        humanoid.Health = 0
        task.wait(0.1)
        if humanoid.Health > 0 then
            character:BreakJoints()
        end
    end
end

local function conectarChar(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end

    -- Detecta PlatformStand (Queda)
    humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if humanoid.PlatformStand == true then
            resetarChar(character, humanoid)
        end
    end)

    -- Detecta Sit (Muitos tasers sentam o player)
    humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        if humanoid.Sit == true then
            -- Verifica se há algum item de taser no char antes de resetar por sentar
            if character:FindFirstChild("Tased") or character:FindFirstChild("BodyGyro") then
                resetarChar(character, humanoid)
            end
        end
    end)

    -- Detecta itens de script de taser
    character.ChildAdded:Connect(function(child)
        local n = child.Name:lower()
        if n == "tased" or n == "client" or n == "bodygyro" or n == "ice" then
            resetarChar(character, humanoid)
        end
    end)
end

if player.Character then conectarChar(player.Character) end
player.CharacterAdded:Connect(conectarChar)

print("🛡️ Anti-Taser de Teste Carregado com Sucesso!")
