## RecordingFile

Introduction to data recording and playback using a file as storage.

### Description

This application can be used to record data into files and playback from recording files.
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
Editing the UI might not work properly in the latest version of SICK AppStudio.
Use SICK AppStudio version <= 2.4.2 to edit the UI.

The 'ImagePlayer' script creates an ImageProvider which reads bitmap images from the 'resources'
folder. This Provider takes images with a period 1000ms, which are provided
asynchronously to the 'handleNewImage' function.
To demo this script the emulator can be used. The image is being displayed in ImageView
on the webpage (localhost 127.0.0.1) and the meta data is logged to the console.
See also sample 'ImageRecorder'.

### How To Run

This sample can be run on any SIM device or the emulator.
Connect a web-browser to the device IP-Address and you will see the web-page of this sample.

### Topics

system, recording, sample, sick-appspace
