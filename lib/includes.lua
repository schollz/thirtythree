-- ships with norns
crow = require("crow")
musicutil = require("musicutil")
tabutil = require("tabutil")

-- supercollider
engine.name = "Thirtythree"

-- classes
include("lib/Sound")  
include("lib/Operator")  

rendererClass=include("lib/renderer")
renderer=rendererClass:new()