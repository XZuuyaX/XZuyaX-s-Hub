local UIS = game:GetService("UserInputService")
local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

if mobile then
    loadstring(game:HttpGet("https://xzuyax-hub.vercel.app/api/loader?script=BLR.lua"))()
else
    loadstring(game:HttpGet("https://loaders.xzuyaxhub.workers.dev"))()
end
