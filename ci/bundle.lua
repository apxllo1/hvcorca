local PARAMS={...}

local function getFlag(f)
	for _,v in ipairs(PARAMS)do
		if v==f then return true end
	end
	return false
end

local OUTPUT_PATH=assert(PARAMS[1])
local VERSION=assert(PARAMS[2])
local DEBUG_MODE=getFlag("debug")
local VERBOSE=getFlag("verbose")
local MINIFY=getFlag("minify")

local ROJO_INPUT=assert(PARAMS[3])
local RUNTIME_FILE="ci/runtime.lua"
local BUNDLE_TEMP="ci/bundle.tmp"

local function transformInput(s)
	s=string.gsub(s,"([%w_]+)%s*([%+%-%*/%%^%.]%.?)=%s*","%1 = %1 %2")
	s=string.gsub(s,"(%s+)continue(%s+)","%1__CONTINUE__()%2")
	return s
end

local function transformOutput(s)
	s=string.gsub(s,"%.%.%.:","(...):")
	s=string.gsub(s,"__CONTINUE__%(%)","continue;")
	return s
end

local function minify(s)
	remodel.writeFile(BUNDLE_TEMP,transformInput(s))
	os.execute("node ci/minify.js")
	local o=remodel.readFile(BUNDLE_TEMP)
	os.remove(BUNDLE_TEMP)
	return transformOutput(o)
end

local function writeModule(o,output)
	local id=o:GetFullName()
	local source=remodel.getRawProperty(o,"Source")
	local path=string.format("%q",id)
	local parent=o.Parent and string.format("%q",o.Parent:GetFullName())or"nil"
	local name=string.format("%q",o.Name)
	local className=string.format("%q",o.ClassName)
	if DEBUG_MODE then
		local def=table.concat({"newModule("..name..", "..className..", "..path..", "..parent..", function ()","local fn = assert(loadstring("..string.format("%q",source)..", '@'.."..path.."))","setfenv(fn, newEnv("..path.."))","return fn()","end)",}," ")
		table.insert(output,def)
	else
		local def=table.concat({"newModule("..name..", "..className..", "..path..", "..parent..", function ()","return setfenv(function()",source,"end, newEnv("..path.."))()","end)",}," ")
		table.insert(output,def)
	end
end

local function writeInstance(o,output)
	local id=o:GetFullName()
	local path=string.format("%q",id)
	local parent=o.Parent and string.format("%q",o.Parent:GetFullName())or"nil"
	local name=string.format("%q",o.Name)
	local className=string.format("%q",o.ClassName)
	local def=table.concat({"newInstance("..name..", "..className..", "..path..", "..parent..")"},"\n")
	table.insert(output,def)
end

local function writeInstanceTree(o,output)
	if o.ClassName=="LocalScript"or o.ClassName=="ModuleScript"then
		writeModule(o,output)
	else
		writeInstance(o,output)
	end
	for _,c in ipairs(o:GetChildren())do
		writeInstanceTree(c,output)
	end
end

local function main()
	local output={}
	local model=remodel.readModelFile(ROJO_INPUT)[1]
	writeInstanceTree(model,output)
	if MINIFY then
		output={minify(table.concat(output,"\n"))}
	end
	local runtime=string.gsub(remodel.readFile(RUNTIME_FILE),"__VERSION__",string.format("%q",VERSION))
	table.insert(output,1,runtime)
	table.insert(output,"hInit()")
	if VERBOSE then
		table.insert(output,2,"local START_TIME = os.clock()")
		table.insert(output,"print(\"[CI "..VERSION.."] Orca run in \" .. (os.clock() - START_TIME) * 1000 .. \" ms\")")
	end
	local dir=string.match(OUTPUT_PATH,"^(.*)[/\\\\]")or"."
	remodel.createDirAll(dir)
	remodel.writeFile(OUTPUT_PATH,table.concat(output,"\n\n"))
	print("[CI "..VERSION.."] Bundle written to "..OUTPUT_PATH)
end

main()
