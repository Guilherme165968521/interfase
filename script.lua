-- Serviços utilizados
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Interface Rayfield
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/Guilherme165968521/interfase/refs/heads/main/interfase.lua"))()
local Window = Rayfield:CreateWindow({
    Name = "Brainrot Finder",
    LoadingTitle = "Loading Brainrot Finder...",
    Enabled = true,
    FolderName = "SabFinderV1",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "Config"
    },
    KeySystem = true,
    KeySettings = {
        Title = "Brainrot Finder Key System",
        Subtitle = "Enter your key below",
        Note = "Get your key @Guizera",
        FileName = "BrainrotFinderKey",
        SaveKey = true,
        Key = "guizeraomaisbrabo"
    }
})

-- Variáveis de estado
local webhookURL = ""
local stopOnRare = false
local hopping = false

-- Aba principal
local MainTab = Window:CreateTab("Main", nil)

MainTab:CreateInput({
    Name = "Webhook URL (optional)",
    Flag = "Webhook",
    PlaceholderText = "Defaults to rare ping only",
    RemoveTextAfterFocusLost = true,
    Callback = function(Value)
        webhookURL = Value
    end
})

MainTab:CreateToggle({
    Name = "Stop hopping when rare is found",
    CurrentValue = false,
    Flag = "StopOnRareToggle",
    Callback = function(Value)
        stopOnRare = Value
    end
})

MainTab:CreateToggle({
    Name = "Start Hopping",
    CurrentValue = false,
    Flag = "StartHop",
    Callback = function(Value)
        hopping = Value
        if hopping then
            print("[HOPPING STARTED]")
            spawn(hopLoop)
        else
            print("[HOPPING PAUSED]")
        end
    end
})

-- Hotkey para iniciar hopping
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Q then
        hopping = not hopping
        if hopping then
            print("[HOPPING STARTED]")
            spawn(hopLoop)
        else
            print("[HOPPING PAUSED]")
        end
    end
end)

-- Notificação de carregamento
Rayfield:Notify({
    Title = "Brainrot Finder",
    Content = "Loaded. Press Q or use toggle to start.",
    Duration = 5
})

-- Função de teleport/hopping
function hopLoop()
    while hopping do
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)

        if success and response and response.data then
            for _, server in ipairs(response.data) do
                if server.playing < 50 and server.id ~= game.JobId then
                    print("[HOP] Teleporting...")
                    local ok, err = pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                    end)
                    if not ok then
                        warn("[Teleport Error]:", err)
                        print("[Teleport Failed] Rejoining current server...")
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
                    end
                    task.wait(3)
                    return
                end
            end
            print("- No models found.")
        end

        task.wait(5)
    end
end

-- Enviar mensagem para Webhook (se necessário)
function sendWebhook(content)
    if webhookURL == "" then return end
    local payload = HttpService:JSONEncode({
        content = content
    })

    local success, err = pcall(function()
        local req = (syn and syn.request) or (http_request) or (fluxus and fluxus.request)
        if req then
            req({
                Url = webhookURL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = payload
            })
        else
            warn("No HTTP request method found.")
        end
    end)
end

-- Raros reconhecidos no jogo (provavelmente NPCs ou blocos)
local raros = {
    "Cocofanto Elephanto",
    "Girafa Celestre",
    "Tralalero Tralala",
    "Gattatino Neonino",
    "Odin Din Din Dun",
    "Tigroligre Frutonni",
    "Espresso Signora",
    "Orcalero Orcala",
    "Matteo",
    "Statutino Libertino",
    "Ballerino Lololo",
    "Trenostruzzo Turbo 3000",
    "Piccione Macchina",
    "Brainrot God Lucky Block",
    "La Vacca Saturno Saturnita",
    "Chimpanzini Spiderini",
    "Los Tralaleritos",
    "Las Tralaleritas",
    "Las Vaquitas Saturnitas",
    "Graipuss Medussi",
    "Torrtuginni Dragonfrutini",
    "Chicletera Bicicletera",
    "Pot Hotspot",
    "La Grande Combinasion",
    "Nuclearo Dinossauro",
    "Garama and Madundung",
    "Secret Lucky Block"
}

-- Detecção de raridade
function verificarRaros()
    for _, nome in ipairs(raros) do
        if workspace:FindFirstChild(nome) then
            print("[RARE FOUND] Stopping hopping.")
            sendWebhook("Raro encontrado: " .. nome)
            if stopOnRare then
                hopping = false
            end
            break
        end
    end
end

-- Loop de verificação
task.spawn(function()
    while true do
        if hopping then
            verificarRaros()
        end
        task.wait(2)
    end
end)
