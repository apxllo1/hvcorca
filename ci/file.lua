--[[
    file.lua – HAVOC v2.0 FileWriter
    Handles writing the bundle string to a file.
]]--

local File = {}

local OUTPUT_PATH = "havoc.bundle.lua"  -- adjust path if needed

function File.write(content)
    -- If you're running in a local Lua env (e.g., Lune, Wax, etc.):
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
