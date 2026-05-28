-- [[ SISTEMA DE PROTEÇÃO LOWHIGH STORE - PREMIUM ]] --
local KeyAuthApp = loadstring(game:HttpGet("https://raw.githubusercontent.com/KeyAuth/roblox-lua-example/main/KeyAuth.lua"))()

KeyAuthApp:init({
    name = "Jeaneloy01's Application",
    ownerid = "bg8cRvXsrd",
    secret = "803735a5e270d0b55245276f24f541361b0065532fb94760c86688ac90ddb9dd", -- <--- NÃO ESQUEÇA A SECRET!
    version = "1.0"
})

KeyAuthApp:login()

-- BLOQUEIO EXCLUSIVO: Só passa se a Key for Level 3
if KeyAuthApp.user_data.subscriptions[1].level ~= "3" then
    game.Players.LocalPlayer:Kick("❌ LowHigh Store: Acesso NEGADO. Esta key não é PREMIUM!")
end

print("Acesso TOTAL Liberado! Bem-vindo ao LowHigh PREMIUM.")

-- [[ SCRIPT PREMIUM - O MAIS APELÃO ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-up-library/master/gui%20v2"))()
local Window = Library:CreateWindow("LowHigh Store - PREMIUM 👑")

-- VARIÁVEIS GLOBAIS
_G.SilentAim = false
_G.HitboxSize = 15
_G.HitboxEnabled = false

-- ABA DE COMBATE (SILENT + HITBOX)
local Combat = Window:Folder("Combate Ultra")

Combat:Toggle("Ativar Silent Aim", function(state)
    _G.SilentAim = state
end)

Combat:Toggle("Ativar Hitbox (Expand)", function(state)
    _G.HitboxEnabled = state
end)

Combat:Slider("Tamanho da Cabeça", 5, 50, 15, function(val)
    _G.HitboxSize = val
end)

-- ABA VISUAL
local Visuals = Window:Folder("Visual")
Visuals:Button("Ativar Full ESP", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/p00p-shid/ESP/main/ESP.lua"))()
end)

-- LÓGICA DA HITBOX (PREMIUM)
spawn(function()
    while wait(1) do
        if _G.HitboxEnabled then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    p.Character.Head.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                    p.Character.Head.Transparency = 0.7
                    p.Character.Head.Material = "Neon"
                    p.Character.Head.CanCollide = false
                end
            end
        end
    end
end)

-- LÓGICA DO SILENT AIM (PREMIUM)
local Mouse = game.Players.LocalPlayer:GetMouse()
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, index)
    if self == Mouse and index == "Hit" and _G.SilentAim then
        -- Lógica simplificada de busca de alvo
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                return v.Character.Head.CFrame
            end
        end
    end
    return oldIndex(self, index)
end)

Main:Label("VOCÊ É UM USUÁRIO PREMIUM!", Color3.fromRGB(0, 255, 0))
