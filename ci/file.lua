local FileStream = {}

function FileStream.write(content)
    local file = io.open("public/latest.lua", "w")
    if not file then
        error("Failed to open public/latest.lua for writing")
    end
    file:write(content)
    file:close()
    print("✅ Wrote public/latest.lua")
end

return FileStream
