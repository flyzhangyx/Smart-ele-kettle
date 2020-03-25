wifi.setmode(wifi.STATION)

wifiinfo = {}

wifiinfo.ssid = "123"

wifiinfo.pwd = "123456788"

cfg={}

cfg.ssid = "123"

cfg.pwd = "123456788"

if file.open("RCN.info") then 
    
    wifiinfo.ssid = file.readline()
    
    wifiinfo.pwd = file.readline()
    
    file.close()
    
    wifi.sta.config(wifiinfo)
else
    
    wifi.sta.config(cfg)
end

wifi.sta.autoconnect(1)

--lllllllllllllllllllllllllllllllllllllll
ifcon = "DISCONNECT"

i = 0;

j    = 0;

flag = 0;

temp = 25110;

time                 = "201901011212"  

cmdtime              = "201801011212"

cmdinfo = "250"

addfromid = "12345678900"--测试账号

cn = 0
--lllllllllllllllllllllllllllllllllllllll
ClientConnectedFlage = 0

TcpConnect = nil

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)

if printip == 0 then

--print("+IP"..T.IP)

end

printip = 1

end)

--************************************
tmr.alarm(1, 1000, 1, function()

if  ClientConnectedFlage == 0 then

Client = net.createConnection(net.TCP, 0)

Client:connect(3566,"47.106.207.241")

Client:on("receive", function(Client, data)
data1 = data : sub(1,3)

uart.write(0,data)
if(data1=="CMD") then 
   data3   = data:sub(4,23)
   cmdtime = string.char(data3:byte(1),data3:byte(2),data3:byte(3),data3:byte(4),data3:byte(6),data3:byte(7),data3:byte(9),data3:byte(10),data3:byte(12),data3:byte(13),data3:byte(15),data3:byte(16))
   cmdinfo = string.char(data3:byte(17),data3:byte(18),data3:byte(19))
    print("\nCMD:"..cmdtime.."|"..cmdinfo.."\n")
    tmr.stop(4)
    gpio.write(RELAY_Pin6,0)
    gpio.write(RELAY_Pin3,0)
    gpio.write(RELAY_Pin2,1)
    gpio.write(RELAY_Pin7,0)
    flag = 0;
    tmr.start(4)
elseif(data1=="TAN")  then
    print("\nTAN\n")
elseif(data1=="TAI")  then
    print("\nTAI\n")
elseif(data1=="SSS")  then 
    print("\nTEST\n")
elseif(data1=="RCN")  then 
    file.open("RCN.info","w+")
    ssid1 = data.sub(4,14)
    pwd1  = data.sub(16,25)
    file.writeline(ssid1)
    file.writeline(pwd1)
    file.flush()
    file.close()
elseif(data1=="ADD")  then 
    print("\nADD\n")
    addfromid = data:sub(4,15)
    gpio.write(RELAY_Pin1,0)
    tmr.start(3);
elseif(data1=="SII")  then 
    cn = 1
    print("Link OK")
--gpio.write(RELAY_Pin4,1)
ifcon = "CONNECTED"
elseif(data1=="Sii")  then 
    print("\nsii\n")
    node.restart()
elseif(data1=="HBI")  then
    data2 = data : sub(12,30)
    time = string.char(data2:byte(13),data2:byte(14),data2:byte(15),data2:byte(16),48,48,data2:byte(1),data2:byte(2),data2:byte(4),data2:byte(5),data2:byte(7),data2:byte(8))
    print("\nHBI:"..time.."\n")
 end

end)

Client:on("connection", function(sck, c)

ClientConnectedFlage = 1
tmr.stop(1)
TcpConnect = Client
TcpConnect:send("ZYXX122712312312312")

tmr.delay(1000000)

    Client:send("12312312312\0")
tmr.delay(1000000)
    Client:send("123456789\0")


Client:on("disconnection", function(sck, c)

ClientConnectedFlage = 0

TcpConnect = nil
--gpio.write(RELAY_Pin4,0)
ifcon = "DISCONNECT"
tmr.start(1)
cn = 0
end)

end)

if  ClientConnectedFlage == 0 then
    --gpio.write(RELAY_Pin4,0)
    ifcon = "DISCONNECT"
    cn    = 0
    print("Link Error\n")

end

end

end)

uart.on("data",0,function(data)

if  TcpConnect ~= nil then

TcpConnect:send(data)

end

end, 0)

