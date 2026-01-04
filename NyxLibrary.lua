-- NyxLibrary.lua
-- Modern Roblox UI Library usando Roact
-- Autor: Tú (puedes poner tu nombre/tag)
-- Versión: 1.0

local Roact = require(script.Parent.Roact) -- Ajusta la ruta si es necesario

local Nyx = {}

-- Tema (fácil de personalizar)
Nyx.Theme = {
    Background = Color3.fromRGB(30, 30, 30),
    Primary = Color3.fromRGB(77, 77, 77),
    Accent = Color3.fromRGB(168, 162, 255),
    Success = Color3.fromRGB(97, 197, 97),
    Text = Color3.fromRGB(255, 255, 255),
    Input = Color3.fromRGB(48, 44, 67),
    Border = Color3.fromRGB(100, 100, 100),
}

-- Utilidad: Crear UICorner y UIStroke comunes
local function CornerStroke(props)
    return {
        UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 8) }),
        UIStroke = Roact.createElement("UIStroke", {
            Color = props.StrokeColor or Nyx.Theme.Border,
            Thickness = 1,
            Transparency = 0.7,
        })
    }
end

-- Ventana principal con barra de título y draggable (opcional)
function Nyx.Window(props)
    local draggable = props.Draggable ~= false

    return Roact.createElement("Frame", {
        Size = props.Size or UDim2.new(0, 500, 0, 400),
        Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Nyx.Theme.Primary,
        BackgroundTransparency = 0,
        ZIndex = props.ZIndex or 1,
    }, {
        CornerStroke(),
        
        TitleBar = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Nyx.Theme.Input,
            BackgroundTransparency = 0.3,
            ZIndex = 2,
        }, {
            CornerStroke(),
            Title = Roact.createElement("TextLabel", {
                Text = props.Title or "Nyx UI",
                Font = Enum.Font.Highway,
                TextColor3 = Nyx.Theme.Text,
                TextSize = 24,
                TextScaled = true,
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0, 60, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Icon = props.Icon and Roact.createElement("ImageLabel", {
                Image = props.Icon,
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(0, 10, 0.5, -20),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 96, 255),
            }),
            CloseButton = props.OnClose and Roact.createElement("ImageButton", {
                Size = UDim2.new(0, 35, 0, 35),
                Position = UDim2.new(1, -45, 0.5, -17.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031097225", -- X icon
                ZIndex = 3,
                [Roact.Event.MouseButton1Click] = props.OnClose,
            }, {
                Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 8) })
            })
        }),

        Content = Roact.createElement("Frame", {
            Size = UDim2.new(1, -20, 1, -70),
            Position = UDim2.new(0, 10, 0, 60),
            BackgroundTransparency = 1,
        }, props.Children)
    })
end

-- Input con label e icono
function Nyx.TextInput(props)
    return Roact.createElement("Frame", {
        Size = props.Size or UDim2.new(1, 0, 0, 40),
        Position = props.Position,
        BackgroundTransparency = 1,
    }, {
        Label = Roact.createElement("TextLabel", {
            Text = props.Label,
            Font = Enum.Font.Arial,
            TextColor3 = Nyx.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 40, 0, -20),
            BackgroundTransparency = 1,
        }),
        Box = Roact.createElement("TextBox", {
            PlaceholderText = props.Placeholder or "",
            Text = props.Text or "",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Nyx.Theme.Input,
            BackgroundTransparency = 0.2,
            TextColor3 = Nyx.Theme.Text,
            Font = Enum.Font.Arial,
            TextSize = 16,
            ClearTextOnFocus = true,
            [Roact.Change.Text] = props.OnTextChanged,
        }, {
            CornerStroke(),
            Icon = props.Icon and Roact.createElement("ImageLabel", {
                Image = props.Icon,
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(0, 8, 0.5, -15),
                BackgroundTransparency = 1,
                ImageTransparency = 0.3,
            })
        })
    })
