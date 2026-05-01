--[[
    file.lua – HAVOC v2.0 FileWriter
    Handles writing the bundle string to a file.
]]--

local File = {}

local OUTPUT_PATH = "havoc.bundle.lua"  -- path on your machine

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
