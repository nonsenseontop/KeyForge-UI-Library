

local repo
if game:GetService("UserInputService").TouchEnabled or game:GetService("UserInputService").GamepadEnabled then
    repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
    print("Mobile Loaded")
else
    repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
    print("PC Loaded")
end

-- // UI Library
local success, KeyForge = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/nonsenseontop/KeyForge-UI-Library/master/KeyForgeUILibrary.lua"))() end)
if not success or not KeyForge then
    error("Failed to load KeyForge UI Library. Please check the GitHub repository and URL accessibility.")
end
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- // Get Player Info
local LocalPlayer = game:GetService("Players").LocalPlayer
local Username = LocalPlayer.Name

-- // Show Notification on Script Load
KeyForge:Notify("Welcome Thank you for using Very Fed - " .. Username .. " 👏", 5)
task.wait(1) 

-- // Create Main UI Window
local Window = KeyForge:CreateWindow({
    Title = 'very fed | ' .. tostring(identifyexecutor()),
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- // Tabs
local Tabs = {
    Main = Window:AddTab('Exclusives', 'star'),
    Player = Window:AddTab('Player', 'user'),
    Vuln = Window:AddTab('Vulnerablities', 'circle-dollar-sign'),
    Combat = Window:AddTab('Aiming', 'circle-plus'),
    Bypasses = Window:AddTab('Bypasses', 'shield'),
    ['Settings'] = Window:AddTab('Settings', 'settings'),
}

-- // Create Groupboxes
local DupeBox = Tabs.Vuln:AddLeftGroupbox("Infinite Money Vuln 💵")
local Tele = Tabs.Main:AddLeftGroupbox('Teleport ⏩')
local QuickShop = Tabs.Main:AddLeftGroupbox('Quick Shop 🛒')
local QuickFits = Tabs.Main:AddRightGroupbox('Quick Fits 👚')


local ATMBank = Tabs.Main:AddRightGroupbox('ATM / Bank 💳')
local Blrhhx = Tabs.Main:AddRightGroupbox('Money Drops 💵')

local Misc = Tabs.Main:AddRightGroupbox('Misc 🪀')
local TargetBox = Tabs.Player:AddLeftGroupbox("Target 🔫")
local Troll = Tabs.Player:AddLeftGroupbox("Troll 😂")

--local TeleportBox = Tabs.Combat:AddLeftGroupbox("Teleports")
local Movement = Tabs.Player:AddRightGroupbox("Movement 👥")
local ExtraBox = Tabs.Bypasses:AddLeftGroupbox("Bypasses 🛡️")
local GunColor = Tabs.Bypasses:AddRightGroupbox("Gun Color 🔫")
-- local Autofarm = Tabs.Autofarm:AddLeftGroupbox("Autofarm")




local Extra = Tabs.Combat:AddLeftGroupbox("HitBox 🎯")
local FunHi = Tabs.Combat:AddLeftGroupbox("Fun Combat 🎯")
local Gun = Tabs.Combat:AddRightGroupbox("Gun Mods 🔫")
local Farm = Tabs.Main:AddRightGroupbox('Quick Farms 🧺')

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character
local humanoidRootPart
local humanoid

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer



local function updateCharacterReferences()
    character = player.Character or player.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end

updateCharacterReferences()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local humanoidRootPart

-- ✅ Always get HumanoidRootPart, even after respawn
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

humanoidRootPart = getHRP()
LocalPlayer.CharacterAdded:Connect(function(char)
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Movement variables
local speed = 16
local flightSpeed = 50
local boostMultiplier = 2
local acceleration = 3 -- higher = faster accel

local enhancedWalk = false
local flying = false
local bodyVelocity, bodyGyro
local targetVelocity = Vector3.zero
local currentVelocity = Vector3.zero

-- Helper
local function cleanupMovement()
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    bodyVelocity, bodyGyro = nil, nil
end

local function smoothApproach(current, target, rate)
    return current + (target - current) * math.clamp(rate, 0, 1)
end

-- 🚶 Enhanced Walk
local function startEnhancedWalk()
    if enhancedWalk then return end
    enhancedWalk = true
    cleanupMovement()

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyGyro.P = 2000
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart

    RunService.RenderStepped:Connect(function(deltaTime)
        if not enhancedWalk or not humanoidRootPart then return end

        local camera = workspace.CurrentCamera
        local moveDir = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z) end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z) end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end

        local maxSpeed = speed
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then maxSpeed *= boostMultiplier end

        if moveDir.Magnitude > 0 then
            targetVelocity = moveDir.Unit * maxSpeed
        else
            targetVelocity = Vector3.zero
        end

        currentVelocity = smoothApproach(currentVelocity, targetVelocity, acceleration * deltaTime)
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, humanoidRootPart.AssemblyLinearVelocity.Y, currentVelocity.Z)

        bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z))
    end)
end

-- ✈️ Flying
local function startFlying()
    if flying then return end
    flying = true
    cleanupMovement()

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.P = 5000
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = humanoidRootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 5000
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart

    RunService.RenderStepped:Connect(function(deltaTime)
        if not flying or not humanoidRootPart then return end

        local camera = workspace.CurrentCamera
        local moveDir = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end

        local maxSpeed = flightSpeed
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then maxSpeed *= boostMultiplier end

        if moveDir.Magnitude > 0 then
            targetVelocity = moveDir.Unit * maxSpeed
        else
            targetVelocity = Vector3.zero
        end

        currentVelocity = smoothApproach(currentVelocity, targetVelocity, acceleration * deltaTime)
        bodyVelocity.Velocity = currentVelocity
        bodyGyro.CFrame = camera.CFrame
    end)
end

-- ⏹ Stop functions
local function stopEnhancedWalk()
    enhancedWalk = false
    cleanupMovement()
    currentVelocity = Vector3.zero
end

local function stopFlying()
    flying = false
    cleanupMovement()
    currentVelocity = Vector3.zero
end





-- GUI Toggle for Enhanced Walking


-- Speed Slider for Walkspeed
Movement:AddSlider('WalkspeedSlider', {
    Text = 'Change Walkspeed',
    Default = 16,
    Min = 16,
    Max = 300,
    Rounding = 1,
    Callback = function(value)
        speed = value
    end
})


-- Speed Slider for Flight Speed
Movement:AddSlider('FlightSpeedSlider', {
    Text = 'Change Fly Speed',
    Default = 100,
    Min = 50,
    Max = 2000,
    Rounding = 0,
    Callback = function(value)
        flightSpeed = value
    end
})
-- Character Respawn Handling
player.CharacterAdded:Connect(function()
    updateCharacterReferences()
    cleanupMovement()
    if enhancedWalk then startEnhancedWalk() end
    if flying then stopFlying() end -- Ensure flight stops completely before restarting
end)






Troll:AddButton("Spam Call Police", function()
    for i = 1,getgenv().intsdp do
        task.wait(0.05)
        game:GetService("ReplicatedStorage").CallPolice:FireServer()
    end
end)


local localPlayer = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local isMoving = {W = false, A = false, S = false, D = false} -- Table to track movement keys
local multiplier = 1  -- Default multiplier (adjustable by the slider)
local movementEnabled = false -- Movement starts disabled
local SwimMethodEnabled = false -- Freefall starts disabled
local currentWalkSpeed = 16  -- Default Walkspeed

-- Display a hint for 2 seconds
task.spawn(function()
    local hint = Instance.new("Hint", workspace)
    task.wait(2)
    hint:Destroy()
end)

-- Function to move the character based on key input
local function moveCharacter()
    if movementEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local direction = Vector3.new(0, 0, 0)
        local camera = workspace.CurrentCamera

        -- Adjust the direction based on pressed keys
        if isMoving.W then
            direction = direction + Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z) -- Forward
        end
        if isMoving.A then
            direction = direction - Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z) -- Left
        end
        if isMoving.S then
            direction = direction - Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z) -- Backward
        end
        if isMoving.D then
            direction = direction + Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z) -- Right
        end

        -- Normalize direction and move the character
        if direction.Magnitude > 0 then
            direction = direction.Unit * multiplier
            localPlayer.Character.HumanoidRootPart.CFrame = localPlayer.Character.HumanoidRootPart.CFrame + direction
        end
    end
end

-- Key press detection for W, A, S, D
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        isMoving.W = true
    elseif input.KeyCode == Enum.KeyCode.A then
        isMoving.A = true
    elseif input.KeyCode == Enum.KeyCode.S then
        isMoving.S = true
    elseif input.KeyCode == Enum.KeyCode.D then
        isMoving.D = true
    end
end)

-- Stop moving when the key is released
uis.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.W then
        isMoving.W = false
    elseif input.KeyCode == Enum.KeyCode.A then
        isMoving.A = false
    elseif input.KeyCode == Enum.KeyCode.S then
        isMoving.S = false
    elseif input.KeyCode == Enum.KeyCode.D then
        isMoving.D = false
    end
end)

-- Update the character's position every frame based on key input
rs.RenderStepped:Connect(moveCharacter)



-- Freefall Method Logic
getgenv().SwimMethod = false

task.spawn(function()
    while task.wait() do
        if getgenv().SwimMethod then
            local player = game:GetService("Players").LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                humanoid:ChangeState(Enum.HumanoidStateType.FallingDown     )
            end
        end
    end
end)
print("bypassed lol")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

local movementEnabled = false
local currentWalkSpeed = 16  -- Default speed

--- Movement:AddSlider('WalkspeedSlider', {
   ---  Text = 'Change Walkspeed',
  ---   Default = 16,
  ---   Min = 16,
  ---   Max = 300,
 ---    Rounding = 1,
  ---   Callback = function(value)
  ---       currentWalkSpeed = value  -- Save the new speed
  ---   end
--- })




Movement:AddSlider('JumpPowerSlider', {
    Text = 'Change Jump Height',
    Default = 1,  -- Default jump height
    Min = 1,  -- Minimum jump height
    Max = 20000,  -- Maximum jump height
    Rounding = 1,
    Callback = function(value)
        currentJumpPower = value  -- Save the new jump height
        local humanoid = game.Players.LocalPlayer.Character.Humanoid
        if jumpPowerEnabled then
            humanoid.JumpHeight = value  -- Change jump height in real-time
        else
            humanoid.JumpHeight = 9  -- Set jump height to 9 when disabled
        end
    end
})



Movement:AddToggle('EnableWalkspeed', {
    Text = 'Walkspeed',
    Default = false,  
    Callback = function(enabled)
        if enabled then
            startEnhancedWalk()
        else
            stopEnhancedWalk()
        end
    end
})

-- GUI Toggle for Flight
Movement:AddToggle('EnableFlight', {
    Text = 'Vehicle Fly',
    Default = false,  
    Callback = function(enabled)
        if enabled then
            startFlying()
        else
            stopFlying()
        end
    end
})


