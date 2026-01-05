-- AuthLibrary.lua CORREGIDO
-- Sistema de Autenticación con Claves para Roblox

local AuthLibrary = {}
AuthLibrary.__index = AuthLibrary

-- Configuración por defecto
AuthLibrary.DefaultConfig = {
    WindowTitle = "Auth System v1.0",
    WindowSize = Vector2.new(500, 400),
    Theme = "Dark",
    APIUrl = "https://api.ejemplo.com/auth",
    EncryptKeys = true,
    DebugMode = false
}

-- Variables internas
AuthLibrary._initialized = false
AuthLibrary._currentUser = nil
AuthLibrary._sessionToken = nil
AuthLibrary._keyCache = {}
AuthLibrary._callbacks = {}

-- Temas disponibles
AuthLibrary.Themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 40),
        Primary = Color3.fromRGB(45, 45, 60),
        Secondary = Color3.fromRGB(60, 60, 80),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(240, 240, 240),
        Success = Color3.fromRGB(76, 175, 80),
        Error = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 193, 7)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(230, 230, 230),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(30, 30, 30),
        Success = Color3.fromRGB(46, 125, 50),
        Error = Color3.fromRGB(211, 47, 47),
        Warning = Color3.fromRGB(245, 124, 0)
    }
}

-- Funciones de utilidad
local function log(message, level)
    if AuthLibrary.DefaultConfig.DebugMode then
        local levels = {
            INFO = "ℹ️",
            WARN = "⚠️",
            ERROR = "❌",
            SUCCESS = "✅"
        }
        print(string.format("[AuthSystem] %s %s", levels[level] or "📝", message))
    end
end

