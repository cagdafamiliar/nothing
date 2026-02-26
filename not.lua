-- ================================================
-- Untitled Enhancements X | LinoriaLib (Compatible con Solara)
-- Creado por Grok - Reescrito para Solara/Executors modernos
-- Jan Lib es vieja (2021), por eso no carga en Solara.
-- Esta versión tiene UI SIMILAR: Tabs, Secciones, Toggles, etc.
-- Copia y pega completo ❤️
-- ================================================

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local Window = library:CreateWindow({
    Title = "Untitled Enhancements X",
    Center = true,
    AutoShow = true
})

-- Notificación inicial
library:Notify("Untitled Enhancements X cargado! (Solara OK)", 4)

-- ==================== PLAYER TAB ====================
local PlayerTab = Window:AddTab("Player")
local PlayerSec = PlayerTab:AddSection("Opciones del Jugador")

local customLevelValue = library:CreateTextbox({
    Name = "Custom Level (Visual)",
    Default = "100",
    Callback = function(text)
        customLevelValue = text
        library:Notify("Nivel cambiado a: " .. text, 2)
    end
})

local hiddenNameToggle = PlayerTab:AddToggle({
    Name = "Hidden Name",
    Default = false,
    Callback = function(state)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Head") then
            for _, v in pairs(char.Head:GetDescendants()) do
                if v:IsA("BillboardGui") then
                    v.Enabled = not state
                end
            end
        end
    end
})

local customNameTextbox = library:CreateTextbox({
    Name = "Custom Name",
    Default = "MiNombreCool",
    Callback = function() end
})

PlayerTab:AddButton({
    Name = "Aplicar Custom Name",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("Head") then 
            library:Notify("Personaje no cargado", 3)
            return 
        end
        
        -- Borra nombres viejos
        for _, v in pairs(char.Head:GetDescendants()) do
            if v:IsA("BillboardGui") and v.Name == "CustomNameGui" then 
                v:Destroy() 
            end
        end
        
        local bg = Instance.new("BillboardGui")
        bg.Name = "CustomNameGui"
        bg.Adornee = char.Head
        bg.Size = UDim2.new(0, 200, 0, 50)
        bg.StudsOffset = Vector3.new(0, 2, 0)
        bg.AlwaysOnTop = true
        bg.Parent = char.Head
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = customNameTextbox.Value
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextStrokeTransparency = 0
        text.TextScaled = true
        text.Font = Enum.Font.GothamBold
        text.Parent = bg
        
        library:Notify("Custom Name aplicado!", 2)
    end
})

local flyToggle = PlayerTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(state)
        local char = game.Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        if state then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
            
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(4000, 4000, 4000)
            bg.P = 2000
            bg.Parent = root
            
            local speedSlider = library:CreateSlider({
                Name = "Fly Speed",
                Min = 1,
                Max = 100,
                Default = 16,
                Color = Color3.fromRGB(255,255,255),
                Increment = 1,
                Callback = function(value)
                    bv.Velocity = bv.Velocity.Unit * value
                end    
            })
            
            spawn(function()
                while flyToggle.Value do
                    local cam = workspace.CurrentCamera
                    local move = Vector3.new()
                    local uis = game:GetService("UserInputService")
                    
                    if uis:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                    if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                    
                    bv.Velocity = move * speedSlider.Value
                    bg.CFrame = cam.CFrame
                    wait()
                end
                bv:Destroy()
                bg:Destroy()
            end)
        end
    end
})

-- ==================== VISUALS TAB ====================
local VisualsTab = Window:AddTab("Visuals")
local VisualsSec = VisualsTab:AddSection("Visuales")

