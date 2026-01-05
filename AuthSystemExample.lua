-- AuthSystemExample.lua
-- Ejemplo de uso del sistema de autenticación

-- Cargar la biblioteca
local AuthLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuusuario/turepo/main/AuthLibrary.lua"))()

-- Configurar e inicializar
local AuthSystem = AuthLibrary.new({
    WindowTitle = "ROBLOX AUTH SYSTEM v2.1",
    WindowSize = Vector2.new(450, 350),
    Theme = "Dark",
    DebugMode = true
})

-- Crear la interfaz
local UI = AuthSystem:CreateWindow()

-- Variables de estado
local IsVerifying = false

-- Función para actualizar estado
local function updateStatus(text, isError)
    if UI.StatusLabel then
        UI.StatusLabel.Text = "Estado: " .. text
        if isError then
            UI.StatusLabel.TextColor3 = AuthSystem._currentTheme.Error
        else
            UI.StatusLabel.TextColor3 = AuthSystem._currentTheme.Text
        end
    end
end

-- Función para mostrar éxito
local function showSuccess(message)
    updateStatus(message, false)
    if UI.StatusLabel then
        UI.StatusLabel.TextColor3 = AuthSystem._currentTheme.Success
    end
end

-- Configurar eventos de botones

-- Botón de login
UI.LoginButton.MouseButton1Click:Connect(function()
    if IsVerifying then return end
    
    local key = UI.KeyBox.Text
    if key == "" or key == nil then
        updateStatus("Por favor ingresa una clave", true)
        return
    end
    
    IsVerifying = true
    UI.LoginButton.Text = "VERIFICANDO..."
    UI.LoginButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    updateStatus("Verificando clave...", false)
    
    -- Simular delay de red
    wait(1.5)
    
    local success, message = AuthSystem:Login(key)
    
    if success then
        showSuccess(message)
        UI.LoginButton.Text = "ACCESO CONCEDIDO"
        UI.LoginButton.BackgroundColor3 = AuthSystem._currentTheme.Success
        
        -- Cerrar ventana después de éxito
        wait(2)
        
        -- Aquí puedes cargar tu script principal
        updateStatus("Cargando scripts...", false)
        
        -- Ejemplo: Ejecutar script después de autenticación
        local userInfo = AuthSystem:GetUserInfo()
        print("=== AUTENTICACIÓN EXITOSA ===")
        print("Usuario:", userInfo.key)
        print("Nivel:", userInfo.level)
        print("HWID:", userInfo.hwid)
        print("Token:", AuthSystem._sessionToken)
        print("=============================")
        
        -- Cerrar la interfaz de autenticación
        wait(1)
        AuthSystem:Destroy()
        
        -- Aquí puedes iniciar tu script principal
        -- loadstring(game:HttpGet("tu_script_principal.lua"))()
        
    else
        updateStatus("Error: " .. message, true)
        UI.LoginButton.Text = "VERIFICAR CLAVE"
        UI.LoginButton.BackgroundColor3 = AuthSystem._currentTheme.Accent
    end
    
    IsVerifying = false
end)

-- Botón para copiar HWID
UI.CopyHWIDButton.MouseButton1Click:Connect(function()
    local hwid = AuthSystem:GetHWID()
    if AuthSystem:CopyToClipboard(hwid) then
        updateStatus("HWID copiado al portapapeles", false)
        UI.CopyHWIDButton.Text = "¡COPIADO!"
        wait(1)
        UI.CopyHWIDButton.Text = "COPIAR HWID AL PORTAPAPELES"
    else
        updateStatus("Error al copiar HWID", true)
    end
end)

-- Botón de Discord
UI.DiscordButton.MouseButton1Click:Connect(function()
    AuthSystem:OpenURL("https://discord.gg/tuinvitacion")
    updateStatus("Abriendo Discord...", false)
end)

-- Botón de Sitio Web
UI.WebsiteButton.MouseButton1Click:Connect(function()
    AuthSystem:OpenURL("https://tusitio.com")
    updateStatus("Abriendo sitio web...", false)
end)

-- Efectos de hover para botones
local function setupButtonHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        if not IsVerifying or button.Name ~= "LoginButton" then
            button.BackgroundColor3 = hoverColor
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not IsVerifying or button.Name ~= "LoginButton" then
            button.BackgroundColor3 = normalColor
        end
    end)
end

-- Aplicar efectos a los botones
setupButtonHover(UI.LoginButton, AuthSystem._currentTheme.Accent, Color3.fromRGB(0, 140, 255))
setupButtonHover(UI.CopyHWIDButton, AuthSystem._currentTheme.Accent, Color3.fromRGB(0, 140, 255))
setupButtonHover(UI.DiscordButton, Color3.fromRGB(88, 101, 242), Color3.fromRGB(108, 121, 255))
setupButtonHover(UI.WebsiteButton, Color3.fromRGB(52, 152, 219), Color3.fromRGB(72, 172, 239))

-- Función para cerrar con Escape
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape then
        AuthSystem:Destroy()
    end
end)

-- Mensaje inicial
updateStatus("Listo para verificar clave", false)

print("Sistema de autenticación cargado correctamente")
print("HWID actual:", AuthSystem:GetHWID())
