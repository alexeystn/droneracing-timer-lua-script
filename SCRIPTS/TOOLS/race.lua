local toolName = "TNS|Race timer|TNE"

local isRaceModeActive = false
local isRaceInitialized = false
local isRaceStarted = false

local currentSwitchState = false
local previousSwitchState = false
local isEnterKeyPressed = false

local displayedTime = 0
local startTime = 0
local warningTime = 0
local finishTime = 0
local afterTime = 0
local blinkCounter = 0

local startSoundPlayed = false
local warningSoundPlayed = false
local finishSoundPlayed = false

local switches = {}
local fields = {}
local selectedField = 1
local isFieldActive = false
local w = 0  -- large screen flag

local scriptPath = "/SCRIPTS/TOOLS/RACE/"
local enterString = "ENT"

-- default configuration
local config = {time = 120, warning = 10, mindelay = 2, maxdelay = 5, switch = 1}


local function playSound(soundName)
  local playWavFiles = true
  if playWavFiles then 
    playFile(scriptPath..soundName..".wav")
  else
    if soundName == "ready" then 
      playTone(3200, 100, 0)
    elseif soundName == "start" then 
      playTone(1600, 500, 0)
    elseif soundName == "warning" then
      playTone(1200, 500, 0)
    elseif soundName == "finish" then
      playTone(2400, 500, 0)
    end
  end
end


local function loadConfig()
  local f = io.open(scriptPath.."settings.dat", "r")
  if f == nil then
    return 0
  end
  config.time     = tonumber(io.read(f, 4))
  config.warning  = tonumber(io.read(f, 4))
  config.mindelay = tonumber(io.read(f, 4))
  config.maxdelay = tonumber(io.read(f, 4))
  config.switch   = tonumber(io.read(f, 4))
  io.close(f)
end


local function saveConfig()
  local f = io.open(scriptPath.."settings.dat", "w")
  io.write(f, string.format("%4d", config.time))
  io.write(f, string.format("%4d", config.warning))
  io.write(f, string.format("%4d", config.mindelay))
  io.write(f, string.format("%4d", config.maxdelay))
  io.write(f, string.format("%4d", config.switch))
  io.close(f)
end


local function getSwitchState()
  local switchName = switches[config.switch]
  if switchName == enterString then
    return isEnterKeyPressed
  end
  local switchId = getFieldInfo(string.lower(switchName)).id
  if getValue(switchId) > 100 then
    return true
  else
    return false
  end
end


local function getSwitchString(switchName)
  if switchName == enterString then
    return enterString
  else
    return switchName.."\193"
  end
end


