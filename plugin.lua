-- NC Camera Preset Control Plugin
-- by Hori Shogo
-- June 2024

-- Information block for the plugin
--[[ #include "info.lua" ]]

function GetColor(props)
  return { 0, 0, 0 }
end

function GetPrettyName(props)
  return "NC Camera Preset Control v" .. PluginInfo.Version
end
--List the pages within the plugin
PageNames = { "Control of Cameras" }

-- Define User configurable Properties of the plugin
function GetProperties()
  local props = {}
  --[[ #include "properties.lua" ]]
  return props
end

-- Defines the Controls used within the plugin
function GetControls(props)
  local ctrls = {}
  --[[ #include "controls.lua" ]]
  return ctrls
end

--Layout of controls and graphics for the plugin UI to display
function GetControlLayout(props)
  local layout = {}
  local graphics = {}
  --[[ #include "layout.lua" ]]
  return layout, graphics
end

--Start event based logic
if Controls then
  --[[ #include "runtime.lua" ]]
end
