local CurrentPage = PageNames[props["page_index"].Value]
local Colors = {
  Black       = {0,0,0}, --Black
  White       = {255,255,255}, --White
  Red         = {255,0,0}, --Red
  Blue        = {0,0,255}, --Blue
  Lime        = {0,255,0}, --Lime
  Gray        = {105,105,105}, --Light Gray
  HGray       = {153,153,153}, -- Header Gray
  AGray       = {153,153,153,163}, -- Alpha Header Gray
  OffGray     = {124,124,124}, -- Gray
  OnRed       = {229,53,57}, -- Orange Red
  OffRed      = {124,0,0}, -- Off Red
  Bar         = {156,171,175}, --Blue gray
  BtnGray     = {51,51,51}, -- Button Baase BackGround
  Background  = {50,50,50},  -- Background Color
  FaderBlue   = {65,211,248}, -- Fader Blue Color
  LightBlue   = {54,197,246}, -- Light Blue
  OnlineGreen = {34,178,76}, -- Online Color
  White0      = {255,255,255,0},-- White Alpha 1~0.1
  Black0      = {0,0,0,0},-- Black Alpha 1~0.1
  LightGray   = {231,231,231}, -- Light gray
}

local cam_number = props["Number of Cameras"].Value
local pre_number = props["Number of Presets"].Value
local labels, ctrls, btn = {size={192,16}},{size={192,20}},{size={36,16}} --mainsize
local frame = {size={192,64}, size2={192,112}}
local xSpace, ySpace = 15, 16
local camframe = {192,170+ySpace*(pre_number-1)}
local zOerders = {back=-20, bar=-5, zero=0, labels=10, ctrl=20, front=1000}

