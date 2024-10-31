function format(tbl) 
    if tbl then
        local oldtbl = tbl
        local newtbl = {}
        local formattedtbl = {}

        for option, v in next, oldtbl do
            newtbl[option:lower()] = v
        end

        setmetatable(formattedtbl, {
            __newindex = function(t, k, v)
                rawset(newtbl, k:lower(), v)
            end,
            __index = function(t, k, v)
                return newtbl[k:lower()]
            end
        })

        return formattedtbl
    else
        return {}
    end
end

local dragutil = {}

function dragutil.Start(frame, dragpart, dspeed)
        local api = {connections = {}}
    spawn(function()
        local startPos
        local dragToggle = nil
        local dragSpeed = dspeed or .25
        local dragInput = nil
        local dragStart = nil
        local dragPos = nil

        function updateInput(input)
            Delta = input.Position - dragStart
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
            game:GetService("TweenService"):Create(frame, TweenInfo.new(.25), {Position = Position}):Play()
        end

        api.connections[1] = dragpart.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragToggle = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if (input.UserInputState == Enum.UserInputState.End) then
                        dragToggle = false
                    end
                end)
            end
        end)

        api.connections[2] = dragpart.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                dragInput = input
            end
        end)

        api.connections[3] = game:GetService("UserInputService").InputChanged:Connect(function(input)
            if (input == dragInput and dragToggle) then
                updateInput(input)
            end
        end)

        function api.End()
            for i,v in next, api.connections do 
                if v then 
                    v:Disconnect()
                end
            end
            connections = {}
        end
    end)
    return api
end
return format(dragutil)
