
--Start of Global Scope---------------------------------------------------------
json = require "json"

--servce functions for acces via the user interface
Script.serveFunction("RecorderFile.startRecording","startRecording")
Script.serveFunction("RecorderFile.stopRecording","stopRecording")
Script.serveFunction("RecorderFile.startPlayback","startPlayback")
Script.serveFunction("RecorderFile.stopPlayback","stopPlayback")
Script.serveFunction("RecorderFile.setDataFormat", "setDataFormat")
Script.serveFunction("RecorderFile.getDataFormats", "getDataFormats")
Script.serveFunction("RecorderFile.getCurrentDataFormat", "getCurrentDataFormat")
Script.serveFunction("RecorderFile.getProviderString", "getProviderString")
Script.serveFunction("RecorderFile.setCurrentProviders", "setCurrentProviders")
Script.serveFunction("RecorderFile.getRecMode", "getRecMode")
Script.serveFunction("RecorderFile.setRecMode", "setRecMode")
Script.serveFunction("RecorderFile.getModeParam", "getModeParam")
Script.serveFunction("RecorderFile.setModeParam", "setModeParam")
Script.serveFunction("RecorderFile.getRecFilePath", "getRecFilePath")
Script.serveFunction("RecorderFile.setRecFilePath", "setRecFilePath")
Script.serveFunction("RecorderFile.getPlayFilePath", "getPlayFilePath")
Script.serveFunction("RecorderFile.setPlayFilePath", "setPlayFilePath")
Script.serveFunction("RecorderFile.toggleDataSource", "toggleDataSource")
Script.serveFunction("RecorderFile.getDataSourceRunning", "getDataSourceRunning")
Script.serveFunction("RecorderFile.getLoop", "getLoop")
Script.serveFunction("RecorderFile.setLoop", "setLoop")
Script.serveFunction("RecorderFile.getDataSourceMode", "getDataSourceMode")
Script.serveFunction("RecorderFile.getDataSourceModes", "getDataSourceModes")
Script.serveFunction("RecorderFile.setDataSourceMode", "setDataSourceMode")
Script.serveFunction("RecorderFile.getPlaybackMode", "getPlaybackMode")
Script.serveFunction("RecorderFile.getPlaybackModes", "getPlaybackModes")
Script.serveFunction("RecorderFile.setPlaybackMode", "setPlaybackMode")
Script.serveFunction("RecorderFile.getDataSourceLookupMode", "getDataSourceLookupMode")
Script.serveFunction("RecorderFile.getDataSourceLookupModes", "getDataSourceLookupModes")
Script.serveFunction("RecorderFile.setDataSourceLookupMode", "setDataSourceLookupMode")
Script.serveFunction("RecorderFile.getSpeedupFactor", "getSpeedupFactor")
Script.serveFunction("RecorderFile.setSpeedupFactor", "setSpeedupFactor")
Script.serveEvent("RecorderFile.OnSensorDataUpdate","OnSensorDataUpdate")
Script.serveEvent("RecorderFile.ProvidersChanged","ProvidersChanged")

