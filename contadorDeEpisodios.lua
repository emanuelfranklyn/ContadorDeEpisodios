component = require('component')
fs = require('filesystem')
event = require('event')
serialization = require('serialization')
term = require('term')
gpu = component.gpu

screens = component.list("screen")
screen1 = component.proxy(screens())
screen2 = component.proxy(screens())

EpisodioFilePath = "./Episodios"
EpisodioFilePathd = "home/Episodios"

Episodio = 1
NumberScreen = ''

function WriteEpisode()
    EpisodeWritter = io.open(EpisodioFilePath, "w")
    EpisodeRaw = { 
        Episode=Episodio,
        NumberScreem=NumberScreen
    }
    EpisodeWritter:write(serialization.serialize(EpisodeRaw))
    EpisodeWritter:close()
end

function ReadEpisode()
    EpisodeReader = io.open(EpisodioFilePath, "r")
    RawEpisode = EpisodeReader:read()
    EpisodeReader:close()
    RawEpisode = serialization.unserialize(RawEpisode)
    Episodio = RawEpisode["Episode"]
    NumberScreen = RawEpisode['NumberScreem']
end

function configure()
    function drawner()
        gpu.setBackground(0x0000FF)
        w, h = gpu.getResolution()
        gpu.fill(1, 1, w, h, ' ')
        text = 'Click-me to set Number Display'
        gpu.setForeground(0xFFFFFF)
        gpu.set((w/2)-(text:len()/2), h/2, text)
    end
    gpu.bind(screen1.address, true)
    os.sleep(0.5)
    term.setCursorBlink(false)
    drawner()
    os.sleep(0.5)
    gpu.bind(screen2.address, true)
    os.sleep(0.5)
    term.setCursorBlink(false)
    drawner()
    NumberScreen = 'Waiting...'
    os.sleep(1)
end

function configureP2(monitorAddress, x, y, button)
    NumberScreen = monitorAddress
    WriteEpisode()
    DrawnUi()
end

function DrawnUi()
    --[Drawn Episode number]--
    gpu.bind(NumberScreen, true)
    os.sleep(0.5)
    gpu.setForeground(0xFFFFFF)
    gpu.setBackground(0x000000)
    gpu.setResolution(string.format(Episodio):len(), 1)
    gpu.set(1,1,string.format(Episodio))
    if (screen1.address == NumberScreen) then
        gpu.bind(screen2.address, true)
    else 
        gpu.bind(screen1.address, true)
    end
    --[DrawnControls]--
    gpu.setResolution(50,7)
    w, h = gpu.getResolution()
    gpu.setForeground(0xFFFFFF)
    gpu.setBackground(0x000000)
    gpu.fill(1,1,w,h," ")
    gpu.fill(1,1,w,1,"=")
    gpu.fill(1,h,w,1,"=")
    gpu.fill(1,1,1,h,"|")
    gpu.fill(w,1,1,h,"|")
    gpu.fill(1,1,1,1,"#")
    gpu.fill(w,1,1,1,"#")
    gpu.fill(1,h,1,1,"#")
    gpu.fill(w,h,1,1,"#")
    gpu.fill(w/3,2,1,h-2,"|")
    gpu.fill((w/3)*2,2,1,h-2,"|")
    gpu.fill((w/3),1,1,1,"#")
    gpu.fill((w/3),h,1,1,"#")
    gpu.fill((w/3)*2,1,1,1,"#")
    gpu.fill((w/3)*2,h,1,1,"#")
    textb1 = 'Episodio anterior'
    textb2 = 'Episodio manual'
    textb3 = 'proximo episodio'
    gpu.set(((w/3)/2)-(textb1:len()/2), (h/2)+1, textb1)
    gpu.set(((((w/3)/2)+(w/3))-(textb2:len()/2)), (h/2)+1, textb2)
    gpu.set(((((w/3)/2)+(w/3)+(w/3))-(textb2:len()/2)), (h/2)+1, textb3)
end

function clickParser(_, monitorAddress, x, y, button)
    if (NumberScreen == '') then
        return configure()
    end
    if (NumberScreen == 'Waiting...') then
        return configureP2(monitorAddress, x, y, button)
    end
        --[check what monitor have been clicked]
        if (monitorAddress ~= NumberScreen) then
            if (screen1.address == NumberScreen) then
                gpu.bind(screen2.address, true)
            else 
                gpu.bind(screen1.address, true)
            end
            os.sleep(0.5)
            gpu.setResolution(50,7)
            --[Check where he clicks]-- (Y doesn't care)
            w, h = gpu.getResolution()
            if (x < (w/3)) then
                Episodio = Episodio - 1
                WriteEpisode()
                DrawnUi()
            elseif (x > (w/3) and x < (w/3)*2) then
                gpu.fill((w/3)+1,(h/2)+1,(w/3)-1,1," ")
                term.setCursor((w/3)+1,(h/2)+1)
                local tempEpiRaw = io.read()
                local tempEpi = tonumber(tempEpiRaw)
                if (tempEpi ~= nil) then
                    Episodio = tempEpi
                    WriteEpisode()
                    DrawnUi()
                else
                    local txt = "Not a number"
                    gpu.set(((((w/3)/2)+(w/3))-(txt:len()/2)),(h/2)+1,txt)
                    os.sleep(1)
                    DrawnUi()
                end
            else
                Episodio = Episodio + 1
                WriteEpisode()
                DrawnUi()
            end
        end
end

term.setCursorBlink(false)
print('Click on screen to start :P')
if (fs.exists(EpisodioFilePathd)) then
    ReadEpisode()
else
    WriteEpisode()
end
while true do
    local id, monitorAddress, x, y, button = event.pullMultiple('touch', 'interrupted')
    if (id == 'interrupted') then
        break
    elseif (id == 'touch') then
        clickParser(id, monitorAddress, x, y, button)
    end
end
