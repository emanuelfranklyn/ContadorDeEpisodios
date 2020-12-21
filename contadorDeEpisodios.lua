--[V2]--
component = require('component')
fs = require('filesystem')
event = require('event')
serialization = require('serialization')
term = require('term')
--[Global Variables]--
StartupBootFileName = '.shrc'
MainFilePath = '/home/'
DataFileName = 'Episodes.data'
ScreenList = component.list("screen")
Screens = {}
gpuTier = 1
gpu = component.gpu
--[Language]--
Languages = {
    EnUS = {
        EpisodeName = 'Episode:',
        BackEpisodeName = 'Previous',
        ManualEpisodeName = 'Manual',
        NextEpisodeName = 'Next',
        ClickOnConfigScreenName = 'Click on the config screen',
        SelectLanguage = 'Please select a language:',
        InvalidInput = 'Invalid input',
        EpisodeWordText = {'Would you like to get the word: "','" together the episode counter?'},
        Yes = 'Yes',
        No = 'No',
        ForegroundAskText = 'Type the hex code of the color than will be atributed to program texts:',
        BackgroundAskText = 'Type the hex code of the color than will be atributed to program background :',
        GeneratingFileMessage = 'Generating configs file...',
        RunOnStartupText = 'Did you want to the episode counter be runned on the startup',
        ProgramWorkTwoScreens = 'To this program works its necessaire two screens attached to computer',
        ProgramWorkTwoScreensPTwo = 'Searching for screens, attach it to continue',
        SelectConfigScreen = 'Please click on screen who will server as control panel',
        ControlPanelSelected= 'This screen has been selected as control panel',
        NotFoundedConfigScreen = 'The controls screen has been not founded, redefine it',
        Redefineit = 'Redefine'
    },
    PtBR = {
        EpisodeName = 'Episodio:',
        BackEpisodeName = 'Anterior',
        ManualEpisodeName = 'Manual',
        NextEpisodeName = 'Proximo',
        ClickOnConfigScreenName = 'Clique na tela de configurações',
        SelectLanguage = 'Por favor selecione uma lingua',
        InvalidInput = 'Entrada invalida',
        EpisodeWordText = {'Você gostaria de inserir a palavra: "','" Junto ao contador de episodios?'},
        Yes = 'Sim',
        No = 'Não',
        ForegroundAskText = 'Digite o codigo hex da cor a ser atribuida aos textos do programa:',
        BackgroundAskText = 'Digite o codigo hex da cor a ser atribuida ao fundo do programa:',
        GeneratingFileMessage = 'Gerando arquivo de configurações...',
        RunOnStartupText = 'Você deseja que o contador de episodios seja executado na inicialisação',
        ProgramWorkTwoScreens = 'Para esse programa funcionar é nescessario dois monitores conectados ao computador',
        ProgramWorkTwoScreensPTwo = 'Procurando por telas, conecte-a para continuar',
        SelectConfigScreen = 'Porfavor clique no monitor que deve servir de painel de controles',
        ControlPanelSelected= 'Esse monitor foi selecionado como monitor de configurações',
        NotFoundedConfigScreen = 'O monitor de controles não foi encontrado, redefina-o',
        Redefineit = 'Redefinir'
    }
}
--[Post initialization Language corrector]--
--[Itens:]--
    --[EpisodeWordText]--
--[Code:]--
for LangName,_ in pairs(Languages) do
    Languages[LangName]['EpisodeWordText'] = Languages[LangName]['EpisodeWordText'][1]..Languages[LangName]['EpisodeName']..Languages[LangName]['EpisodeWordText'][2]
end
CurrentLanguage = Languages['EnUS']
--[UI]--
Ui = {
    ForegroundColor = 0x000000,
    BackgroundColor = 0xFFFFFF,
    EpisodeScreenHeight = 1,
    EpisodeScreenWidth = 1,
    WriteEpisodeWord = false,
    ConfigScreen = {
        Tier1 = {
            Width = 50,
            Height = 5,
            Colors = false
        },
        Tier2 = {
            Width = 80,
            Height = 5,
            Colors = true
        },
        Tier3 = {
            Width = 110,
            Height = 5,
            Colors = true
        },
    },
    ConfigsScreen = {
        Width = 1,
        Height = 1,
        Colors = false
    }
}

