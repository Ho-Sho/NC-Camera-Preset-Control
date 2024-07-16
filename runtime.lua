json = require 'rapidjson'
-- Table to store camera names and Position
local cam_tbl = {}
local camPos = {}
local Cameras, CamerasHome = {}, {}
local PropPresetNum = Properties["Number of Presets"].Value --#Controls["Preset Cam 1"]
local repeatime = 0.2
print('Presets Equal Position LED : ' .. Properties['Presets Equal Position LED'].Value)
----------------------------------------------------------------------------------------------
-- Create func return table if not table to check if Controls type is table
function CheckTypeTable(control) return type(control) == "table" and control or {control} end
Controls["Cam Name"] = CheckTypeTable(Controls["Cam Name"])
for i=1, PropPresetNum do
  Controls["Preset Cam "..i] = CheckTypeTable(Controls["Preset Cam "..i])
  Controls["Preset Cam LED "..i] = CheckTypeTable(Controls["Preset Cam LED "..i])
end
local PropCamNum = Properties["Number of Cameras"].Value --#Controls["Cam Name"]
----------------------------------------------------------------------------------------------
-- Iterate through Components to find cameras of type 'onvif_camera_operative'
for _, comps in pairs(Component.GetComponents()) do
  if comps.Type == "onvif_camera_operative" then table.insert(cam_tbl, comps.Name) end
end
table.insert(cam_tbl, "none")
-- Create PresetLED State function
function PresetLED(cam_num, preset_num)
  for preset_num, ctl in ipairs(Controls['Preset Cam LED '..cam_num]) do
    if Cameras[cam_num] and Controls['Preset Cam '..cam_num][preset_num].String ~= "" then
      --ctl.Boolean = Cameras[cam_num].String == Controls['Preset Cam '..cam_num][preset_num].String
      local camerasPos_Vals = {}
      local presetPos_Vals = {}
      for value in Cameras[cam_num].String:gmatch("[-%d%.]+") do table.insert(camerasPos_Vals, tonumber(value)) end
      for value in Controls['Preset Cam '..cam_num][preset_num].String:gmatch("[-%d%.]+") do table.insert(presetPos_Vals, tonumber(value)) end
      local isEqual = true
      if #camerasPos_Vals == #presetPos_Vals then
        for i = 1, #camerasPos_Vals do
          if string.format('%.4f', camerasPos_Vals[i]) ~= string.format('%.4f', presetPos_Vals[i]) then isEqual = false end
        end
      else
        isEqual = false
      end
      ctl.Boolean = isEqual
    end
  end
end
-- Create Cam Name.Choices cam_tbl from ComponetName
for i=1, PropCamNum do Controls['Cam Name '..i].Choices = cam_tbl end
-- Create Cam Name Eventhandlers
for cam_num=1, PropCamNum do
  Controls['Cam Name '..cam_num].EventHandler = function()
    if Controls['Cam Name '..cam_num].String == "none" then return end
    if Controls['Cam Name '..cam_num].String ~= "" and Controls['Cam Name '..cam_num].String ~= "none" then
      Cameras[cam_num], CamerasHome[cam_num] = Component.New(Controls['Cam Name '..cam_num].String)["ptz.preset"], Component.New(Controls['Cam Name '..cam_num].String)["preset.home.load"]
      Cameras[cam_num].EventHandler = function()
        --print('Controls["Cam Name '..cam_num..'"]', Controls['Cam Name '..cam_num].String, "Coordinate: ".. Cameras[cam_num].String)
        camPos[cam_num] = Cameras[cam_num].String
        if Properties['Presets Equal Position LED'].Value == 'Yes' then PresetLED(cam_num, preset_num) end
      end
      Cameras[cam_num].EventHandler()--first initileze
    end
  end
  Controls['Cam Name '..cam_num].EventHandler()--first initileze
end

-- Create Press Hold Load or Save EventHandlers
local hold = {}
local count_downs = {}
for cam_num=1, PropCamNum do
  hold[cam_num] = {}
  count_downs[cam_num] = 0
  for preset_num=1, PropPresetNum do
    hold[cam_num][preset_num] = 0
    Controls["SaveLoad Cam "..cam_num][preset_num].EventHandler = function(ctl)
      count_downs[cam_num] = Controls['Set Home Minute'].Value*60
      if Controls["SaveLoad Cam "..cam_num][preset_num].Boolean then
        local function Save()
          hold[cam_num][preset_num] = hold[cam_num][preset_num] + 1
          --print("hold["..cam_num.."]["..preset_num.."]:" .. hold[cam_num][preset_num])
          if hold[cam_num][preset_num] >= Controls["Hold Time"].Value / repeatime then
            if camPos[cam_num] then
              Controls["Preset Cam "..cam_num][preset_num].String = camPos[cam_num]
              print("Long Press ".. "Saved: ".. "Cam Name: "..Controls["Cam Name "..cam_num].String.." Coordinate: "..camPos[cam_num])
            end
            Controls["Saved LED"].Boolean = true
            Timer.CallAfter(function() Controls["Saved LED"].Boolean = false end, Controls["Saved LED Time"].Value)
            hold[cam_num][preset_num] = 0
          else
            if Controls["SaveLoad Cam "..cam_num][preset_num].Boolean then
              Timer.CallAfter(Save, repeatime) --Repeat function
            else
              hold[cam_num][preset_num] = 0
              if Cameras[cam_num] then
                Cameras[cam_num].String = Controls["Preset Cam "..cam_num][preset_num].String
                print("Short Press " .. "Load: ".. "Cam Name: "..Controls["Cam Name "..cam_num].String.." Coordinate: "..camPos[cam_num])
              end
            end
          end
          PresetLED(cam_num, preset_num)
        end
        Timer.CallAfter(Save, repeatime) --Repeat function
      else
        hold[cam_num][preset_num] = 0
      end
      count_downs[cam_num] = Controls['Set Home Minute'].Value*60
    end
  end
