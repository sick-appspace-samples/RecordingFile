--[[----------------------------------------------------------------------------

  Application Name: ImagePlayer                                                                                                                        
                                                                                             
  Description:
  Viewing images provided from resources in specific user interface. Meta information 
  is printed to console.
                                                               
  Script creates an ImageProvider which reads bitmap images from the 'resources' 
  folder. This Provider takes images with a period 1000ms, which are provided 
  asynchronously to the handleNewImage function.  
  To demo this script the emulator can be used. The image is being displayed in ImageView
  on the webpage (localhost 127.0.0.1) and the meta data is logged to the console.
  See also sample 'ImageRecorder'.
   
------------------------------------------------------------------------------]]

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

--@mute()
function mute()
  tmr:stop()
end

--@start()
function start()
  tmr:start()
end

--Start of Function and Event Scope---------------------------------------------

--@newImage()
function newImage()
  if(imgNr == 1) then
    imgNr = 2
  else
    imgNr = 1
  end
  viewer1:view(Image.load(images[imgNr]))
  Script.notifyEvent("OnNewSensorData", tostring(DateTime.getTimestamp()), tostring(frameNr))
  frameNr = frameNr+1
end

--End of Function and Event Scope------------------------------------------------