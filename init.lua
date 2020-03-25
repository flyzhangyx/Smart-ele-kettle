RELAY_Pin1 = 4--LED
gpio.mode(RELAY_Pin1, gpio.OUTPUT)
gpio.write(RELAY_Pin1,1)
RELAY_Pin2 = 0--HEAT
gpio.mode(RELAY_Pin2, gpio.OUTPUT)
gpio.write(RELAY_Pin2,1)
RELAY_Pin3 = 1--COOL
gpio.mode(RELAY_Pin3, gpio.OUTPUT)
gpio.write(RELAY_Pin3,0)
--RELAY_Pin4 = 2--CONNECT
--gpio.mode(RELAY_Pin4, gpio.OUTPUT)
--gpio.write(RELAY_Pin4,0)
RELAY_Pin5 = 5--INT
gpio.mode(RELAY_Pin5, gpio.INT, gpio.PULLUP)
gpio.write(RELAY_Pin5,0)
RELAY_Pin6 = 6--WORK
gpio.mode(RELAY_Pin6, gpio.OUTPUT)
gpio.write(RELAY_Pin6,0)
RELAY_Pin7 = 7--WARM
gpio.mode(RELAY_Pin7, gpio.OUTPUT)
gpio.write(RELAY_Pin7,0)
function ledTrg()
   gpio.write(RELAY_Pin1,1)
end


--****************
function init_OLED()
    i2c.setup(0, 2, 3, i2c.SLOW)
    disp = u8g.ssd1306_128x64_i2c(0x3C)
    disp:setFont(u8g.font_6x10)
    disp : setFontRefHeightExtendedText()
    disp:setDefaultForegroundColor()
    disp:setFontPosTop()
end
function print_OLED(str1,str2)
   disp:firstPage()
   repeat
   disp:drawFrame(0, 0,128,16)
   disp:setFont(u8g.font_6x10)
   disp:drawStr(40, 5, str1)
   disp:drawStr(25, 30,str2)
   disp:drawStr(85, 45, "by:ZLD")
   disp:drawFrame(0, 16,128,45)
   until disp:nextPage() == false
end



gpio.trig(RELAY_Pin5, "high", ledTrg)

init_OLED()


tmr.alarm(0,4000,0,function()
    dofile("main.lua")
end)
