local UIS = game:GetService("UserInputService")
local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

if mobile then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XZuuyaX/XZuyaX-s-Hub/main/Test.lua"))()
else
    loadstring(game:HttpGet("https://protected-roblox-scripts.onrender.com/230ba0efdee09ac0dccdcf0b566fec49"))()
end
