local FierceHub = {}
FierceHub.Version = "1.0"
FierceHub.Enabled = true
FierceHub.Connections = {}

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

FierceHub.FierceSight = {
    Enabled = false,
    Highlight = nil
}

function FierceHub.FierceSight:Refresh()
    if self.Highlight then self.Highlight:Destroy() end
    local dad = Services.Workspace:FindFirstChild("Dad") or Services.Workspace:FindFirstChild("Jerry")
    if not dad then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "FierceSight_Dad"
    highlight.Adornee = dad
    highlight.FillColor = Color3.fromRGB(192, 192, 192)
    highlight.OutlineColor = Color3.fromRGB(220, 220, 255)
    highlight.FillTransparency = 0.35
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = dad
    self.Highlight = highlight
end

function FierceHub.FierceSight:Enable()
    self.Enabled = true
    self:Refresh()
    table.insert(FierceHub.Connections, Services.Workspace.ChildAdded:Connect(function(child)
        if self.Enabled and (child.Name == "Dad" or child.Name == "Jerry") then
            task.wait(0.6)
            self:Refresh()
        end
    end))
end

function FierceHub.FierceSight:Disable()
    self.Enabled = false
    if self.Highlight then
        self.Highlight:Destroy()
        self.Highlight = nil
    end
end

FierceHub.UtilityGod = {
    Enabled = false,
    Connection = nil
}

function FierceHub.UtilityGod:ProcessAll()
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = 0
            obj.MaxActivationDistance = 40
            obj.RequiresLineOfSight = false
        end
    end
end

function FierceHub.UtilityGod:Enable()
    self.Enabled = true
    self:ProcessAll()
    self.Connection = Services.Workspace.DescendantAdded:Connect(function(desc)
        if self.Enabled and desc:IsA("ProximityPrompt") then
            desc.HoldDuration = 0
            desc.MaxActivationDistance = 40
            desc.RequiresLineOfSight = false
        end
    end)
    table.insert(FierceHub.Connections, self.Connection)
end

function FierceHub.UtilityGod:Disable()
    self.Enabled = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

FierceHub.Adrenaline = {
    Enabled = false,
    Speed = 55,
    Connection = nil
}

function FierceHub.Adrenaline:Enable()
    self.Enabled = true
    self.Connection = Services.RunService.Heartbeat:Connect(function(deltaTime)
        if not self.Enabled or not HumanoidRootPart then return end
        local moveDir = HumanoidRootPart.CFrame.LookVector
        local offset = moveDir * self.Speed * deltaTime
        HumanoidRootPart.CFrame += offset
    end)
    table.insert(FierceHub.Connections, self.Connection)
end

function FierceHub.Adrenaline:Disable()
    self.Enabled = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

function FierceHub:Shutdown()
    FierceHub.FierceSight:Disable()
    FierceHub.UtilityGod:Disable()
    FierceHub.Adrenaline:Disable()
    for _, conn in ipairs(FierceHub.Connections) do
        if conn then conn:Disconnect() end
    end
    FierceHub.Connections = {}
end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/lib'))()

local Window = Rayfield:CreateWindow({
    Name = "Fierce Hub",
    LoadingTitle = "Fierce Hub",
    LoadingSubtitle = "Weird Strict Dad • v" .. FierceHub.Version,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FierceHub",
        FileName = "Config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local VisualsTab = Window:CreateTab("Visuals", "eye")

VisualsTab:CreateToggle({
    Name = "Fierce Sight (Dad ESP - Silver)",
    CurrentValue = false,
    Flag = "FierceSight",
    Callback = function(Value)
        if Value then
            FierceHub.FierceSight:Enable()
        else
            FierceHub.FierceSight:Disable()
        end
    end
})

local UtilityTab = Window:CreateTab("Utility", "wrench")

UtilityTab:CreateToggle({
    Name = "Utility God (Instant Chores & Shopping)",
    CurrentValue = false,
    Flag = "UtilityGod",
    Callback = function(Value)
        if Value then
            FierceHub.UtilityGod:Enable()
        else
            FierceHub.UtilityGod:Disable()
        end
    end
})

local MovementTab = Window:CreateTab("Movement", "zap")

MovementTab:CreateSlider({
    Name = "Adrenaline Speed",
    Range = {20, 120},
    Increment = 1,
    CurrentValue = 55,
    Flag = "AdrenalineSpeed",
    Callback = function(Value)
        FierceHub.Adrenaline.Speed = Value
    end
})

MovementTab:CreateToggle({
    Name = "Adrenaline (TP Walk - Rage Mode Bypass)",
    CurrentValue = false,
    Flag = "Adrenaline",
    Callback = function(Value)
        if Value then
            FierceHub.Adrenaline:Enable()
        else
            FierceHub.Adrenaline:Disable()
        end
    end
})

local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateButton({
    Name = "Shutdown Fierce Hub",
    Callback = function()
        FierceHub:Shutdown()
        Rayfield:Destroy()
    end
})

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

print("Fierce Hub v" .. FierceHub.Version .. " loaded - systems architect approved.")