Movement:AddToggle('EnableJumpPower', {
    Text = 'Jump Power',
    Default = false,  -- Default to off
    Callback = function(Value)
        if Value then
            -- Enable Jump Power with the current jump power (don't reset to 50)
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = currentJumpPower
            jumpPowerEnabled = true  -- Enable jump power when toggle is on
        else
            -- Disable Jump Power
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 0  -- Disable jump power if toggle is off
            jumpPowerEnabled = false  -- Disable jump power when toggle is off
        end
    end
})

local noclip = false

-- Function to toggle noclip
local function toggleNoclip()
    noclip = not noclip
    if noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end
-- Create the toggle button for Infinite Jump
local infJump
local infJumpDebounce = false
local UserInputService = game:GetService("UserInputService")

Movement:AddToggle('InfiniteJumpToggle', {
    Text = 'Infinite Jump',
    Default = false,  -- Default to off
    Callback = function(Value)
        local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
        
        -- If Infinite Jump is enabled
        if Value then
            -- Disconnect any previous infinite jump connections
            if infJump then
                infJump:Disconnect()
            end
            infJumpDebounce = false

            -- Set up the infinite jump logic
            infJump = UserInputService.JumpRequest:Connect(function()
                if not infJumpDebounce then
                    infJumpDebounce = true
                    -- Make the humanoid jump
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        wait(0.1)  -- Ensure the jump state is set
                        humanoid:ChangeState(Enum.HumanoidStateType.Seated)  -- Optionally simulate landing
                    end
                    infJumpDebounce = false
                end
            end)

        else
            -- Disable infinite jump when toggle is off
            if infJump then
                infJump:Disconnect()
            end
            infJumpDebounce = false
        end
    end
})



-- Create the toggle button for noclip
Movement:AddToggle('NoclipToggle', {
    Text = 'Noclip',
    Default = false,  -- Default to off
    Callback = function(Value)
        toggleNoclip(Value)  -- Call the toggleNoclip function when the toggle state changes
    end
})

-- Infinite Jump Script with Toggle Control

-- Services
-- Use getgenv() to store the infinite jump state globally

-- // Infinite Stamina
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Infinite Stamina Toggle
ExtraBox:AddToggle('InfiniteStamina', {
    Text = 'Infinite Stamina', 
    Default = false,
    Callback = function(Value)
        local StaminaBar = LocalPlayer.PlayerGui:FindFirstChild("Run") and 
                           LocalPlayer.PlayerGui.Run.Frame.Frame.Frame:FindFirstChild("StaminaBarScript")
        if StaminaBar then
            StaminaBar.Enabled = not Value
        end
    end
})

-- Infinite Hunger Toggle
ExtraBox:AddToggle('InfiniteHunger', {
    Text = 'Infinite Hunger',
    Default = false,
    Callback = function(Value)
        local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
        local hungerBar = playerGui.Hunger.Frame.Frame.Frame:FindFirstChild("HungerBarScript")

        if hungerBar then
            hungerBar.Enabled = not Value
        end
    end
})

-- Infinite Sleep Toggle
ExtraBox:AddToggle('InfiniteSleep', {
    Text = 'Infinite Sleep',
    Default = false,
    Callback = function(Value)
        local sleepGui = game:GetService("Players").LocalPlayer.PlayerGui.SleepGui
        local sleepBar = sleepGui.Frame.sleep.SleepBar:FindFirstChild("sleepScript")

        if sleepBar then
            sleepBar.Enabled = not Value
        end
    end
})

-- No Rent Pay Toggle
ExtraBox:AddToggle('NoRentPay', {
    Text = 'No Rent Pay',
    Default = false,
    Callback = function(Value)
        local rentGui = game:GetService("StarterGui").RentGui
        local rentScript = rentGui:FindFirstChild("LocalScript")

        if rentScript then
            rentScript.Enabled = not Value
        end
    end
})

-- Instant Interaction Toggle
ExtraBox:AddToggle('InstantInteraction', {
    Text = 'Instant Prompt', 
    Default = false,
    Callback = function(Value)
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = Value and 0 or 1
                v.RequiresLineOfSight = not Value
            end
        end
    end
})

-- Remove Jump Cooldown Toggle
local JumpDebounceBackup

ExtraBox:AddToggle('RemoveJumpCooldown', {
    Text = 'Remove Jump Cooldown', 
    Default = false,
    Callback = function(Value)
        local JumpDebounce = LocalPlayer.PlayerGui:FindFirstChild("JumpDebounce")
        if Value then
            if JumpDebounce then
                JumpDebounceBackup = JumpDebounce:Clone()
                JumpDebounce:Destroy()
            end
        else
            if not LocalPlayer.PlayerGui:FindFirstChild("JumpDebounce") and JumpDebounceBackup then
                JumpDebounceBackup.Parent = LocalPlayer.PlayerGui
                JumpDebounceBackup = nil
            end
        end
    end
})

-- Anti Fall Damage Toggle
ExtraBox:AddToggle('AntiFallDamage', {
    Text = 'Anti Fall Damage', 
    Default = false,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChild("Humanoid")
        local fallDamage = character:FindFirstChild("FallDamageRagdoll")

        if humanoid and fallDamage then
            if Value then
                fallDamage:Destroy() 
            else
               
                print("Fall damage enabled.")  -- For example, you could re-enable fall damage here if needed
            end
        end
    end
})
ExtraBox:AddToggle('AntiJumpCooldown', {
    Text = 'Anti Jump Cooldown',
    Default = false,
    Callback = function(Value)
        local localPlayer = game:GetService("Players").LocalPlayer
        local jumpDebounce = localPlayer.PlayerGui:FindFirstChild("JumpDebounce")
        local localScript = jumpDebounce and jumpDebounce:FindFirstChild("LocalScript")

        if localScript then
            if Value then
                localScript.Enabled = false
            else
                localScript.Enabled = true
            end
        end
    end
})

--//

GunColor:AddLabel("Change Gun Color (CLIENT SIDE ONLY)")
GunColor:AddToggle('Gun changing', {Text = "Change CURRENT Item Color.", Default = false, Callback = function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    -- Store original data so we can revert later
    local originalData = {}

    local function applyEffect(tool)
        if not tool then return end
        for _, part in ipairs(tool:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Save original properties if not already saved
                if not originalData[part] then
                    originalData[part] = {
                        Color = part.Color,
                        Material = part.Material
                    }
                end

                -- Apply forcefield effect
                part.Color = Color3.fromRGB(0, 255, 255) -- your color
                part.Material = Enum.Material.ForceField
            end
        end
    end

    local function revertEffect()
        for part, data in pairs(originalData) do
            if part and part.Parent then
                part.Color = data.Color
                part.Material = data.Material
            end
        end
        originalData = {} -- clear stored data
    end

    if state then
        -- Apply to current tool
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            applyEffect(tool)
        end

        -- Detect new tools
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                applyEffect(child)
            end
        end)
    else
        revertEffect()
    end
end})


--Main 

local lastDupeTime = 0
local cooldownTime = 1 

task.spawn(function()
    while task.wait() do
        if getgenv().SwimMethod then
            local player = game:GetService("Players").LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
            end
        end
    end
end)
DupeBox:AddButton('Trunk Dupe', function()
    local currentTime = os.time()

    if currentTime - lastDupeTime < cooldownTime then
        return
    end

    lastDupeTime = currentTime
    getgenv().SwimMethod = true 

    task.wait(0.8)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")

    local function GetCharacter()
        return Players.LocalPlayer and Players.LocalPlayer.Character
    end

local function BypassTp(targetCFrame)
    local character = GetCharacter()
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Teleport the character by directly setting their CFrame
        character.HumanoidRootPart.CFrame = targetCFrame + Vector3.new(2, 0, 0)
    end
end

    local function FindTrunkPrompt()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                if obj.ActionText == "Open Storage" and obj.ObjectText == "Trunk" then
                    return obj.Parent
                end
            end
        end
    end

    -- Function to check if remotes exist
    local function GetRemote(remoteName)
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if not remote then
            warn(remoteName .. " not found in ReplicatedStorage!")
        end
        return remote
    end

    -- Get Inventory and Backpack remotes with error handling
    local InventoryRemote = GetRemote("TrunkStorage")
    local BackpackRemote = GetRemote("BackpackRemote")

    -- Handle cases where the remotes might be nil
    if not InventoryRemote or not BackpackRemote then
        print("Missing remotes! Cannot proceed with the dupe.")
        getgenv().SwimMethod = false
        return
    end

    local character = GetCharacter()
    if character and character:FindFirstChildOfClass("Tool") then
        local gunTool = character:FindFirstChildOfClass("Tool")
        local gunName = gunTool.Name

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:UnequipTools() end

        local trunk = FindTrunkPrompt()
        if not trunk then 
            getgenv().SwimMethod = false 
            return 
        end

        local oldCFrame = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.CFrame

        BypassTp(trunk.CFrame)
        task.wait(0.5)

        -- Perform the action (e.g., store gun in trunk)
        task.spawn(function()
            BackpackRemote:InvokeServer("Store", gunName)
        end)

        task.spawn(function()
            InventoryRemote:FireServer("Store", gunName, "Backpack", trunk)
        end)

        task.wait(0.5)

        if oldCFrame then
            BypassTp(oldCFrame)
        end

        task.wait(1.2)

        -- Grab the gun after storing
        BackpackRemote:InvokeServer("Grab", gunName)

        task.wait(0.5)

        if oldCFrame then
            BypassTp(oldCFrame)
        end

        getgenv().SwimMethod = false 
    else
        getgenv().SwimMethod = false 
    end
end)



DupeBox:AddButton('Market Dupe', function()
loadstring(game:HttpGet("https://pastefy.app/D7oclHQ0/raw"))()
end)
DupeBox:AddButton('Safe Dupe', function()
    local currentTime = os.time()

    if currentTime - lastDupeTime < cooldownTime then
        return
    end

    lastDupeTime = currentTime
    getgenv().SwimMethod = true 

    task.wait(0.8)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")

    local function GetCharacter()
        return Players.LocalPlayer and Players.LocalPlayer.Character
    end

function BypassTp(targetCFrame)
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
KeyForge:Notify("Error: Character not ready for teleport", 3)
        return
    end

    local hrp = character.HumanoidRootPart

    -- Activate Freefall (SwimMethod)
    getgenv().SwimMethod = true

    -- Wait briefly before teleporting
    task.wait(0.1)

    -- Teleport the HumanoidRootPart slightly offset
    hrp.CFrame = targetCFrame + Vector3.new(2, 0, 0)

    -- Wait briefly after teleporting
    task.wait(0.1)

    -- Deactivate Freefall
    getgenv().SwimMethod = false

    Library:Notify("Bypass teleport executed", 3)
end




    local InventoryRemote = ReplicatedStorage:WaitForChild("Inventory")
    local BackpackRemote = ReplicatedStorage:WaitForChild("BackpackRemote")

    local character = GetCharacter()
    if character and character:FindFirstChildOfClass("Tool") then
        local gunTool = character:FindFirstChildOfClass("Tool")
        local gunName = gunTool.Name

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:UnequipTools() end

        local safe = workspace:FindFirstChild("1# Map") 
                 and workspace["1# Map"]:FindFirstChild("2 Crosswalks") 
                 and workspace["1# Map"]["2 Crosswalks"].Safes:GetChildren()[3]
        if not safe then 
            getgenv().SwimMethod = false 
            return 
        end

        local oldCFrame = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.CFrame

        BypassTp(safe.Union.CFrame)
        task.wait(0.5)

        task.spawn(function()
            BackpackRemote:InvokeServer("Store", gunName)
        end)

        task.spawn(function()
            InventoryRemote:FireServer("Change", gunName, "Backpack", safe)
        end)

        task.wait(0.5)

        if oldCFrame then
            BypassTp(oldCFrame)
        end

        task.wait(1.2)

        BackpackRemote:InvokeServer("Grab", gunName)

        task.wait(0.5)

        if oldCFrame then
            BypassTp(oldCFrame)
        end

        getgenv().SwimMethod = false 
    else
        getgenv().SwimMethod = false 
    end
end)

DupeBox:AddDivider()

DupeBox:AddButton('Buy KoolAid Essentials', function()
local player = game.Players.LocalPlayer
repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local character = player.Character
local hrp = character:FindFirstChild("HumanoidRootPart")

local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local ShopRemote = ReplicatedStorage:WaitForChild("ShopRemote")
local ExoticShopRemote = ReplicatedStorage:WaitForChild("ExoticShopRemote")

local Backpack = player:WaitForChild("Backpack")

--// Functions
function teleport(position)
    local character = player.Character
    if not character then
        Library:Notify("Error: Character not found", 3)
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Library:Notify("Error: HumanoidRootPart missing", 3)
        return
    end

    -- Activate Freefall (SwimMethod)
    getgenv().SwimMethod = true

    -- Wait a moment before teleporting
    task.wait(0.5)

    -- Teleport the HumanoidRootPart to the position
    hrp.CFrame = CFrame.new(position)

    -- Deactivate Freefall
    getgenv().SwimMethod = false

    Library:Notify("Teleported to position", 3)
end



local function BuyItem(itemName)
    ExoticShopRemote:InvokeServer(itemName)
end

local function nearprompt(filterText)
    local closestPrompt, minDistance = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled and v.Parent and (v.Parent:IsA("BasePart") or v.Parent:IsA("Attachment")) then
            if filterText and not v.ActionText:find(filterText) then continue end
            local part = v.Parent:IsA("Attachment") and v.Parent.Parent or v.Parent
            if part and part:IsA("BasePart") then
                local distance = (hrp.Position - part.Position).Magnitude
                if distance < minDistance then
                    closestPrompt, minDistance = v, distance
                end
            end
        end
    end
    return closestPrompt
end

local function fireprompt(prompt)
    if prompt then
        prompt.HoldDuration = 0
        fireproximityprompt(prompt)
    end
end

local function equipTool(name)
    local tool = Backpack:FindFirstChild(name) or character:FindFirstChild(name)
    if tool then
        character.Humanoid:EquipTool(tool)
        task.wait(0.2)
    end
end

local function useTool(name)
    equipTool(name)
    local prompt = nearprompt()
    if prompt then
        fireprompt(prompt)
    end
    task.wait(2)
end

--// GUI


--// MAIN

-- Create GUI first
-- Now teleport to shop
teleport(Vector3.new(-1608.934326171875, 253.8587188720703, -485.9544677734375))
task.wait(1)

-- Buy items
BuyItem("FreshWater")
task.wait(1)
BuyItem("FijiWater")
task.wait(1)
BuyItem("Ice-Fruit Bag")
task.wait(1)
BuyItem("Ice-Fruit Cupz")
task.wait(1)


task.wait(2)

useTool("FreshWater")
useTool("FreshWater")

useTool("FijiWater")

useTool("Ice-Fruit Bag")




while true do
    task.wait(0.5)
    local fillPrompt = nearprompt("Fill Pitcher Cup")
    if fillPrompt then
        equipTool("Ice-Fruit Cupz")
        fireprompt(fillPrompt)

        break
    end
end



task.wait(1)
cookingGui:Destroy()
end)

local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

local v11 = {}
v11.Font = Enum.Font.SourceSans
v11.MainColor = Color3.fromRGB(40, 40, 40)
v11.OutlineColor = Color3.fromRGB(20, 20, 20)
v11.AccentColor = Color3.fromRGB(0, 150, 255)
v11.Registry = {}
v11.RegistryMap = {}
v11.HudRegistry = {}

local v12 = Instance.new("ScreenGui")
v12.IgnoreGuiInset = true
v12.ResetOnSpawn = false
v12.Name = "NotificationGui"
v12.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

function v11:Create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do
        inst[i] = v
    end
    return inst
end

v11.NotificationArea = v11:Create('Frame', {
    BackgroundTransparency = 1;
    Position = UDim2.new(0, 0, 0, 40);
    Size = UDim2.new(0, 300, 0, 200);
    ZIndex = 100;
    Parent = v12;
})

v11:Create('UIListLayout', {
    Padding = UDim.new(0, 4);
    FillDirection = Enum.FillDirection.Vertical;
    SortOrder = Enum.SortOrder.LayoutOrder;
    Parent = v11.NotificationArea;
})

function v11:GetTextBounds(Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end

function v11:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end

v11.AccentColorDark = v11:GetDarkerColor(v11.AccentColor)

function v11:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #v11.Registry + 1;
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    };

    table.insert(v11.Registry, Data);
    v11.RegistryMap[Instance] = Data;

    if IsHud then
        table.insert(v11.HudRegistry, Data);
    end;
end

function v11:RemoveFromRegistry(Instance)
    local Data = v11.RegistryMap[Instance];

    if Data then
        for Idx = #v11.Registry, 1, -1 do
            if v11.Registry[Idx] == Data then
                table.remove(v11.Registry, Idx);
            end;
        end;

        for Idx = #v11.HudRegistry, 1, -1 do
            if v11.HudRegistry[Idx] == Data then
                table.remove(v11.HudRegistry, Idx);
            end;
        end;

        v11.RegistryMap[Instance] = nil;
    end;
end

function v11:CreateLabel(props)
    props.TextColor3 = Color3.new(1,1,1)
    props.BackgroundTransparency = 1
    props.Font = v11.Font
    return v11:Create('TextLabel', props)
end

function v11:Notify(Text, Time)
    local v13, v14 = v11:GetTextBounds(Text, v11.Font, 14);
    v14 = v14 + 7

    local v15 = v11:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 2);
        Size = UDim2.new(0, 0, 0, v14);
        ClipsDescendants = true;
        ZIndex = 100;
        Parent = v11.NotificationArea;
    });

    local v16 = v11:Create('Frame', {
        BackgroundColor3 = v11.MainColor;
        BorderColor3 = v11.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = v15;
    });

    v11:AddToRegistry(v16, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local v17 = v11:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 102;
        Parent = v16;
    });

    local v18 = v11:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, v11:GetDarkerColor(v11.MainColor)),
            ColorSequenceKeypoint.new(1, v11.MainColor),
        });
        Rotation = -90;
        Parent = v17;
    });

    v11:AddToRegistry(v18, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, v11:GetDarkerColor(v11.MainColor)),
                ColorSequenceKeypoint.new(1, v11.MainColor),
            });
        end
    });

    local v19 = v11:CreateLabel({
        Position = UDim2.new(0, 4, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        Text = Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = 14;
        ZIndex = 103;
        Parent = v17;
    });

    local v20 = v11:Create('Frame', {
        BackgroundColor3 = v11.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, -1, 0, -1);
        Size = UDim2.new(0, 3, 1, 2);
        ZIndex = 104;
        Parent = v15;
    });

    v11:AddToRegistry(v20, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    v15:TweenSize(UDim2.new(0, v13 + 8 + 4, 0, v14), 'Out', 'Quad', 0.4, true)

    task.spawn(function()
        wait(Time or 5);
        v15:TweenSize(UDim2.new(0, 0, 0, v14), 'Out', 'Quad', 0.4, true);
        wait(0.4);
        v15:Destroy();
    end);
end


DupeBox:AddButton('Infinite Money', function()


-- (( End )) --

-- ;; Main Function ;; --

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

function TeleportViaSeat(position)
    local character = player.Character
    if not character then
        Library:Notify("Error: Character not found", 3)
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Library:Notify("Error: HumanoidRootPart missing", 3)
        return
    end

    -- Activate Freefall (SwimMethod)
    getgenv().SwimMethod = true

    -- Wait a moment before teleporting
    task.wait(1)

    -- Teleport the HumanoidRootPart to the position
    hrp.CFrame = CFrame.new(position)

    -- Deactivate Freefall
    getgenv().SwimMethod = false

    Library:Notify("Teleported to position", 3)
end







-- 



local TeleportPosition = Vector3.new(-(3630.7261 - 2703), 35.136799999999994 + 218, -(1575.3687 - 884))

local function SpamPrompt(Prompt)
	local Total = 974000
	local BatchSize = 500
	for i = 1, Total, BatchSize do
		for j = 1, BatchSize do
			local Stored = Player:FindFirstChild("stored")
			local FilthyStack = Stored and Stored:FindFirstChild("FilthyStack")

			if FilthyStack and FilthyStack:IsA("IntValue") and (FilthyStack.Value == 990000 or FilthyStack.Value == 1600000) then
				TeleportViaSeat(TeleportPosition)
				if v11 and v11.Notify then
					v11:Notify("Finished! Clean your money now!", 3)
				end
				return
			end

			pcall(function()
				Prompt.HoldDuration = 0
				Prompt:InputHoldBegin()
				Prompt:InputHoldEnd()
			end)
		end
		task.wait()
	end
end

local function GoToJuice()


    local HRP = Character:WaitForChild("HumanoidRootPart")
    local OriginalPosition = HRP.Position

    for _, Obj in ipairs(workspace:GetDescendants()) do
        if Obj:IsA("ProximityPrompt") and Obj.ObjectText == "Juice" then
            local Part = Obj.Parent
            if Part and Part:IsA("BasePart") then
                -- Teleport near the Juice using seat method
                local OffsetPos = Vector3.new(-50.18476104736328, 286.7206115722656, -338.2304382324219)
                TeleportViaSeat(OffsetPos)

                task.wait(0.6) -- Wait to fully settle before next seat teleport

                -- Teleport directly to the Juice part (3 studs above and 3 forward)
                local juiceTargetPos = Part.Position + Vector3.new(0, 3, 3)
                TeleportViaSeat(juiceTargetPos)

                task.wait(0.6)

                -- Interact with the prompt
                SpamPrompt(Obj)

                task.wait(0.6)

                -- Return to original position
                TeleportViaSeat(OriginalPosition)

                break
            end
        end
    end
end

GoToJuice()
end)
DupeBox:AddLabel("Click Buy KoolAid Essentials")
DupeBox:AddLabel("It Should TP To Cook Them")
DupeBox:AddLabel("Wait Till Done And Click Infinite")
DupeBox:AddLabel("Money")

local Locations = {
    ["🔫 Gunshop"] = Vector3.new(92972.28125, 122097.953125, 17022.783203125),
    ["🔫 Gunshop 2"] = Vector3.new(66202, 123615.7109375, 5749.81591796875),
    ["🔫 Gunshop 3"] = Vector3.new(60819.78515625, 87609.140625, -347.30889892578),
    ["💼 Safe Items"] = Vector3.new(68514.8984375, 52941.5, -796.09197998047),
    ["🚧 Construction Site"] = Vector3.new(-1731.8306884766, 370.81228637695, -1176.8387451172),
    ["💎 Ice Box"] = Vector3.new(-249.57780456543, 283.51541137695, -1256.6583251953),
    ["🧊 Frozen Shop"] = Vector3.new(-225.86630249023, 283.84869384766, -1169.9425048828),
    ["👚 Drip Store"] = Vector3.new(67462.6953125, 10489.032226563, 549.58947753906),
    ["💳 Bank"] = Vector3.new(-240.43710327148, 283.62673950195, -1214.4128417969),
    ["🪝 Pawn Shop"] = Vector3.new(-1049.6430664063, 253.53065490723, -814.26971435547),
    ["🏠 Penthouse"] = Vector3.new(-(555.4557 - (360 + 65)), 392.4685 + 27, -(822.7767 - (79 + 175))),
    ["🍗 Chicken Wings"] = Vector3.new(-957.91418457031, 253.53065490723, -815.94421386719),
    ["🚚 Deli"] = Vector3.new(-927.72607421875, 253.73307800293, -691.36871337891),
    ["🚗 Car Dealer"] = Vector3.new(-410.52230834961, 253.25646972656, -1245.5539550781),
    ["🧼 Laundromat"] = Vector3.new(-987.75, 253.91, -682.57),
    ["🩹 Margreens"] = Vector3.new(-384.37, 254.45, -373.76),
    ["🏥 Hospital"] = Vector3.new(-1579.51, 253.95, 24.49),
    ["🏢 Roof Top"] = Vector3.new(-383.88, 340.52, -558.30),
    ["🎒 BackPack"] = Vector3.new(-676.00, 253.78, -685.84),
}

local function TableKeys(tbl)
    local keys = {}
    for key in pairs(tbl) do
        keys[#keys + 1] = key
    end
    return keys
end


local Player = game:GetService("Players").LocalPlayer
local SelectedLocation = nil

function TeleportToLocation()
    if not SelectedLocation then
        Library:Notify("Error: No location selected!", 3)
        return
    end

    local Character = Player.Character
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        Library:Notify("Error: Invalid Teleport Target!", 3)
        return
    end

    -- Step 1: Activate Freefall (SwimMethod)
    getgenv().SwimMethod = true

    -- Step 2: Wait 1 second before teleporting
    task.wait(1)

    -- Step 3: Teleport local player to SelectedLocation
    HumanoidRootPart.CFrame = CFrame.new(SelectedLocation)

    -- Step 4: Deactivate Freefall after teleportation
    getgenv().SwimMethod = false

    Library:Notify("Teleported to location", 3)
end

local LocationDropdown = Tele:AddDropdown('LocationDropdown', {
    Values = TableKeys(Locations),
    Default = "",
    Multi = false,
    Text = 'Select Location',
    Searchable = true,
    Callback = function(SelectedLocationName)
        if Locations[SelectedLocationName] then
            SelectedLocation = Locations[SelectedLocationName]
            Library:Notify("Location Found: " .. SelectedLocationName, 3)
            TeleportToLocation()
        else
            Library:Notify("Error: Location not found!", 3)
        end
    end
})

local player = game.Players.LocalPlayer
local gunsFolder = workspace:WaitForChild("GUNS")

local Guns = {} -- gunName => { Part = BuyPrompt.Parent, BuyPrompt = BuyPrompt }

for _, gunModel in ipairs(gunsFolder:GetChildren()) do
    local modelChild = gunModel:FindFirstChild("Model")
    if modelChild and modelChild:IsA("Model") then
        -- Find BuyPrompt anywhere inside modelChild
        local buyPrompt = modelChild:FindFirstChildWhichIsA("ProximityPrompt", true)
        if buyPrompt and buyPrompt.Name == "BuyPrompt" then
            local parentPart = buyPrompt.Parent
            if parentPart and parentPart:IsA("BasePart") then
                Guns[gunModel.Name] = {
                    Part = parentPart,
                    BuyPrompt = buyPrompt,
                }
            else
                print("BuyPrompt parent is not a BasePart for", gunModel.Name)
            end
        else
            print("BuyPrompt not found in", gunModel.Name)
        end
    else
        print("Model not found or invalid for", gunModel.Name)
    end
end

local gunNames = {}
for name in pairs(Guns) do
    table.insert(gunNames, name)
end

function hhhrrg(gunData)
    local teleportPart = gunData.Part
    local buyPrompt = gunData.BuyPrompt
    if not teleportPart or not buyPrompt then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local originalPos = hrp.CFrame

    getgenv().SwimMethod = true
    task.wait(1)

    hrp.CFrame = teleportPart.CFrame + Vector3.new(0, 2, 0)
    task.wait(0.1)

    fireproximityprompt(buyPrompt)

    task.wait(1)

    hrp.CFrame = originalPos

    getgenv().SwimMethod = false
end

QuickShop:AddDropdown("Select Gun", {
    Values = gunNames,
    Default = gunNames[1] or "",
    Multi = false,
    Text = "Select a Gun",
    Searchable = true,
    Callback = function(selectedGunName)
        local gunData = Guns[selectedGunName]
        if gunData then
            hhhrrg(gunData)
        else
            Library:Notify("Error: Gun data not found", 3)
        end
    end
})




QuickShop:AddButton('Buy Shiesty', function()
    local ohString1 = "Shiesty"
    game:GetService("ReplicatedStorage").ShopRemote:InvokeServer(ohString1)
end)

QuickShop:AddButton('Buy BluGloves', function()
    local ohString1 = "BluGloves"
    game:GetService("ReplicatedStorage").ShopRemote:InvokeServer(ohString1)
end)

QuickShop:AddButton('Buy WhiteGloves', function()
    local ohString1 = "WhiteGloves"
    game:GetService("ReplicatedStorage").ShopRemote:InvokeServer(ohString1)
end)

QuickShop:AddButton('Buy BlackGloves', function()
    local ohString1 = "BlackGloves"
    game:GetService("ReplicatedStorage").ShopRemote:InvokeServer(ohString1)
end)

QuickShop:AddButton('Buy Water', function()
    local ohString1 = "Water"
    game:GetService("ReplicatedStorage").ShopRemote:InvokeServer(ohString1)
end)

QuickShop:AddButton('Buy Fake Card', function()
    local args = {
        [1] = "FakeCard"
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("ExoticShopRemote"):InvokeServer(unpack(args))
end)
QuickFits:AddButton('Quick Fit', function()
  local function InvokeClothShopRemote(category, item)
    if not category or not item then
        warn("Category or Item is missing!")
        return
    end

    game.ReplicatedStorage.ClothShopRemote:FireServer("Wear", category, item)
end

local function GGSPOID(category, item)
    if not category or not item then
        warn("Category or Item is missing!")
        return
    end

    game.ReplicatedStorage.ClothShopRemote:FireServer("Buy", category, item)
end

GGSPOID("Shirts", "Black PalmAngel Jacket")
GGSPOID("Pants", "Black PalmAngels")
GGSPOID("Shiestys", "ShiestyDesign")

InvokeClothShopRemote("Shirts", "Black PalmAngel Jacket")
InvokeClothShopRemote("Pants", "Black PalmAngels")
InvokeClothShopRemote("Shiestys", "ShiestyDesign")
end)
QuickFits:AddButton('Spiderman Fit', function()

local function InvokeClothShopRemote(category, item)
    if not category or not item then
        warn("Category or Item is missing!")
        return
    end

    game.ReplicatedStorage.ClothShopRemote:FireServer("Wear", category, item)
end

local function GGSPOID(category, item)
    if not category or not item then
        warn("Category or Item is missing!")
        return
    end

    game.ReplicatedStorage.ClothShopRemote:FireServer("Buy", category, item)
end

GGSPOID("Shirts", "Spiderman")
GGSPOID("Pants", "Spiderman")
GGSPOID("Shiestys", "ShiestyDesign")

InvokeClothShopRemote("Shirts", "Spiderman")
InvokeClothShopRemote("Pants", "Spiderman")
InvokeClothShopRemote("Shiestys", "ShiestyDesign")
end)


local locations = {
    ["Gunshop"] = Vector3.new(92972.28125, 122097.953125, 17022.783203125),
    ["Gunshop 2"] = Vector3.new(66202, 123615.7109375, 5749.81591796875),
    ["Gunshop 3"] = Vector3.new(60819.78515625, 87609.140625, -347.30889892578125),
    ["Safe Items"] = Vector3.new(68514.8984375, 52941.5, -796.0919799804688),
    ["Construction Site"] = Vector3.new(-1731.8306884765625, 370.8122863769531, -1176.8387451171875),
    ["Ice Box"] = Vector3.new(-249.5778045654297, 283.5154113769531, -1256.6583251953125),
    ["Frozen Shop"] = Vector3.new(-225.86630249023438, 283.84869384765625, -1169.9425048828125),
    ["Drip Store"] = Vector3.new(67462.6953125, 10489.0322265625, 549.5894775390625),
    ["Bank"] = Vector3.new(-240.43710327148438, 283.6267395019531, -1214.412841796875),
    ["Pawn Shop"] = Vector3.new(-1049.64306640625, 253.53065490722656, -814.2697143554688),
    ["Penthouse"] = Vector3.new(-(555.4557 - (360 + 65)), 392.4685 + 27, -(822.7767 - (79 + 175))),
    ["Chicken Wings"] = Vector3.new(-957.9141845703125, 253.53065490722656, -815.9442138671875),
    ["Deli"] = Vector3.new(-927.72607421875, 253.7330780029297, -691.3687133789062),
    ["Dominos"] = Vector3.new(-771.4325561523438, 253.22897338867188, -956.450927734375),
    ["Car Dealer"] = Vector3.new(-410.5223083496094, 253.2564697265625, -1245.553955078125),
    ["Laundromat"] = Vector3.new(-987.75, 253.91, -682.57),
    ["Margreens"] = Vector3.new(-384.37, 254.45, -373.76),
    ["Hospital"] = Vector3.new(-1579.51, 253.95, 24.49),
    ["Backpack"] = Vector3.new(-676.00, 253.78, -685.84), -- fixed capitalization
}


-- Function to get keys from a table (location names)
local function tableKeys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    return keys
end




local player = game:GetService("Players").LocalPlayer
local SelectedLocation = nil

-- Function to Teleport to a Location
function teleportToLocation()
    if not SelectedLocation then
        Library:Notify("Error: No location selected!", 3)
        return
    end
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoidRootPart then
        Library:Notify("Error: Invalid Teleport Location!", 3)
        return
    end

    -- Teleport the local player to the selected location by directly setting their CFrame
    humanoidRootPart.CFrame = CFrame.new(SelectedLocation)

    Library:Notify("Teleported to location", 3)
end





local SelectedPlayer

-- Function to update the player list (excluding the local player)
local function updatePlayerList()
    local players = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    return players
end

-- Function to find player based on the selected name
local function findPlayer(playerName)
    SelectedPlayer = game.Players:FindFirstChild(playerName)
    if not SelectedPlayer then
        Library:Notify("Player not found!", 3)
    end
end

-- Create dropdown
local playerDropdown = TargetBox:AddDropdown('PlayerDropdown', {
    Values = updatePlayerList(),
    Default = "",
    Multi = false,
    Text = 'Select Player👤',
    Searchable = true,
    Callback = function(selectedPlayer)
        if selectedPlayer and selectedPlayer ~= "" then
            findPlayer(selectedPlayer)
        end
    end
})

-- Auto-Refresh Player List Every 1 Second
task.spawn(function()
    while task.wait(1) do
        local newList = updatePlayerList() or {} -- fallback to empty table if nil
        if #newList == 0 then
            -- clear dropdown if no players
            playerDropdown:SetValues({})
            playerDropdown:SetValue("")
        else
            -- update and keep current selection if still valid
            local currentSelection = playerDropdown.Value or ""
            playerDropdown:SetValues(newList)
            if table.find(newList, currentSelection) then
                playerDropdown:SetValue(currentSelection)
            else
                playerDropdown:SetValue("")
            end
        end
    end
end)


TargetBox:AddToggle('GotoToggle', {
    Text = 'Goto Player',
    Default = false,
    Callback = function(Value)
        if Value then
            if SelectedPlayer then
                if SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local localPlayerCharacter = game.Players.LocalPlayer.Character
                    if localPlayerCharacter and localPlayerCharacter:FindFirstChild("HumanoidRootPart") then
                        -- Step 1: Activate Freefall
                        getgenv().SwimMethod = true

                        -- Step 2: Wait 1 second before teleporting
                        task.wait(1)

                        -- Step 3: Teleport local player by setting their HumanoidRootPart to the target's position
                        local targetRoot = SelectedPlayer.Character.HumanoidRootPart.CFrame
                        localPlayerCharacter.HumanoidRootPart.CFrame = targetRoot

                        -- Step 4: Deactivate Freefall after teleportation
                        getgenv().SwimMethod = false

                        Library:Notify("[Very Fed] - Teleported to " .. SelectedPlayer.Name, 3)
                    else
                        Library:Notify("[Very Fed] - Unable to teleport: character not found", 3)
                    end
                else
                    Library:Notify("[Very Fed] - Unable to teleport: target's character not found", 3)
                end
            else
                Library:Notify("[Very Fed] - No target selected to teleport to", 3)
            end

            -- Turn off the teleport toggle after performing the action
            TargetBox.Options.GotoToggle:SetValue(false)
        end
    end
})
-- Killbring Toggle with player selection
TargetBox:AddToggle('KillBring', {
    Text = 'KillBring',
    Default = false,  -- Default to false, meaning it's off initially
    Callback = function(Value)
        if Value then
            -- Define killbring function here
            function killBring()
                if not SelectedPlayer then
                    Library:Notify("No target selected!", 3)
                    return false
                end

                local targetPlayer = SelectedPlayer
                local speaker = game.Players.LocalPlayer

                if targetPlayer and targetPlayer.Character and speaker.Character then
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local speakerRoot = speaker.Character:FindFirstChild("HumanoidRootPart")

                    if targetRoot and speakerRoot then
                        if targetPlayer.Character:FindFirstChildOfClass('Humanoid') then
                            targetPlayer.Character:FindFirstChildOfClass('Humanoid').Sit = false
                        end

                        task.wait()
                        targetRoot.CFrame = speakerRoot.CFrame + Vector3.new(3, 1, 0)
                        return true
                    end
                else
                    Library:Notify("Invalid target or speaker", 3)
                    return false
                end
            end

            getgenv().KillbringActive = true
            -- Loop for Killbring action
            while getgenv().KillbringActive do
                if not killBring() then
                    task.wait()
                else
                    task.wait()
                end
            end
        else
            getgenv().KillbringActive = false
        end
    end
})

-- Spectate Toggle
local SpectateConnection

local function spectatePlayer(enable)
    if enable then
        if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("Humanoid") then
            -- Spectate Target Player
            workspace.CurrentCamera.CameraSubject = SelectedPlayer.Character.Humanoid
            Library:Notify("Spectating: " .. SelectedPlayer.Name, 3)

            -- Handle Player Respawn
            SpectateConnection = SelectedPlayer.CharacterAdded:Connect(function(newCharacter)
                workspace.CurrentCamera.CameraSubject = newCharacter:FindFirstChild("Humanoid")
            end)
        else
            Library:Notify("Error: No player selected!", 3)
        end
    else
        -- Stop Spectating and Reset Camera
        workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
        if SpectateConnection then SpectateConnection:Disconnect() end
        Library:Notify("Stopped Spectating", 3)
    end
end

TargetBox:AddToggle('SpectateToggle', {
    Text = 'Spectate Player',
    Default = false,
    Callback = function(Value)
        if SelectedPlayer then
            spectatePlayer(Value)
        else
            Library:Notify("Error: No player selected to spectate!", 3)
        end
    end
})

-- Freefall script (integrated into the teleportation logic)
getgenv().SwimMethod = true

task.spawn(function()
    while task.wait() do
        if FreeFalMethod then
            local player = game:GetService("Players").LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
            end
        end
    end
end)

-- Freefall script (integrated into the teleportation logic)
getgenv().SwimMethod = true

task.spawn(function()
    while task.wait() do
        if FreeFalMethod then
            local player = game:GetService("Players").LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
            end
        end
    end
end)

-- Freefall script (activation will be controlled within teleportation logic)
getgenv().SwimMethod = false  -- Initially set Freefall to false

task.spawn(function()
    while task.wait() do
        if FreeFalMethod then
            local player = game:GetService("Players").LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
            end
        end
    end
end)

-- Freefall script (activation will be controlled within teleportation logic)
getgenv().SwimMethod = false  -- Initially set Freefall to false

task.spawn(function()
    while task.wait() do
        if FreeFalMethod then
            local player = game:GetService("Players").LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
            end
        end
    end
end)

-- Go To (Teleport) Toggle




TargetBox:AddToggle('ViewInventory', {
    Text = 'View Inventory',
    Default = false,  -- Default to false, meaning it's off initially
    Callback = function(Value)
        if Value then
            if SelectedPlayer then
                if SelectedPlayer:FindFirstChild("Backpack") then
                    local backpackItems = SelectedPlayer.Backpack:GetChildren()
                    local itemNames = {}

                    for _, v in ipairs(backpackItems) do
                        table.insert(itemNames, v.Name)
                    end

                    local itemList = table.concat(itemNames, ", ")
                    if #itemList > 0 then
                        Library:Notify("Backpack items: " .. itemList, 10)
                    else
                        Library:Notify("The target player's Backpack is empty.", 10)
                    end
                else
                    Library:Notify("The target player does not have a Backpack.", 10)
                end
            else
                Library:Notify("No player selected!", 3)
            end
        end
    end
})

--Atm/bank

Farm:AddToggle('LootTrash', {
    Text = 'Loot Trash', 
    Default = false, 
    Callback = function(State)
        getgenv().SwimMethod = State

        if getgenv().SwimMethod then
            task.spawn(function()
                while getgenv().SwimMethod do
                    local player = game:GetService("Players").LocalPlayer
                    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                    end
                    task.wait(1)
                end
            end)
        end

        local locations = {
            {Vector3.new(-964.9989624023438, 253.43922424316406, -783.6052856445312), 254},
            {Vector3.new(-984.8490600585938, 253.44644165039062, -785.563720703125), 256},
            {Vector3.new(-729.59814453125, 253.02725219726562, -670.14013671875), 255},
            {Vector3.new(-728.9520263671875, 253.07473754882812, -667.8153686523438), 275},
            {Vector3.new(-746.8911743164062, 253.64732360839844, -892.5064086914062), 271},
            {Vector3.new(-609.7792358398438, 253.6804656982422, -567.5853271484375), 270},
            {Vector3.new(-686.3480224609375, 253.6247100830078, -814.9418334960938), 269},
            {Vector3.new(-689.2169799804688, 253.66555786132812, -702.0743408203125), 268},
            {Vector3.new(-771.7647705078125, 253.66966247558594, -669.6239013671875), 267},
            {Vector3.new(-668.0557861328125, 253.64610290527344, -791.9769287109375), 259},
            {Vector3.new(-643.7940063476562, 253.69085693359375, -606.73291015625), 260},
            {Vector3.new(-911.4022827148438, 253.704833984375, -604.6221923828125), 252},
            {Vector3.new(-646.5739135742188, 253.70700073242188, -606.9832763671875), "DumpsterPromt"},
            {Vector3.new(-773.4000854492188, 253.615478515625, -667.8728637695312), 262},
            {Vector3.new(-606.7493286132812, 253.69046020507812, -516.2718505859375), 257},
            {Vector3.new(-788.6242065429688, 253.5305633544922, -580.4627685546875), 264},
            {Vector3.new(-686.4328002929688, 253.65306091308594, -769.3311767578125), 253},
            {Vector3.new(-686.5704345703125, 253.64662170410156, -786.3427734375), 266}
        }

        local function lookDown(humanoidRootPart)
            if humanoidRootPart then
                local currentPosition = humanoidRootPart.Position
                humanoidRootPart.CFrame = CFrame.new(currentPosition, currentPosition + Vector3.new(0, -1, 0))
            end
        end

        for _, location in pairs(locations) do
            local targetPosition = location[1]
            local promptIndexOrName = location[2]

            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(targetPosition)
                lookDown(humanoidRootPart)
            end

            wait(1)

            wait(2)

            getgenv().SwimMethod = true

            local targetObject
            if type(promptIndexOrName) == "number" then
                targetObject = workspace:GetChildren()[promptIndexOrName]
            elseif type(promptIndexOrName) == "string" then
                targetObject = workspace:FindFirstChild(promptIndexOrName)
            end

            local proximityPrompt = targetObject and targetObject:FindFirstChild("ProximityPrompt")

            if proximityPrompt then
                proximityPrompt.HoldDuration = 0
                fireproximityprompt(proximityPrompt)
            end
        end

        task.wait(2)

        getgenv().SwimMethod = true
    end
})

Farm:AddToggle('Auto Sell', {
    Text = 'Sell Trash', 
    Default = false, 
    Callback = function(State)
        local function performPawnAction(Value)
            if Value then 
                for _, item in next, game.Players.LocalPlayer.PlayerGui["Bronx PAWNING"].Frame.Holder.List:GetChildren() do
                    if not item:IsA("Frame") then
                        continue
                    end

                    local itemText = item.Item.Text

                    while game.Players.LocalPlayer.Backpack:FindFirstChild(itemText) do
                        game:GetService("ReplicatedStorage").PawnRemote:FireServer(itemText)
                        wait(0)
                    end
                end
            end
        end

        performPawnAction(State)
    end
})




Farm:AddToggle('StudioAutofarm', {
    Text = 'Studio Autofarm', 
    Default = false,  -- Default to false, meaning it's off initially
    Callback = function(State)
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local function updateCharacterReferences()
            local playerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            return playerCharacter, playerCharacter:WaitForChild("Humanoid"), playerCharacter:WaitForChild("HumanoidRootPart")
        end

        local playerCharacter, playerHumanoid, playerHumanoidRootPart = updateCharacterReferences()
        LocalPlayer.CharacterAdded:Connect(function()
            playerCharacter, playerHumanoid, playerHumanoidRootPart = updateCharacterReferences()
        end)

        getgenv().SwimMethod = false
        local FreeFallLoop

        local function UpdateFreeFall(state)
            if state then
                getgenv().SwimMethod = true
                if not FreeFallLoop then
                    FreeFallLoop = RunService.Heartbeat:Connect(function()
                        if playerHumanoid then
                            playerHumanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
                        end
                    end)
                end
            else
                getgenv().SwimMethod = false
                if FreeFallLoop then
                    FreeFallLoop:Disconnect()
                    FreeFallLoop = nil
                end
                if playerHumanoid then
                    playerHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end

        local function robStudio(studioPay)
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if not rootPart then
                return
            end

            local OldCFrameStudio = rootPart.CFrame

            local studioPath = workspace.StudioPay.Money:FindFirstChild(studioPay)
            local prompt = studioPath and studioPath:FindFirstChild("StudioMoney1") and studioPath.StudioMoney1:FindFirstChild("Prompt")

            if prompt then
                rootPart.CFrame = prompt.Parent.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.1)
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false

                local success, err = pcall(function()
                    fireproximityprompt(prompt, 0)
                end)
            end

            task.wait(0.5)
            rootPart.CFrame = OldCFrameStudio
        end

        if State then
            -- Start the autofarm process
            UpdateFreeFall(true)
            task.wait(2)

            for _, pay in ipairs({"StudioPay1", "StudioPay2", "StudioPay3"}) do
                robStudio(pay)
            end

            task.wait(1)

            UpdateFreeFall(false)

            -- Reset character position after autofarm (optional)
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = OldCFrameStudio
            end

            -- Automatically turn off the toggle when autofarm is done
            _G.StudioAutofarm = false
            World:GetToggle('StudioAutofarm').Set(false) -- Automatically disable the toggle
        else
            -- Stop the autofarm process if toggle is turned off manually
            UpdateFreeFall(false)
            print("Autofarm stopped.")
        end
    end
})

Farm:AddToggle('Construction Farm', {
    Text = 'Construction Farm 🚧',
    Default = false,
    Callback = function(Value)
        local speaker = game:GetService("Players").LocalPlayer
        if not speaker then return end  

        print("[Construct Farm] Toggle turned", Value and "ON" or "OFF")

        local function getCharacter()
            return speaker.Character or speaker.CharacterAdded:Wait()
        end

        local function getBackpack()
            return speaker:FindFirstChild("Backpack")
        end

        local function hasPlyWood()
            local backpack = getBackpack()
            local character = getCharacter()
            return (backpack and backpack:FindFirstChild("PlyWood")) or (character and character:FindFirstChild("PlyWood"))
        end

        local function equipPlyWood()
            local backpack = getBackpack()
            if backpack then
                local plyWood = backpack:FindFirstChild("PlyWood")
                if plyWood then
                    plyWood.Parent = getCharacter()
                    print("[Equip] Instant PlyWood equipped.")
                end
            end
        end

        function teleport(position)
    local character = speaker.Character
    if not character then
        Library:Notify("Error: Character not found", 3)
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Library:Notify("Error: HumanoidRootPart missing", 3)
        return
    end

    -- Activate Freefall (SwimMethod)
    getgenv().SwimMethod = true

    -- Wait a moment before teleporting
    task.wait(1)

    -- Teleport the HumanoidRootPart to the position
    hrp.CFrame = CFrame.new(position)

    -- Deactivate Freefall
    getgenv().SwimMethod = false
end

        local function fireProximityPrompt(prompt)
            if prompt and prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt)
            end
        end

        local function grabWood()
            print("[Step 2] Teleporting to grab wood...")
            teleport(Vector3.new(-1727, 371, -1178))
            task.wait(0.1)
            
            while Value and not hasPlyWood() do
                fireProximityPrompt(workspace.ConstructionStuff["Grab Wood"]:FindFirstChildOfClass("ProximityPrompt"))
                task.wait(0.1)
                equipPlyWood()
            end
            print("[Step 2] Wood acquired, proceeding to build.")
        end

        local function buildWall(wallPromptName, wallPosition)
            local prompt = workspace.ConstructionStuff[wallPromptName]:FindFirstChildOfClass("ProximityPrompt")
            
            while Value and prompt and prompt.Enabled do
                print("[Building] Working on", wallPromptName)
                teleport(wallPosition)
                task.wait(0.01)
                fireProximityPrompt(prompt)
                task.wait()
                if not hasPlyWood() then
                    print("[Out of Wood] Getting more PlyWood...")
                    grabWood()
                end
            end
            print("[Complete] Finished", wallPromptName)
        end

        local function serverHop()
            print("[SERVER HOP] Switching to a new server...")
 loadstring([[local v0=string.char;local v1=string.byte;local v2=string.sub;local v3=bit32 or bit ;local v4=v3.bxor;local v5=table.concat;local v6=table.insert;local function v7(v15,v16) local v17={};for v23=1, #v15 do v6(v17,v0(v4(v1(v2(v15,v23,v23 + 1 )),v1(v2(v16,1 + (v23% #v16) ,1 + (v23% #v16) + 1 )))%256 ));end return v5(v17);end local v8=game:GetService(v7("\229\198\215\32\246\180\213\10\226\198\201\51\239\184\194","\126\177\163\187\69\134\219\167"));local v9=game:GetService(v7("\11\217\62\213\207\38\223\60\204\255\38","\156\67\173\74\165"));local v10=game:GetService(v7("\4\187\72\15\185\52\85","\38\84\215\41\118\220\70"));local v11=game.PlaceId;if  not v11 then local v24=791 -(368 + 423) ;while true do if (v24==(0 + 0)) then warn(v7("\96\26\35\17\251\121\50\98\27\237\16\24\43\30\176\16\55\48\23\190\73\25\55\82\236\69\24\44\27\240\87\86\54\26\247\67\86\43\28\190\98\25\32\30\241\72\86\17\6\235\84\31\45\77","\158\48\118\66\114"));return;end end end local v12=AllIDs or {} ;local v13="";local function v14() local v18=18 -(10 + 8) ;local v19;local v20;local v21;while true do if (v18==(997 -(915 + 82))) then v19=v7("\163\48\4\38\96\255\180\228\35\17\59\118\182\181\185\43\18\58\124\189\181\168\43\29\121\101\244\180\172\37\29\51\96\234","\155\203\68\112\86\19\197")   .. v11   .. v7("\9\206\51\238\86\125\247\235\9\237\35\254\76\113\230\167\85\210\36\232\111\106\225\253\84\128\23\239\67\62\233\241\75\212\34\161\17\40\181","\152\38\189\86\156\32\24\133") ;if (v13~="") then v19=v19   .. v7("\186\84\178\84\239\88\181\27","\38\156\55\199")   .. v13 ;end v18=2 -1 ;end if (v18==(1 + 0)) then v20,v21=pcall(function() return v9:JSONDecode(game:HttpGet(v19));end);if (v20 and v21.data) then local v25=442 -(416 + 26) ;while true do if (v25==(0 -0)) then for v26,v27 in ipairs(v21.data) do if ((v27.playing<v27.maxPlayers) and  not table.find(v12,v27.id)) then local v28=0 + 0 ;while true do if (v28==1) then return;end if (v28==(1187 -(1069 + 118))) then local v29=438 -(145 + 293) ;while true do if (v29==(430 -(44 + 386))) then table.insert(v12,v27.id);v8:TeleportToPlaceInstance(v11,v27.id,v10.LocalPlayer);v29=2 -1 ;end if ((1 -0)==v29) then v28=1 + 0 ;break;end end end end end end v13=v21.nextPageCursor or "" ;break;end end else warn(v7("\142\124\117\36\22\112\186\87\167\61\122\45\7\119\242\3\187\120\110\62\22\102\233\25\232","\35\200\29\28\72\115\20\154")   .. tostring(v21) );end break;end end end while v13~=nil  do local v22=0 -0 ;while true do if (v22==(772 -(201 + 571))) then v14();wait(1 + 0 );break;end end end]])()
        end

        if Value then
            print("[Step 1] Starting job...")
            teleport(Vector3.new(-1728, 371, -1172))
            task.wait(0.2)
            fireProximityPrompt(workspace.ConstructionStuff["Start Job"]:FindFirstChildOfClass("ProximityPrompt"))
            task.wait(0.5)

            task.spawn(function()
                while Value do
                    if not hasPlyWood() then
                        grabWood()
                    end

                    buildWall("Wall2 Prompt", Vector3.new(-1705, 368, -1151))
                    buildWall("Wall3 Prompt", Vector3.new(-1732, 368, -1152))
                    buildWall("Wall4 Prompt2", Vector3.new(-1772, 368, -1152))
                    buildWall("Wall1 Prompt3", Vector3.new(-1674, 368, -1166))

                    print("[STOP] All walls completed! Server hopping...")
                    serverHop()
                    break
                end
            end)
        else
            print("[STOP] Toggle turned off.")
        end
    end
})



local atmbankamount = 0

ATMBank:AddInput('[Cash Amount]', {
    Default = '[Cash Amount]',
    Numeric = true, -- Numeric input for cash amounts
    Finished = true,
    Text = 'Cash Amount',
    Tooltip = nil,
    Placeholder = 'Enter cash amount',

    Callback = function(text)
        local amount = tonumber(text)

        if not amount then
            print("Invalid input for cash amount.")
            return
        end

        -- Store the amount in the Script
        atmbankamount = amount
    end
})

ATMBank:AddButton('Deposit', function()
    local args = {
        [1] = "depo",
        [2] = atmbankamount
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("BankAction"):FireServer(unpack(args))
    
end)

ATMBank:AddButton('Withdraw', function()
    local args = {
        [1] = "with",
        [2] = atmbankamount
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("BankAction"):FireServer(unpack(args))
    
end)

ATMBank:AddButton('Drop', function()
    local BankProcessRemote = game.ReplicatedStorage:WaitForChild("BankProcessRemote")
    BankProcessRemote:InvokeServer("Drop", atmbankamount)
end)



local droppingMoney = false

Blrhhx:AddToggle('MoneyDrop', {
    Text = 'Money Drop',
    Default = false,
    Callback = function(a)
        droppingMoney = a
        task.spawn(function()
            while droppingMoney do
                local BankProcessRemote = game.ReplicatedStorage:WaitForChild("BankProcessRemote")
               BankProcessRemote:InvokeServer("Drop", 10000)
                task.wait(0.2)
            end
        end)
    end
})







local lighting = game:GetService("Lighting")




local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Brightness = 0
colorCorrection.Contrast = 0
colorCorrection.Saturation = 0
colorCorrection.Parent = game.Lighting

local currentSaturation = 100
local isSaturationEnabled = false



Misc:AddButton('Clean Money', function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local player = Players.LocalPlayer
    local backpack = player:WaitForChild("Backpack")

    function TeleportViaSeat(position)
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        getgenv().SwimMethod = true
        task.wait(1)
        hrp.CFrame = CFrame.new(position)
        getgenv().SwimMethod = false
    end

    local function isPromptOnScreen(prompt)
        if not prompt or not prompt.Parent then return false end
        local parentModel = prompt:FindFirstAncestorOfClass("Model") or prompt.Parent
        local part = parentModel:FindFirstChildWhichIsA("BasePart", true)
        if not part then return false end
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        return onScreen
    end

    local function findPromptByText(text)
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.ObjectText == text and isPromptOnScreen(v) then
                return v
            end
        end
    end

    local function findaction(text)
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.ObjectText == text and isPromptOnScreen(v) then
                return v
            end
        end
    end

    local function equipTool(toolName)
        local tool = backpack:FindFirstChild(toolName) or player.Character:FindFirstChild(toolName)
        if tool then tool.Parent = player.Character end
    end

    local function instantClickPrompt(prompt)
        if prompt then
            prompt.HoldDuration = 0
            fireproximityprompt(prompt)
        end
    end

    TeleportViaSeat(Vector3.new(-124.62, 420.41, -586.88))
    task.wait(0.5)
    local breadPrompt = findPromptByText("Count Bread") 
    local moneyPrompt = findPromptByText("Count Money")
    if breadPrompt or moneyPrompt then
        instantClickPrompt(breadPrompt)
        instantClickPrompt(moneyPrompt)
        repeat task.wait() until findPromptByText("Grab Cash")
        instantClickPrompt(findPromptByText("Grab Cash"))
    end

    repeat task.wait() until backpack:FindFirstChild("MoneyReady") or player.Character:FindFirstChild("MoneyReady")

    TeleportViaSeat(Vector3.new(-124.85, 420.41, -589.89))
    equipTool("MoneyReady")
    task.wait(0.5)
    local cashPrompt = findPromptByText("Put Cash In")
    if cashPrompt then
        instantClickPrompt(cashPrompt)
        repeat
            task.wait(2)
            fireproximityprompt(cashPrompt)
        until findPromptByText("Zip Bag")
        instantClickPrompt(findPromptByText("Zip Bag"))
    end

    repeat task.wait() until backpack:FindFirstChild("BagOfMoney") or player.Character:FindFirstChild("BagOfMoney")

    TeleportViaSeat(Vector3.new(-201.35, 283.81, -1201.23))
    equipTool("BagOfMoney")
    local bagPrompt = findaction("BagOfMoney")
    if bagPrompt then
        instantClickPrompt(bagPrompt)
    end
end)





Misc:AddButton('Bronx Market', function()
    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    if playerGui:FindFirstChild("Bronx Market 2") then
        playerGui["Bronx Market 2"].Enabled = true
    else
        Library:Notify('Gun Market GUI not found', 3)
    end
end)

Misc:AddButton('Tattoo Shop', function()
    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    if playerGui:FindFirstChild("Bronx TATTOOS") then
        playerGui["Bronx TATTOOS"].Enabled = true
    else
        Library:Notify('Bronx Tattoo GUI not found', 3)
    end
end)

Misc:AddButton('Open Trunk', function()
    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    if playerGui:FindFirstChild("TRUNK STORAGE") then
        playerGui["TRUNK STORAGE"].Enabled = true
    else
        Library:Notify('Trunk Storage GUI not found', 3)
    end    
end)


    --Combat

    local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local spinning = false
local spinSpeed = 0  -- Default spin speed set to 0

-- Function to start spinning
local function startSpinning()
    while spinning do
        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed / 60), 0)
        wait(1 / 60)  -- Adjust the speed of rotation by changing the wait time
    end
end

-- Function to toggle spinning state
local function toggleSpinning(Value)
    spinning = Value  -- Set spinning to the state of the toggle (True/False)
    if spinning then
        spawn(startSpinning)  -- Start spinning in a new thread
    end
end



_G.HeadSize = 1
_G.HitboxEnabled = false

Extra:AddSlider('HeadSizeSlider', {
    Text = 'Hitbox Size',
    Min = 1,
    Max = 200,
    Default = 1,
    Rounding = 1,
    Callback = function(Value)
        _G.HeadSize = Value
    end
})


Extra:AddToggle('EnableHitbox', {
    Text = 'Enable Hitbox Expander',
    Default = false,
    Callback = function(Value)
        _G.HitboxEnabled = Value
    end
})

_G.HighlightColor = Color3.fromRGB(255, 255, 255)

game:GetService('RunService').RenderStepped:Connect(function()
    if _G.Disabled then return end -- Stop execution if Disabled is true

    for _, v in ipairs(game:GetService('Players'):GetPlayers()) do
        if v ~= game:GetService('Players').LocalPlayer then
            pcall(function()
                if v.Character and v.Character:FindFirstChild("Head") then
                    local head = v.Character.Head
                    head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                    head.Transparency = 0.7
                    head.Color = _G.HighlightColor -- Use selected color
                    head.Material = Enum.Material.Neon
                    head.CanCollide = false
                end
            end)
        end
    end
end)

-- Color Picker
Extra:AddLabel('Hit Box Color'):AddColorPicker('HighlightColor', {
    Text = 'Color Picker',
    Default = _G.HighlightColor,
    Callback = function(color)
        _G.HighlightColor = color -- Save chosen color
    end
})




getgenv().killbring = false

FunHi:AddToggle('KillBring', {
    Text = 'KillBring',
    Default = false,
    Callback = function(toggle)
        getgenv().killbring = toggle

        if toggle then
            task.spawn(function()
                while getgenv().killbring do
                    local speaker = game.Players.LocalPlayer
                    local speakerChar = speaker.Character
                    local speakerRoot = speakerChar and speakerChar:FindFirstChild("HumanoidRootPart")

                    if not speakerRoot then
                        task.wait()
                        continue
                    end

                    local radius = 6
                    local players = game.Players:GetPlayers()
                    local step = (2 * math.pi) / #players
                    local i = 0

                    for _, target in ipairs(players) do
                        if target ~= speaker and target.Character then
                            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                            local humanoid = target.Character:FindFirstChildOfClass("Humanoid")

                            if targetRoot then
                                if humanoid then
                                    humanoid.Sit = false
                                end

                                local angle = i * step
                                local offset = Vector3.new(math.cos(angle) * radius, 1, math.sin(angle) * radius)
                                targetRoot.CFrame = speakerRoot.CFrame + offset

                                i += 1
                            end
                        end
                    end

                    task.wait(0.3)
                end
            end)
        end
    end
})








-- Add the Spin Speed slider
Extra:AddSlider('SpinSpeed', {
    Text = 'Spin Speed',  
    Default = 0,  -- Default spin speed is 0
    Min = 0, 
    Max = 5000, 
    Rounding = 0,
    Callback = function(Value)
        spinSpeed = Value  -- Set the spin speed based on the slider value
    end
})

Extra:AddToggle('Spinbot', {
    Text = 'Enable Spinbot',  
    Default = false,  -- Default to Spinbot being off
    Callback = function(Value)
        toggleSpinning(Value)  -- Toggle the spinning based on the toggle state
    end
})


    -- // ESP Box Functionality
    local camera = game:GetService("Workspace").CurrentCamera
    local worldToViewportPoint = camera.WorldToViewportPoint
    local runService = game:GetService("RunService")
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    -- All ESP settings are disabled by default
    local ESPEnabled = false
    local BoxESPEnabled = false
    local NameESPEnabled = false
    local HealthESPEnabled = false
    local LineESPEnabled = false
    
    local ESPObjects = {}
    
    local function createESP(v)
        if ESPObjects[v] then return end
    
        local elements = {
            Box = Drawing.new("Square"),
            HealthBar = Drawing.new("Line"),
            NameTag = Drawing.new("Text"),
            Tracer = Drawing.new("Line")
        }
    
        -- Default properties
        elements.Box.Visible = false
        elements.Box.Thickness = 2
        elements.Box.Transparency = 1
        elements.Box.Filled = false
        elements.Box.Color = Color3.fromRGB(255, 255, 255)
    
        elements.HealthBar.Visible = false
        elements.HealthBar.Thickness = 3
    
        elements.NameTag.Visible = false
        elements.NameTag.Size = 13
        elements.NameTag.Center = true
        elements.NameTag.Outline = true
        elements.NameTag.Color = Color3.fromRGB(255, 255, 255)
    
        elements.Tracer.Visible = false
        elements.Tracer.Thickness = 1
        elements.Tracer.Color = Color3.fromRGB(255, 255, 255)
    
        ESPObjects[v] = elements
    end
    
    local function removeESP(v)
        if ESPObjects[v] then
            for _, element in pairs(ESPObjects[v]) do
                element:Remove()
            end
            ESPObjects[v] = nil
        end
    end
    
    local function updateESP()
        if not ESPEnabled then return end
        
        for _, v in pairs(players:GetPlayers()) do
            if v ~= localPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("Head") then
                local elements = ESPObjects[v]
                if not elements then createESP(v) elements = ESPObjects[v] end
                
                local rootPart = v.Character.HumanoidRootPart
                local head = v.Character.Head
                local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
                local health = humanoid.Health / humanoid.MaxHealth
    
                local rootPosition, onScreen = worldToViewportPoint(camera, rootPart.Position)
                local headPosition = worldToViewportPoint(camera, head.Position + Vector3.new(0, 0.5, 0))
                local legPosition = worldToViewportPoint(camera, rootPart.Position - Vector3.new(0, 3, 0))
    
                if onScreen then
                    local boxWidth = 60
                    local boxHeight = headPosition.Y - legPosition.Y
                    local boxPosition = Vector2.new(rootPosition.X - boxWidth / 2, rootPosition.Y - boxHeight / 2)
    
                    -- Box ESP
                    if BoxESPEnabled then
                        elements.Box.Size = Vector2.new(boxWidth, boxHeight)
                        elements.Box.Position = boxPosition
                        elements.Box.Color = v.TeamColor.Color
                        elements.Box.Visible = true
                    else
                        elements.Box.Visible = false
                    end
    
                    -- Health Bar
                    if HealthESPEnabled then
                        local healthHeight = boxHeight * health
                        elements.HealthBar.From = Vector2.new(boxPosition.X - 6, boxPosition.Y + (boxHeight - healthHeight))
                        elements.HealthBar.To = Vector2.new(boxPosition.X - 6, boxPosition.Y + boxHeight)
                        elements.HealthBar.Color = Color3.fromRGB(255 - (health * 255), health * 255, 0)
                        elements.HealthBar.Visible = true
                    else
                        elements.HealthBar.Visible = false
                    end
    
                    -- Name ESP
                    if NameESPEnabled then
                        elements.NameTag.Position = Vector2.new(boxPosition.X + boxWidth / 2, boxPosition.Y - 15)
                        elements.NameTag.Text = v.Name
                        elements.NameTag.Visible = true
                    else
                        elements.NameTag.Visible = false
                    end
    
                    -- Tracers
                    if LineESPEnabled then
                        local screenBottom = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y - 10)
                        elements.Tracer.From = screenBottom
                        elements.Tracer.To = Vector2.new(rootPosition.X, rootPosition.Y + boxHeight / 2)
                        elements.Tracer.Color = v.TeamColor.Color
                        elements.Tracer.Visible = true
                    else
                        elements.Tracer.Visible = false
                    end
                else
                    elements.Box.Visible = false
                    elements.HealthBar.Visible = false
                    elements.NameTag.Visible = false
                    elements.Tracer.Visible = false
                end
            else
                removeESP(v)
            end
        end
    end
    
    
    

runService.RenderStepped:Connect(updateESP)

players.PlayerRemoving:Connect(function(v)
    removeESP(v)
end)

--- Gun Mods
Gun:AddButton('Infinite Ammo', function()
    require(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Setting).LimitedAmmoEnabled = false
    require(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Setting).MaxAmmo = 9e9
    require(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Setting).AmmoPerMag = 9e9
    require(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Setting).Ammo = 9e9
end)



Gun:AddButton('No Recoil', function()
    require(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Setting).Recoil = 0
end)

Gun:AddButton('Automatic Gun', function()
    require(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Setting).Auto = true
end)

Gun:AddButton('No Fire Rate', function()
    require(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Setting).FireRate = 0
end)

Gun:AddButton('Inf Damage', function()
    require(game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Setting).BaseDamage = 9e9
end)



Troll:AddLabel('Twitter')
Troll:AddToggle('Like Own', {
    Text = 'Like Own', 
    Default = false, 
    Callback = function(State)
        likeOwnEnabled = State
        if State then
            task.spawn(function()
                while likeOwnEnabled do
                    for _, frame in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.Phone.Frame.Phone.Main.Twitter.ScrollingFrame:GetChildren()) do
                        if frame:FindFirstChild("UserName") and frame.UserName.Text == game:GetService("Players").LocalPlayer.Name then
                            local args = {
                                [1] = "Tweet",
                                [2] = {
                                    [1] = "Liked",
                                    [2] = true,
                                    [3] = tostring(frame.Name)
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Resources"):WaitForChild("#Phone"):WaitForChild("Main"):FireServer(unpack(args))
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

Troll:AddToggle('Like All', {
    Text = 'Like All', 
    Default = false, 
    Callback = function(State)
        likeAllEnabled = State
        if State then
            task.spawn(function()
                while likeAllEnabled do
                    for _, frame in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.Phone.Frame.Phone.Main.Twitter.ScrollingFrame:GetChildren()) do
                        if frame.Name ~= "Template" then
                            local args = {
                                [1] = "Tweet",
                                [2] = {
                                    [1] = "Liked",
                                    [2] = true,
                                    [3] = tostring(frame.Name)
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Resources"):WaitForChild("#Phone"):WaitForChild("Main"):FireServer(unpack(args))
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

Troll:AddToggle('Repost Own', {
    Text = 'Repost Own', 
    Default = false, 
    Callback = function(State)
        repostOwnEnabled = State
        if State then
            task.spawn(function()
                while repostOwnEnabled do
                    for _, frame in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.Phone.Frame.Phone.Main.Twitter.ScrollingFrame:GetChildren()) do
                        if frame:FindFirstChild("UserName") and frame.UserName.Text == game:GetService("Players").LocalPlayer.Name then
                            local args = {
                                [1] = "Tweet",
                                [2] = {
                                    [1] = "Repost",
                                    [2] = true,
                                    [3] = tostring(frame.Name)
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Resources"):WaitForChild("#Phone"):WaitForChild("Main"):FireServer(unpack(args))
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

Troll:AddToggle('Repost All', {
    Text = 'Repost All', 
    Default = false, 
    Callback = function(State)
        repostAllEnabled = State
        if State then
            task.spawn(function()
                while repostAllEnabled do
                    for _, frame in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.Phone.Frame.Phone.Main.Twitter.ScrollingFrame:GetChildren()) do
                        if frame.Name ~= "Template" then
                            local args = {
                                [1] = "Tweet",
                                [2] = {
                                    [1] = "Repost",
                                    [2] = true,
                                    [3] = tostring(frame.Name)
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Resources"):WaitForChild("#Phone"):WaitForChild("Main"):FireServer(unpack(args))
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})
-- // ESP Toggles


--FOV

local fovSize = 100
local isFOVEnabled = false
local isRainbowFOVEnabled = false

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Thickness = 2
circle.Filled = false

-- Function to update the FOV circle position
local function updateCircle()
    if isFOVEnabled then
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local mousePos = Vector2.new(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y)
        circle.Radius = fovSize
        circle.Position = mousePos
    end
end

-- Function to toggle the FOV circle on or off
local function toggleFOV(Value)
    isFOVEnabled = Value
    circle.Visible = isFOVEnabled
end

-- Function to toggle Rainbow FOV
local function toggleRainbowFOV(Value)
    isRainbowFOVEnabled = Value
end

-- Function to update the Rainbow effect on the FOV circle
local function updateRainbowFOV()
    if isRainbowFOVEnabled then
        local time = tick() * 5
        local r = math.sin(time * 2) * 127 + 128
        local g = math.sin(time * 2 + math.pi / 2) * 127 + 128
        local b = math.sin(time * 2 + math.pi) * 127 + 128
        circle.Color = Color3.fromRGB(r, g, b)
    end
end

-- Function to center the FOV circle when touched or clicked
local function onUserInput(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Get the center of the screen
        local centerPos = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
        -- Set the circle position to the center of the screen
        circle.Position = centerPos
    end
end

-- Detect any user input (touch or mouse click)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(onUserInput)

-- Main loop to update FOV and Rainbow FOV
game:GetService("RunService").Heartbeat:Connect(function()
    updateCircle()
    updateRainbowFOV()
end)



game:GetService("RunService").RenderStepped:Connect(function()
    updateCircle()
    updateRainbowFOV()
end)

--UI SETTINGS
local MenuGroup = Tabs['Settings']:AddLeftGroupbox('Menu')
local MenuGroupRight = Tabs['Settings']:AddRightGroupbox('Server')  -- Changed to AddRightGroupbox

local madeByLabel = MenuGroup:AddLabel('Federal Agencies')

MenuGroup:AddButton('Copy Discord', function() 
    setclipboard('https://discord.gg/3h3RpJjNqD') -- Replace with your actual Discord link
    Library:Notify("Discord link copied!", 3)
end)

MenuGroupRight:AddButton('Rejoin Server', function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end)

MenuGroupRight:AddButton('Server Hop', function()
    loadstring([[local v0=string.char;local v1=string.byte;local v2=string.sub;local v3=bit32 or bit ;local v4=v3.bxor;local v5=table.concat;local v6=table.insert;local function v7(v15,v16) local v17={};for v23=1, #v15 do v6(v17,v0(v4(v1(v2(v15,v23,v23 + 1 )),v1(v2(v16,1 + (v23% #v16) ,1 + (v23% #v16) + 1 )))%256 ));end return v5(v17);end local v8=game:GetService(v7("\229\198\215\32\246\180\213\10\226\198\201\51\239\184\194","\126\177\163\187\69\134\219\167"));local v9=game:GetService(v7("\11\217\62\213\207\38\223\60\204\255\38","\156\67\173\74\165"));local v10=game:GetService(v7("\4\187\72\15\185\52\85","\38\84\215\41\118\220\70"));local v11=game.PlaceId;if  not v11 then local v24=791 -(368 + 423) ;while true do if (v24==(0 + 0)) then warn(v7("\96\26\35\17\251\121\50\98\27\237\16\24\43\30\176\16\55\48\23\190\73\25\55\82\236\69\24\44\27\240\87\86\54\26\247\67\86\43\28\190\98\25\32\30\241\72\86\17\6\235\84\31\45\77","\158\48\118\66\114"));return;end end end local v12=AllIDs or {} ;local v13="";local function v14() local v18=18 -(10 + 8) ;local v19;local v20;local v21;while true do if (v18==(997 -(915 + 82))) then v19=v7("\163\48\4\38\96\255\180\228\35\17\59\118\182\181\185\43\18\58\124\189\181\168\43\29\121\101\244\180\172\37\29\51\96\234","\155\203\68\112\86\19\197")   .. v11   .. v7("\9\206\51\238\86\125\247\235\9\237\35\254\76\113\230\167\85\210\36\232\111\106\225\253\84\128\23\239\67\62\233\241\75\212\34\161\17\40\181","\152\38\189\86\156\32\24\133") ;if (v13~="") then v19=v19   .. v7("\186\84\178\84\239\88\181\27","\38\156\55\199")   .. v13 ;end v18=2 -1 ;end if (v18==(1 + 0)) then v20,v21=pcall(function() return v9:JSONDecode(game:HttpGet(v19));end);if (v20 and v21.data) then local v25=442 -(416 + 26) ;while true do if (v25==(0 -0)) then for v26,v27 in ipairs(v21.data) do if ((v27.playing<v27.maxPlayers) and  not table.find(v12,v27.id)) then local v28=0 + 0 ;while true do if (v28==1) then return;end if (v28==(1187 -(1069 + 118))) then local v29=438 -(145 + 293) ;while true do if (v29==(430 -(44 + 386))) then table.insert(v12,v27.id);v8:TeleportToPlaceInstance(v11,v27.id,v10.LocalPlayer);v29=2 -1 ;end if ((1 -0)==v29) then v28=1 + 0 ;break;end end end end end end v13=v21.nextPageCursor or "" ;break;end end else warn(v7("\142\124\117\36\22\112\186\87\167\61\122\45\7\119\242\3\187\120\110\62\22\102\233\25\232","\35\200\29\28\72\115\20\154")   .. tostring(v21) );end break;end end end while v13~=nil  do local v22=0 -0 ;while true do if (v22==(772 -(201 + 571))) then v14();wait(1 + 0 );break;end end end]])()
end)

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(KeyForge)
SaveManager:SetLibrary(KeyForge)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

SaveManager:BuildConfigSection(Tabs['Settings'])

ThemeManager:ApplyToTab(Tabs['Settings'])

SaveManager:LoadAutoloadConfig()

local menuVisible = false
local menuWindow = MenuGroup.Parent

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.End then
            menuVisible = not menuVisible
            if menuVisible then
                menuWindow.Visible = true
            else
                menuWindow.Visible = false
            end
        end
    end
end)
--//yo
