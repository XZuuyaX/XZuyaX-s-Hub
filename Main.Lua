local UIS = game:GetService("UserInputService")
local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

if mobile then
    loadstring(game:HttpGet("https://loader.xzuyaxhub.workers.dev/?repo=BLR"))()
else
    loadstring(game:HttpGet("https://loaders.xzuyaxhub.workers.dev"))()
end