--********************************************************
tmr.alarm(2,800,1,function()
j = j+1;
    
    

if  TcpConnect~=nil and cn==1 then

    
    if adc.force_init_mode(adc.INIT_ADC)
then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end

    if(j==1) then
TcpConnect:send("HBI                           ")
end
if(adc.read(0)>400) then
    temp = -153*adc.read(0)+174460;
    if(gpio.read(7)==0 and gpio.read(6)==1) then
        s = "01"
    elseif(gpio.read(7)==1 and gpio.read(6)==1) then
        s = "02"
    else
        s = "00"
    end
    if(j>=5) then
    TcpConnect:send('TAI12345678900+'..temp..''..s..'')
    print("\nSystem :"..temp.."\n")
    j = 0;
end
elseif(adc.read(0)<400) then
    temp = 25110;
    if(j>=5) then
    TcpConnect:send('TAI12345678900+'..temp..'00')
    print("\nSystem :"..temp.."\n")
    j = 0;
end
    
end

end
    ty = temp/1000
    print_OLED(ifcon,'Temp: +'..ty..'')
end)
--***************************************************
tmr.alarm(3,100,1,function()
    i = i+1 ;
    if(i>50) then 
        i = 0;
        gpio.write(RELAY_Pin1,1)
        tmr.stop(3)
    elseif(i<=50) then
        if(gpio.read(RELAY_Pin1)==1) then
            if  TcpConnect ~= nil then
                TcpConnect:send('ADS'..addfromid..'    ')  
                i = 0;
                tmr.stop(3)
            end
        end
            
    end
end)
--**********************************************
tmr.alarm(4,5000,1,function()
print(""..flag.."..")
    if(flag==0) then
        print(""..cmdinfo:byte(3)..".."..cmdinfo.."")
        if(cmdinfo:byte(3)==48) then
            gpio.write(RELAY_Pin6,0)
        else
            print("\n"..cmdtime..".."..time.."/"..cmdinfo.."")
            if(cmdtime : byte(7)==time:byte(7) and cmdtime:byte(8)==time:byte(8) and cmdtime : byte(9)==time:byte(9) and cmdtime:byte(10)==time:byte(10) and cmdtime:byte(11)==time:byte(11)) then
                if(cmdtime:byte(12)-time:byte(12)<=1 and cmdtime:byte(12)-time:byte(12)>=-1)  then         
                    flag = 1;
                    print("TIME RIGHT")
                end
            end
        end
    elseif(flag==1) then
        if (cmdinfo:byte(3)==49) then
            if ((cmdinfo:byte(1)-48)*10000+(cmdinfo:byte(2)-48)*1000-temp>=-500 and (cmdinfo:byte(1)-48)*10000+(cmdinfo:byte(2)-48)*1000-temp<=500) then
                tmr.stop(4) 
                gpio.write(RELAY_Pin6,1)
                gpio.write(RELAY_Pin3,0)
                gpio.write(RELAY_Pin2,1)
                gpio.write(RELAY_Pin7,0)
            elseif((cmdinfo:byte(1)-48)*10000+(cmdinfo:byte(2)-48)*1000-temp>500)  then  
                gpio.write(RELAY_Pin3,0)
                gpio.write(RELAY_Pin2,0)
                gpio.write(RELAY_Pin6,1)
                gpio.write(RELAY_Pin7,0)
            elseif((cmdinfo:byte(1)-48)*10000+(cmdinfo:byte(2)-48)*1000-temp<-500) then
                gpio.write(RELAY_Pin3,1)
                gpio.write(RELAY_Pin2,1)
                gpio.write(RELAY_Pin6,1)
                gpio.write(RELAY_Pin7,0)
            end
        elseif(cmdinfo:byte(3)==50) then
            if ((cmdinfo:byte(1)-48)*10000+(cmdinfo:byte(2)-48)*1000-temp>=-500 and (cmdinfo:byte(1)-48)*10000+(cmdinfo:byte(2)-48)*1000-temp<=500) then
                gpio.write(RELAY_Pin6,1)
                gpio.write(RELAY_Pin3,0)
                gpio.write(RELAY_Pin2,1)
                gpio.write(RELAY_Pin7,1) 
            elseif((cmdinfo:byte(1)-48)*10000+(cmdinfo:byte(2)-48)*1000-temp<-500)  then  
                gpio.write(RELAY_Pin3,1)
                gpio.write(RELAY_Pin2,1)
                gpio.write(RELAY_Pin6,1)
                gpio.write(RELAY_Pin7,0)
            elseif((cmdinfo:byte(1)-48)*10000+(cmdinfo:byte(2)-48)*1000-temp>500) then
                gpio.write(RELAY_Pin3,0)
                gpio.write(RELAY_Pin2,0)
                gpio.write(RELAY_Pin6,1)
                gpio.write(RELAY_Pin7,0)
            end
        end
    end
end)
--**********************************************
    printip = 0

    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(T)

    printip = 0

end)

