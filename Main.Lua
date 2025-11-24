local dcl = "https://discord.gg/X4H7phPu8P" 

pcall(function()
    if setclipboard then
        setclipboard(dcl)
    elseif toclipboard then
        toclipboard(dcl)
    end
end)

local msg = "This script is not updated yet. Please join the Discord. The link has been copied."

game.Players.LocalPlayer:Kick(msg)
