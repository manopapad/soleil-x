import 'regent'

-------------------------------------------------------------------------------
-- Local types
-------------------------------------------------------------------------------

struct Foo {
  x : double,
  y : double,
}

-------------------------------------------------------------------------------
-- Module parameters
-------------------------------------------------------------------------------

return function(particlesRegion, particlesType)

-------------------------------------------------------------------------------
-- Compile-time computation
-------------------------------------------------------------------------------

local acos = regentlib.acos(double)
local pow = regentlib.pow(double)
local pi = rexpr 2.0 * acos(0.0) end

local config
local i = 1
while i <= #arg do
  if arg[i] == '-i' and i < #arg then
    config = loadfile(arg[i+1])()
    break
  end
  i = i + 1
end
if not config then
  print("config file required (-i <file> option)")
  os.exit(1)
end

local absorptivity = config.absorptivity
local radiationIntensity = config.radiationIntensity
local heatCapacity = config.heatCapacity

-------------------------------------------------------------------------------
-- Local tasks
-------------------------------------------------------------------------------

local __demand(__parallel) task AddRadiation
  (particles : particlesType, r : region(ispace(int3d),Foo))
where
  reads(particles.density), reads(particles.diameter),
  reads writes(particles.temperature_t)
do
  for p in particles do
    var crossSectionArea = pi * pow(p.diameter, 2.0) / 4.0
    var volume = pi * pow(p.diameter, 3.0) / 6.0
    var mass = volume * p.density
    var absorbedRadiationIntensity =
      absorptivity * radiationIntensity * crossSectionArea
    p.temperature_t += absorbedRadiationIntensity / (mass * heatCapacity)
  end
end

-------------------------------------------------------------------------------
-- Exported quotes
-------------------------------------------------------------------------------

local r = regentlib.newsymbol(nil, 'r')

local exports = {}

exports.Init = rquote
  var [r] = region(ispace(int3d,{2,2,2}),Foo)
end

exports.AddRadiation = rquote
  AddRadiation(particlesRegion, r)
end

-------------------------------------------------------------------------------
-- Module exports
-------------------------------------------------------------------------------

return exports
end