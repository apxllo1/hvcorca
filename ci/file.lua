--[[
    file.lua – HAVOC v2.0 FileWriter
]]--

local File = {}

-- Write bundle to public/latest.lua (or wherever you want)
local OUTPUT_PATH = "public/latest.lua"

function File.write(content)
    local file, err = io.open(OUTPUT_PATH, "w")
    if not file then
        -- If `warn` doesn't exist, use `print` as fallback
        (warn or print)("HAVOC FileWriter: could not open file: " .. tostring(err))
        return
    end

    file:write(content)
    file:close()

    (warn or print)("📦 HAVOC bundle written to: " .. OUTPUT_PATH)
end

return File
