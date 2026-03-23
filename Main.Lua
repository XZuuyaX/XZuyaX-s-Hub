local UIS = game:GetService("UserInputService")
local mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

if mobile then
    loadstring(game:HttpGet("https://xzuyax-hub.vercel.app/BLR.lua"))()
else
    loadstring(game:HttpGet("https://xzuyaxserver.up.railway.app/loader/BLR"))()
end