end

-- Botón estilizado
function Nyx.Button(props)
    return Roact.createElement("TextButton", {
        Size = props.Size or UDim2.new(0, 140, 0, 40),
        Position = props.Position,
        BackgroundColor3 = props.Color or Nyx.Theme.Accent,
        Text = props.Text or "Button",
        Font = Enum.Font.SourceSansBold,
        TextColor3 = Nyx.Theme.Text,
        TextSize = 18,
        AutoButtonColor = false,
        [Roact.Event.MouseButton1Click] = props.OnClick,
    }, {
        CornerStroke(),
        Icon = props.Icon and Roact.createElement("ImageLabel", {
            Image = props.Icon,
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0, 10, 0.5, -14),
            BackgroundTransparency = 1,
        })
    })
end

-- Checkbox
function Nyx.Checkbox(props)
    local checked = props.Checked or false

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = props.Position,
        BackgroundTransparency = 1,
    }, {
        Button = Roact.createElement("TextButton", {
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundColor3 = checked and Nyx.Theme.Accent or Nyx.Theme.Input,
            [Roact.Event.MouseButton1Click] = props.OnToggle,
        }, {
            CornerStroke(),
            Check = Roact.createElement("ImageLabel", {
                Image = "rbxassetid://6031068425",
                Size = UDim2.new(1, -6, 1, -6),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Visible = checked,
            })
        }),
        Label = Roact.createElement("TextLabel", {
            Text = props.Text or "Option",
            TextColor3 = Nyx.Theme.Text,
            TextTransparency = checked and 0 or 0.4,
            Font = Enum.Font.Highway,
            TextSize = 16,
            Position = UDim2.new(0, 34, 0, 0),
            Size = UDim2.new(1, -34, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
    })
end

-- Grupo (Frame con título)
function Nyx.Group(props)
    return Roact.createElement("Frame", {
        Size = props.Size or UDim2.new(1, 0, 0, 200),
        Position = props.Position,
        BackgroundColor3 = Nyx.Theme.Background,
        BackgroundTransparency = 0.3,
    }, {
        CornerStroke(),
        Title = Roact.createElement("TextLabel", {
            Text = props.Title or "Group",
            Font = Enum.Font.GothamBold,
            TextColor3 = Nyx.Theme.Text,
            TextSize = 16,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Nyx.Theme.Accent,
            BackgroundTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Center,
        }, {
            Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 8) })
        }),
        Content = Roact.createElement("Frame", {
            Size = UDim2.new(1, -16, 1, -40),
            Position = UDim2.new(0, 8, 0, 35),
            BackgroundTransparency = 1,
        }, props.Children)
    })
end

-- Tabs (pestañas)
function Nyx.Tabs(props)
    local currentTab = props.CurrentTab or 1

    return Roact.createElement("Frame", {
        Size = props.Size or UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, {
        TabBar = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
        }, {
            List = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
            }),
            Tabs = Roact.createFragment(
                (function()
                    local tabs = {}
                    for i, tabName in ipairs(props.TabNames) do
                        tabs["Tab"..i] = Roact.createElement("TextButton", {
                            Text = tabName,
                            Size = UDim2.new(0, 120, 1, 0),
                            BackgroundColor3 = i == currentTab and Nyx.Theme.Accent or Nyx.Theme.Input,
                            TextColor3 = Nyx.Theme.Text,
                            Font = Enum.Font.SourceSansBold,
                            TextSize = 16,
                            [Roact.Event.MouseButton1Click] = function()
                                if props.OnTabChanged then props.OnTabChanged(i) end
                            end,
                        }, CornerStroke())
                    end
                    return tabs
                end)()
            )
        }),
        TabContent = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 1, -40),
            Position = UDim2.new(0, 0, 0, 40),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
        }, props.TabContents[currentTab] or {})
    })
end

return Nyx
