--[[----------------------------------------------------------------------------

  Application Name: 
  RecorderFile                                                                                                                       
  
  Summary: 
  Introduction to data recording and playback using a file as storage.
                                                                              
  Description: 
  This application can be used to record data into and playback from recording files.
  It includes a specific user interface, which can be used to:
    - show and specify the events recorded.
    - specify the data format to record and playback.
    - specify the filename to record to and playback from.
    - specify and parametrize the recording mode.
    - parametrize the playback.
    - start and stop the recording and playback.
    - start and stop the data source.
    - show the images provided by the data source.
  The user interface contains two pages, one for recording and one for playback.
  
  How to run:
  Connect a web-browser to the device IP-Address and you will see the web-page of this sample.  
  
------------------------------------------------------------------------------]]

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

--@startRecording()
function startRecording()
  recorder:setMetaInfo("Comment", "text/plain", "This is a sample for the recording API!")
  recorder:setMetaInfo("Comment2", "application/octet-stream", "Example", "Find a sample for how to use recording here!")
  recorder:removeAllTargets()
  recorder:addFileTarget(recFile..".sdr." .. string.lower(currentDataFormat), recFile..".sdri." .. string.lower(currentDataFormat))
  recorder:start()
  print("Recording started. Recording will be saved to " .. recFile)
end

--@stopRecording()
function stopRecording()
  recorder:stop()
  print("Recording stopped")
end

--@startPlayback()
function startPlayback()
  play:setFileSource(playFile..".sdr." .. string.lower(currentDataFormat), playFile..".sdri."  .. string.lower(currentDataFormat))
  play:register("OnPlaybackStopped", "restart")
  play:start()
  canceled = false
  print("Playback started")
end

--@stopPlayback()
function stopPlayback()
  canceled = true
  play:stop()
  print("Playback stopped")
end

--@handleOnNewSensorData(tsstring:string,framenostring:string)
function handleOnNewSensorData(tsstring,framenostring)
  sData = "FrameNo: " .. framenostring .. " Timestamp: " .. tsstring
  Script.notifyEvent("OnSensorDataUpdate",sData)
end
local regSuccess = Script.register("DataSource.OnNewSensorData", handleOnNewSensorData)

--@setDataFormat(format:string)
function setDataFormat(format)
  recorder:setDataFormat(format)
  currentDataFormat = format
end

--@getDataFormats():string[]
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

--@getCurrentDataFormat():string[]
function getCurrentDataFormat()
  return currentDataFormat
end

--@getProviderString():string
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
  
--@setCurrentProviders(providers:auto)
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

--@getRecMode():int
function getRecMode()
  return recMode
end

--@setRecMode(mode:int)
function setRecMode(mode)
  recMode = mode
  print(recmodes[mode])
  recorder:setMode(recmodes[mode], modeParam)
end

--@getModeParam():int
function getModeParam()
  return modeParam
end

--@setModeParam(param:int)
function setModeParam(param)
  modeParam = param
  recorder:setMode(recmodes[recMode], modeParam)
end

--@getRecFilePath():string
function getRecFilePath()
  return recFile
end

--@setRecFilePath(path:string)
function setRecFilePath(path)
  recFile = path
end

--@getPlayFilePath():string
function getPlayFilePath()
  return playFile
end

--@setPlayFilePath(path:string)
function setPlayFilePath(path)
  playFile = path
end

--@getLoop():boolean
function getLoop()
  return loop
end

--@setLoop(doLoop:boolean)
function setLoop(doLoop)
  loop = doLoop
end

--@restart()
function restart()
  if loop and not canceled then
    startPlayback()
  end
end

--@toggleDataSource(running:boolean)
function toggleDataSource(running)
  if running then
    dataSourceRunning = true
    DataSource.start()
  else
    dataSourceRunning = false
    DataSource.mute()
  end
end

--@getDataSourceRunning():boolean
function getDataSourceRunning()
  return dataSourceRunning
end

--@getDataSourceMode():String
function getDataSourceMode()
  return dataSourceMode
end

--@setDataSourceMode(mode:String)
function setDataSourceMode(mode)
  dataSourceMode = mode
  play:setDataSourceMode(mode)
end

--@getPlaybackMode():String
function getPlaybackMode()
  return playmode
end

--@setPlaybackMode(mode:String)
function setPlaybackMode(mode)
  playmode = mode
  play:setPlayBackMode(mode)
end

--@getDataSourceLookupMode():String
function getDataSourceLookupMode()
  return dataSourceLookupMode
end

--@setDataSourceLookupMode(mode:String)
function setDataSourceLookupMode(mode)
  dataSourceLookupMode = mode
  play:setDataSourceLookupMode(mode)
end

--@getSpeedupFactor():int
function getSpeedupFactor()
  return speedupFactor
end

--@setSpeedupFactor(factor:int)
function setSpeedupFactor(factor)
  speedupFactor = factor
  play:setSpeedUpFactor(factor)
end

--@getDataSourceModes():String
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

--@getPlaybackModes():String
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

--@getDataSourceLookupModes():String
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
