--[[
    file.lua – HAVOC v2.0 FileWriter
]]--

local File = {}

-- Write bundle straight into public/latest.lua
local OUTPUT_PATH = "public/latest.lua"  -- ← make sure path is relative like this

function File.write(content)
    local file, err = io.open(OUTPUT_PATH, "w")
    if not file then
        warn("HAVOC FileWriter: could not open file: " .. tostring(err))
        return
    end

    file:write(content)
    file:close()

    print("📦 HAVOC bundle written to: " .. OUTPUT_PATH)
end

return File
