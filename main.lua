

local F   =  ' x*sin(y/2) '
local G   =  ' y*cos(x/2) '

local f,g

--[[
Let f,g be scalar functions such that:

( a, b ) = P(x,y)

( a, b )  =  (f(x,y) , g(x,y))

such that P(x,y) gives a vector field of vectors (a,b)
across the (x,y) plane


Now using finite differences for automatic differentiation

]]
setmetatable(_G,{__index=math})



local function makeFn(st)
    return loadstring([[
        u = function(x,y)
            return ]] .. st .. [[
        end
    ]])
end


local function df_dx(x,y) return (f(x+0.001,y) - f(x-0.001,y))/0.002 end
local function df_dy(x,y) return (f(x,y+0.001) - f(x,y-0.001))/0.002 end

local function dg_dx(x,y) return (g(x+0.001,y) - g(x-0.001,y))/0.002  end
local function dg_dy(x,y) return (g(x,y+0.001) - g(x,y-0.001))/0.002 end



local function divergence(x,y)
    return df_dx(x,y) + dg_dy(x,y)
end

local function curl(x,y)
    return dg_dx(x,y) - df_dy(x,y)
end


local function P(x,y)
    return f(x,y), g(x,y)
end

local function magnitude(x, y)
    local x,y = P(x,y)
    return (x^2 + y^2)^0.5
end






local x = -4
local y = -4

local w = 8
local h = 8

local SAMPLES = 80; -- there will be SAMPLES ^ 2 samples made.
            -- DONT MAKE THIS NUMBER LARGE!!!

local CAP = 750

love.window.setMode(CAP,CAP)


local CLAMP_VAL = 100

local max = math.max
local min = math.min

local function clamp(n)
    return min(max(-CLAMP_VAL, n), CLAMP_VAL)
end



local avg_mag
local avg_curl
local avg_div

local var_mag
local var_curl
local var_div


local n



local function load()

    local c = 0 -- average sums
    local d = 0
    local m = 0

    local ct = 0

    for X=x, x+w, w/SAMPLES do
        for Y=y, y+h, h/SAMPLES do
            c = c + clamp(curl(X, Y))
            d = d + clamp(divergence(X, Y))
            m = m + clamp(magnitude(X, Y))
            ct = ct + 1
        end
    end

    avg_mag = m / ct
    avg_curl = c / ct
    avg_div = d / ct


    local vc = 0 -- variances * (n-1)
    local vd = 0
    local vm = 0

    for X=x, x+w, w/SAMPLES do
        for Y=y, y+h, h/SAMPLES do
            vc = vc + (clamp(curl(X, Y)) - avg_curl)^2
            vd = vd + (clamp(divergence(X, Y)) - avg_div)^2
            vm = vm + (clamp(magnitude(X, Y)) - avg_mag)^2
        end
    end

    var_curl = (vc / (ct-1))^0.5
    var_mag  = (vm / (ct-1))^0.5 -- originally ^0.75 (idk y, ^0.75 looked cooler)
    var_div  = (vd / (ct-1))^0.5
    n=ct
end


--[[
    git branch -m main master
git fetch origin
git branch -u origin/master master
git remote set-head origin -a
]]


local function changeFunction( F, G )
    F=F:gsub(" ",""):gsub("f(x,y)",""):gsub("=","")
    G=G:gsub(" ",""):gsub("f(x,y)",""):gsub("=","")    

    makeFn(F)()
    f=u
    makeFn(G)()
    g=u

    -- create custom shader string from template
    local autoeffect = io.open("template.glsl","r")
    assert(autoeffect,"eh?")
    local autostr = autoeffect:read("*all")
    autostr=autostr:gsub("%@F", F):gsub("%@G", G)
    autoeffect:close()

    -- push custom shader code into temp GLSL file
    local tmp = io.open("_TEMP.glsl", "w+")
    tmp:write(autostr)
    tmp:close()
    
    if sh then sh:release() end
    sh = love.graphics.newShader("_TEMP.glsl")
    love.graphics.setShader(sh)

    load()
end



changeFunction(F,G)


local function toPlotCoords(X,Y)
    X=CAP-X
    Y=CAP-Y
    return (w*X)/CAP + x, (h*Y)/CAP + y
end



load()

local theta = 0
local mega  = 0



function love.draw()
    love.graphics.setShader(sh)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill",-200,-200,CAP*2,CAP*2)

    love.graphics.setColor(0,0,0,1)
    for x=1,CAP,CAP/50 do
        for y=1,CAP,CAP/50 do
            local px, py = toPlotCoords(x, y)
            love.graphics.line(x,y, x + f(px,py), y + g(px,py))
        end
    end
    love.graphics.setShader(  )
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill",8,10,220,50)
    love.graphics.setColor(0,0,0)
    love.graphics.print(("F(x,y) = (x)*sin(y/2 + %f)"):format(theta),10,26)
    love.graphics.print(("G(x,y) = (y)*cos(x/2 + %f)"):format(mega), 10,10)
    love.graphics.print("(x,y) --> ( F(x,y), G(x,y) )",10,42)
end


function love.update(dt)
    local  A =  ("(x)*sin(y/2 + %f)"):format(theta)
    local  B =  ("(y)*cos(x/2 + %f)"):format(mega)
    changeFunction(
        A,
        B
    )
    local change = 100*((2*math.pi)/(9.5*60))*dt
    theta = (theta + change) % (2*math.pi)
    mega = (mega + change) % (2*math.pi)

    sh:send("dscale", max(1,var_div))
    sh:send("doffset", avg_div)

    sh:send("cscale", max(1,var_curl))
    sh:send("coffset", avg_curl)

    sh:send("mscale", max(1,var_mag))
    sh:send("moffset", avg_mag)

    sh:send("sx", x)
    sh:send("sy", y)
    sh:send("w", w)
    sh:send("h", h)

    sh:send("CAP",CAP)
end