local function encrypt(text, key)
    if not AuthLibrary.DefaultConfig.EncryptKeys then
        return text
    end
    
    -- Simulación de encriptación básica
    local result = ""
    for i = 1, #text do
        local charCode = string.byte(text, i)
        local keyChar = string.byte(key, (i % #key) + 1)
        -- Usar bit32 si está disponible, sino usar operación XOR simple
        if bit32 then
            local encrypted = bit32.bxor(charCode, keyChar)
            result = result .. string.char(encrypted)
        else
            local encrypted = charCode ~ keyChar
            result = result .. string.char(encrypted)
        end
    end
    return result
end

local function decrypt(text, key)
    if not AuthLibrary.DefaultConfig.EncryptKeys then
        return text
    end
    return encrypt(text, key)
end

-- Métodos principales
function AuthLibrary.new(config)
    local self = setmetatable({}, AuthLibrary)
    
    -- Fusionar configuración
    self.Config = {}
    for k, v in pairs(AuthLibrary.DefaultConfig) do
        self.Config[k] = v
    end
    if config then
        for k, v in pairs(config) do
            self.Config[k] = v
        end
    end
    
    self._currentTheme = AuthLibrary.Themes[self.Config.Theme] or AuthLibrary.Themes.Dark
    self._initialized = true
    
    log("Biblioteca de autenticación inicializada", "SUCCESS")
    return self
end

function AuthLibrary:CreateWindow()
    if not self._initialized then
        error("AuthLibrary no ha sido inicializada. Use AuthLibrary.new() primero.")
    end
    
    -- Crear interfaz gráfica
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AuthSystemGUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    
    -- Intentar diferentes formas de parentar
    local success, parent = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if not success then
        success, parent = pcall(function()
            return game.Players.LocalPlayer:WaitForChild("PlayerGui")
        end)
    end
    
    if success and parent then
        ScreenGui.Parent = parent
    else
        ScreenGui.Parent = game:GetService("StarterGui")
    end
    
    -- Ventana principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, self.Config.WindowSize.X, 0, self.Config.WindowSize.Y)
    MainFrame.Position = UDim2.new(0.5, -self.Config.WindowSize.X/2, 0.5, -self.Config.WindowSize.Y/2)
    MainFrame.BackgroundColor3 = self._currentTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Sombra
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.8
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.BackgroundTransparency = 1
    Shadow.Parent = MainFrame
    Shadow.ZIndex = -1
    
    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = self._currentTheme.Primary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.Config.WindowTitle
    TitleLabel.TextColor3 = self._currentTheme.Text
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = self._currentTheme.Error
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Contenedor principal
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame
    
    -- Pestañas
    local Tabs = Instance.new("Frame")
    Tabs.Name = "Tabs"
    Tabs.Size = UDim2.new(1, 0, 0, 30)
    Tabs.BackgroundTransparency = 1
    Tabs.Parent = Container
    
    local LoginTab = Instance.new("TextButton")
    LoginTab.Name = "LoginTab"
    LoginTab.Size = UDim2.new(0.5, -5, 1, 0)
    LoginTab.Position = UDim2.new(0, 0, 0, 0)
    LoginTab.BackgroundColor3 = self._currentTheme.Accent
    LoginTab.BorderSizePixel = 0
    LoginTab.Text = "INICIAR SESIÓN"
    LoginTab.TextColor3 = Color3.new(1, 1, 1)
    LoginTab.TextSize = 12
    LoginTab.Font = Enum.Font.GothamSemibold
    LoginTab.Parent = Tabs
    
    local RegisterTab = Instance.new("TextButton")
    RegisterTab.Name = "RegisterTab"
    RegisterTab.Size = UDim2.new(0.5, -5, 1, 0)
    RegisterTab.Position = UDim2.new(0.5, 5, 0, 0)
    RegisterTab.BackgroundColor3 = self._currentTheme.Secondary
    RegisterTab.BorderSizePixel = 0
    RegisterTab.Text = "REGISTRAR CLAVE"
    RegisterTab.TextColor3 = self._currentTheme.Text
    RegisterTab.TextSize = 12
    RegisterTab.Font = Enum.Font.GothamSemibold
    RegisterTab.Parent = Tabs
    
    -- Contenido de las pestañas
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -40)
    Content.Position = UDim2.new(0, 0, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Parent = Container
    
    -- Panel de Login
    local LoginPanel = Instance.new("Frame")
    LoginPanel.Name = "LoginPanel"
    LoginPanel.Size = UDim2.new(1, 0, 1, 0)
    LoginPanel.BackgroundTransparency = 1
    LoginPanel.Visible = true
    LoginPanel.Parent = Content
    
    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Name = "KeyLabel"
    KeyLabel.Size = UDim2.new(1, 0, 0, 20)
    KeyLabel.Position = UDim2.new(0, 0, 0, 20)
    KeyLabel.BackgroundTransparency = 1
    KeyLabel.Text = "INGRESA TU CLAVE DE ACCESO:"
    KeyLabel.TextColor3 = self._currentTheme.Text
    KeyLabel.TextSize = 12
    KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeyLabel.Font = Enum.Font.Gotham
    KeyLabel.Parent = LoginPanel
    
    local KeyBox = Instance.new("TextBox")
    KeyBox.Name = "KeyBox"
    KeyBox.Size = UDim2.new(1, 0, 0, 35)
    KeyBox.Position = UDim2.new(0, 0, 0, 45)
    KeyBox.BackgroundColor3 = self._currentTheme.Primary
    KeyBox.BorderSizePixel = 0
    KeyBox.PlaceholderText = "ej: ABCDE-12345-FGHIJ-67890"
    KeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyBox.Text = ""
    KeyBox.TextColor3 = self._currentTheme.Text
    KeyBox.TextSize = 14
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.TextXAlignment = Enum.TextXAlignment.Center
    KeyBox.Parent = LoginPanel
    
    local HWIDLabel = Instance.new("TextLabel")
    HWIDLabel.Name = "HWIDLabel"
    HWIDLabel.Size = UDim2.new(1, 0, 0, 20)
    HWIDLabel.Position = UDim2.new(0, 0, 0, 95)
    HWIDLabel.BackgroundTransparency = 1
    HWIDLabel.Text = "HWID (Automático):"
    HWIDLabel.TextColor3 = self._currentTheme.Text
    HWIDLabel.TextSize = 12
    HWIDLabel.TextXAlignment = Enum.TextXAlignment.Left
    HWIDLabel.Font = Enum.Font.Gotham
    HWIDLabel.Parent = LoginPanel
    
    local HWIDBox = Instance.new("TextBox")
    HWIDBox.Name = "HWIDBox"
    HWIDBox.Size = UDim2.new(1, 0, 0, 35)
    HWIDBox.Position = UDim2.new(0, 0, 0, 120)
    HWIDBox.BackgroundColor3 = self._currentTheme.Primary
    HWIDBox.BorderSizePixel = 0
    HWIDBox.Text = self:GetHWID()
    HWIDBox.TextColor3 = Color3.fromRGB(180, 180, 180)
    HWIDBox.TextSize = 12
    HWIDBox.Font = Enum.Font.Gotham
    HWIDBox.TextEditable = false
    HWIDBox.Parent = LoginPanel
    
    local LoginButton = Instance.new("TextButton")
    LoginButton.Name = "LoginButton"
    LoginButton.Size = UDim2.new(1, 0, 0, 40)
    LoginButton.Position = UDim2.new(0, 0, 0, 170)
    LoginButton.BackgroundColor3 = self._currentTheme.Accent
    LoginButton.BorderSizePixel = 0
    LoginButton.Text = "VERIFICAR CLAVE"
    LoginButton.TextColor3 = Color3.new(1, 1, 1)
    LoginButton.TextSize = 14
    LoginButton.Font = Enum.Font.GothamBold
    LoginButton.Parent = LoginPanel
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Position = UDim2.new(0, 0, 0, 220)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Estado: Esperando clave..."
    StatusLabel.TextColor3 = self._currentTheme.Text
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = LoginPanel
    
    -- Panel de Registro
    local RegisterPanel = Instance.new("Frame")
    RegisterPanel.Name = "RegisterPanel"
    RegisterPanel.Size = UDim2.new(1, 0, 1, 0)
    RegisterPanel.BackgroundTransparency = 1
    RegisterPanel.Visible = false
    RegisterPanel.Parent = Content
    
    local RegisterTitle = Instance.new("TextLabel")
    RegisterTitle.Name = "RegisterTitle"
    RegisterTitle.Size = UDim2.new(1, 0, 0, 40)
    RegisterTitle.Position = UDim2.new(0, 0, 0, 10)
    RegisterTitle.BackgroundTransparency = 1
    RegisterTitle.Text = "REGISTRO DE NUEVA CLAVE"
    RegisterTitle.TextColor3 = self._currentTheme.Text
    RegisterTitle.TextSize = 16
    RegisterTitle.Font = Enum.Font.GothamBold
    RegisterTitle.Parent = RegisterPanel
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Name = "InfoLabel"
    InfoLabel.Size = UDim2.new(1, 0, 0, 60)
    InfoLabel.Position = UDim2.new(0, 0, 0, 60)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Para obtener una clave, contacta al administrador del sistema o visita nuestro sitio web."
    InfoLabel.TextColor3 = self._currentTheme.Text
    InfoLabel.TextSize = 12
    InfoLabel.TextWrapped = true
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Parent = RegisterPanel
    
    local CopyHWIDButton = Instance.new("TextButton")
    CopyHWIDButton.Name = "CopyHWIDButton"
    CopyHWIDButton.Size = UDim2.new(1, 0, 0, 40)
    CopyHWIDButton.Position = UDim2.new(0, 0, 0, 130)
    CopyHWIDButton.BackgroundColor3 = self._currentTheme.Accent
    CopyHWIDButton.BorderSizePixel = 0
    CopyHWIDButton.Text = "COPIAR HWID AL PORTAPAPELES"
    CopyHWIDButton.TextColor3 = Color3.new(1, 1, 1)
    CopyHWIDButton.TextSize = 14
    CopyHWIDButton.Font = Enum.Font.GothamBold
    CopyHWIDButton.Parent = RegisterPanel
    
    local DiscordButton = Instance.new("TextButton")
    DiscordButton.Name = "DiscordButton"
    DiscordButton.Size = UDim2.new(1, 0, 0, 40)
    DiscordButton.Position = UDim2.new(0, 0, 0, 180)
    DiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    DiscordButton.BorderSizePixel = 0
    DiscordButton.Text = "UNIRSE A DISCORD"
    DiscordButton.TextColor3 = Color3.new(1, 1, 1)
    DiscordButton.TextSize = 14
    DiscordButton.Font = Enum.Font.GothamBold
    DiscordButton.Parent = RegisterPanel
    
    local WebsiteButton = Instance.new("TextButton")
    WebsiteButton.Name = "WebsiteButton"
    WebsiteButton.Size = UDim2.new(1, 0, 0, 40)
    WebsiteButton.Position = UDim2.new(0, 0, 0, 230)
    WebsiteButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    WebsiteButton.BorderSizePixel = 0
    WebsiteButton.Text = "VISITAR SITIO WEB"
    WebsiteButton.TextColor3 = Color3.new(1, 1, 1)
    WebsiteButton.TextSize = 14
    WebsiteButton.Font = Enum.Font.GothamBold
    WebsiteButton.Parent = RegisterPanel
    
    -- Funcionalidad de pestañas
    LoginTab.MouseButton1Click:Connect(function()
        LoginPanel.Visible = true
        RegisterPanel.Visible = false
        LoginTab.BackgroundColor3 = self._currentTheme.Accent
        RegisterTab.BackgroundColor3 = self._currentTheme.Secondary
        LoginTab.TextColor3 = Color3.new(1, 1, 1)
        RegisterTab.TextColor3 = self._currentTheme.Text
    end)
    
    RegisterTab.MouseButton1Click:Connect(function()
        LoginPanel.Visible = false
        RegisterPanel.Visible = true
        LoginTab.BackgroundColor3 = self._currentTheme.Secondary
        RegisterTab.BackgroundColor3 = self._currentTheme.Accent
        LoginTab.TextColor3 = self._currentTheme.Text
        RegisterTab.TextColor3 = Color3.new(1, 1, 1)
    end)
    
    -- Guardar referencias
    self._screenGui = ScreenGui
    
    return {
        GUI = ScreenGui,
        LoginButton = LoginButton,
        CopyHWIDButton = CopyHWIDButton,
        DiscordButton = DiscordButton,
        WebsiteButton = WebsiteButton,
        KeyBox = KeyBox,
        StatusLabel = StatusLabel,
        HWIDBox = HWIDBox,
        CloseButton = CloseButton
    }
end

function AuthLibrary:GetHWID()
    -- Generar un HWID único
    local info = ""
    
    -- Obtener información del usuario
    local success, player = pcall(function()
        return game:GetService("Players").LocalPlayer
    end)
    
    if success and player then
        info = info .. tostring(player.UserId)
    end
    
    -- Agregar timestamp
    info = info .. tostring(tick())
    
    -- Calcular hash simple
    local hash = 0
    for i = 1, #info do
        local byte = string.byte(info, i)
        hash = (hash * 31 + byte) % 1000000
    end
    
    return string.format("HWID-%06d", hash)
end

function AuthLibrary:ValidateKey(key, hwid)
    log(string.format("Validando clave: %s", key), "INFO")
    
    -- Verificación básica de formato
    if #key < 5 then
        return false, "Clave inválida: demasiado corta"
    end
    
    -- Tabla de claves válidas (SIMULACIÓN - reemplazar con API real)
    local validKeys = {
        ["ABCDE-12345-FGHIJ-67890"] = {
            expiry = os.time() + 86400,
            level = "VIP",
            hwidLocked = false
        },
        ["TEST-KEY-12345-67890"] = {
            expiry = os.time() + 3600,
            level = "TEST",
            hwidLocked = false
        },
        ["VIP-ACCESS-99999-11111"] = {
            expiry = os.time() + 2592000,
            level = "PREMIUM",
            hwidLocked = false
        },
        ["DEMO-2024-AUTH-SYSTEM"] = {
            expiry = os.time() + 7200,
            level = "DEMO",
            hwidLocked = false
        }
    }
    
    if validKeys[key] then
        local keyData = validKeys[key]
        
        -- Verificar expiración
        if os.time() > keyData.expiry then
            return false, "Clave expirada"
        end
        
        -- Verificar HWID si está bloqueado
        if keyData.hwidLocked and keyData.hwid ~= hwid then
            return false, "Clave vinculada a otro HWID"
        end
        
        -- Guardar sesión
        self._currentUser = {
            key = key,
            hwid = hwid,
            level = keyData.level,
            expiry = keyData.expiry,
            loginTime = os.time()
        }
        
        -- Generar token de sesión
        self._sessionToken = string.format("SESSION-%s-%d", key:sub(1, 5), os.time())
        
        log(string.format("Clave válida. Nivel: %s", keyData.level), "SUCCESS")
        return true, string.format("Acceso concedido. Nivel: %s", keyData.level)
    else
        -- Intentar con API real si está configurada
        if self.Config.APIUrl and self.Config.APIUrl ~= "https://api.ejemplo.com/auth" then
            -- Aquí iría la llamada a la API real
            -- Por ahora retornamos falso
            return false, "Clave no válida"
        else
            return false, "Clave no válida"
        end
    end
end

function AuthLibrary:Login(key)
    local hwid = self:GetHWID()
    local success, message = self:ValidateKey(key, hwid)
    return success, message
end

function AuthLibrary:IsLoggedIn()
    return self._currentUser ~= nil
end

function AuthLibrary:GetUserInfo()
    return self._currentUser
end

function AuthLibrary:Logout()
    self._currentUser = nil
    self._sessionToken = nil
    log("Sesión cerrada", "INFO")
end

function AuthLibrary:CopyToClipboard(text)
    -- Intentar diferentes métodos para copiar al portapapeles
    local clipboardFuncs = {
        setclipboard,
        toclipboard,
        set_clipboard,
        write_clipboard
    }
    
    for _, func in pairs(clipboardFuncs) do
        if type(func) == "function" then
            local success = pcall(func, text)
            if success then
                return true
            end
        end
    end
    return false
end

function AuthLibrary:OpenURL(url)
    local openFuncs = {
        syn and syn.open,
        request
    }
    
    for _, func in pairs(openFuncs) do
        if type(func) == "function" then
            pcall(func, url)
            return true
        end
    end
    return false
end

function AuthLibrary:Destroy()
    if self._screenGui and self._screenGui.Parent then
        self._screenGui:Destroy()
    end
    self._initialized = false
    log("Interfaz destruida", "INFO")
end

return AuthLibrary
