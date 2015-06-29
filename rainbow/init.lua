buttonPin = 3
rgbPin = 4

rgbTimerId = 0
buttonTimerId = 1

modeOff = 0
modeReveal = 1
modeBlink = 2
modes = {modeOff, modeReveal, modeBlink}
mode = modeOff

rgb_black = string.char(0, 0, 0)
rgb_red = string.char(228, 3, 3)
rgb_orange = string.char(255, 140, 0)
rgb_yellow = string.char(255, 237, 0)
rgb_green = string.char(0, 128, 38)
rgb_blue = string.char(0, 77, 255)
rgb_purple = string.char(117, 7, 135)

-- Only 5 LEDs avail on dev board. Yellow and orange LEDs look very similar
-- on the dev board => skip yellow.
rainbow = {rgb_red, rgb_orange, rgb_green, rgb_blue, rgb_purple}

counter = 1
delta = 1
gpio.mode(buttonPin, gpio.OUTPUT, gpio.PULLUP)
ws2812.writergb(rgbPin, rgb_black:rep(5))

print(wifi.sta.getmac())

tmr.stop(rgbTimerId)
tmr.alarm(rgbTimerId, 500, 1, function()
    if mode == modeReveal then
        if counter < 6 then
            rgb = ""
            for i,v in ipairs(rainbow) do
                if i <= counter then
                    rgb = rgb .. v
                else
                    rgb = rgb .. rgb_black
                end
            end
            ws2812.writergb(rgbPin, rgb)
        end

        if counter == 0 or counter == 5 then
            delta = -delta
        end
        counter = counter + delta
    end

    if mode == modeBlink then
        rgb = ""
        if counter % 2 == 0 then
            for i,v in ipairs(rainbow) do
                rgb = rgb .. v
            end
        else
            rgb = rgb_black:rep(5)
        end
        ws2812.writergb(rgbPin, rgb)
        counter = counter + 1
    end

    if mode == modeOff then
        ws2812.writergb(rgbPin, rgb_black:rep(5))
    end
end )

tmr.stop(buttonTimerId)
tmr.alarm(buttonTimerId, 150, 1, function()
    if gpio.read(buttonPin) == 0 then
        counter = 1
        ws2812.writergb(rgbPin, rgb_black:rep(5))
        mode = (mode + 1) % #modes
    end
end )
