--[[
    file.lua – HAVOC v2.0 FileWriter
]]--

local File = {}

-- Write bundle into repo's public/latest.lua
local OUTPUT_PATH = "public/latest.lua"

function File.write(content)
    remodel.writeFile(OUTPUT_PATH, content)
end

return File