end
-- Create round onedecimal
function OneDecimal(ctl) ctl.Value = tonumber(string.format("%.1f", ctl.Value)) end
-- Create Time Eventhandlers
Controls["Hold Time"].EventHandler = OneDecimal(Controls["Hold Time"])
Controls["Saved LED Time"].EventHandler = OneDecimal(Controls["Saved LED Time"])
-- Set home after settime function
function SetHome(cam_num)
  Controls['Set Home '..cam_num].EventHandler = function()
    count_downs[cam_num] = Controls['Set Home Minute'].Value*60--convert second
    if Controls['Set Home '..cam_num].Boolean then
      local function CountDown()
        count_downs[cam_num] = count_downs[cam_num] - 1
        local minutes, seconds = math.floor(count_downs[cam_num] / 60), count_downs[cam_num] % 60
        local remain = string.format("%d min %d sec", minutes, seconds)
        Controls['Set Home '..cam_num].Legend = remain
        if count_downs[cam_num] <= 0 then
          if CamerasHome[cam_num] then CamerasHome[cam_num]:Trigger()
          Timer.CallAfter(function() PresetLED(cam_num, preset_num) end, 1.5)
          end
          Controls['Set Home '..cam_num].Legend = "Executed"
          count_downs[cam_num] = Controls['Set Home Minute'].Value*60
          Timer.CallAfter(CountDown, 1)
        else
          if Controls['Set Home '..cam_num].Boolean then
            Timer.CallAfter(CountDown, 1)
          else
            Controls['Set Home '..cam_num].Legend = "Stop"
            count_downs[cam_num] = Controls['Set Home Minute'].Value*60
          end
        end
      end
      local init = string.format("%d min %d sec", math.floor(count_downs[cam_num] / 60), count_downs[cam_num] % 60)
      Controls['Set Home '..cam_num].Legend = init
      Timer.CallAfter(CountDown, 1)
    else
      Controls['Set Home '..cam_num].Legend = "Stop"
      count_downs[cam_num] = Controls['Set Home Minute'].Value*60
    end
  end
  Controls['Set Home '..cam_num].EventHandler()
end

function OnePointfive(ctl) ctl.Value = tonumber(string.format("%.0f", ctl.Value * 2)) / 2 end
Controls["Set Home Minute"].EventHandler = function(ctl)
  OnePointfive(ctl)
  for cam_num=1, PropCamNum do count_downs[cam_num] = Controls['Set Home Minute'].Value*60 end
end

-- Search my code name function
function MyCodeName()
  local id = Controls.MyID
  if id.String == "" or nil then id.String = math.random() end
  for _, components in pairs(Component.GetComponents()) do
    for _, controls in pairs (Component.GetControls(components.Name)) do
      if controls.Name == "MyID" and controls.String == id.String then
        return components.Name
      end
    end
  end
end
-- Export Import from component
this = {
  Name = '',
  init = function() this.Name = Component.New(MyCodeName()) end,
  --export position
  export = function()
  local thisCtrls = Component.GetControls(this.Name)
  local ctltbl = {}

  for _, ctrl in pairs(thisCtrls) do
    if ctrl.Type == "Text" and ctrl.Name:find("Preset Cam") then
      table.insert(ctltbl, { Name = ctrl.Name, String = ctrl.String })
    end
  end
    Controls.Memorytext.String = json.encode(ctltbl)--, { pretty = true } Crypto.Base64Encode
    print(json.encode(ctltbl, { pretty = true }))
  end,
  --import position
  import = function()
    local memory = json.decode(Controls.Memorytext.String) -- Crypto.Base64Decode
    print(json.encode(Controls.Memorytext.String))
    if memory then
      for _, str in pairs(memory) do
        if str.Name and this.Name[str.Name] then
          this.Name[str.Name].String = str.String
        end
      end
    end
  end,
}

Controls.Export.EventHandler = this.export
Controls.Import.EventHandler = this.import
if MyCodeName()~= nil then this.init() end
--Initilize----------------------------------------------------------------------------------
for cam_num=1, PropCamNum do PresetLED(cam_num, preset_num) end
for cam_num=1, PropCamNum do SetHome(cam_num) end