local function init_func()
  
  for i = 1, 10 do
    local switchName = 's'..string.char(i + 96)
    if getFieldInfo(switchName) then
      print(switchName.." - Yes")
      switches[#switches+1] = string.upper(switchName)
    else
      print(switchName.." - No")
    end
  end
  switches[#switches+1] = enterString
  
  if LCD_H > 96 then
    w = 1
  end  
  
  config.switch = 1
  loadConfig()
   
  fields[1] = {label = "Time", min = 10, max = 300, step = 5, value = config.time, typ = "tim"}
  fields[2] = {label = "Warning", min = 0, max = 60, step = 1, value = config.warning, typ = "tim"}
  fields[3] = {label = "Min delay", min = 1, max = 30, step = 1, value = config.mindelay, typ = "tim"}
  fields[4] = {label = "Max delay", min = 1, max = 30, step = 1, value = config.maxdelay, typ = "tim"}
  fields[5] = {label = "Switch", min = 1, max = #switches, step = 1, value = config.switch, typ = "sw"}
  fields[6] = {label = "", min = "", max = "", step = "", value = "[Start]", typ = "btn"}
  selectedField = #fields
  
end


local function run_func(event)
-- is called periodically
  
  if isRaceModeActive then
    
    if not isRaceInitialized then
      previousSwitchState = true
      isRaceStarted = false
      afterTime = 0
      isRaceInitialized = true
    end
    
    local currentTime = getTime()
    
    currentSwitchState = getSwitchState()
    if (currentSwitchState and not previousSwitchState) and not isRaceStarted then
        playSound("ready")
        startTime = currentTime + math.random(config.mindelay * 100, config.maxdelay * 100)
        finishTime = startTime + config.time * 100
        warningTime = finishTime - config.warning * 100
        afterTime = finishTime + 2 * 100 
        isRaceStarted = true
        startSoundPlayed = false
        warningSoundPlayed = false
        finishSoundPlayed = false  
    end
    previousSwitchState = currentSwitchState

    if isRaceStarted then 
      displayedTime = (finishTime - currentTime) / 100 + 1
      if (displayedTime >= config.time) then
        displayedTime = config.time
      end
    else
      if currentTime <= afterTime then
        displayedTime = 0
      else
        displayedTime = config.time
      end
    end
    
    if isRaceStarted then      
      if not startSoundPlayed then
        if currentTime >= startTime then
          playSound("start")
          startSoundPlayed = true
        end
      end
      if not warningSoundPlayed then 
        if config.warning > 0 and currentTime >= warningTime then
          playSound("warning")
          warningSoundPlayed = true
        end
      end     
      if not finishSoundPlayed then 
        if currentTime >= finishTime then
          playSound("finish")
          finishSoundPlayed = true
          isRaceStarted = false
        end
      end         
    end
    
    lcd.clear()
    lcd.drawTimer(LCD_W/2 - 51 - 30*w, 8 + 12*w, displayedTime, XXLSIZE)
    
    if isRaceStarted then
      if not startSoundPlayed then
        lcd.drawText(LCD_W/2 - 19 - 10*w, 60*w + 50, "Ready", MIDSIZE)
      else
        lcd.drawText(LCD_W/2 - 9 - 7*w, 60*w + 50, "GO!", MIDSIZE)
      end
    else
      if getTime() > afterTime then
        lcd.drawText(LCD_W/2 - 51 - 24*w, 60*w + 52, "Toggle "..getSwitchString(switches[config.switch]).." to start")
      end
    end

    if event == EVT_EXIT_BREAK then
      isRaceModeActive = false
    end
    
    if event == EVT_ENTER_BREAK then
      isEnterKeyPressed = true
    else
      isEnterKeyPressed = false
    end

  else

    if event == EVT_ENTER_BREAK then
      isFieldActive = not isFieldActive
      if isFieldActive then
        blinkCounter = 0
      end
    end
    
    if event == EVT_EXIT_BREAK then
      isFieldActive = false
    end    
    
    if isFieldActive and fields[selectedField].typ == "btn" then
      saveConfig()
      isFieldActive = false
      isRaceInitialized = false
      isRaceModeActive = true
    end
    
    if isFieldActive then
      if (event == EVT_ROT_RIGHT) or (event == EVT_PLUS_BREAK) or 
      (event == EVT_UP_BREAK) or (event == EVT_PLUS_REPT) or (event == EVT_UP_REPT) then
        if fields[selectedField].value < fields[selectedField].max then
          fields[selectedField].value = fields[selectedField].value + fields[selectedField].step
        end
      elseif (event == EVT_ROT_LEFT) or (event == EVT_MINUS_BREAK) or 
      (event == EVT_DOWN_BREAK) or (event == EVT_MINUS_REPT) or (event == EVT_DOWN_REPT) then
        if fields[selectedField].value > fields[selectedField].min then
          fields[selectedField].value = fields[selectedField].value - fields[selectedField].step
        end     
      end   
      if selectedField == 3 and fields[3].value > fields[4].value then
        fields[4].value = fields[3].value
      end
      if selectedField == 4 and fields[4].value < fields[3].value then
        fields[3].value = fields[4].value
      end
    else
      if event == EVT_ROT_RIGHT or event == EVT_MINUS_BREAK or event == EVT_DOWN_BREAK  then
        if selectedField < #fields then
          selectedField = selectedField + 1
        end
      elseif event == EVT_ROT_LEFT or event == EVT_PLUS_BREAK or event == EVT_UP_BREAK  then
        if selectedField > 1 then
          selectedField = selectedField - 1
        end
      end
    end
    
    lcd.clear()
    local flag = 0
    
    for i = 1, #fields do
      lcd.drawText(LCD_W/2 - 44 - 48*w, (8 + 12*w) * i - 2, fields[i].label)
      if i == selectedField and not (isFieldActive and blinkCounter < 7) then
        flag = INVERS
      else
        flag = 0
      end
      
      if fields[i].typ == "tim" then
        lcd.drawTimer(LCD_W/2 + 20 + 22*w, (8 + 12*w) * i - 2, fields[i].value, flag)
      elseif fields[i].typ == "sw" then
        lcd.drawText(LCD_W/2 + 20 + 22*w, (8 + 12*w) * i - 2, getSwitchString(switches[fields[i].value]), flag)
      elseif fields[i].typ == "btn" then
        lcd.drawText(LCD_W/2 - 18 - 6*w, (8 + 12*w) * i + 3, fields[i].value, flag)
      end 
      
    end

    config.time      = fields[1].value
    config.warning   = fields[2].value
    config.mindelay  = fields[3].value
    config.maxdelay  = fields[4].value
    config.switch    = fields[5].value
    
  end
  
  blinkCounter = blinkCounter + 1
  if blinkCounter > 14 then
    blinkCounter = 0
  end

	return 0
  
end

return { init=init_func, run=run_func }