function validateInput(min, max, x)
    x = x or 3
    CW,CH = term.getCursor()
    term.setCursor(x,CH-1)
    local input = io.read()
    local proceed = false
    while proceed == false do
        if (tonumber(input) ~= nil and tonumber(input) > min and tonumber(input) < max and tonumber(input)%1 == 0) then
            input = tonumber(input)
            proceed = true
            break
        else
            input = InvalidInput(x, CH, w, '> ')
        end
    end
    return input
end

function InvalidInput(x, CH, w, txt)
    gpu.fill(1,CH-1,w,1,' ')
    term.setCursor(1,CH-1)
    print(txt..CurrentLanguage['InvalidInput'])
    os.sleep(1)
    gpu.fill(1,CH-1,w,1,' ')
    term.setCursor(1,CH-1)
    print(txt)
    term.setCursor(x,CH-1)
    input = io.read()
    return input
end

--[Functions and definitions]
function installer()
    --[Wrap all screens on a list]--
    local index = 0
    for Screen,_ in ScreenList do
        index = index + 1
        Screens[index] = Screen 
    end
    --[Get gpu tier]--
    if (gpu.getDepth() == 8) then
        gpuTier = 3
    elseif (gpu.getDepth() == 4) then
        gpuTier = 2
    else
        gpuTier = 1
    end
    Ui['ConfigsScreen'] = Ui['ConfigScreen']['Tier'..string.format(gpuTier)] 
    --[Show Instalator on main screen]--
    gpu.setResolution(Ui['ConfigsScreen']['Width'],16)
    w, h = gpu.getResolution()
    if (gpuTier > 1) then
        gpu.setBackground(0xFFBB00)
        gpu.setForeground(0x000000)
    else
        gpu.setBackground(0x000000)
        gpu.setForeground(0xFFFFFF)
    end
    local languageList = {}
    local languageListIndex = 0
    for Language,_ in pairs(Languages) do
        languageListIndex = languageListIndex + 1
        languageList[languageListIndex] = Language
    end
    gpu.fill(1,1,w,h,' ')
    term.setCursor(1,1)
    print(CurrentLanguage['SelectLanguage'])
    local HeightLanguage = 2
    local endLine = 2
    for i=0, #languageList-1 do
        endLine = HeightLanguage+i
        term.setCursor(1,HeightLanguage+i)
        print("["..string.format(i+1).."] "..languageList[i+1])
    end
    term.setCursor(1,endLine+1)
    print('> ')
    input = validateInput(0, #languageList+1)
    CurrentLanguage = Languages[languageList[input]]
    gpu.fill(1,1,w,h,' ')
    --[Show Episode word on the Episodes Screen]--
    term.setCursor(1,1)
    print(CurrentLanguage['EpisodeWordText'])
    print('[1] '..CurrentLanguage['Yes'])
    print('[2] '..CurrentLanguage['No'])
    print('> ')
    input = validateInput(0, 3)
    if (tonumber(input) == 1) then
        Ui['WriteEpisodeWord'] = true
        Ui['EpisodeScreenWidth'] = CurrentLanguage['EpisodeName']:len()+2
        Ui['EpisodeScreenHeight'] = 3
    else
        Ui['WriteEpisodeWord'] = false
        Ui['EpisodeScreenWidth'] = 1
        Ui['EpisodeScreenHeight'] = 1
    end
    gpu.fill(1,1,w,h,' ')
    --[Asks the main color of system, Foreground color]--
    term.setCursor(1,1)
    print(CurrentLanguage['ForegroundAskText'])
    print('> #')
    CW,CH = term.getCursor()
    term.setCursor(4,CH-1)
    local input = io.read()
    local proceed = false
    while proceed == false do
        if (tonumber('0x'..input) ~= nil and input:len() == 6 and tonumber('0x'..input)%1 == 0) then
            proceed = true
            break
        else
            input = InvalidInput(4, CH, w, '> #')
        end
    end
    Ui['ForegroundColor'] = tonumber('0x'..input)
    gpu.setForeground(Ui['ForegroundColor'])
    gpu.fill(1,1,w,h,' ')
    --[Asks the secound color of system, Background color]--
    term.setCursor(1,1)
    print(CurrentLanguage['BackgroundAskText'])
    print('> #')
    CW,CH = term.getCursor()
    term.setCursor(4,CH-1)
    local input = io.read()
    local proceed = false
    while proceed == false do
        if (tonumber('0x'..input) ~= nil and input:len() == 6 and tonumber('0x'..input)%1 == 0) then
            proceed = true
            break
        else
            input = InvalidInput(4, CH, w, '> #')
        end
    end
    Ui['BackgroundColor'] = tonumber('0x'..input)
    gpu.setBackground(Ui['BackgroundColor'])
    gpu.fill(1,1,w,h,' ')
    --[Run on startup]--
    term.setCursor(1,1)
    AlreadRunningOnStartup = false
    ProgramName = ''
    Programs = {}
    FilesOnHome = fs.list(MainFilePath)
    SearchFinished = false
    SearchIndex = 0
    while SearchFinished == false do
        SearchIndex = SearchIndex + 1
        CurrentSearchingFile = FilesOnHome()
        if (CurrentSearchingFile ~= nil) then
            Programs[SearchIndex] = CurrentSearchingFile
        else
            SearchFinished = true
        end
    end
    for i=1, #Programs do
        if (Programs[i]:sub(-4) == ".lua") then
            ProgramName = Programs[i]
            break
        end
    end
    for line in io.lines(StartupBootFileName) do
        if (line == ProgramName) then
            AlreadRunningOnStartup = true
        end
    end
    if (AlreadRunningOnStartup == false) then
        print(CurrentLanguage['RunOnStartupText'])
        print('[1] '..CurrentLanguage['Yes'])
        print('[2] '..CurrentLanguage['No'])
        print('> ')
        input = validateInput(0, 3)
        if (tonumber(input) == 1) then
            startupfile = io.open(StartupBootFileName,'a')
            startupfile:write("\n"..ProgramName)
            startupfile:close()
        end
    end
    --[Select Configs monitor]--
    gpu.fill(1,1,w,h,' ')
    term.setCursor(1,1)
    if (#Screens < 2) then
        print(CurrentLanguage['ProgramWorkTwoScreens'])
        print(CurrentLanguage['ProgramWorkTwoScreensPTwo'])
        Searching = false
        while Searching == false do
            ScreenList = component.list("screen")
            Screens = {}
            index = 0
            for Screen,_ in ScreenList do
                index = index + 1
                Screens[index] = Screen 
            end
            if (#Screens > 1) then
                Searching = true
            end
            os.sleep(1)
        end
    end
    for i=1, #Screens do
        gpu.bind(Screens[i], false)
        gpu.setForeground(Ui['ForegroundColor'])
        gpu.setBackground(Ui['BackgroundColor'])
        gpu.setResolution(Ui['ConfigsScreen']['Width'],16)
        w, h = gpu.getResolution()
        gpu.fill(1,1,w,h,' ')
        term.setCursor(1,1)
        print(CurrentLanguage['SelectConfigScreen'])
    end
    local _, monitorAddress = event.pull('touch')
    ControlPanelAddress = monitorAddress
    for i=1, #Screens do
        gpu.bind(Screens[i], false)
        gpu.setForeground(Ui['ForegroundColor'])
        gpu.setBackground(Ui['BackgroundColor'])
        gpu.setResolution(Ui['ConfigsScreen']['Width'],16)
        w, h = gpu.getResolution()
        gpu.fill(1,1,w,h,' ')
        if (Screens[i] == ControlPanelAddress) then
            print(CurrentLanguage['ControlPanelSelected'])
        end
    end
    os.sleep(1)
    --[Save configs]--
    gpu.fill(1,1,w,h,' ')
    term.setCursor(1,1)
    print(CurrentLanguage['GeneratingFileMessage'])
    ConfigFile = io.open(MainFilePath..DataFileName, 'w')
    ConfigContent = {
        GpuTier = gpuTier,
        BackgroundColor = Ui['BackgroundColor'],
        ForegroundColor = Ui['ForegroundColor'],
        Language = CurrentLanguage,
        ShowEpisode = Ui['WriteEpisodeWord'],
        EpisodeNumber = 1,
        ControlPanelAddress = ControlPanelAddress,
        ConfigsScreen = Ui['ConfigsScreen']
    }
    ConfigFile:write(serialization.serialize(ConfigContent))
    ConfigFile:close()
    component.computer.beep(200, 0.5)
    component.computer.beep(500, 0.5)
    component.computer.beep(1000, 0.5)
    component.computer.beep(2000, 0.5)
end

function App()
    --[Load CurrentLanguage]--
    ConfigFile = io.open(MainFilePath..DataFileName, 'r')
    ConfigsRaw = ConfigFile:read()
    UserConfigs = serialization.unserialize(ConfigsRaw)
    ConfigFile:close()
    gpuTier = UserConfigs.GpuTier
    Ui['BackgroundColor'] = UserConfigs.BackgroundColor
    Ui['ForegroundColor'] = UserConfigs.ForegroundColor
    CurrentLanguage = UserConfigs.Language
    Ui['WriteEpisodeWord'] = UserConfigs.ShowEpisode
    EpisodeNumber = UserConfigs.EpisodeNumber
    ControlPanelAddress = UserConfigs.ControlPanelAddress
    Ui['ConfigsScreen'] = UserConfigs.ConfigsScreen
    --[]
    w, h = gpu.getResolution()
    local index = 0
    for Screen,_ in ScreenList do
        index = index + 1
        Screens[index] = Screen 
    end
    if (#Screens < 2) then
        gpu.setBackground(Ui['BackgroundColor'])
        gpu.setForeground(Ui['ForegroundColor'])
        gpu.fill(1,1,w,h,' ')
        term.setCursor(1,1)
        print(CurrentLanguage['ProgramWorkTwoScreens'])
        print(CurrentLanguage['ProgramWorkTwoScreensPTwo'])
    end
    Searching = false
    ControlPanelFounded = false
    while Searching == false do
        ScreenList = component.list("screen")
        local index = 0
        for Screen,_ in ScreenList do
            index = index + 1
            Screens[index] = Screen 
            if (Screens[index] == ControlPanelAddress) then
                ControlPanelFounded = true
            end
        end
        if (#Screens > 1) then
            Searching = true
        end
        os.sleep(1)
    end
    --[Verify if control panel exists]
    if (ControlPanelFounded == false) then
        for i=1, #Screens do
            gpu.bind(Screens[i], false)
            gpu.setForeground(Ui['ForegroundColor'])
            gpu.setBackground(Ui['BackgroundColor'])
            gpu.setResolution(Ui['ConfigsScreen']['Width'],Ui['ConfigsScreen']['Height'])
            w, h = gpu.getResolution()
            gpu.fill(1,1,w,h,' ')
            term.setCursor(1,1)
            print(CurrentLanguage['NotFoundedConfigScreen'])
            print(CurrentLanguage['SelectConfigScreen'])
        end
        local _, monitorAddress = event.pull('touch')
        ControlPanelAddress = monitorAddress
        for i=1, #Screens do
            gpu.bind(Screens[i], false)
            gpu.setForeground(Ui['ForegroundColor'])
            gpu.setBackground(Ui['BackgroundColor'])
            gpu.setResolution(Ui['ConfigsScreen']['Width'],Ui['ConfigsScreen']['Height'])
            w, h = gpu.getResolution()
            gpu.fill(1,1,w,h,' ')
            if (Screens[i] == ControlPanelAddress) then
                print(CurrentLanguage['ControlPanelSelected'])
            end
        end
        os.sleep(1)
        ConfigFile = io.open(MainFilePath..DataFileName, 'w')
        ConfigContent = {
            GpuTier = gpuTier,
            BackgroundColor = Ui['BackgroundColor'],
            ForegroundColor = Ui['ForegroundColor'],
            Language = CurrentLanguage,
            ShowEpisode = Ui['WriteEpisodeWord'],
            EpisodeNumber = 1,
            ControlPanelAddress = ControlPanelAddress
        }
        ConfigFile:write(serialization.serialize(ConfigContent))
        ConfigFile:close()
    end
    --[MAGIC! ControlPanel]
    function DrawnConfigsPanel()
        gpu.bind(ControlPanelAddress, false)
        gpu.setForeground(Ui['ForegroundColor'])
        gpu.setBackground(Ui['BackgroundColor'])
        gpu.setResolution(Ui['ConfigsScreen']['Width'],Ui['ConfigsScreen']['Height'])
        w,h = Ui['ConfigsScreen']['Width'],Ui['ConfigsScreen']['Height']
        gpu.fill(1,1,w,h,' ')
        gpu.setBackground(0xAAAAAA)
        gpu.fill(1,1,w,1,'=')
        gpu.fill(1,h,w,1,'=')
        gpu.fill(1,1,1,h,'|')
        gpu.fill(w,1,1,h,'|')
        gpu.fill((w/3),1,1,h,'|')
        gpu.fill((w/3)*2,1,1,h,'|')
        gpu.fill(1,1,1,1,'#')
        gpu.fill(w,1,1,1,'#')
        gpu.fill(1,h,1,1,'#')
        gpu.fill(w,h,1,1,'#')
        gpu.fill((w/3),1,1,1,'#')
        gpu.fill((w/3)*2,1,1,1,'#')
        gpu.fill((w/3),h,1,1,'#')
        gpu.fill((w/3)*2,h,1,1,'#')
        gpu.set(((w/3)/2)-((" "..CurrentLanguage['BackEpisodeName'].." "):len()/2), (h/2)+1, " "..CurrentLanguage['BackEpisodeName'].." ")
        gpu.set(((w/3)*1)+((w/3)/2)-((" "..CurrentLanguage['ManualEpisodeName'].." "):len()/2),(h/2)+1, " "..CurrentLanguage['ManualEpisodeName'].." ")
        gpu.set(((w/3)*2)+((w/3)/2)-((" "..CurrentLanguage['NextEpisodeName'].." "):len()/2),(h/2)+1, " "..CurrentLanguage['NextEpisodeName'].." ")
        gpu.setForeground(Ui['BackgroundColor'])
        gpu.setBackground(Ui['ForegroundColor'])
        gpu.set((w)-(CurrentLanguage['Redefineit']:len()), 1, CurrentLanguage['Redefineit'])
    end
    function DrawnNumbers()
        ScreenList = component.list("screen")
        for Screen,_ in ScreenList do
            if (Screen ~= ControlPanelAddress) then
                gpu.bind(Screen)
                gpu.setForeground(Ui['ForegroundColor'])
                gpu.setBackground(Ui['BackgroundColor'])
                if (Ui['WriteEpisodeWord'] == true) then
                    gpu.setResolution(CurrentLanguage['EpisodeName']:len()+2, 3)
                    gpu.fill(1,1,CurrentLanguage['EpisodeName']:len()+2, 3, " ")
                    gpu.set(2,1,CurrentLanguage['EpisodeName'])
                    gpu.set(((CurrentLanguage['EpisodeName']:len()+2)/2)-((string.format(EpisodeNumber):len()/2)-1),3,string.format(EpisodeNumber))
                else
                    gpu.setResolution(string.format(EpisodeNumber):len(), 1)
                    gpu.fill(1,1,string.format(EpisodeNumber):len(), 1, " ")
                    gpu.set(1,1,string.format(EpisodeNumber))
                end
            end
        end
    end
    function reloadConfigs()
        ConfigFile = io.open(MainFilePath..DataFileName, 'r')
        ConfigsRaw = ConfigFile:read()
        UserConfigs = serialization.unserialize(ConfigsRaw)
        ConfigFile:close()
            gpuTier = UserConfigs.GpuTier
            Ui['BackgroundColor'] = UserConfigs.BackgroundColor
            Ui['ForegroundColor'] = UserConfigs.ForegroundColor
            CurrentLanguage = UserConfigs.Language
            Ui['WriteEpisodeWord'] = UserConfigs.ShowEpisode
            EpisodeNumber = UserConfigs.EpisodeNumber
            ControlPanelAddress = UserConfigs.ControlPanelAddress
            Ui['ConfigsScreen'] = UserConfigs.ConfigsScreen
    end
    function EditConfigs()
        ConfigFile = io.open(MainFilePath..DataFileName, 'w')
        ConfigContent = {
            GpuTier = gpuTier,
            BackgroundColor = Ui['BackgroundColor'],
            ForegroundColor = Ui['ForegroundColor'],
            Language = CurrentLanguage,
            ShowEpisode = Ui['WriteEpisodeWord'],
            EpisodeNumber = EpisodeNumber,
            ControlPanelAddress = ControlPanelAddress,
            ConfigsScreen = Ui['ConfigsScreen']
        }
        ConfigFile:write(serialization.serialize(ConfigContent))
        ConfigFile:close()
    end
    function clickParser(_,monitorAddress,x,y)
        if (monitorAddress == ControlPanelAddress) then
            gpu.bind(ControlPanelAddress, false)
            gpu.setResolution(Ui['ConfigsScreen']['Width'],Ui['ConfigsScreen']['Height'])
            if (x>1 and x<(Ui['ConfigsScreen']['Width']/3)-1 and y>1 and y<Ui['ConfigsScreen']['Height']) then
                --BackEpisode
                gpu.setForeground(Ui['BackgroundColor'])
                gpu.setBackground(Ui['ForegroundColor'])
                gpu.fill(2,2,(Ui['ConfigsScreen']['Width']/3)-2,Ui['ConfigsScreen']['Height']-2, ' ')
                gpu.setForeground(Ui['BackgroundColor'])
                gpu.setBackground(0xAAAAAA)
                gpu.set(((w/3)/2)-((" "..CurrentLanguage['BackEpisodeName'].." "):len()/2), (h/2)+1, " "..CurrentLanguage['BackEpisodeName'].." ")
                reloadConfigs()
                EpisodeNumber = EpisodeNumber - 1
                EditConfigs()
                DrawnNumbers()
                os.sleep(0.3)
                DrawnConfigsPanel()
            elseif (x > Ui['ConfigsScreen']['Width']/3 and x < ((Ui['ConfigsScreen']['Width']/3)*2)-1 and y > 1 and y< Ui['ConfigsScreen']['Height']) then
                --ManualEpisode
                gpu.setForeground(Ui['BackgroundColor'])
                gpu.setBackground(Ui['ForegroundColor'])
                gpu.fill((Ui['ConfigsScreen']['Width']/3)+1,2,(Ui['ConfigsScreen']['Width']/3),Ui['ConfigsScreen']['Height']-2, ' ')
                gpu.setForeground(Ui['BackgroundColor'])
                gpu.setBackground(0xAAAAAA)
                gpu.fill(((w/3)*1)+2, (h/2)+1, ((w/3)*1)-2, 1, " ")
                term.setCursor(((w/3)*1)+2, (h/2)+1)
                reloadConfigs()
                Reader = io.read()
                EpisodeNumber = tonumber(Reader)
                EditConfigs()
                DrawnNumbers()
                os.sleep(0.3)
                DrawnConfigsPanel()
            elseif (x > (Ui['ConfigsScreen']['Width']/3)*2 and x < Ui['ConfigsScreen']['Width'] and y > 1 and y< Ui['ConfigsScreen']['Height']) then
                --NextEpisode
                gpu.setForeground(Ui['BackgroundColor'])
                gpu.setBackground(Ui['ForegroundColor'])
                gpu.fill(((Ui['ConfigsScreen']['Width']/3)*2)+1,2,Ui['ConfigsScreen']['Width']-1,Ui['ConfigsScreen']['Height']-2, ' ')
                gpu.setForeground(Ui['BackgroundColor'])
                gpu.setBackground(0xAAAAAA)
                gpu.set(((w/3)*2)+((w/3)/2)-((" "..CurrentLanguage['NextEpisodeName'].." "):len()/2), (h/2)+1, " "..CurrentLanguage['NextEpisodeName'].." ")
                reloadConfigs()
                EpisodeNumber = EpisodeNumber + 1 
                EditConfigs()
                DrawnNumbers()
                os.sleep(0.3)
                DrawnConfigsPanel()
            elseif (x> (Ui['ConfigsScreen']['Width'])-(CurrentLanguage['Redefineit']:len())+1 and x< Ui['ConfigsScreen']['Width'] and y==1) then
                fs.remove(MainFilePath..DataFileName)
                installer()
                return
            end
        end
    end
    DrawnConfigsPanel()
    DrawnNumbers()
    while true do
        local id, monitorAddress, x, y, button = event.pullMultiple('touch', 'interrupted')
        if (id == 'interrupted') then
            break
        elseif (id == 'touch') then
            clickParser(id, monitorAddress, x, y)
        end
    end
end

--[Program Initialization]--
if (fs.exists(MainFilePath..DataFileName)) then
    App()
else
    installer()
    App()
end
