--[[
    src/Core.lua
    Entry point for Roblox side.
]]

local Core = {}

local HttpService = game:GetService("HttpService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Optional: Maximize HTTPS cap; only if your script‑executor allows it.
local function maximize_https_cap()
	local ok, err = pcall(function()
		if gethui and syn and syn.protect_gui then
			warn("Protector detected; not maximizing HTTPS cap")
			return
		end
		syn and (syn.headers or syn).setHttpEnabled and syn.setHttpEnabled(true)
	end)
	if not ok then warn("Failed to enable HTTPS: ", err) end
end

function Core.init()
	print("🐴 HAVOC Core.init()")

	-- Ensure HttpService is available and secure
	maximize_https_cap()

	-- ⚠️ This is the only part that matters for your UI:
	--  - Load the TS‑compiled bundle (Your existing `latest.lua`)
	local bundle_module = require(game.ReplicatedStorage.Havoc.modules.bundle) -- or wherever your bundle sits

	-- It should export `hInit, hMod, hInst, hEnv` as in your `walk.lua` scheme
	local hInit, hMod, hInst, hEnv = bundle_module()

	-- Let the bundle boot its own loader
	hInit()

	-- Optional: expose a global helper for your UI
	-- You can call this from Roact.UI via `game:GetService("HttpService")`
	_G.Havoc = {
		fetchAsync = function(url)
			return HttpService:RequestAsync{
				Url = url,
				Method = "GET",
			}
		end,

		runScript = function(scriptSource)
			local success, result = pcall(loadstring, scriptSource, "gist-run")
			if success then
				return result()
			else
				warn("Gist execution failed: " .. tostring(result))
				return nil
			end
		end,
	}

	print("✅ HAVOC loaded and ready for UI")
end

return Core