--Page Select----------------------------------------------------------------------------------------
if CurrentPage == "Control of Cameras" then
-----------------------------------------------------------------------------------------------------
  table.insert(graphics,{--back frame
    Type = "GroupBox",
    Fill = Colors.White,
    StrokeWidth = 1,
    StrokeColor = Colors.Black,
    Position = {3,0},
    Size = {606,151},
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "NC Camera Preset Control",
    Position = {3,3},
    Size = {606,16},
    FontSize = 12,
    Font ="Roboto",
    FontStyle = "Medium",
    HTextAlign = "Center",
  })
  for i=1, 3 do
    table.insert(graphics,{--text frame
      Type = "GroupBox",
      Fill = Colors.White,
      CornerRadius = 0,
      StrokeWidth = 1,
      Position = {3+207*(i-1),30},
      Size = i==3 and frame.size2 or frame.size,
    })
  end

  local texts = {"Hold Time ( 0.5-5 second )","Saved LED Time ( 0.5-5 second )","Export Cameras Positions",
  "Set Home Minutes ( 0.5- 120 minute )","Saved LED","Import Cameras Positions","Memory Text"}
  for i = 1, #texts do
    local colSizes = {3, 210, 417} -- X offset
    local rowSizes = {30, 62, 94} -- Y offset
    local col = i==#texts and 3 or (i - 1) % 3 + 1 -- col calculate
    local row = math.ceil(i / 3) -- row calculate
    local xpos, ypos = colSizes[col], rowSizes[row]
    table.insert(graphics,{
      Type = "Text",
      Text = texts[i],
      Position = {xpos,ypos},
      Size = labels.size,
      FontSize = 9,
      Font ="Roboto",
      HTextAlign = "Center",
    })
  end
  local textCtrls = {
  c_name = {"Hold Time","Saved LED Time","Export","Set Home Minute","Saved LED","Import","Memorytext"},
  c_pretty = {"Hold Time","Saved LED Time","Export Cameras Positions","Set Home Minutes","Saved LED","Import Cameras Positions","Memory Text"},
  c_ctrl = {"Text","Text","Button","Text","Button","Button","Text"},
  c_colors = {Colors.Black,Colors.Black,Colors.White,Colors.Black,Colors.Red,Colors.White,Colors.White},
  c_offcolors = {nil, nil, Colors.Lime, nil, Colors.OffRed, Colors.Blue, nil}
  }
  for i = 1, #textCtrls.c_name do
    local colSizes = {3, 210, 417} -- X offset
    local rowSizes = {46, 78, 110} -- Y offset
    local col = i==#textCtrls.c_name and 3 or (i - 1) % 3 + 1 -- col calculate
    local row = math.ceil(i / 3) -- row calculate
    local xpos, ypos = colSizes[col], rowSizes[row]
    layout[textCtrls.c_name[i]] = {
      PrettyName = textCtrls.c_pretty[i],
      Style = textCtrls.c_ctrl[i],
      ButtonStyle = (textCtrls.c_name[i]=="Export" or textCtrls.c_name[i]=="Import") and "Trigger" or (textCtrls.c_name[i]=="Saved LED") and "Toggle" or nil,
      ButtonVisualStyle = (textCtrls.c_name[i]=="Export" or textCtrls.c_name[i]=="Import") and "Flat" or nil,
      Position = {xpos,ypos},
      Size = i==#textCtrls.c_name and {192,32} or labels.size,
      Color = textCtrls.c_colors[i],
      UnlinkOffColor = (textCtrls.c_name[i]=="Export" or textCtrls.c_name[i]=="Import" or textCtrls.c_name[i]=="Saved LED") and true or nil,
      OffColor = textCtrls.c_offcolors[i],
      CornerRadius = 0,
      Margin = 0,
      StrokeWidth = (textCtrls.c_name[i]=="Export" or textCtrls.c_name[i]=="Import" or textCtrls.c_name[i]=="Saved LED" or textCtrls.c_name[i]=="Memorytext") and 1 or 0,
      FontSize = 9,
      HTextAlign = i==#textCtrls.c_name and "Left" or "Center",
    }
  end
  table.insert(graphics,{
    Type = "Text",
    Text = "Script Access must be enabled.\nExport and import functions are not available.",
    Position = {3,110},
    Size = {192,32},
    CornerRadius = 0,
    Margin = 5,
    StrokeWidth = 0,
    FontSize = 9,
    Font ="Roboto",
    HTextAlign = "Left",
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "To use the camera controls\nNC Cameras Script Access must be enabled.",
    Position = {210,110},
    Size = {192,32},
    CornerRadius = 0,
    Margin = 5,
    StrokeWidth = 0,
    FontSize = 9,
    Font ="Roboto",
    HTextAlign = "Left",
  })
  --local pre_offset = pre_number>4 and ySpace*(pre_number-4) or 0
  local pre_offset = pre_number>1 and ySpace*(pre_number-1) or 0
  local cam_frame = {size={192,114+pre_offset+2}}

  for x=1,cam_number do
    local col = (x - 1) % 3 + 1 -- col calculate
    local row = math.ceil(x / 3) -- row calculate
    local colPos = {3, 210, 417} -- X offset
    local ypos_offset = pre_number > 1 and pre_offset or 0
    local rowPos = 160 + 120*(row - 1)+ypos_offset*(row - 1) -- Y offset
    local xpos, ypos = colPos[col], rowPos
    table.insert(graphics,{--camera frame
      Type = "GroupBox",
      Fill = Colors.White,
      CornerRadius = 0,
      StrokeWidth = 1,
      StrokeColor = Colors.Black,
      Position = {xpos,ypos},
      Size = cam_frame.size,
    })
    table.insert(graphics,{
      Type = "Text",
      Text = "Name of Camera"..x,
      Position = {xpos,ypos},
      Size = labels.size,
      FontSize = 9,
      Font ="Roboto",
      HTextAlign = "Center",
    })
    layout["Cam Name "..x] = {
      PrettyName = "Camera "..x.."~".."Name "..x,
      Style = "ComboBox",
      Position = {xpos,ypos+16},
      Size = ctrls.size,
      Color = Colors.Black,
      TextColor = Colors.White,
      CornerRadius = 2,
      Margin = 0,
      StrokeColor = Colors.Black,
      StrokeWidth = 1,
      FontSize = 11,
    }
    table.insert(graphics,{
      Type = "Text",
      Text = "Set Home Time to Trigger",
      Position = {xpos,ypos+36},
      Size = labels.size,
      FontSize = 9,
      Font ="Roboto",
      HTextAlign = "Center",
    })
    layout["Set Home "..x] = {
      PrettyName = "Camera "..x.."~".."Set Home "..x,
      Style = "Button",
      ButtonStyle = "Toggle",
      Position = {xpos,ypos+52},
      Size = ctrls.size,
      Color = Colors.Red,
      UnlinkOffColor = true,
      OffColor = Colors.Black,
      CornerRadius = 2,
      Margin = 0,
      StrokeWidth = 1,
      Legend = "Stop",
      FontSize = 11,
    }
    table.insert(graphics,{
      Type = "Text",
      Text = "Short Press is Load\nLong Press is Save",
      Position = {xpos,ypos+72},
      Size = {96,26},
      FontSize = 9,
      Font ="Roboto",
      HTextAlign = "Center",
    })
    table.insert(graphics,{
      Type = "Text",
      Text = "Save Positions",
      Position = {xpos+96,ypos+82},
      Size = {96,16},
      FontSize = 9,
      Font ="Roboto",
      HTextAlign = "Center",
    })

    for y=1,pre_number do
      local y_offset = ySpace*(y-1)
      local function CreateKey(key,x,y,pre_number)
        if pre_number==1 then return key..x else return key..x.." "..y end
      end
      layout[CreateKey("Preset Cam LED ",x,y,pre_number)] = {
        PrettyName = "Camera "..x.."~".."Preset Camera LED "..y,
        Style = "LED",
        Position = {xpos+44, ypos+98+y_offset},
        Size = {16,16},
        Margin = 3,
        StrokeWidth = 1,
      }
      layout[CreateKey("SaveLoad Cam ",x,y,pre_number)] = {
        PrettyName = "Camera "..x.."~".."Save Load Button "..y,
        Style = "Button",
        ButtonStyle = "Momentary",
        Position = {xpos+44+16, ypos+98+y_offset},
        Size = btn.size,
        Color = Colors.White,
        UnlinkOffColor = true,
        OffColor = Colors.Black,
        CornerRadius = 2,
        Margin = 2,
        Padding = 0,
        StrokeWidth = 1,
        FontSize = 9,
        TextColor = Colors.Black,
      }
      layout[CreateKey("Preset Cam ",x,y,pre_number)] = {
        PrettyName = "Camera "..x.."~".."Preset Camera Position "..y,
        Style = "Text",
        TextBoxStyle="NoBackground",
        Position = {xpos+44+16+36, ypos+98+y_offset},
        Size = {96,16},
        StrokeWidth = 0,
        FontSize = 9,
      }
      table.insert(graphics,{
        Type = "Text",
        Text = "Preset "..y,
        Position = {xpos, ypos+98+y_offset},
        Size = {44,16},
        FontSize = 9,
        Font ="Roboto",
        HTextAlign = "Right",
      })
    end
  end

end