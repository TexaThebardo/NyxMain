-- ExampleTabbedUI.lua
-- Ejemplo avanzado usando NyxLibrary

local Roact = require(game.ReplicatedStorage.Libraries.Roact)
local Nyx = require(game.ReplicatedStorage.Libraries.NyxLibrary)

local TabbedUI = Roact.Component:extend("TabbedUI")

function TabbedUI:init()
    self:setState({
        currentTab = 1,
        toggle1 = false,
        toggle2 = true,
    })
end

function TabbedUI:render()
    local tabs = {"Home", "Player", "Settings"}

    local tabContents = {
        -- Tab 1: Home
        {
            Welcome = Roact.createElement("TextLabel", {
                Text = "Welcome to Nyx UI!",
                Font = Enum.Font.Highway,
                TextSize = 28,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Center,
            }),
            Info = Roact.createElement("TextLabel", {
                Text = "This is a modern UI library for Roblox exploits/scripts.",
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 16,
                Position = UDim2.new(0.5, 0, 0, 80),
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0.8, 0, 0, 100),
                BackgroundTransparency = 1,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Center,
            })
        },

        -- Tab 2: Player
        {
            Group1 = Roact.createElement(Nyx.Group, {
                Title = "Movement",
                Size = UDim2.new(1, 0, 0, 150),
                Position = UDim2.new(0, 0, 0, 10),
            }, {
                SpeedButton = Roact.createElement(Nyx.Button, {
                    Text = "Speed Hack",
                    Position = UDim2.new(0, 20, 0, 40),
                    OnClick = function() print("Speed activated") end
                }),
                JumpButton = Roact.createElement(Nyx.Button, {
                    Text = "Infinite Jump",
                    Position = UDim2.new(0.5, 10, 0, 40),
                    OnClick = function() print("Infinite Jump ON") end
                }),
                FlyToggle = Roact.createElement(Nyx.Checkbox, {
                    Text = "Fly Mode",
                    Position = UDim2.new(0, 20, 0, 100),
                    Checked = self.state.toggle1,
                    OnToggle = function()
                        self:setState({toggle1 = not self.state.toggle1})
                    end
                })
            }),

            Group2 = Roact.createElement(Nyx.Group, {
                Title = "Visuals",
                Size = UDim2.new(1, 0, 0, 120),
                Position = UDim2.new(0, 0, 0, 170),
            }, {
                ESPToggle = Roact.createElement(Nyx.Checkbox, {
                    Text = "ESP",
                    Position = UDim2.new(0, 20, 0, 40),
                    Checked = self.state.toggle2,
                    OnToggle = function()
                        self:setState({toggle2 = not self.state.toggle2})
                    end
                })
            })
        },

        -- Tab 3: Settings
        {
            ConfigGroup = Roact.createElement(Nyx.Group, {
                Title = "Configuration",
                Size = UDim2.new(1, 0, 0, 200),
            }, {
                KeyInput = Roact.createElement(Nyx.TextInput, {
                    Label = "Auth Key",
                    Position = UDim2.new(0, 20, 0, 40),
                }),
                SaveButton = Roact.createElement(Nyx.Button, {
                    Text = "Save Config",
                    Color = Color3.fromRGB(97, 197, 97),
                    Position = UDim2.new(0.5, -70, 0, 140),
                    OnClick = function() print("Config saved!") end
                })
            })
        }
    }

    return Roact.createElement(Nyx.Window, {
        Title = "N Y X",
        Size = UDim2.new(0, 600, 0, 500),
        Draggable = true,
        OnClose = function()
            Roact.unmount(self._handle)
        end
    }, {
        Tabs = Roact.createElement(Nyx.Tabs, {
            TabNames = tabs,
            CurrentTab = self.state.currentTab,
            TabContents = tabContents,
            OnTabChanged = function(index)
                self:setState({currentTab = index})
            end
        })
    })
end

return TabbedUI