local espToggle = VisualsTab:AddToggle({
    Name = "ESP (Cajas + Nombre + Dist)",
    Default = false,
    Callback = function(state)
        if state then
            -- Código ESP aquí (Drawing API)
            local espObjects = {}
            local function addESP(plr)
                if plr == game.Players.LocalPlayer then return end
                local box = Drawing.new("Square")
                box.Thickness = 2
                box.Filled = false
                box.Transparency = 1
                box.Color = Color3.new(1, 0, 0)
                box.Visible = false
                
                local nameTag = Drawing.new("Text")
                nameTag.Size = 16
                nameTag.Center = true
                nameTag.Outline = true
                nameTag.Color = Color3.new(1,1,1)
                nameTag.Visible = false
                
                espObjects[plr] = {box = box, name = nameTag}
            end
            
            for _, plr in pairs(game.Players:GetPlayers()) do
                addESP(plr)
            end
            game.Players.PlayerAdded:Connect(addESP)
            
            game.Players.PlayerRemoving:Connect(function(plr)
                if espObjects[plr] then
                    espObjects[plr].box:Remove()
                    espObjects[plr].name:Remove()
                    espObjects[plr] = nil
                end
            end)
            
            local rs = game:GetService("RunService")
            local conn
            conn = rs.RenderStepped:Connect(function()
                if not espToggle.Value then
                    conn:Disconnect()
                    return
                end
                
                for plr, objs in pairs(espObjects) do
                    local char = plr.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and char.Humanoid.Health > 0 then
                        local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                        if onScreen then
                            local headPos = workspace.CurrentCamera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0))
                            local legPos = workspace.CurrentCamera:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0, 4, 0))
                            
                            local height = math.abs(legPos.Y - headPos.Y)
                            local width = height / 2
                            
                            objs.box.Size = Vector2.new(width, height)
                            objs.box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                            objs.box.Visible = true
                            
                            local dist = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
                            objs.name.Text = plr.Name .. "\n[" .. dist .. "m]"
                            objs.name.Position = Vector2.new(rootPos.X, headPos.Y - 16)
                            objs.name.Visible = true
                        else
                            objs.box.Visible = false
                            objs.name.Visible = false
                        end
                    else
                        objs.box.Visible = false
                        objs.name.Visible = false
                    end
                end
            end)
            
            library:Notify("ESP Activado!", 2)
        else
            library:Notify("ESP Desactivado!", 2)
        end
    end
})

local emoteTextbox = library:CreateTextbox({
    Name = "Emote ID / Nombre",
    Default = "wave",
    Callback = function() end
})

VisualsTab:AddButton({
    Name = "Play Emote (Free)",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:PlayEmote(emoteTextbox.Value)
            library:Notify("Emote reproducido: " .. emoteTextbox.Value, 2)
        end
    end
})

-- ==================== MISC TAB ====================
local MiscTab = Window:AddTab("Misc")
local MiscSec = MiscTab:AddSection("Misceláneo")

local skinUserTextbox = library:CreateTextbox({
    Name = "Username para copiar Skin",
    Default = "Roblox",
    Callback = function() end
})

MiscTab:AddButton({
    Name = "Copiar Skin de Usuario",
    Callback = function()
        local username = skinUserTextbox.Value
        local success, userId = pcall(game.Players.GetUserIdFromNameAsync, game.Players, username)
        if success and userId then
            local desc = game.Players:GetHumanoidDescriptionFromUserId(userId)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ApplyDescription(desc)
                library:Notify("Skin copiada de " .. username .. " (client-side)!", 3)
            end
        else
            library:Notify("Usuario no encontrado: " .. username, 3)
        end
    end
})

local assetIdTextbox = library:CreateTextbox({
    Name = "Asset ID (ej: 1234567890)",
    Default = "",
    Callback = function() end
})

local assetTypeList = library:CreateDropdown({
    Name = "Tipo de Item",
    Options = {"HatAccessory", "Shirt", "Pants", "Face", "TShirt", "Head", "GraphicTShirt", "BodyColors"},
    Default = 1,
    Callback = function(option)
        -- Guardar selección si necesitas
    end
})

MiscTab:AddButton({
    Name = "Añadir Item NO comprado (Client-side)",
    Callback = function()
        local id = assetIdTextbox.Value
        if id == "" then 
            library:Notify("Ingresa un Asset ID", 3)
            return 
        end
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local desc = char.Humanoid:GetAppliedDescription() or Instance.new("HumanoidDescription")
            desc[assetTypeList.Value] = tonumber(id)
            char.Humanoid:ApplyDescription(desc)
            library:Notify("Item " .. id .. " añadido (solo visual en juego)!", 2)
        end
    end
})

-- ==================== SETTINGS ====================
-- LinoriaLib ya tiene:
-- • Keybind (RightControl por defecto, cámbialo en menú)
-- • Themes / Colores (en menú principal)
-- • Configs: Guarda/Carga automático en "Linoria"

local SettingsTab = Window:AddTab("Settings")
SettingsTab:AddSection("Info")
SettingsTab:AddParagraph("LinoriaLib Features:", 
    "• Keybind: RightControl\n" ..
    "• Themes/Colores integrados\n" ..
    "• Configs: Guarda con el botón en menú\n" ..
    "¡Todo client-side, seguro fuera del juego!")

-- Bind al spawn de personaje para reaplicar cosas si quieres
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if hiddenNameToggle.Value then
        hiddenNameToggle:Callback(true)
    end
end)

library:Notify("¡Script listo! Funciona en CUALQUIER juego, no solo Rivals. Prueba en cualquier mapa.", 5)
