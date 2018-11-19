### Drone Racing Timer Lua script for OpenTX

This simple Lua script is created for drone pilots who wants to refine their skills in the conditions the most similar to a real race.

The script plays start and finish sounds for a quad race.

https://www.youtube.com/watch?v=hj8fPDgjJTs

### How to use
* Place you drone on a starting grid, put your FPV-goggles on and arm your quad.
* Toggle a switch on your TX.
* Wait a random delay (from 2 to 5 seconds) for a start signal.
* Fly as many laps as you can in 2 minutes.
* 10 seconds before the end of the race you will hear a warning buzzer.
* When the race is finished you will hear another buzzer.

All time intervals and a switch are configurable:

![IMG](https://github.com/alexeystn/droneracing-timer-lua-script/blob/master/images/scr1.png)

![IMG](https://github.com/alexeystn/droneracing-timer-lua-script/blob/master/images/scr2.png)

### How to install
* Download [zip-archive](https://github.com/alexeystn/droneracing-timer-lua-script/archive/master.zip) of this repository.
* Copy the content of /TELEMETRY/ folder to /SCRIPTS/TELEMETRY/ folder on your SD card. It contains 'race.lua' file and 'race' folder with 4 wav-files.
* Open Telemetry page of your model and select the custom script ‘race’ for any of your telemetry screens.
* Long press 'Menu' button on the main screen of your model to switch to the script's screen.

![IMG](https://github.com/alexeystn/droneracing-timer-lua-script/blob/master/images/scr0.png)
 
### Compatibility
This script was successfully tested on Taranis Q X7 with OpenTX 2.2.2. 
It should also work on Taranis X9 and X-Lite.

If you face any issues, feel free to contact me.

https://t.me/AlexeyStn

Your feedback is welcome!

-------

Inspired by GoRace script from [RCdiy.ca](http://rcdiy.ca/quad-race-start-sequence-gorace/)