--init recorder
local recorder = Recording.Recorder.create()
local provs = recorder:getProviders() -- provs is a list
provs[1]:setSelected(true)
print("Number of providers is " .. #provs)
recorder:setProviders(provs)

--init player
local play = Recording.Player.create()

--init modes
local recmodes = Engine.getEnumValues("Recording.Recorder.RecordingMode")
local dataSourceModes = Engine.getEnumValues("Recording.Player.DataSourceMode")
local playmodes = Engine.getEnumValues("Recording.Player.PlayBackMode")
local dataSourceLookupModes = Engine.getEnumValues("Recording.Player.DataSourceLookupMode")
recMode = 1
dataSourceMode = "MUTE"
playmode = "TIME_BASED"
dataSourceLookupMode = "BEST_MATCH"
speedupFactor = 1

--init parametrization
recProv = nil
recFile = "public/MyRecording"
playFile = "public/MyRecording"
modeParam = 128 --default queue size
loop = false
canceled = false
dataSourceRunning = true
currentDataFormat = "JSON"

--init viewer
viewer1 = View.create()
viewer1:setID("Viewer1")

function startRecording()
  recorder:setMetaInfo("Comment", "text/plain", "This is a sample for the recording API!")
  recorder:setMetaInfo("Comment2", "application/octet-stream", "Example", "Find a sample for how to use recording here!")
  recorder:removeAllTargets()
  recorder:addFileTarget(recFile..".sdr." .. string.lower(currentDataFormat), recFile..".sdri." .. string.lower(currentDataFormat))
  recorder:start()
  print("Recording started. Recording will be saved to " .. recFile)
end

function stopRecording()
  recorder:stop()
  print("Recording stopped")
end

function startPlayback()
  play:setFileSource(playFile..".sdr." .. string.lower(currentDataFormat), playFile..".sdri."  .. string.lower(currentDataFormat))
  play:register("OnPlaybackStopped", "restart")
  play:start()
  canceled = false
  print("Playback started")
end

function stopPlayback()
  canceled = true
  play:stop()
  print("Playback stopped")
end

---@param tsstring string
---@param framenostring string
function handleOnNewSensorData(tsstring,framenostring)
  sData = "FrameNo: " .. framenostring .. " Timestamp: " .. tsstring
  Script.notifyEvent("OnSensorDataUpdate",sData)
end
local regSuccess = Script.register("DataSource.OnNewSensorData", handleOnNewSensorData)

---@param format string
function setDataFormat(format)
  recorder:setDataFormat(format)
  currentDataFormat = format
end

---@return string
function getDataFormats()
  local formats = Engine.getEnumValues("Object.DataFormat")
  local res = "["
  for key,value in pairs(formats) do
    res = res .. "{" .. "\"label\":\"" .. value .. "\",\"value\":\"" .. value .. "\"},"
  end
  if(#res > 1) then
    res = string.sub(res, 0, #res-1)
  end
  res = res .. "]"
  return res
end

---@return string[]
function getCurrentDataFormat()
  return currentDataFormat
end

---@return string
function getProviderString()
  local provString = "["
  for key,value in pairs(provs) do
    provString = provString .. "{"
    prov = value
    appName = prov:getAppName()
    if string.len(appName) ~= 0 then
      name = appName .. "." .. prov:getCrownName() .. "." .. prov:getEventName()
    else
      name = prov:getCrownName() .. "." .. prov:getEventName()
    end

    selected = prov:getSelected()
    conf = prov:getConfigData()
    provString = provString .. "\"name\":\"" .. name .. "\","
    provString = provString .. "\"selected\":" .. tostring(selected) .. ","
    provString = provString .. "\"config\":\"" .. string.gsub(conf, "\"", "\\\"") .. "\","
    provString = provString .. "\"engine\":\"" .. prov:getEngineName() .. "\","
    provString = provString .. "\"instanceCount\":" .. prov:getInstanceCount()
    provString = provString .. "},"
  end
  if (#provString > 1) then
    provString = string.sub(provString, 0, #provString - 1)
  end
  provString = provString .. "]"
  return provString
end

---@param providers auto
function setCurrentProviders(providers)
  local prvTbl = json.decode(providers)
  local newProviders = {}
  for key,prov in pairs(prvTbl) do
    local name = prov["name"]
    local nameParts = {}
    nameParts["app"] = string.sub(name, 0, string.find(name, "%.") - 1)
    name = string.sub(name, string.find(name, "%.") + 1)
    while string.find(name, "%.") ~= nil do
      local pos = string.find(name, "%.")
      if(nameParts["crown"] == nil) then
        nameParts["crown"] = string.sub(name, 0, pos - 1)
      else
        nameParts["crown"] = nameParts["crown"] .. "." .. string.sub(name, 0, pos - 1)
      end
      name = string.sub(name, pos + 1)
    end
    nameParts["event"] = name
    local provider = Recording.Provider.create()
    provider:setAppName(nameParts["app"])
    provider:setCrownName(nameParts["crown"])
    provider:setEventName(nameParts["event"])
    provider:setSelected(prov["selected"])
    provider:setConfigData(prov["config"])
    provider:setEngineName(prov["engine"])
    provider:setInstanceCount(prov["instanceCount"])
    newProviders[key] = provider
  end
  provs = newProviders
  recorder:setProviders(newProviders)
  Script.notifyEvent("ProvidersChanged", getProviderString())
end

---@return int
function getRecMode()
  return recMode
end

---@param mode int
function setRecMode(mode)
  recMode = mode
  print(recmodes[mode])
  recorder:setMode(recmodes[mode], modeParam)
end

---@return int
function getModeParam()
  return modeParam
end

---@param param int
function setModeParam(param)
  modeParam = param
  recorder:setMode(recmodes[recMode], modeParam)
end

---@returnn string
function getRecFilePath()
  return recFile
end

---@param path string
function setRecFilePath(path)
  recFile = path
end

---@return string
function getPlayFilePath()
  return playFile
end

---@param path string
function setPlayFilePath(path)
  playFile = path
end

---@return boolean
function getLoop()
  return loop
end

---@param doLoop boolean
function setLoop(doLoop)
  loop = doLoop
end

function restart()
  if loop and not canceled then
    startPlayback()
  end
end

---@param running boolean
function toggleDataSource(running)
  if running then
    dataSourceRunning = true
    DataSource.start()
  else
    dataSourceRunning = false
    DataSource.mute()
  end
end

---@return boolean
function getDataSourceRunning()
  return dataSourceRunning
end

---@return String
function getDataSourceMode()
  return dataSourceMode
end

---@param mode String
function setDataSourceMode(mode)
  dataSourceMode = mode
  play:setDataSourceMode(mode)
end

---@param String
function getPlaybackMode()
  return playmode
end

---@param mode String
function setPlaybackMode(mode)
  playmode = mode
  play:setPlayBackMode(mode)
end

---@return String
function getDataSourceLookupMode()
  return dataSourceLookupMode
end

---@param mode String
function setDataSourceLookupMode(mode)
  dataSourceLookupMode = mode
  play:setDataSourceLookupMode(mode)
end

---@return int
function getSpeedupFactor()
  return speedupFactor
end

---@param factor int
function setSpeedupFactor(factor)
  speedupFactor = factor
  play:setSpeedUpFactor(factor)
end

---@return String
function getDataSourceModes()
  local res = "["
  for key,value in pairs(dataSourceModes) do
    res = res .. "{" .. "\"label\":\"" .. value .. "\",\"value\":\"" .. value .. "\"},"
  end
  if(#res > 1) then
    res = string.sub(res, 0, #res-1)
  end
  res = res .. "]"
  return res
end

---@return String
function getPlaybackModes()
  local res = "["
  for key,value in pairs(playmodes) do
    res = res .. "{" .. "\"label\":\"" .. value .. "\",\"value\":\"" .. value .. "\"},"
  end
  if(#res > 1) then
    res = string.sub(res, 0, #res-1)
  end
  res = res .. "]"
  return res
end

---@return String
function getDataSourceLookupModes()
  local res = "["
  for key,value in pairs(dataSourceLookupModes) do
    res = res .. "{" .. "\"label\":\"" .. value .. "\",\"value\":\"" .. value .. "\"},"
  end
  if(#res > 1) then
    res = string.sub(res, 0, #res-1)
  end
  res = res .. "]"
  return res
end
