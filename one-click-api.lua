local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local isSystemActive = true
local lastHeartbeatSent = 0

if not one_click_config or not one_click_config.HEARTBEAT_SERVER_URL or not one_click_config.PC_NAME or not one_click_config.ONE_CLICK_USERNAME or not one_click_config.HEARTBEAT_INTERVAL then
    warn("Heartbeat System: CRITICAL ERROR - 'one_click_config' is incomplete. Make sure HEARTBEAT_SERVER_URL is set by the client.")
    isSystemActive = false
    return
end

local HEARTBEAT_ENDPOINT = one_click_config.HEARTBEAT_SERVER_URL .. "/api/heartbeat/lua"


local function stopSystem(reason)
    if not isSystemActive then return end
    isSystemActive = false
    print(string.format("Heartbeat System: Stopping. Reason: %s", reason))
end

local function sendHeartbeat()
    if not isSystemActive or not LocalPlayer or not LocalPlayer.Name or (tick() - lastHeartbeatSent < one_click_config.HEARTBEAT_INTERVAL) then
        return
    end

    lastHeartbeatSent = tick()

    local payload = {
        pc_name = one_click_config.PC_NAME,
        account = one_click_config.ONE_CLICK_USERNAME,
        username = LocalPlayer.Name
    }

    local requestData = {
        Url = HEARTBEAT_ENDPOINT,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    }

    task.spawn(function()
        if not http_request then
            warn("Heartbeat System: 'http_request' function not available in this executor.")
            stopSystem("http_request not found")
            return
        end

        local success, response = pcall(function()
            return http_request(requestData)
        end)

        if not success then
            warn("Heartbeat System: Critical error calling http_request: " .. tostring(response))
        elseif response and not response.Success then
        end
    end)
end

-- ==============================================================================
-- ===                         Event Listeners & Main Loop                  ===
-- ==============================================================================

if not LocalPlayer then
    print("Heartbeat System: Waiting for LocalPlayer...")
    LocalPlayer = Players.PlayerAdded:Wait()
end

print(string.format("Heartbeat System: Initialized for %s (ID: %d) on PC '%s'", LocalPlayer.Name, LocalPlayer.UserId, one_click_config.PC_NAME))
print("Heartbeat System: Target URL -> " .. HEARTBEAT_ENDPOINT)

GuiService.ErrorMessageChanged:Connect(function()
    local errorCode = GuiService:GetErrorCode().Value
    if errorCode >= Enum.ConnectionError.DisconnectErrors.Value then
        local errorName = "Unknown"
        for _, enumItem in ipairs(Enum.ConnectionError:GetEnumItems()) do
            if enumItem.Value == errorCode then
                errorName = enumItem.Name
                break
            end
        end
        stopSystem(string.format("Game Disconnect Error (%d: %s)", errorCode, errorName))
    end
    task.wait(1)
    game:Shutdown()
end)

TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    if player == LocalPlayer then
        stopSystem(string.format("Teleport Failed (%s)", teleportResult.Name))
    end
end)

LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Started then
        stopSystem("Teleport Started")
    end
end)

print("Heartbeat System: Event handlers connected.")
RunService.Heartbeat:Connect(sendHeartbeat)
print("--- Heartbeat System is now active. ---")
