table.insert(props, {
  Name = "Number of Cameras",
  Type = "integer",
  Min = 1,
  Max = 21,
  Value = 3,
})
table.insert(props, {
  Name = "Number of Presets",
  Type = "integer",
  Min = 2,
  Max = 30,
  Value = 4,
})
table.insert(props, {
  Name = "Presets Equal Position LED",
  Type = "enum",
  Choices = {"Yes","No"},
  Value = "Yes",
})
