
Script.serveFunction("DataSource.start", "start")
Script.serveFunction("DataSource.mute", "mute")
Script.serveEvent("DataSource.OnNewSensorData","OnNewSensorData")

viewer1 = View.create()
viewer1:setID("Viewer1")


--Start of Global Scope---------------------------------------------------------

playPath = "resources/"

local imgNr = 1
local frameNr = 1
local images = {"resources/sicklogo.bmp","resources/sicklogo_neg.bmp"}

--setup a timer to trigger new images
local tmr = Timer.create()
tmr:setPeriodic(true)
tmr:setExpirationTime(1000)
tmr:register("OnExpired", "newImage")
tmr:start()

--End of Global Scope-----------------------------------------------------------

function mute()
  tmr:stop()
end

function start()
  tmr:start()
end

--Start of Function and Event Scope---------------------------------------------

function newImage()
  if(imgNr == 1) then
    imgNr = 2
  else
    imgNr = 1
  end
  viewer1:addImage(Image.load(images[imgNr]))
  viewer1:present()
  Script.notifyEvent("OnNewSensorData", tostring(DateTime.getTimestamp()), tostring(frameNr))
  frameNr = frameNr+1
end

--End of Function and Event Scope------------------------------------------------