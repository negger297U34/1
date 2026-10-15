local cloneref = cloneref or function(object)
	return object
end

local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Lighting = cloneref(game:GetService("Lighting"))
local LocalPlayer = Players.LocalPlayer

local Library = {
	Name = "Commission",
	Folder = "Commission",
	Flags = {},
	Options = {},
	Toggles = {},
	Connections = {},
	Windows = {},
	Unloaded = false,
	Open = true,
	ToggleKey = Enum.KeyCode.RightShift,
	Scale = 1,
	UserScale = 1,
	BlurEnabled = true,
	GlowEnabled = true,
	FontName = "Gotham",
	Statuses = {},
	OnUnload = {},
}

local Theme = {
	Accent = Color3.fromHex("B40250"),
	Glow = Color3.fromHex("B40250"),
	Sidebar = Color3.fromRGB(5, 5, 7),
	SidebarTab = Color3.fromRGB(17, 17, 20),
	Content = Color3.fromRGB(12, 12, 15),
	Groupbox = Color3.fromRGB(17, 17, 21),
	Element = Color3.fromRGB(25, 25, 30),
	ElementHover = Color3.fromRGB(33, 33, 39),
	Border = Color3.fromRGB(38, 38, 45),
	Text = Color3.fromRGB(236, 236, 242),
	SubText = Color3.fromRGB(150, 150, 162),
	Disabled = Color3.fromRGB(88, 88, 98),
	Risky = Color3.fromRGB(255, 82, 96),
	Popup = Color3.fromRGB(16, 16, 20),
}
Library.Theme = Theme

Library.ThemeZones = {
	{ "Accent", "Accent" },
	{ "Glow", "Window Glow" },
	{ "Sidebar", "Sidebar" },
	{ "SidebarTab", "Sidebar Tabs" },
	{ "Content", "Content" },
	{ "Groupbox", "Groupbox" },
	{ "Element", "Elements" },
	{ "ElementHover", "Element Hover" },
	{ "Border", "Borders" },
	{ "Text", "Text" },
	{ "SubText", "Dim Text" },
	{ "Risky", "Risky" },
}

Library.ThemePresets = {
	["Chrome Pink"] = { Accent = "B40250", Glow = "B40250" },
	["Crimson"] = { Accent = "D1263B", Glow = "D1263B" },
	["Violet"] = { Accent = "7B3FE4", Glow = "7B3FE4" },
	["Ocean"] = { Accent = "1E88E5", Glow = "1E88E5" },
	["Emerald"] = { Accent = "13A86B", Glow = "13A86B" },
	["Amber"] = { Accent = "E8930C", Glow = "E8930C" },
	["Ice"] = { Accent = "8FD3FF", Glow = "8FD3FF" },
	["Mono"] = { Accent = "E6E6EA", Glow = "E6E6EA" },
}

local FONT_FAMILIES = {
	Gotham = "rbxasset://fonts/families/GothamSSm.json",
	Builder = "rbxasset://fonts/families/BuilderSans.json",
	Roboto = "rbxasset://fonts/families/Roboto.json",
	Montserrat = "rbxasset://fonts/families/Montserrat.json",
	["Source Sans"] = "rbxasset://fonts/families/SourceSansPro.json",
	Ubuntu = "rbxasset://fonts/families/Ubuntu.json",
	["Roboto Mono"] = "rbxasset://fonts/families/RobotoMono.json",
}
Library.Fonts = { "Gotham", "Builder", "Roboto", "Montserrat", "Source Sans", "Ubuntu", "Roboto Mono" }

local Themed = setmetatable({}, { __mode = "k" })
local FontObjects = setmetatable({}, { __mode = "k" })
local ThemeHooks = {}

local function font(weight)
	return Font.new(FONT_FAMILIES[Library.FontName] or FONT_FAMILIES.Gotham, weight or Enum.FontWeight.Regular)
end

local function create(class, props)
	local inst = Instance.new(class)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	local parent = props.Parent
	props.Parent = nil
	for key, value in pairs(props) do
		inst[key] = value
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function paint(inst, map)
	Themed[inst] = map
	for prop, key in pairs(map) do
		inst[prop] = Theme[key]
	end
	return inst
end

local function onTheme(fn)
	table.insert(ThemeHooks, fn)
	fn()
	return fn
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = radius == "full" and UDim.new(1, 0) or UDim.new(0, radius or 6), Parent = parent })
end

local function stroke(parent, key, transparency, thickness)
	local s = create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		Parent = parent,
	})
	paint(s, { Color = key or "Border" })
	return s
end

local function padding(parent, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		Parent = parent,
	})
end

local function list(parent, gap, direction, halign, valign)
	return create("UIListLayout", {
		Padding = UDim.new(0, gap or 0),
		FillDirection = direction or Enum.FillDirection.Vertical,
		HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent,
	})
end

local function text(props)
	local class = props.Class or "TextLabel"
	props.Class = nil
	local weight = props.Weight or Enum.FontWeight.Regular
	props.Weight = nil
	local colorKey = props.ColorKey or "Text"
	props.ColorKey = nil
	props.BackgroundTransparency = props.BackgroundTransparency or 1
	props.TextSize = props.TextSize or 14
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.FontFace = font(weight)
	local inst = create(class, props)
	FontObjects[inst] = weight
	if colorKey ~= false then
		paint(inst, { TextColor3 = colorKey })
	end
	return inst
end

local function tween(inst, props, duration, style)
	local t = TweenService:Create(inst, TweenInfo.new(duration or 0.15, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function connect(signal, fn)
	local conn = signal:Connect(fn)
	table.insert(Library.Connections, conn)
	return conn
end

local function textWidth(str, size, weight)
	local ok, bounds = pcall(function()
		local params = Instance.new("GetTextBoundsParams")
		params.Text = str
		params.Font = font(weight)
		params.Size = size
		params.Width = 10000
		return TextService:GetTextBoundsAsync(params)
	end)
	if ok and bounds then
		return bounds.X
	end
	return #str * size * 0.55
end

local Icons = nil
do
	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua"))()
	end)
	if ok and type(result) == "table" then
		Icons = result
	end
end

local function decodeBase64(data)
	if type(crypt) == "table" and type(crypt.base64decode) == "function" then
		local ok, out = pcall(crypt.base64decode, data)
		if ok and type(out) == "string" and #out > 0 then
			return out
		end
	end
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local map = {}
	for index = 1, 64 do
		map[alphabet:sub(index, index)] = index - 1
	end
	data = data:gsub("[^%w%+/=]", "")
	local out, bits, count = {}, 0, 0
	for index = 1, #data do
		local char = data:sub(index, index)
		if char == "=" then
			break
		end
		bits = bits * 64 + map[char]
		count += 6
		if count >= 8 then
			count -= 8
			table.insert(out, string.char(math.floor(bits / 2 ^ count) % 256))
			bits = bits % 2 ^ count
		end
	end
	return table.concat(out)
end

function Library:LoadImage(source, name)
	if type(source) ~= "string" or source == "" then
		return nil
	end
	if source:find("^rbx") then
		return source
	end
	if type(writefile) ~= "function" or type(getcustomasset) ~= "function" then
		return nil
	end
	pcall(function()
		if not isfolder(Library.Folder) then
			makefolder(Library.Folder)
		end
		if not isfolder(Library.Folder .. "/assets") then
			makefolder(Library.Folder .. "/assets")
		end
	end)
	local path
	if source:find("^https?://") then
		local file = (source:match("([^/%?#]+)$") or tostring(#source)):gsub("[^%w%._%-]", "")
		path = Library.Folder .. "/assets/" .. file
		if not (isfile and isfile(path)) then
			local ok, body = pcall(function()
				return game:HttpGet(source)
			end)
			if not ok or type(body) ~= "string" or #body == 0 then
				return nil
			end
			writefile(path, body)
		end
	elseif #source < 260 and isfile and isfile(source) then
		path = source
	else
		path = Library.Folder .. "/assets/" .. (name or "image") .. "_" .. tostring(#source) .. (source:sub(1, 4) == "/9j/" and ".jpg" or ".png")
		if not (isfile and isfile(path)) then
			writefile(path, decodeBase64(source))
		end
	end
	local ok, asset = pcall(getcustomasset, path)
	if ok and type(asset) == "string" then
		return asset
	end
	return nil
end

local function applyIcon(image, name)
	if type(name) ~= "string" or name == "" then
		return false
	end
	if name:find("rbxasset", 1, true) or name:find("rbxthumb", 1, true) or name:find("http", 1, true) then
		image.Image = Library:LoadImage(name, "icon") or name
		return true
	end
	if not Icons then
		return false
	end
	local ok, asset = pcall(Icons.GetAsset, name)
	if ok and asset then
		image.Image = asset.Url
		image.ImageRectSize = asset.ImageRectSize
		image.ImageRectOffset = asset.ImageRectOffset
		return true
	end
	return false
end

local function icon(name, size, colorKey, props)
	props = props or {}
	props.BackgroundTransparency = 1
	props.Size = props.Size or UDim2.fromOffset(size, size)
	props.ScaleType = Enum.ScaleType.Fit
	local image = create("ImageLabel", props)
	paint(image, { ImageColor3 = colorKey or "Text" })
	if not applyIcon(image, name) then
		image.Visible = false
	end
	return image
end

local function guiParent()
	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and hui then
		return hui
	end
	local okCore, core = pcall(function()
		return cloneref(game:GetService("CoreGui"))
	end)
	if okCore and core then
		return core
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function newGui(name, order)
	local gui = create("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = order,
	})
	pcall(function()
		if protect_gui then
			protect_gui(gui)
		elseif syn and syn.protect_gui then
			syn.protect_gui(gui)
		end
	end)
	local ok = pcall(function()
		gui.Parent = guiParent()
	end)
	if not ok or not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	return gui
end

Library.Gui = newGui("CommissionUI", 100)
Library.HudGui = newGui("CommissionHUD", 95)
Library.PopupGui = newGui("CommissionPopups", 110)
Library.PopupRoot = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = Library.PopupGui })

local ScaleObjects = {}
local function scaled(frame)
	local scale = create("UIScale", { Scale = Library.Scale, Parent = frame })
	table.insert(ScaleObjects, scale)
	return scale
end

function Library:SetScale(value)
	Library.Scale = value
	for _, scale in ipairs(ScaleObjects) do
		if scale.Parent then
			scale.Scale = value
		end
	end
end

local function refreshScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local fit = math.min((viewport.X - 24) / 820, (viewport.Y - 24) / 560)
	Library:SetScale(math.clamp(math.min(fit, 1) * Library.UserScale, 0.4, 2))
end

function Library:SetUserScale(value)
	Library.UserScale = math.clamp(tonumber(value) or 1, 0.5, 1.6)
	refreshScale()
end

function Library:SetThemeColor(key, color)
	if typeof(color) ~= "Color3" then
		return
	end
	Theme[key] = color
	for inst, map in pairs(Themed) do
		for prop, k in pairs(map) do
			if k == key then
				pcall(function()
					inst[prop] = color
				end)
			end
		end
	end
	for _, fn in ipairs(ThemeHooks) do
		pcall(fn)
	end
end

function Library:SetFont(name)
	if not FONT_FAMILIES[name] then
		return
	end
	Library.FontName = name
	for inst, weight in pairs(FontObjects) do
		pcall(function()
			inst.FontFace = font(weight)
		end)
	end
end

function Library:ApplyPreset(name)
	local preset = Library.ThemePresets[name]
	if not preset then
		return false
	end
	for key, hex in pairs(preset) do
		local ok, color = pcall(Color3.fromHex, hex)
		if ok then
			Library:SetThemeColor(key, color)
		end
	end
	return true
end

local function makeDraggable(handle, target, onClick)
	local dragging, startInput, startPos, moved = false, nil, nil, 0
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = 0
			startInput = input.Position
			startPos = target.Position
			local changed
			changed = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					changed:Disconnect()
					if onClick and moved < 6 then
						onClick()
					end
				end
			end)
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - startInput
		moved = math.max(moved, delta.Magnitude)
		target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end)
end

local function hover(target, onEnter, onLeave)
	target.MouseEnter:Connect(onEnter)
	target.MouseLeave:Connect(onLeave)
end

local Tooltip = nil
local function attachTooltip(target, message)
	if type(message) ~= "string" or message == "" then
		return
	end
	local inside = false
	target.MouseEnter:Connect(function()
		inside = true
		task.delay(0.35, function()
			if not inside or not target.Parent then
				return
			end
			if Tooltip then
				Tooltip:Destroy()
			end
			local mouse = UserInputService:GetMouseLocation()
			Tooltip = create("Frame", {
				Position = UDim2.fromOffset(mouse.X + 14, mouse.Y + 6),
				Size = UDim2.fromOffset(0, 26),
				AutomaticSize = Enum.AutomaticSize.X,
				ZIndex = 50,
				Parent = Library.PopupRoot,
			})
			paint(Tooltip, { BackgroundColor3 = "Popup" })
			corner(Tooltip, 5)
			stroke(Tooltip, "Accent", 0.4)
			padding(Tooltip, 9, 9, 0, 0)
			scaled(Tooltip)
			text({ Text = message, TextSize = 13, ColorKey = "SubText", Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 51, Parent = Tooltip })
		end)
	end)
	target.MouseLeave:Connect(function()
		inside = false
		if Tooltip then
			Tooltip:Destroy()
			Tooltip = nil
		end
	end)
end

local Popup = { frame = nil, blocker = nil, onClose = nil }

local function closePopup()
	local onClose = Popup.onClose
	if Popup.frame then
		Popup.frame:Destroy()
	end
	if Popup.blocker then
		Popup.blocker:Destroy()
	end
	Popup.frame, Popup.blocker, Popup.onClose = nil, nil, nil
	if onClose then
		pcall(onClose)
	end
end
Library.ClosePopup = closePopup

local function openPopup(owner, width, height, onClose, alignRight)
	closePopup()
	local root = Library.PopupRoot
	local blocker = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 20,
		Parent = root,
	})
	blocker.MouseButton1Click:Connect(closePopup)
	local abs = owner.AbsolutePosition - root.AbsolutePosition
	local size = owner.AbsoluteSize
	local view = root.AbsoluteSize
	local s = Library.Scale
	local x = alignRight and (abs.X + size.X - width * s) or abs.X
	local y = abs.Y + size.Y + 4 * s
	if x + width * s > view.X - 6 then
		x = view.X - width * s - 6
	end
	if y + height * s > view.Y - 6 then
		y = abs.Y - height * s - 4 * s
	end
	local frame = create("Frame", {
		Position = UDim2.fromOffset(math.floor(math.max(x, 6)), math.floor(math.max(y, 6))),
		Size = UDim2.fromOffset(width, height),
		ZIndex = 21,
		Parent = root,
	})
	paint(frame, { BackgroundColor3 = "Popup" })
	corner(frame, 6)
	stroke(frame, "Border")
	scaled(frame)
	Popup.frame, Popup.blocker, Popup.onClose = frame, blocker, onClose
	return frame
end

local function keyName(value)
	if typeof(value) == "EnumItem" then
		if value == Enum.UserInputType.MouseButton1 then
			return "MB1"
		elseif value == Enum.UserInputType.MouseButton2 then
			return "MB2"
		elseif value == Enum.UserInputType.MouseButton3 then
			return "MB3"
		end
		return value.Name
	end
	return tostring(value)
end

local function inputMatches(input, value)
	if value == nil or value == "None" then
		return false
	end
	if value == "MB1" then
		return input.UserInputType == Enum.UserInputType.MouseButton1
	elseif value == "MB2" then
		return input.UserInputType == Enum.UserInputType.MouseButton2
	elseif value == "MB3" then
		return input.UserInputType == Enum.UserInputType.MouseButton3
	end
	return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == value
end

local function fireChanged(obj, value)
	for _, fn in ipairs(obj.Changed) do
		task.spawn(fn, value)
	end
	if obj.Callback then
		task.spawn(obj.Callback, value)
	end
end

local ActiveList = { frame = nil, holder = nil, rows = {} }
local KeybindList = { frame = nil, holder = nil, rows = {} }
local refreshHudLists

local function softGlow(target, radius, layers, strength)
	local holder = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = target.ZIndex, Parent = target })
	for index = 1, layers do
		local ring = create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(-index, -index),
			Size = UDim2.new(1, index * 2, 1, index * 2),
			ZIndex = target.ZIndex,
			Parent = holder,
		})
		create("UICorner", { CornerRadius = UDim.new(0, radius + index), Parent = ring })
		local fade = 1 - (index - 1) / layers
		local s = create("UIStroke", { Transparency = 1 - strength * fade * fade, Thickness = 1, Parent = ring })
		paint(s, { Color = "Accent" })
	end
	return holder
end

local function addKeyPicker(owner, flag, opts)
	opts = opts or {}
	local picker = {
		Type = "KeyPicker",
		Value = opts.Default or "None",
		Mode = opts.Mode or "Toggle",
		Text = opts.Text or owner.Text or flag,
		Changed = {},
		Callback = opts.Callback,
		Listening = false,
		Owner = owner,
		Held = false,
	}
	local button = text({
		Class = "TextButton",
		Text = "",
		TextSize = 12,
		ColorKey = "SubText",
		TextXAlignment = Enum.TextXAlignment.Center,
		AutoButtonColor = false,
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 1,
		Parent = owner.Right,
	})
	paint(button, { BackgroundColor3 = "Element" })
	corner(button, 4)
	stroke(button, "Border")
	padding(button, 8, 8, 0, 0)
	create("UISizeConstraint", { MinSize = Vector2.new(26, 20), Parent = button })
	picker.Button = button

	local function render()
		button.Text = picker.Listening and "..." or (picker.Value == "None" and "-" or picker.Value)
	end

	function picker:SetValue(value, mode)
		if type(value) == "table" then
			mode = value.Mode or mode
			value = value.Key or value[1]
		end
		picker.Value = value or "None"
		if mode then
			picker.Mode = mode
		end
		Library.Flags[flag] = { Key = picker.Value, Mode = picker.Mode }
		render()
		fireChanged(picker, picker.Value)
		if refreshHudLists then
			refreshHudLists()
		end
	end

	function picker:OnChanged(fn)
		table.insert(picker.Changed, fn)
	end

	function picker:GetState()
		if picker.Mode == "Always" then
			return true
		elseif picker.Mode == "Hold" then
			return picker.Held
		end
		return owner.Type == "Toggle" and owner.Value or false
	end

	button.MouseButton1Click:Connect(function()
		if picker.Listening then
			return
		end
		picker.Listening = true
		render()
		task.wait(0.12)
		local conn
		conn = UserInputService.InputBegan:Connect(function(input)
			local value
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					value = "None"
				else
					value = input.KeyCode.Name
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3 then
				value = keyName(input.UserInputType)
			end
			if value then
				conn:Disconnect()
				picker.Listening = false
				picker:SetValue(value)
			end
		end)
	end)

	button.MouseButton2Click:Connect(function()
		local frame = openPopup(button, 110, 3 * 28 + 8, nil, true)
		padding(frame, 4, 4, 4, 4)
		list(frame, 0)
		for index, mode in ipairs({ "Toggle", "Hold", "Always" }) do
			local option = text({
				Class = "TextButton",
				Text = mode,
				TextSize = 13,
				ColorKey = picker.Mode == mode and "Accent" or "SubText",
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 28),
				LayoutOrder = index,
				ZIndex = 22,
				Parent = frame,
			})
			padding(option, 8, 8, 0, 0)
			option.MouseButton1Click:Connect(function()
				picker.Mode = mode
				Library.Flags[flag] = { Key = picker.Value, Mode = picker.Mode }
				closePopup()
				if mode == "Always" and owner.Type == "Toggle" then
					owner:SetValue(true)
				end
				if refreshHudLists then
					refreshHudLists()
				end
			end)
		end
	end)

	connect(UserInputService.InputBegan, function(input, processed)
		if picker.Listening or UserInputService:GetFocusedTextBox() then
			return
		end
		if not inputMatches(input, picker.Value) then
			return
		end
		if processed and input.UserInputType == Enum.UserInputType.Keyboard then
			return
		end
		picker.Held = true
		if owner.Type == "Toggle" and not owner.Disabled then
			if picker.Mode == "Hold" then
				owner:SetValue(true)
			elseif picker.Mode == "Toggle" then
				owner:SetValue(not owner.Value)
			end
		end
		if opts.Pressed then
			task.spawn(opts.Pressed)
		end
		if refreshHudLists then
			refreshHudLists()
		end
	end)

	connect(UserInputService.InputEnded, function(input)
		if inputMatches(input, picker.Value) then
			picker.Held = false
			if picker.Mode == "Hold" and owner.Type == "Toggle" then
				owner:SetValue(false)
			end
			if refreshHudLists then
				refreshHudLists()
			end
		end
	end)

	Library.Flags[flag] = { Key = picker.Value, Mode = picker.Mode }
	Library.Options[flag] = picker
	owner.KeyPicker = picker
	render()
	return picker
end

local Rainbow = { objects = {}, conn = nil }
local function rainbowSync()
	local any = false
	for picker in pairs(Rainbow.objects) do
		if picker.Rainbow then
			any = true
		else
			Rainbow.objects[picker] = nil
		end
	end
	if any and not Rainbow.conn then
		Rainbow.conn = RunService.Heartbeat:Connect(function()
			local hue = (os.clock() * 0.12) % 1
			for picker in pairs(Rainbow.objects) do
				local _, s, v = picker.Value:ToHSV()
				picker:SetValueRGB(Color3.fromHSV((hue + (picker.RainbowOffset or 0)) % 1, math.max(s, 0.6), math.max(v, 0.6)), picker.Alpha, true)
			end
		end)
	elseif not any and Rainbow.conn then
		Rainbow.conn:Disconnect()
		Rainbow.conn = nil
	end
end

local function addColorPicker(owner, flag, opts)
	opts = opts or {}
	local picker = {
		Type = "ColorPicker",
		Value = opts.Default or Color3.new(1, 1, 1),
		Alpha = opts.Transparency or 0,
		Default = opts.Default or Color3.new(1, 1, 1),
		DefaultAlpha = opts.Transparency or 0,
		Rainbow = false,
		Changed = {},
		Callback = opts.Callback,
		Title = opts.Title or owner.Text or "Color",
	}
	local swatch = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = picker.Value,
		Size = UDim2.fromOffset(24, 16),
		LayoutOrder = 2,
		Parent = owner.Right,
	})
	corner(swatch, 4)
	stroke(swatch, "Border")
	picker.Swatch = swatch

	function picker:SetValueRGB(color, alpha, silentRainbow)
		picker.Value = color
		if alpha ~= nil then
			picker.Alpha = math.clamp(alpha, 0, 1)
		end
		swatch.BackgroundColor3 = color
		swatch.BackgroundTransparency = picker.Alpha * 0.8
		Library.Flags[flag] = { Color = color:ToHex(), Alpha = picker.Alpha, Rainbow = picker.Rainbow }
		fireChanged(picker, color)
		if picker.Refresh and not silentRainbow then
			picker.Refresh()
		elseif picker.Refresh then
			picker.Refresh(true)
		end
	end
	function picker:SetValue(value, alpha)
		if type(value) == "table" then
			local ok, color = pcall(Color3.fromHex, tostring(value.Color or "FFFFFF"))
			picker.Rainbow = value.Rainbow == true
			if picker.Rainbow then
				Rainbow.objects[picker] = true
			end
			rainbowSync()
			picker:SetValueRGB(ok and color or picker.Value, tonumber(value.Alpha) or 0)
			return
		end
		picker:SetValueRGB(value, alpha)
	end
	function picker:SetRainbow(state)
		picker.Rainbow = state == true
		if picker.Rainbow then
			Rainbow.objects[picker] = true
		end
		rainbowSync()
		Library.Flags[flag] = { Color = picker.Value:ToHex(), Alpha = picker.Alpha, Rainbow = picker.Rainbow }
	end
	function picker:OnChanged(fn)
		table.insert(picker.Changed, fn)
	end

	swatch.MouseButton1Click:Connect(function()
		local frame = openPopup(swatch, 226, 286, function()
			picker.Refresh = nil
		end, true)
		local h, s, v = picker.Value:ToHSV()
		text({ Text = picker.Title, TextSize = 13, Weight = Enum.FontWeight.SemiBold, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 18), ZIndex = 22, Parent = frame })
		local sv = create("TextButton", { Text = "", AutoButtonColor = false, Position = UDim2.fromOffset(10, 30), Size = UDim2.fromOffset(170, 150), ZIndex = 22, Parent = frame })
		corner(sv, 4)
		local white = create("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), ZIndex = 23, Parent = sv })
		corner(white, 4)
		create("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
		local black = create("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), ZIndex = 24, Parent = sv })
		corner(black, 4)
		create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
		local cursor = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Size = UDim2.fromOffset(10, 10), ZIndex = 25, Parent = sv })
		corner(cursor, "full")
		create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = cursor })
		local hue = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.fromOffset(188, 30), Size = UDim2.fromOffset(12, 150), ZIndex = 22, Parent = frame })
		corner(hue, 4)
		local keys = {}
		for index = 0, 6 do
			table.insert(keys, ColorSequenceKeypoint.new(index / 6, Color3.fromHSV(index / 6, 1, 1)))
		end
		create("UIGradient", { Rotation = 90, Color = ColorSequence.new(keys), Parent = hue })
		local hueCursor = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1, 0, 0, 2), ZIndex = 23, Parent = hue })
		local alphaBar = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = picker.Value, Position = UDim2.fromOffset(206, 30), Size = UDim2.fromOffset(12, 150), ZIndex = 22, Parent = frame })
		corner(alphaBar, 4)
		local alphaGradient = create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0, 1), Parent = alphaBar })
		local alphaCursor = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1, 0, 0, 2), ZIndex = 23, Parent = alphaBar })
		local hex = text({ Class = "TextBox", Text = "", TextSize = 13, ClearTextOnFocus = false, BackgroundTransparency = 0, Position = UDim2.fromOffset(10, 188), Size = UDim2.fromOffset(120, 24), ZIndex = 22, Parent = frame })
		paint(hex, { BackgroundColor3 = "Element" })
		corner(hex, 4)
		padding(hex, 8, 8, 0, 0)
		local alphaBox = text({ Class = "TextBox", Text = "", TextSize = 13, ClearTextOnFocus = false, BackgroundTransparency = 0, Position = UDim2.fromOffset(136, 188), Size = UDim2.fromOffset(80, 24), ZIndex = 22, Parent = frame })
		paint(alphaBox, { BackgroundColor3 = "Element" })
		corner(alphaBox, 4)
		padding(alphaBox, 8, 8, 0, 0)
		local row = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 220), Size = UDim2.new(1, -20, 0, 24), ZIndex = 22, Parent = frame })
		list(row, 6, Enum.FillDirection.Horizontal)
		local function smallButton(label, order, fn)
			local b = text({ Class = "TextButton", Text = label, TextSize = 12, ColorKey = "SubText", TextXAlignment = Enum.TextXAlignment.Center, AutoButtonColor = false, BackgroundTransparency = 0, Size = UDim2.new(1 / 3, -4, 1, 0), LayoutOrder = order, ZIndex = 22, Parent = row })
			paint(b, { BackgroundColor3 = "Element" })
			corner(b, 4)
			b.MouseButton1Click:Connect(fn)
			return b
		end
		local rainbowRow = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 252), Size = UDim2.new(1, -20, 0, 24), ZIndex = 22, Parent = frame })
		local rainbowBox = create("Frame", { Position = UDim2.fromOffset(0, 4), Size = UDim2.fromOffset(16, 16), ZIndex = 23, Parent = rainbowRow })
		corner(rainbowBox, 4)
		stroke(rainbowBox, "Border")
		text({ Text = "Rainbow / animated", TextSize = 13, ColorKey = "SubText", Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -24, 1, 0), ZIndex = 23, Parent = rainbowRow })

		local function refresh(fromRainbow)
			if fromRainbow then
				h, s, v = picker.Value:ToHSV()
			end
			sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			cursor.Position = UDim2.fromScale(s, 1 - v)
			hueCursor.Position = UDim2.fromScale(0, h)
			alphaCursor.Position = UDim2.fromScale(0, picker.Alpha)
			alphaBar.BackgroundColor3 = picker.Value
			alphaGradient.Transparency = NumberSequence.new(0, 1)
			if not hex:IsFocused() then
				hex.Text = "#" .. picker.Value:ToHex()
			end
			if not alphaBox:IsFocused() then
				alphaBox.Text = string.format("%d%%", math.floor((1 - picker.Alpha) * 100 + 0.5))
			end
			rainbowBox.BackgroundColor3 = picker.Rainbow and Theme.Accent or Theme.Element
		end
		picker.Refresh = refresh
		refresh()

		local mode = nil
		local function update(position)
			if mode == "sv" then
				s = math.clamp((position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
				v = 1 - math.clamp((position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
			elseif mode == "hue" then
				h = math.clamp((position.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
			elseif mode == "alpha" then
				picker.Alpha = math.clamp((position.Y - alphaBar.AbsolutePosition.Y) / alphaBar.AbsoluteSize.Y, 0, 1)
			end
			picker:SetValueRGB(Color3.fromHSV(h, s, v), picker.Alpha)
		end
		local function begin(kind)
			return function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					mode = kind
					update(input.Position)
				end
			end
		end
		sv.InputBegan:Connect(begin("sv"))
		hue.InputBegan:Connect(begin("hue"))
		alphaBar.InputBegan:Connect(begin("alpha"))
		local moveConn = UserInputService.InputChanged:Connect(function(input)
			if mode and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input.Position)
			end
		end)
		local endConn = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				mode = nil
			end
		end)
		frame.Destroying:Connect(function()
			moveConn:Disconnect()
			endConn:Disconnect()
		end)
		hex.FocusLost:Connect(function()
			local ok, color = pcall(Color3.fromHex, (hex.Text:gsub("#", "")))
			if ok and color then
				h, s, v = color:ToHSV()
				picker:SetValueRGB(color, picker.Alpha)
			end
			refresh()
		end)
		alphaBox.FocusLost:Connect(function()
			local number = tonumber((alphaBox.Text:gsub("%%", "")))
			if number then
				picker:SetValueRGB(picker.Value, 1 - math.clamp(number, 0, 100) / 100)
			end
			refresh()
		end)
		smallButton("Copy", 1, function()
			Library.ColorClipboard = { picker.Value, picker.Alpha }
			pcall(function()
				setclipboard("#" .. picker.Value:ToHex())
			end)
		end)
		smallButton("Paste", 2, function()
			local clip = Library.ColorClipboard
			if clip then
				h, s, v = clip[1]:ToHSV()
				picker:SetValueRGB(clip[1], clip[2])
			end
		end)
		smallButton("Reset", 3, function()
			picker:SetRainbow(false)
			h, s, v = picker.Default:ToHSV()
			picker:SetValueRGB(picker.Default, picker.DefaultAlpha)
		end)
		rainbowRow.MouseButton1Click:Connect(function()
			picker:SetRainbow(not picker.Rainbow)
			refresh()
		end)
	end)

	Library.Flags[flag] = { Color = picker.Value:ToHex(), Alpha = picker.Alpha, Rainbow = false }
	Library.Options[flag] = picker
	swatch.BackgroundTransparency = picker.Alpha * 0.8
	return picker
end

local Container = {}
Container.__index = Container

function Container:_row(height, searchText)
	self.Order = (self.Order or 0) + 1
	local row = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height),
		LayoutOrder = self.Order,
		Parent = self.Holder,
	})
	if self.Page and searchText then
		table.insert(self.Page.Searchables, { Frame = row, Text = string.lower(searchText), Box = self })
	end
	return row
end

local function highlightRow(row)
	local glow = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(-6, 0),
		Size = UDim2.new(1, 12, 1, 0),
		ZIndex = 0,
		Parent = row,
	})
	paint(glow, { BackgroundColor3 = "ElementHover" })
	corner(glow, 5)
	hover(row, function()
		tween(glow, { BackgroundTransparency = 0.55 }, 0.12)
	end, function()
		tween(glow, { BackgroundTransparency = 1 }, 0.18)
	end)
	return glow
end

local function rightSlot(row)
	local right = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 3,
		Parent = row,
	})
	list(right, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	return right
end

local function addonMethods(obj)
	function obj:AddKeyPicker(flag, opts)
		addKeyPicker(obj, flag, opts)
		return obj
	end
	function obj:AddColorPicker(flag, opts)
		addColorPicker(obj, flag, opts)
		return obj
	end
end

function Container:AddToggle(flag, opts)
	opts = opts or {}
	local row = self:_row(34, opts.Text)
	highlightRow(row)
	local toggle = {
		Type = "Toggle",
		Value = false,
		Text = opts.Text or flag,
		Disabled = opts.Disabled == true,
		Risky = opts.Risky == true,
		Changed = {},
		Callback = opts.Callback,
		Row = row,
	}
	local hit = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = row })
	local box = create("Frame", { Position = UDim2.fromOffset(0, 8), Size = UDim2.fromOffset(18, 18), ZIndex = 2, Parent = row })
	corner(box, 4)
	local boxStroke = stroke(box, "Border")
	local boxGlow = softGlow(box, 4, 3, 0.25)
	local check = icon("check", 12, "Text", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 3, Parent = box })
	local label = text({
		Text = toggle.Text,
		ColorKey = toggle.Disabled and "Disabled" or (toggle.Risky and "Risky" or "Text"),
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -110, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
		Parent = row,
	})
	toggle.Label = label
	toggle.Right = rightSlot(row)
	attachTooltip(hit, opts.Tooltip)

	local function render()
		box.BackgroundColor3 = toggle.Value and Theme.Accent or Theme.Element
		boxStroke.Color = toggle.Value and Theme.Accent or Theme.Border
		boxGlow.Visible = toggle.Value
		check.Visible = toggle.Value
		box.BackgroundTransparency = toggle.Disabled and 0.5 or 0
	end
	onTheme(render)

	function toggle:SetValue(value)
		value = value == true
		if toggle.Value == value and toggle.Ready then
			return
		end
		toggle.Value = value
		Library.Flags[flag] = value
		render()
		fireChanged(toggle, value)
		if refreshHudLists then
			refreshHudLists()
		end
	end
	function toggle:OnChanged(fn)
		table.insert(toggle.Changed, fn)
	end
	function toggle:SetDisabled(value)
		toggle.Disabled = value == true
		paint(label, { TextColor3 = toggle.Disabled and "Disabled" or (toggle.Risky and "Risky" or "Text") })
		render()
	end
	function toggle:SetVisible(value)
		row.Visible = value
	end
	function toggle:SetText(value)
		toggle.Text = value
		label.Text = value
	end
	addonMethods(toggle)

	hit.MouseButton1Click:Connect(function()
		if not toggle.Disabled then
			toggle:SetValue(not toggle.Value)
		end
	end)

	toggle.Value = opts.Default == true
	Library.Flags[flag] = toggle.Value
	render()
	toggle.Ready = true
	Library.Toggles[flag] = toggle
	Library.Options[flag] = toggle
	return toggle
end

function Container:AddButtons(buttons)
	local names = {}
	for _, item in ipairs(buttons) do
		table.insert(names, item.Text or "")
	end
	local row = self:_row(40, table.concat(names, " "))
	local holder = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 32), Parent = row })
	list(holder, 8, Enum.FillDirection.Horizontal)
	local count = #buttons
	local result = { Buttons = {} }
	for index, item in ipairs(buttons) do
		local button = text({
			Class = "TextButton",
			Text = item.Text or "",
			Weight = Enum.FontWeight.Medium,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AutoButtonColor = false,
			BackgroundTransparency = 0,
			Size = UDim2.new(1 / count, -(8 * (count - 1)) / count, 1, 0),
			LayoutOrder = index,
			Parent = holder,
		})
		paint(button, { BackgroundColor3 = "Element" })
		corner(button, 5)
		local s = stroke(button, "Border")
		hover(button, function()
			tween(button, { BackgroundColor3 = Theme.ElementHover }, 0.12)
			s.Color = Theme.Accent
		end, function()
			tween(button, { BackgroundColor3 = Theme.Element }, 0.15)
			s.Color = Theme.Border
		end)
		button.MouseButton1Click:Connect(function()
			tween(button, { BackgroundColor3 = Theme.Accent }, 0.05)
			task.delay(0.12, function()
				tween(button, { BackgroundColor3 = Theme.ElementHover }, 0.2)
			end)
			if item.Func then
				task.spawn(item.Func)
			end
		end)
		attachTooltip(button, item.Tooltip)
		result.Buttons[index] = button
	end
	function result:SetVisible(value)
		row.Visible = value
	end
	return result
end

function Container:AddButton(textOrOpts, func)
	local opts = type(textOrOpts) == "table" and textOrOpts or { Text = textOrOpts, Func = func }
	return self:AddButtons({ opts })
end

local function sliderTrack(row, y)
	local track = create("Frame", { Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 6), Parent = row })
	paint(track, { BackgroundColor3 = "Element" })
	corner(track, 3)
	local fill = create("Frame", { Size = UDim2.fromScale(0, 1), Parent = track })
	paint(fill, { BackgroundColor3 = "Accent" })
	corner(fill, 3)
	return track, fill
end

local function sliderKnob(track)
	local knob = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = 3, Parent = track })
	corner(knob, "full")
	stroke(knob, "Accent", 0, 2)
	return knob
end

local function formatNumber(value, rounding, suffix)
	if rounding <= 0 then
		return tostring(math.floor(value + 0.5)) .. (suffix or "")
	end
	return string.format("%." .. rounding .. "f", value) .. (suffix or "")
end

function Container:AddSlider(flag, opts)
	opts = opts or {}
	local row = self:_row(48, opts.Text)
	highlightRow(row)
	local min, max = opts.Min or 0, opts.Max or 100
	local rounding = opts.Rounding or 0
	local slider = { Type = "Slider", Value = opts.Default or min, Min = min, Max = max, Changed = {}, Callback = opts.Callback }
	local label = text({ Text = opts.Text or flag, Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, -90, 0, 20), Parent = row })
	local valueLabel = text({ Text = "", ColorKey = "SubText", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 4), Size = UDim2.fromOffset(90, 20), Parent = row })
	local track, fill = sliderTrack(row, 32)
	local knob = sliderKnob(track)
	attachTooltip(label, opts.Tooltip)
	local hit = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 24), ZIndex = 4, Parent = row })

	local function render()
		local pct = (max - min) == 0 and 0 or (slider.Value - min) / (max - min)
		fill.Size = UDim2.fromScale(pct, 1)
		knob.Position = UDim2.fromScale(pct, 0.5)
		valueLabel.Text = formatNumber(slider.Value, rounding, opts.Suffix)
	end
	function slider:SetValue(value)
		local factor = 10 ^ rounding
		value = math.clamp(math.floor((tonumber(value) or min) * factor + 0.5) / factor, min, max)
		if value == slider.Value and slider.Ready then
			return
		end
		slider.Value = value
		Library.Flags[flag] = value
		render()
		fireChanged(slider, value)
	end
	function slider:OnChanged(fn)
		table.insert(slider.Changed, fn)
	end
	function slider:SetVisible(value)
		row.Visible = value
	end

	local dragging = false
	local function update(x)
		local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		slider:SetValue(min + (max - min) * pct)
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input.Position.X)
			tween(knob, { Size = UDim2.fromOffset(15, 15) }, 0.1)
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			tween(knob, { Size = UDim2.fromOffset(12, 12) }, 0.1)
		end
	end)

	slider.Value = math.clamp(slider.Value, min, max)
	Library.Flags[flag] = slider.Value
	render()
	slider.Ready = true
	Library.Options[flag] = slider
	return slider
end

function Container:AddRangeSlider(flag, opts)
	opts = opts or {}
	local row = self:_row(48, opts.Text)
	highlightRow(row)
	local min, max = opts.Min or 0, opts.Max or 100
	local rounding = opts.Rounding or 0
	local default = opts.Default or { min, max }
	local range = { Type = "RangeSlider", Value = { Min = default[1] or default.Min or min, Max = default[2] or default.Max or max }, Changed = {}, Callback = opts.Callback }
	text({ Text = opts.Text or flag, Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, -120, 0, 20), Parent = row })
	local valueLabel = text({ Text = "", ColorKey = "SubText", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 4), Size = UDim2.fromOffset(120, 20), Parent = row })
	local track, fill = sliderTrack(row, 32)
	local lowKnob = sliderKnob(track)
	local highKnob = sliderKnob(track)
	local hit = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 24), ZIndex = 4, Parent = row })

	local function pctOf(value)
		return (max - min) == 0 and 0 or (value - min) / (max - min)
	end
	local function render()
		local a, b = pctOf(range.Value.Min), pctOf(range.Value.Max)
		fill.Position = UDim2.fromScale(a, 0)
		fill.Size = UDim2.fromScale(b - a, 1)
		lowKnob.Position = UDim2.fromScale(a, 0.5)
		highKnob.Position = UDim2.fromScale(b, 0.5)
		valueLabel.Text = formatNumber(range.Value.Min, rounding, opts.Suffix) .. " - " .. formatNumber(range.Value.Max, rounding, opts.Suffix)
	end
	function range:SetValue(lowValue, highValue)
		if type(lowValue) == "table" then
			highValue = lowValue.Max or lowValue[2]
			lowValue = lowValue.Min or lowValue[1]
		end
		local factor = 10 ^ rounding
		local low = math.clamp(math.floor((tonumber(lowValue) or min) * factor + 0.5) / factor, min, max)
		local high = math.clamp(math.floor((tonumber(highValue) or max) * factor + 0.5) / factor, min, max)
		if low > high then
			low, high = high, low
		end
		range.Value = { Min = low, Max = high }
		Library.Flags[flag] = { Min = low, Max = high }
		render()
		fireChanged(range, range.Value)
	end
	function range:OnChanged(fn)
		table.insert(range.Changed, fn)
	end

	local dragging = nil
	local function valueAt(x)
		local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		return min + (max - min) * pct
	end
	local function update(x)
		local v = valueAt(x)
		if dragging == "low" then
			range:SetValue(math.min(v, range.Value.Max), range.Value.Max)
		else
			range:SetValue(range.Value.Min, math.max(v, range.Value.Min))
		end
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local v = valueAt(input.Position.X)
			dragging = math.abs(v - range.Value.Min) <= math.abs(v - range.Value.Max) and "low" or "high"
			update(input.Position.X)
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = nil
		end
	end)

	Library.Flags[flag] = { Min = range.Value.Min, Max = range.Value.Max }
	render()
	Library.Options[flag] = range
	return range
end

local function fieldBox(row, y)
	local box = create("Frame", { Position = UDim2.fromOffset(0, y or 26), Size = UDim2.new(1, 0, 0, 32), Parent = row })
	paint(box, { BackgroundColor3 = "Element" })
	corner(box, 5)
	local s = stroke(box, "Border")
	return box, s
end

local function optionList(frame, values, isOn, onPick, searchable)
	local scroll = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, searchable and 34 or 0),
		Size = UDim2.new(1, 0, 1, searchable and -34 or 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ZIndex = 22,
		Parent = frame,
	})
	paint(scroll, { ScrollBarImageColor3 = "Accent" })
	padding(scroll, 4, 6, 4, 4)
	list(scroll, 2)
	local items = {}
	local function paintItems()
		for name, item in pairs(items) do
			local on = isOn(name)
			item.Label.TextColor3 = on and Theme.Accent or Theme.SubText
			item.Check.Visible = on
		end
	end
	for index, name in ipairs(values) do
		local itemButton = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = index, ZIndex = 22, Parent = scroll })
		paint(itemButton, { BackgroundColor3 = "ElementHover" })
		corner(itemButton, 4)
		local itemLabel = text({ Text = tostring(name), TextSize = 13, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -34, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 23, Parent = itemButton })
		local itemCheck = icon("check", 13, "Accent", { Position = UDim2.new(1, -22, 0, 7), ZIndex = 23, Parent = itemButton })
		items[name] = { Button = itemButton, Label = itemLabel, Check = itemCheck }
		hover(itemButton, function()
			itemButton.BackgroundTransparency = 0.4
		end, function()
			itemButton.BackgroundTransparency = 1
		end)
		itemButton.MouseButton1Click:Connect(function()
			onPick(name)
			paintItems()
		end)
	end
	paintItems()
	if searchable then
		local search = text({ Class = "TextBox", Text = "", PlaceholderText = "search...", TextSize = 13, ClearTextOnFocus = false, BackgroundTransparency = 0, Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 24), ZIndex = 22, Parent = frame })
		paint(search, { BackgroundColor3 = "Element", PlaceholderColor3 = "SubText" })
		corner(search, 4)
		padding(search, 8, 8, 0, 0)
		search:GetPropertyChangedSignal("Text"):Connect(function()
			local query = string.lower(search.Text)
			for name, item in pairs(items) do
				item.Button.Visible = query == "" or string.find(string.lower(tostring(name)), query, 1, true) ~= nil
			end
		end)
	end
	return paintItems
end

function Container:AddDropdown(flag, opts)
	opts = opts or {}
	local row = self:_row(66, opts.Text)
	local dropdown = {
		Type = "Dropdown",
		Values = opts.Values or {},
		Multi = opts.Multi == true,
		AllowNull = opts.AllowNull == true,
		Value = nil,
		Changed = {},
		Callback = opts.Callback,
	}
	local label = text({ Text = opts.Text or flag, Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 20), Parent = row })
	attachTooltip(label, opts.Tooltip)
	local box, boxStroke = fieldBox(row, 26)
	local button = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = box })
	local display = text({ Text = "", TextSize = 13, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -40, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = box })
	local chevron = icon("chevron-down", 14, "SubText", { Position = UDim2.new(1, -24, 0, 9), Parent = box })
	hover(button, function()
		boxStroke.Color = Theme.Accent
	end, function()
		boxStroke.Color = Theme.Border
	end)

	local function selected()
		if not dropdown.Multi then
			return dropdown.Value ~= nil and { dropdown.Value } or {}
		end
		local out = {}
		for _, item in ipairs(dropdown.Values) do
			if dropdown.Value[item] then
				table.insert(out, item)
			end
		end
		return out
	end
	local function render()
		local picked = selected()
		display.Text = #picked > 0 and table.concat(picked, ", ") or "None"
		paint(display, { TextColor3 = #picked > 0 and "Text" or "SubText" })
	end
	function dropdown:SetValue(value)
		if dropdown.Multi then
			local set = {}
			if type(value) == "table" then
				for key, item in pairs(value) do
					if type(key) == "number" then
						set[item] = true
					elseif item then
						set[key] = true
					end
				end
			end
			dropdown.Value = set
			local out = {}
			for key in pairs(set) do
				table.insert(out, key)
			end
			Library.Flags[flag] = out
		else
			dropdown.Value = value
			Library.Flags[flag] = value
		end
		render()
		fireChanged(dropdown, dropdown.Value)
	end
	function dropdown:SetValues(values)
		dropdown.Values = values or {}
		if not dropdown.Multi and dropdown.Value ~= nil and not table.find(dropdown.Values, dropdown.Value) then
			dropdown.Value = nil
			Library.Flags[flag] = nil
		end
		render()
	end
	function dropdown:OnChanged(fn)
		table.insert(dropdown.Changed, fn)
	end
	function dropdown:SetVisible(value)
		row.Visible = value
	end

	button.MouseButton1Click:Connect(function()
		local searchable = opts.Searchable == true or #dropdown.Values > 8
		local count = math.clamp(#dropdown.Values, 1, 7)
		local height = count * 30 + 10 + (searchable and 34 or 0)
		local frame = openPopup(box, box.AbsoluteSize.X / Library.Scale, height, function()
			tween(chevron, { Rotation = 0 })
		end)
		tween(chevron, { Rotation = 180 })
		optionList(frame, dropdown.Values, function(name)
			if dropdown.Multi then
				return dropdown.Value[name] == true
			end
			return dropdown.Value == name
		end, function(name)
			if dropdown.Multi then
				local copy = table.clone(dropdown.Value)
				copy[name] = not copy[name] or nil
				dropdown:SetValue(copy)
			else
				if dropdown.Value == name and dropdown.AllowNull then
					dropdown:SetValue(nil)
				else
					dropdown:SetValue(name)
				end
				closePopup()
			end
		end, searchable)
	end)

	if opts.SpecialType == "Player" then
		local function refreshPlayers()
			local names = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if not (opts.ExcludeLocalPlayer and player == LocalPlayer) then
					table.insert(names, player.Name)
				end
			end
			table.sort(names)
			dropdown:SetValues(names)
		end
		refreshPlayers()
		connect(Players.PlayerAdded, refreshPlayers)
		connect(Players.PlayerRemoving, function()
			task.defer(refreshPlayers)
		end)
	end

	if dropdown.Multi then
		dropdown.Value = {}
	end
	if opts.Default ~= nil then
		dropdown:SetValue(opts.Default)
	else
		render()
	end
	Library.Options[flag] = dropdown
	return dropdown
end

function Container:AddInput(flag, opts)
	opts = opts or {}
	local row = self:_row(66, opts.Text)
	local input = { Type = "Input", Value = opts.Default or "", Changed = {}, Callback = opts.Callback }
	local label = text({ Text = opts.Text or flag, Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 20), Parent = row })
	attachTooltip(label, opts.Tooltip)
	local box, boxStroke = fieldBox(row, 26)
	local textbox = text({
		Class = "TextBox",
		Text = input.Value,
		PlaceholderText = opts.Placeholder or "",
		TextSize = 13,
		ClearTextOnFocus = false,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = box,
	})
	paint(textbox, { TextColor3 = "Text", PlaceholderColor3 = "SubText" })
	textbox.Focused:Connect(function()
		boxStroke.Color = Theme.Accent
	end)
	function input:SetValue(value)
		value = tostring(value or "")
		if opts.Numeric then
			value = value:gsub("[^%d%.%-]", "")
		end
		input.Value = value
		textbox.Text = value
		Library.Flags[flag] = value
		fireChanged(input, value)
	end
	function input:OnChanged(fn)
		table.insert(input.Changed, fn)
	end
	function input:SetVisible(value)
		row.Visible = value
	end
	textbox.FocusLost:Connect(function()
		boxStroke.Color = Theme.Border
		input:SetValue(textbox.Text)
	end)
	if not opts.Finished then
		textbox:GetPropertyChangedSignal("Text"):Connect(function()
			if textbox:IsFocused() then
				input.Value = textbox.Text
				Library.Flags[flag] = textbox.Text
			end
		end)
	end
	Library.Flags[flag] = input.Value
	Library.Options[flag] = input
	return input
end

function Container:AddLabel(textOrOpts, extra)
	local opts = type(textOrOpts) == "table" and textOrOpts or { Text = textOrOpts }
	if type(extra) == "table" then
		for key, value in pairs(extra) do
			opts[key] = value
		end
	end
	local muted = opts.Muted == true or opts.DoesWrap == true
	local row = self:_row(muted and 22 or 32, opts.Text)
	local labelObj = { Type = "Label", Text = opts.Text, Row = row }
	local label = text({
		Text = opts.Text or "",
		TextSize = muted and 13 or 14,
		ColorKey = muted and "SubText" or "Text",
		TextWrapped = muted,
		Size = UDim2.new(1, muted and 0 or -80, 1, 0),
		Parent = row,
	})
	if muted then
		row.AutomaticSize = Enum.AutomaticSize.Y
		label.AutomaticSize = Enum.AutomaticSize.Y
	end
	labelObj.Label = label
	labelObj.Right = rightSlot(row)
	function labelObj:SetText(value)
		label.Text = value
	end
	function labelObj:SetVisible(value)
		row.Visible = value
	end
	addonMethods(labelObj)
	return labelObj
end

function Container:AddDivider(caption)
	local row = self:_row(caption and 28 or 14)
	if caption and caption ~= "" then
		local width = textWidth(caption, 12) + 20
		text({ Text = caption, TextSize = 12, ColorKey = "SubText", TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(width, 18), Parent = row })
		for _, side in ipairs({ 0, 1 }) do
			local line = create("Frame", { AnchorPoint = Vector2.new(side, 0.5), Position = UDim2.fromScale(side, 0.5), Size = UDim2.new(0.5, -width / 2, 0, 1), Parent = row })
			paint(line, { BackgroundColor3 = "Border" })
		end
	else
		local line = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 1), Parent = row })
		paint(line, { BackgroundColor3 = "Border" })
	end
end

function Container:AddList(flag, opts)
	opts = opts or {}
	local height = opts.Height or 170
	local row = self:_row(height + 26, opts.Text)
	local listObj = { Type = "List", Values = opts.Values or {}, Multi = opts.Multi == true, Value = nil, Changed = {}, Callback = opts.Callback }
	text({ Text = opts.Text or flag, Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 20), Parent = row })
	local box = create("Frame", { Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, height), ClipsDescendants = true, Parent = row })
	paint(box, { BackgroundColor3 = "Element" })
	corner(box, 5)
	stroke(box, "Border")
	local paintItems
	local function rebuild()
		for _, child in ipairs(box:GetChildren()) do
			if not child:IsA("UICorner") and not child:IsA("UIStroke") then
				child:Destroy()
			end
		end
		paintItems = optionList(box, listObj.Values, function(name)
			if listObj.Multi then
				return listObj.Value[name] == true
			end
			return listObj.Value == name
		end, function(name)
			if listObj.Multi then
				local copy = table.clone(listObj.Value)
				copy[name] = not copy[name] or nil
				listObj:SetValue(copy)
			else
				listObj:SetValue(listObj.Value == name and nil or name)
			end
		end, true)
		for _, child in ipairs(box:GetDescendants()) do
			if child:IsA("GuiObject") then
				child.ZIndex = math.max(child.ZIndex - 20, 1)
			end
		end
	end
	function listObj:SetValue(value)
		if listObj.Multi then
			local set = {}
			if type(value) == "table" then
				for key, item in pairs(value) do
					if type(key) == "number" then
						set[item] = true
					elseif item then
						set[key] = true
					end
				end
			end
			listObj.Value = set
			local out = {}
			for key in pairs(set) do
				table.insert(out, key)
			end
			Library.Flags[flag] = out
		else
			listObj.Value = value
			Library.Flags[flag] = value
		end
		if paintItems then
			paintItems()
		end
		fireChanged(listObj, listObj.Value)
	end
	function listObj:SetValues(values)
		listObj.Values = values or {}
		rebuild()
	end
	function listObj:OnChanged(fn)
		table.insert(listObj.Changed, fn)
	end
	if listObj.Multi then
		listObj.Value = {}
	end
	rebuild()
	if opts.Default ~= nil then
		listObj:SetValue(opts.Default)
	end
	Library.Options[flag] = listObj
	return listObj
end

local BODY_PARTS = {
	{ "Head", 0.39, 0.0, 0.22, 0.18 },
	{ "Torso", 0.3, 0.2, 0.4, 0.34 },
	{ "Left Arm", 0.12, 0.2, 0.16, 0.34 },
	{ "Right Arm", 0.72, 0.2, 0.16, 0.34 },
	{ "Left Leg", 0.3, 0.56, 0.19, 0.44 },
	{ "Right Leg", 0.51, 0.56, 0.19, 0.44 },
}
Library.PartMap = {
	Head = { "Head" },
	Torso = { "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart" },
	["Left Arm"] = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm" },
	["Right Arm"] = { "RightUpperArm", "RightLowerArm", "RightHand", "Right Arm" },
	["Left Leg"] = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg" },
	["Right Leg"] = { "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg" },
}

function Container:AddPartPicker(flag, opts)
	opts = opts or {}
	local row = self:_row(196, opts.Text or "hit parts")
	local picker = { Type = "PartPicker", Multi = opts.Multi ~= false, Value = {}, Changed = {}, Callback = opts.Callback }
	text({ Text = opts.Text or "Hit Parts", Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 20), Parent = row })
	local stage = create("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 28), Size = UDim2.fromOffset(110, 160), BackgroundTransparency = 1, Parent = row })
	local parts = {}
	local function render()
		for name, frame in pairs(parts) do
			local on = picker.Value[name] == true
			frame.BackgroundColor3 = on and Theme.Accent or Theme.Element
			frame.BackgroundTransparency = on and 0.1 or 0
		end
	end
	onTheme(render)
	for _, info in ipairs(BODY_PARTS) do
		local name = info[1]
		local frame = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Position = UDim2.fromScale(info[2], info[3]),
			Size = UDim2.new(info[4], -2, info[5], -2),
			Parent = stage,
		})
		corner(frame, name == "Head" and 6 or 3)
		stroke(frame, "Border")
		attachTooltip(frame, name)
		parts[name] = frame
		frame.MouseButton1Click:Connect(function()
			local copy = picker.Multi and table.clone(picker.Value) or {}
			copy[name] = not picker.Value[name] or nil
			picker:SetValue(copy)
		end)
	end
	function picker:SetValue(value)
		local set = {}
		if type(value) == "table" then
			for key, item in pairs(value) do
				if type(key) == "number" then
					set[item] = true
				elseif item then
					set[key] = true
				end
			end
		elseif type(value) == "string" then
			set[value] = true
		end
		picker.Value = set
		local out = {}
		for key in pairs(set) do
			table.insert(out, key)
		end
		Library.Flags[flag] = out
		render()
		fireChanged(picker, out)
	end
	function picker:GetParts(character)
		local found = {}
		for name in pairs(picker.Value) do
			for _, partName in ipairs(Library.PartMap[name] or {}) do
				local part = character and character:FindFirstChild(partName)
				if part then
					table.insert(found, part)
					break
				end
			end
		end
		return found
	end
	function picker:OnChanged(fn)
		table.insert(picker.Changed, fn)
	end
	picker:SetValue(opts.Default or { "Head" })
	Library.Options[flag] = picker
	return picker
end

local STATUS_ORDER = { "Neutral", "Target", "Whitelist" }
local STATUS_COLOR = { Neutral = "SubText", Target = "Risky", Whitelist = "Accent" }

function Library:GetStatus(player)
	return Library.Statuses[player and player.UserId or 0] or "Neutral"
end

function Library:SetStatus(player, status)
	if player then
		Library.Statuses[player.UserId] = status ~= "Neutral" and status or nil
		Library.Flags.__statuses = Library.Statuses
		for _, fn in ipairs(Library.StatusChanged or {}) do
			task.spawn(fn, player, status)
		end
	end
end

function Library:OnStatusChanged(fn)
	Library.StatusChanged = Library.StatusChanged or {}
	table.insert(Library.StatusChanged, fn)
end

function Container:AddTargetList(opts)
	opts = opts or {}
	local height = opts.Height or 260
	local row = self:_row(height + 34, "target list players")
	local search = text({ Class = "TextBox", Text = "", PlaceholderText = "search player...", TextSize = 13, ClearTextOnFocus = false, BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 28), Parent = row })
	paint(search, { BackgroundColor3 = "Element", PlaceholderColor3 = "SubText" })
	corner(search, 5)
	stroke(search, "Border")
	padding(search, 10, 10, 0, 0)
	local scroll = create("ScrollingFrame", { Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, height), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, Parent = row })
	paint(scroll, { BackgroundColor3 = "Element", ScrollBarImageColor3 = "Accent" })
	corner(scroll, 5)
	padding(scroll, 6, 8, 6, 6)
	list(scroll, 6)
	local rows = {}

	local function copy(value)
		pcall(function()
			setclipboard(tostring(value))
		end)
		Library:Notify({ Title = "Copied", Text = tostring(value), Duration = 2, Type = "info" })
	end
	local function miniButton(parent, label, x, fn)
		local b = text({ Class = "TextButton", Text = label, TextSize = 11, ColorKey = "SubText", TextXAlignment = Enum.TextXAlignment.Center, AutoButtonColor = false, BackgroundTransparency = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 34), Size = UDim2.fromOffset(52, 18), Parent = parent })
		paint(b, { BackgroundColor3 = "Groupbox" })
		corner(b, 4)
		b.MouseButton1Click:Connect(fn)
		return b
	end
	local function addPlayer(player)
		if player == LocalPlayer or rows[player] then
			return
		end
		local card = create("Frame", { Size = UDim2.new(1, 0, 0, 58), Parent = scroll })
		paint(card, { BackgroundColor3 = "Groupbox" })
		corner(card, 5)
		local avatar = create("ImageLabel", { Position = UDim2.fromOffset(6, 7), Size = UDim2.fromOffset(44, 44), Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150", Parent = card })
		paint(avatar, { BackgroundColor3 = "Element" })
		corner(avatar, "full")
		text({ Text = player.DisplayName, TextSize = 14, Weight = Enum.FontWeight.SemiBold, Position = UDim2.fromOffset(58, 6), Size = UDim2.new(1, -150, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card })
		text({ Text = "@" .. player.Name .. "  |  " .. player.UserId, TextSize = 12, ColorKey = "SubText", Position = UDim2.fromOffset(58, 24), Size = UDim2.new(1, -150, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card })
		local pill = text({ Class = "TextButton", Text = "", TextSize = 12, Weight = Enum.FontWeight.SemiBold, TextXAlignment = Enum.TextXAlignment.Center, AutoButtonColor = false, BackgroundTransparency = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 8), Size = UDim2.fromOffset(84, 22), Parent = card })
		paint(pill, { BackgroundColor3 = "Element" })
		corner(pill, 11)
		local pillStroke = stroke(pill, "Border")
		local function renderPill()
			local status = Library:GetStatus(player)
			pill.Text = status
			pill.TextColor3 = Theme[STATUS_COLOR[status]]
			pillStroke.Color = Theme[STATUS_COLOR[status]]
		end
		pill.MouseButton1Click:Connect(function()
			local current = table.find(STATUS_ORDER, Library:GetStatus(player)) or 1
			Library:SetStatus(player, STATUS_ORDER[current % #STATUS_ORDER + 1])
			renderPill()
		end)
		miniButton(card, "copy id", -6, function()
			copy(player.UserId)
		end)
		miniButton(card, "copy name", -62, function()
			copy(player.Name)
		end)
		renderPill()
		rows[player] = { Card = card, Render = renderPill, Text = string.lower(player.Name .. " " .. player.DisplayName .. " " .. player.UserId) }
	end
	for _, player in ipairs(Players:GetPlayers()) do
		addPlayer(player)
	end
	connect(Players.PlayerAdded, addPlayer)
	connect(Players.PlayerRemoving, function(player)
		if rows[player] then
			rows[player].Card:Destroy()
			rows[player] = nil
		end
	end)
	search:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(search.Text)
		for _, info in pairs(rows) do
			info.Card.Visible = query == "" or string.find(info.Text, query, 1, true) ~= nil
		end
	end)
	onTheme(function()
		for _, info in pairs(rows) do
			info.Render()
		end
	end)
	return { Refresh = function()
		for _, info in pairs(rows) do
			info.Render()
		end
	end }
end

function Container:AddESPPreview(opts)
	opts = opts or {}
	local height = opts.Height or 300
	local row = self:_row(height, "esp preview")
	local frame = create("Frame", { Size = UDim2.fromScale(1, 1), ClipsDescendants = true, Parent = row })
	paint(frame, { BackgroundColor3 = "Element" })
	corner(frame, 6)
	stroke(frame, "Border")
	local viewport = create("ViewportFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Ambient = Color3.fromRGB(170, 170, 180), LightColor = Color3.new(1, 1, 1), Parent = frame })
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	local model = nil
	local function buildModel()
		if model then
			model:Destroy()
			model = nil
		end
		local char = LocalPlayer.Character
		if not char then
			return
		end
		local ok, clone = pcall(function()
			char.Archivable = true
			local c = char:Clone()
			return c
		end)
		if not ok or not clone then
			return
		end
		for _, item in ipairs(clone:GetDescendants()) do
			if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("Tool") or item:IsA("ForceField") then
				item:Destroy()
			elseif item:IsA("BasePart") then
				item.Anchored = true
			end
		end
		local root = clone:FindFirstChild("HumanoidRootPart")
		if root then
			clone.PrimaryPart = root
			clone:PivotTo(CFrame.new(0, 0, 0))
		end
		clone.Parent = viewport
		model = clone
	end
	buildModel()
	camera.CFrame = CFrame.new(Vector3.new(0, 0.6, 10.5), Vector3.new(0, 0, 0))

	local box = create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.new(0, 108, 0.74, 0), Parent = frame })
	local boxStroke = stroke(box, "Accent", 0, 1)
	local elements = {}
	local layout = { Name = "Top", Distance = "Bottom", Health = "Left", Armor = "Right" }
	local SLOTS = {
		Top = function(size)
			return UDim2.new(0.5, 0, 0, -size.Y - 4), Vector2.new(0.5, 0)
		end,
		Bottom = function()
			return UDim2.new(0.5, 0, 1, 4), Vector2.new(0.5, 0)
		end,
		Left = function(size)
			return UDim2.new(0, -size.X - 5, 0, 0), Vector2.new(0, 0)
		end,
		Right = function()
			return UDim2.new(1, 5, 0, 0), Vector2.new(0, 0)
		end,
	}
	local function place(name)
		local element = elements[name]
		if not element then
			return
		end
		local slot = layout[name]
		local size = element.Instance.AbsoluteSize / math.max(Library.Scale, 0.01)
		local position, anchor = SLOTS[slot](size)
		element.Instance.AnchorPoint = anchor
		element.Instance.Position = position
		if element.Bar then
			local vertical = slot == "Left" or slot == "Right"
			element.Instance.Size = vertical and UDim2.new(0, 4, 1, 0) or UDim2.new(1, 0, 0, 4)
			element.Fill.AnchorPoint = vertical and Vector2.new(0, 1) or Vector2.new(0, 0)
			element.Fill.Position = vertical and UDim2.fromScale(0, 1) or UDim2.fromScale(0, 0)
		end
	end
	local function makeDraggableElement(name, inst)
		local dragging, startPos = false, nil
		inst.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				startPos = input.Position
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if not dragging then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				local center = box.AbsolutePosition + box.AbsoluteSize / 2
				local delta = Vector2.new(input.Position.X, input.Position.Y) - center
				local slot
				if math.abs(delta.X) / box.AbsoluteSize.X > math.abs(delta.Y) / box.AbsoluteSize.Y then
					slot = delta.X < 0 and "Left" or "Right"
				else
					slot = delta.Y < 0 and "Top" or "Bottom"
				end
				for other, otherSlot in pairs(layout) do
					if other ~= name and otherSlot == slot then
						layout[other] = layout[name]
					end
				end
				layout[name] = slot
				for other in pairs(elements) do
					place(other)
				end
				Library.Flags.__esp_layout = table.clone(layout)
			end
		end)
	end
	local function addText(name, value)
		local label = text({ Text = value, TextSize = 13, Weight = Enum.FontWeight.SemiBold, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, Active = true, Parent = box })
		elements[name] = { Instance = label }
		makeDraggableElement(name, label)
	end
	local function addBar(name, colorTop, colorBottom)
		local bar = create("Frame", { BackgroundColor3 = Color3.fromRGB(10, 10, 12), Active = true, Parent = box })
		corner(bar, 2)
		local fill = create("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), Parent = bar })
		corner(fill, 2)
		create("UIGradient", { Rotation = 90, Color = ColorSequence.new(colorTop, colorBottom), Parent = fill })
		elements[name] = { Instance = bar, Fill = fill, Bar = true }
		makeDraggableElement(name, bar)
	end
	addText("Name", LocalPlayer.DisplayName)
	addText("Distance", "[ 12m ]")
	addBar("Health", Color3.fromRGB(80, 255, 120), Color3.fromRGB(255, 70, 70))
	addBar("Armor", Color3.fromRGB(120, 180, 255), Color3.fromRGB(70, 90, 255))
	task.defer(function()
		for name in pairs(elements) do
			place(name)
		end
	end)

	local preview = { Elements = elements, Layout = layout }
	function preview:SetVisible(name, value)
		if name == "Box" then
			boxStroke.Enabled = value
		elseif elements[name] then
			elements[name].Instance.Visible = value
		end
	end
	function preview:SetColor(name, color)
		if name == "Box" then
			Themed[boxStroke] = nil
			boxStroke.Color = color
		elseif elements[name] and not elements[name].Bar then
			Themed[elements[name].Instance] = nil
			elements[name].Instance.TextColor3 = color
		end
	end
	function preview:SetLayout(saved)
		if type(saved) == "table" then
			for name, slot in pairs(saved) do
				if layout[name] and SLOTS[slot] then
					layout[name] = slot
				end
			end
			for name in pairs(elements) do
				place(name)
			end
		end
	end

	local spin, phase, conn = 0, 0, nil
	local function setRunning(state)
		if state and not conn then
			conn = RunService.RenderStepped:Connect(function(dt)
				spin += dt * 0.6
				phase += dt
				if model and model.PrimaryPart then
					model:PivotTo(CFrame.Angles(0, spin, 0))
				end
				local hp = 0.55 + math.sin(phase * 1.3) * 0.4
				local armor = 0.5 + math.cos(phase * 0.9) * 0.45
				if elements.Health then
					local vertical = layout.Health == "Left" or layout.Health == "Right"
					elements.Health.Fill.Size = vertical and UDim2.fromScale(1, hp) or UDim2.fromScale(hp, 1)
				end
				if elements.Armor then
					local vertical = layout.Armor == "Left" or layout.Armor == "Right"
					elements.Armor.Fill.Size = vertical and UDim2.fromScale(1, armor) or UDim2.fromScale(armor, 1)
				end
				if elements.Distance then
					elements.Distance.Instance.Text = string.format("[ %dm ]", 10 + math.floor((math.sin(phase * 0.5) + 1) * 15))
				end
			end)
		elseif not state and conn then
			conn:Disconnect()
			conn = nil
		end
	end
	local function visibleNow()
		return row.Parent ~= nil and frame.AbsoluteSize.X > 0 and frame.Visible and Library.Open and row:FindFirstAncestorWhichIsA("ScreenGui") ~= nil
	end
	local watch = function()
		local page = self.Page
		setRunning(visibleNow() and (not page or page.Frame.Visible))
	end
	connect(LocalPlayer.CharacterAdded, function()
		task.wait(1)
		buildModel()
	end)
	if self.Page then
		table.insert(self.Page.OnShow, watch)
	end
	table.insert(Library.OpenChanged, watch)
	task.defer(watch)
	return preview
end

local function newContainer(holder, page, extra)
	local container = setmetatable({ Holder = holder, Page = page, Order = 0 }, Container)
	for key, value in pairs(extra or {}) do
		container[key] = value
	end
	return container
end

local function groupboxShell(column, name, iconName)
	local frame = create("Frame", { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = column })
	paint(frame, { BackgroundColor3 = "Groupbox" })
	corner(frame, 6)
	stroke(frame, "Border")
	local header = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = frame })
	local titleX = 14
	if iconName then
		icon(iconName, 15, "Accent", { Position = UDim2.fromOffset(14, 12), Parent = header })
		titleX = 36
	end
	text({ Text = name or "", Weight = Enum.FontWeight.SemiBold, Position = UDim2.fromOffset(titleX, 0), Size = UDim2.new(1, -titleX - 14, 1, 0), Parent = header })
	local line = create("Frame", { Position = UDim2.fromOffset(14, 39), Size = UDim2.new(1, -28, 0, 1), Parent = frame })
	paint(line, { BackgroundColor3 = "Border" })
	local accentLine = create("Frame", { Position = UDim2.fromOffset(14, 39), Size = UDim2.fromOffset(36, 1), Parent = frame })
	paint(accentLine, { BackgroundColor3 = "Accent" })
	local holder = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 46), Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = frame })
	padding(holder, 14, 14, 0, 12)
	list(holder, 4)
	return frame, holder
end

local function newTabbox(page, column)
	local frame = create("Frame", { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = column })
	paint(frame, { BackgroundColor3 = "Groupbox" })
	corner(frame, 6)
	stroke(frame, "Border")
	local header = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 6), Size = UDim2.new(1, -16, 0, 30), Parent = frame })
	list(header, 6, Enum.FillDirection.Horizontal)
	local line = create("Frame", { Position = UDim2.fromOffset(14, 41), Size = UDim2.new(1, -28, 0, 1), Parent = frame })
	paint(line, { BackgroundColor3 = "Border" })
	local tabbox = { Tabs = {} }
	local function select(tab)
		for _, other in ipairs(tabbox.Tabs) do
			local on = other == tab
			other.Holder.Visible = on
			paint(other.Button, { TextColor3 = on and "Accent" or "SubText", BackgroundColor3 = on and "Element" or "Groupbox" })
		end
	end
	function tabbox:AddTab(name)
		local button = text({ Class = "TextButton", Text = name, TextSize = 13, Weight = Enum.FontWeight.Medium, TextXAlignment = Enum.TextXAlignment.Center, AutoButtonColor = false, BackgroundTransparency = 0, Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = #tabbox.Tabs + 1, Parent = header })
		corner(button, 5)
		padding(button, 12, 12, 0, 0)
		local holder = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 48), Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, Parent = frame })
		padding(holder, 14, 14, 0, 12)
		list(holder, 4)
		local tab = newContainer(holder, page, { Button = button })
		table.insert(tabbox.Tabs, tab)
		button.MouseButton1Click:Connect(function()
			select(tab)
		end)
		if #tabbox.Tabs == 1 then
			select(tab)
		else
			paint(button, { TextColor3 = "SubText", BackgroundColor3 = "Groupbox" })
		end
		return tab
	end
	return tabbox
end

Library.OpenChanged = {}

function Library:CreateWindow(opts)
	opts = opts or {}
	Library.Name = opts.Title or Library.Name
	Library.Folder = opts.Folder or Library.Folder
	local width, height = opts.Width or 820, opts.Height or 560
	local sidebarWidth = 210
	local Window = { Tabs = {}, Pages = {}, Query = "" }

	local holder = create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(width, height), Parent = Library.Gui })
	scaled(holder)
	Window.Holder = holder

	local glow = create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://18245826428",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
		Position = UDim2.fromOffset(-24, -24),
		Size = UDim2.new(1, 48, 1, 48),
		ImageTransparency = 0.15,
		ZIndex = 0,
		Parent = holder,
	})
	paint(glow, { ImageColor3 = "Glow" })
	Window.Glow = glow

	local main = create("CanvasGroup", { Size = UDim2.fromScale(1, 1), Parent = holder })
	paint(main, { BackgroundColor3 = "Content" })
	corner(main, 7)
	local border = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 10, Parent = holder })
	corner(border, 7)
	stroke(border, "Accent", 0.1, 1)

	local sidebar = create("Frame", { Size = UDim2.new(0, sidebarWidth, 1, 0), ZIndex = 2, Parent = main })
	paint(sidebar, { BackgroundColor3 = "Sidebar" })
	local divider = create("Frame", { Position = UDim2.fromOffset(sidebarWidth, 0), Size = UDim2.new(0, 1, 1, 0), ZIndex = 3, Parent = main })
	paint(divider, { BackgroundColor3 = "Accent" })

	local brand = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 72), ZIndex = 2, Parent = sidebar })
	local logo = create("ImageLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 18), Size = UDim2.fromOffset(36, 36), ScaleType = Enum.ScaleType.Fit, ZIndex = 2, Parent = brand })
	if opts.Logo then
		applyIcon(logo, opts.Logo)
	else
		applyIcon(logo, "eye")
		paint(logo, { ImageColor3 = "Accent" })
	end
	text({ Text = opts.Title or "Commission", TextSize = 17, Weight = Enum.FontWeight.Bold, Position = UDim2.fromOffset(60, 18), Size = UDim2.new(1, -66, 0, 20), ZIndex = 2, Parent = brand })
	text({ Text = opts.Subtitle or "", TextSize = 12, ColorKey = "SubText", Position = UDim2.fromOffset(60, 38), Size = UDim2.new(1, -66, 0, 14), ZIndex = 2, Parent = brand })
	makeDraggable(brand, holder)

	local tabList = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 80),
		Size = UDim2.new(1, 0, 1, -80 - 112),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		ZIndex = 2,
		Parent = sidebar,
	})
	padding(tabList, 14, 14, 4, 4)
	list(tabList, 8)

	local profileLine = create("Frame", { Position = UDim2.new(0, 14, 1, -104), Size = UDim2.new(1, -28, 0, 1), ZIndex = 2, Parent = sidebar })
	paint(profileLine, { BackgroundColor3 = "Accent" })
	local avatar = create("ImageLabel", {
		Position = UDim2.new(0, 14, 1, -88),
		Size = UDim2.fromOffset(46, 46),
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150",
		ZIndex = 2,
		Parent = sidebar,
	})
	paint(avatar, { BackgroundColor3 = "Element" })
	corner(avatar, "full")
	stroke(avatar, "Accent", 0.3)
	text({ Text = "@" .. LocalPlayer.Name, TextSize = 14, Weight = Enum.FontWeight.SemiBold, ColorKey = "Accent", Position = UDim2.new(0, 68, 1, -86), Size = UDim2.new(1, -74, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = sidebar })
	text({ Text = LocalPlayer.DisplayName, TextSize = 12, ColorKey = "SubText", Position = UDim2.new(0, 68, 1, -66), Size = UDim2.new(1, -74, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = sidebar })
	local expires = text({ Text = "", TextSize = 12, ColorKey = "SubText", Position = UDim2.new(0, 68, 1, -50), Size = UDim2.new(1, -74, 0, 14), RichText = true, ZIndex = 2, Parent = sidebar })
	local executorName = "Unknown"
	pcall(function()
		if identifyexecutor then
			executorName = (identifyexecutor())
		elseif getexecutorname then
			executorName = getexecutorname()
		end
	end)
	text({ Text = tostring(executorName), TextSize = 11, ColorKey = "Disabled", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -12), Size = UDim2.new(1, -24, 0, 14), ZIndex = 2, Parent = sidebar })
	function Window:SetExpires(value)
		expires.Text = 'Expires: <font color="#' .. Theme.Text:ToHex() .. '">' .. tostring(value) .. "</font>"
	end
	Window:SetExpires(opts.Expires or "Lifetime")

	local content = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(sidebarWidth + 1, 0), Size = UDim2.new(1, -sidebarWidth - 1, 1, 0), ZIndex = 1, Parent = main })
	local topBar = create("Frame", { Size = UDim2.new(1, 0, 0, 56), ZIndex = 2, Parent = content })
	paint(topBar, { BackgroundColor3 = "Content" })
	local topLine = create("Frame", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), ZIndex = 2, Parent = topBar })
	paint(topLine, { BackgroundColor3 = "Border" })
	makeDraggable(topBar, holder)
	local miniTabs = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 11), Size = UDim2.new(1, -200, 0, 34), ZIndex = 3, Parent = topBar })
	list(miniTabs, 8, Enum.FillDirection.Horizontal)

	local search = create("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 11), Size = UDim2.fromOffset(160, 34), ZIndex = 3, Parent = topBar })
	paint(search, { BackgroundColor3 = "Element" })
	corner(search, 5)
	local searchStroke = stroke(search, "Border")
	icon("search", 14, "SubText", { Position = UDim2.fromOffset(10, 10), ZIndex = 3, Parent = search })
	local searchBox = text({ Class = "TextBox", Text = "", PlaceholderText = "search...", TextSize = 13, ClearTextOnFocus = false, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -40, 1, 0), ZIndex = 3, Parent = search })
	paint(searchBox, { TextColor3 = "Text", PlaceholderColor3 = "SubText" })
	searchBox.Focused:Connect(function()
		searchStroke.Color = Theme.Accent
	end)
	searchBox.FocusLost:Connect(function()
		searchStroke.Color = Theme.Border
	end)

	local pages = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -56), Parent = content })

	local function applyFilter(page)
		if not page then
			return
		end
		local query = Window.Query
		local boxes = {}
		for _, entry in ipairs(page.Searchables) do
			local match = query == "" or entry.Text:find(query, 1, true) ~= nil
			entry.Frame.Visible = match
			if entry.Box and entry.Box.Frame then
				boxes[entry.Box.Frame] = boxes[entry.Box.Frame] or match
			end
		end
		for frame, any in pairs(boxes) do
			frame.Visible = any or query == ""
		end
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		Window.Query = string.lower(searchBox.Text)
		applyFilter(Window.CurrentPage)
	end)

	local function newPage()
		local frame = create("ScrollingFrame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Visible = false,
			Parent = pages,
		})
		paint(frame, { ScrollBarImageColor3 = "Accent" })
		padding(frame, 16, 16, 16, 16)
		local columns = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = frame })
		local function column(x, w)
			local col = create("Frame", { BackgroundTransparency = 1, Position = x, Size = w, AutomaticSize = Enum.AutomaticSize.Y, Parent = columns })
			list(col, 14)
			return col
		end
		local page = {
			Frame = frame,
			Left = column(UDim2.fromScale(0, 0), UDim2.new(0.5, -7, 0, 0)),
			Right = column(UDim2.new(0.5, 7, 0, 0), UDim2.new(0.5, -7, 0, 0)),
			Searchables = {},
			OnShow = {},
		}
		function page:AddGroupbox(name, iconName, side)
			local col = side == 2 and page.Right or page.Left
			local box, holderFrame = groupboxShell(col, name, iconName)
			local container = newContainer(holderFrame, page, { Frame = box })
			function container:SetVisible(value)
				box.Visible = value
			end
			return container
		end
		function page:AddLeftGroupbox(name, iconName)
			return page:AddGroupbox(name, iconName, 1)
		end
		function page:AddRightGroupbox(name, iconName)
			return page:AddGroupbox(name, iconName, 2)
		end
		function page:AddLeftTabbox()
			return newTabbox(page, page.Left)
		end
		function page:AddRightTabbox()
			return newTabbox(page, page.Right)
		end
		table.insert(Window.Pages, page)
		return page
	end

	local function pageMethods(owner)
		local function ensure()
			owner.Page = owner.Page or newPage()
			return owner.Page
		end
		for _, method in ipairs({ "AddGroupbox", "AddLeftGroupbox", "AddRightGroupbox", "AddLeftTabbox", "AddRightTabbox" }) do
			owner[method] = function(_, ...)
				local page = ensure()
				return page[method](page, ...)
			end
		end
		return ensure
	end

	function Window:Select(tab, sub)
		if tab.SubTabs[1] and not sub then
			sub = tab.LastSub or tab.SubTabs[1]
		end
		for _, other in ipairs(Window.Tabs) do
			local on = other == tab
			other.Bar.Visible = on
			other.BarGlow.Visible = on
			tween(other.Fade, { BackgroundTransparency = on and 0 or 1 }, 0.2)
			paint(other.Label, { TextColor3 = on and "Text" or "SubText" })
			paint(other.Icon, { ImageColor3 = on and "Accent" or "SubText" })
			for _, button in ipairs(other.MiniButtons) do
				button.Visible = on
			end
		end
		for _, entry in ipairs(tab.SubTabs) do
			local on = entry == sub
			entry.Bar.Visible = on
			tween(entry.Fade, { BackgroundTransparency = on and 0 or 1 }, 0.2)
			paint(entry.Label, { TextColor3 = on and "Accent" or "SubText" })
			entry.Stroke.Color = on and Theme.Accent or Theme.Border
			entry.Stroke.Transparency = on and 0.4 or 0
		end
		if sub then
			tab.LastSub = sub
		end
		local page = sub and sub.Ensure() or tab.Ensure()
		for _, other in ipairs(Window.Pages) do
			other.Frame.Visible = other == page
		end
		Window.CurrentPage = page
		Window.CurrentTab, Window.CurrentSub = tab, sub
		applyFilter(page)
		for _, fn in ipairs(page.OnShow) do
			task.spawn(fn)
		end
		for _, other in ipairs(Window.Pages) do
			if other ~= page then
				for _, fn in ipairs(other.OnShow) do
					task.spawn(fn)
				end
			end
		end
	end

	local function fadeGradient(frame)
		local g = create("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1) }), Parent = frame })
		return g
	end

	function Window:AddTab(name, iconName)
		local tab = { Name = name, SubTabs = {}, MiniButtons = {} }
		local button = create("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = #Window.Tabs + 1, ZIndex = 2, Parent = tabList })
		paint(button, { BackgroundColor3 = "SidebarTab" })
		corner(button, 6)
		stroke(button, "Border", 0.2)
		create("UIGradient", { Rotation = 0, Transparency = NumberSequence.new(0, 0.35), Parent = button })
		local fade = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = button })
		paint(fade, { BackgroundColor3 = "Accent" })
		corner(fade, 6)
		fadeGradient(fade)
		local bar = create("Frame", { Position = UDim2.fromOffset(0, 6), Size = UDim2.new(0, 3, 1, -12), Visible = false, ZIndex = 4, Parent = button })
		paint(bar, { BackgroundColor3 = "Accent" })
		corner(bar, 2)
		local barGlow = softGlow(bar, 2, 4, 0.5)
		barGlow.Visible = false
		tab.Icon = icon(iconName, 17, "SubText", { Position = UDim2.fromOffset(16, 12), ZIndex = 3, Parent = button })
		tab.Label = text({ Text = name, TextSize = 14, Weight = Enum.FontWeight.Medium, ColorKey = "SubText", Position = UDim2.fromOffset(iconName and 44 or 16, 0), Size = UDim2.new(1, -50, 1, 0), ZIndex = 3, Parent = button })
		tab.Bar, tab.BarGlow, tab.Fade = bar, barGlow, fade
		tab.Ensure = pageMethods(tab)
		hover(button, function()
			if Window.CurrentTab ~= tab then
				tween(button, { BackgroundColor3 = Theme.ElementHover }, 0.12)
			end
		end, function()
			tween(button, { BackgroundColor3 = Theme.SidebarTab }, 0.15)
		end)
		button.MouseButton1Click:Connect(function()
			Window:Select(tab)
		end)

		function tab:AddSubTab(subName)
			local sub = { Name = subName }
			local subButton = create("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(textWidth(subName, 14, Enum.FontWeight.Medium) + 46, 34), LayoutOrder = #tab.SubTabs + 1, Visible = false, ZIndex = 3, Parent = miniTabs })
			paint(subButton, { BackgroundColor3 = "Element" })
			corner(subButton, 5)
			sub.Stroke = stroke(subButton, "Border")
			local subFade = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = subButton })
			paint(subFade, { BackgroundColor3 = "Accent" })
			corner(subFade, 5)
			fadeGradient(subFade)
			local subBar = create("Frame", { Position = UDim2.fromOffset(0, 5), Size = UDim2.new(0, 3, 1, -10), Visible = false, ZIndex = 5, Parent = subButton })
			paint(subBar, { BackgroundColor3 = "Accent" })
			corner(subBar, 2)
			sub.Label = text({ Text = subName, TextSize = 14, Weight = Enum.FontWeight.Medium, ColorKey = "SubText", TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = subButton })
			sub.Bar, sub.Fade = subBar, subFade
			sub.Ensure = pageMethods(sub)
			subButton.MouseButton1Click:Connect(function()
				Window:Select(tab, sub)
			end)
			table.insert(tab.SubTabs, sub)
			table.insert(tab.MiniButtons, subButton)
			return sub
		end

		table.insert(Window.Tabs, tab)
		if #Window.Tabs == 1 then
			task.defer(function()
				if not Window.CurrentTab then
					Window:Select(tab)
				end
			end)
		end
		return tab
	end

	function Window:AddHomeTab(homeOpts)
		homeOpts = homeOpts or {}
		local tab = Window:AddTab(homeOpts.Name or "Home", homeOpts.Icon or "house")
		local page = tab.Ensure()
		page.Left.Parent.Visible = false
		local root = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = page.Frame })
		list(root, 12)

		local function card(parent, height, order, tint, rotation, stops)
			local frame = create("Frame", { Size = UDim2.new(1, 0, 0, height), LayoutOrder = order, ClipsDescendants = true, Parent = parent })
			paint(frame, { BackgroundColor3 = "Groupbox" })
			corner(frame, 8)
			stroke(frame, "Border")
			if tint then
				local overlay = create("Frame", { Size = UDim2.fromScale(1, 1), Parent = frame })
				if typeof(tint) == "Color3" then
					overlay.BackgroundColor3 = tint
				else
					paint(overlay, { BackgroundColor3 = tint })
				end
				corner(overlay, 8)
				create("UIGradient", { Rotation = rotation or 90, Transparency = NumberSequence.new(stops), Parent = overlay })
			end
			return frame
		end
		local bottomGlow = { NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.55, 0.95), NumberSequenceKeypoint.new(1, 0.62) }
		local sideGlow = { NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(0.6, 0.6), NumberSequenceKeypoint.new(1, 0.92) }

		local function header(parent, title, subtitle)
			text({ Text = title, TextSize = 15, Weight = Enum.FontWeight.SemiBold, Position = UDim2.fromOffset(14, 12), Size = UDim2.new(1, -28, 0, 18), ZIndex = 2, Parent = parent })
			text({ Text = subtitle, TextSize = 12, ColorKey = "SubText", Position = UDim2.fromOffset(14, 31), Size = UDim2.new(1, -28, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = parent })
		end

		local function tile(parent, column, rowIndex, tileHeight, title, subtitle, onClick)
			local button = create("TextButton", {
				Text = "",
				AutoButtonColor = false,
				BackgroundTransparency = 0.15,
				Position = UDim2.new(column * 0.5, column == 0 and 12 or 4, 0, 56 + rowIndex * (tileHeight + 8)),
				Size = UDim2.new(0.5, -16, 0, tileHeight),
				ZIndex = 2,
				Parent = parent,
			})
			paint(button, { BackgroundColor3 = "Element" })
			corner(button, 6)
			stroke(button, "Border", 0.3)
			text({ Text = title, TextSize = 14, Weight = Enum.FontWeight.SemiBold, Position = UDim2.new(0, 12, 0.5, -17), Size = UDim2.new(1, -24, 0, 18), ZIndex = 3, Parent = button })
			local sub = text({ Text = subtitle, TextSize = 12, ColorKey = "SubText", Position = UDim2.new(0, 12, 0.5, 2), Size = UDim2.new(1, -24, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = button })
			hover(button, function()
				tween(button, { BackgroundColor3 = Theme.ElementHover }, 0.12)
			end, function()
				tween(button, { BackgroundColor3 = Theme.Element }, 0.15)
			end)
			if onClick then
				button.MouseButton1Click:Connect(onClick)
			end
			return sub
		end

		local top = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 96), LayoutOrder = 1, Parent = root })
		local avatarCard = create("Frame", { Size = UDim2.fromOffset(96, 96), Parent = top })
		paint(avatarCard, { BackgroundColor3 = "Groupbox" })
		corner(avatarCard, 8)
		stroke(avatarCard, "Border")
		create("ImageLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, -8, 1, -8),
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150",
			Parent = avatarCard,
		})
		local greet = create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 108, 0.5, 0), Size = UDim2.new(1, -108, 0, 66), Parent = top })
		paint(greet, { BackgroundColor3 = "Groupbox" })
		corner(greet, 8)
		stroke(greet, "Border")
		text({ Text = "Hello, " .. LocalPlayer.DisplayName, TextSize = 18, Weight = Enum.FontWeight.Bold, Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -32, 0, 22), TextTruncate = Enum.TextTruncate.AtEnd, Parent = greet })
		text({ Text = "@" .. LocalPlayer.Name .. "  -  " .. (homeOpts.Title or Library.Name), TextSize = 13, ColorKey = "SubText", Position = UDim2.fromOffset(16, 36), Size = UDim2.new(1, -32, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, Parent = greet })

		local grid = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = root })
		local leftColumn = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = grid })
		list(leftColumn, 12)
		local rightColumn = create("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0.5, 6, 0, 0), Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = grid })
		list(rightColumn, 12)

		local server = card(leftColumn, 238, 1, Color3.fromRGB(40, 200, 120), 90, bottomGlow)
		header(server, "Server", "Information on the session you're currently in")
		local playersSub = tile(server, 0, 0, 50, "Players", "")
		local maxSub = tile(server, 1, 0, 50, "Maximum Players", Players.MaxPlayers .. " players can join this server")
		local pingSub = tile(server, 0, 1, 50, "Latency", "")
		local regionSub = tile(server, 1, 1, 50, "Server Region", "...")
		local timeSub = tile(server, 0, 2, 50, "In server for", "")
		tile(server, 1, 2, 50, "Join Script", "Tap to copy join script", function()
			local script = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, game.JobId)
			local ok = pcall(setclipboard, script)
			Library:Notify({ Title = "Server", Text = ok and "join script copied" or "clipboard not supported", Type = ok and "success" or "error", Duration = 2 })
		end)

		local discord = card(leftColumn, 88, 2, Color3.fromRGB(88, 101, 242), 0, sideGlow)
		text({ Text = "Discord", TextSize = 22, Weight = Enum.FontWeight.Bold, Position = UDim2.fromOffset(18, 16), Size = UDim2.new(1, -36, 0, 26), ZIndex = 2, Parent = discord })
		text({ Text = homeOpts.DiscordText or "Tap to join the Discord Server", TextSize = 14, ColorKey = "SubText", Position = UDim2.fromOffset(18, 46), Size = UDim2.new(1, -36, 0, 18), ZIndex = 2, Parent = discord })
		icon("arrow-up-right", 18, "Text", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16), ZIndex = 2, Parent = discord })
		local discordHit = create("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = discord })
		local discordStroke = discord:FindFirstChildOfClass("UIStroke")
		hover(discordHit, function()
			discordStroke.Color = Color3.fromRGB(88, 101, 242)
		end, function()
			discordStroke.Color = Theme.Border
		end)
		discordHit.MouseButton1Click:Connect(function()
			Library:JoinDiscord(homeOpts.Discord)
		end)

		local executorName = "Unknown"
		pcall(function()
			if identifyexecutor then
				executorName = (identifyexecutor())
			elseif getexecutorname then
				executorName = getexecutorname()
			end
		end)
		local executor = card(rightColumn, 88, 1, "Accent", 0, sideGlow)
		text({ Text = tostring(executorName), TextSize = 22, Weight = Enum.FontWeight.Bold, Position = UDim2.fromOffset(18, 16), Size = UDim2.new(1, -36, 0, 26), ZIndex = 2, Parent = executor })
		text({ Text = homeOpts.ExecutorText or "Your executor seems to support this script.", TextSize = 14, ColorKey = "SubText", TextWrapped = true, Position = UDim2.fromOffset(18, 46), Size = UDim2.new(1, -36, 0, 34), TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 2, Parent = executor })

		local friends = card(rightColumn, 238, 2, Color3.fromRGB(230, 170, 40), 90, bottomGlow)
		header(friends, "Friends", "Find out what your friends are currently doing")
		local inServerSub = tile(friends, 0, 0, 79, "In Server", "...")
		local offlineSub = tile(friends, 1, 0, 79, "Offline", "...")
		local onlineSub = tile(friends, 0, 1, 79, "Online", "...")
		local allSub = tile(friends, 1, 1, 79, "All", "...")

		local function plural(count, word)
			return count == 0 and ("no " .. word .. "s") or (count .. " " .. word .. (count == 1 and "" or "s"))
		end
		local function refreshInServer()
			task.spawn(function()
				local count = 0
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer then
						local ok, isFriend = pcall(LocalPlayer.IsFriendsWith, LocalPlayer, player.UserId)
						if ok and isFriend then
							count += 1
						end
					end
				end
				inServerSub.Text = plural(count, "friend")
			end)
		end
		task.spawn(function()
			local total, online = nil, nil
			pcall(function()
				local pages = Players:GetFriendsAsync(LocalPlayer.UserId)
				local count = 0
				while true do
					count += #pages:GetCurrentPage()
					if pages.IsFinished then
						break
					end
					pages:AdvanceToNextPageAsync()
				end
				total = count
			end)
			pcall(function()
				online = #LocalPlayer:GetFriendsOnline(200)
			end)
			allSub.Text = total and plural(total, "friend") or "unavailable"
			onlineSub.Text = online and plural(online, "friend") or "unavailable"
			offlineSub.Text = (total and online) and plural(math.max(total - online, 0), "friend") or "unavailable"
		end)
		refreshInServer()
		connect(Players.PlayerAdded, refreshInServer)
		connect(Players.PlayerRemoving, function()
			task.defer(refreshInServer)
		end)
		task.spawn(function()
			local region = "Unknown"
			pcall(function()
				region = cloneref(game:GetService("LocalizationService")):GetCountryRegionForPlayerAsync(LocalPlayer)
			end)
			regionSub.Text = tostring(region)
		end)

		local function update()
			local count = #Players:GetPlayers()
			playersSub.Text = count .. " playing"
			maxSub.Text = Players.MaxPlayers .. " players can join this server"
			local ping = 0
			pcall(function()
				ping = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5)
			end)
			pingSub.Text = ping .. "ms"
			local elapsed = math.floor(workspace.DistributedGameTime)
			timeSub.Text = string.format("%02d:%02d:%02d", elapsed // 3600, elapsed // 60 % 60, elapsed % 60)
		end
		update()
		local running = false
		local function watch()
			if running or Library.Unloaded or not Library.Open or not page.Frame.Visible then
				return
			end
			running = true
			task.spawn(function()
				while Library.Open and page.Frame.Visible and not Library.Unloaded do
					update()
					task.wait(1)
				end
				running = false
			end)
		end
		table.insert(page.OnShow, watch)
		table.insert(Library.OpenChanged, watch)
		return tab
	end

	table.insert(Library.Windows, Window)
	refreshScale()
	return Window
end

function Library:JoinDiscord(invite)
	local code = tostring(invite or ""):match("([%w%-_]+)/?$")
	if not code or code == "" then
		return
	end
	task.spawn(function()
		local request = (syn and syn.request) or http_request or request or (http and http.request) or (fluxus and fluxus.request)
		local opened = false
		if request then
			local ok, response = pcall(request, {
				Url = "http://127.0.0.1:6463/rpc?v=1",
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json",
					["Origin"] = "https://discord.com",
				},
				Body = HttpService:JSONEncode({
					cmd = "INVITE_BROWSER",
					args = { code = code },
					nonce = HttpService:GenerateGUID(false),
				}),
			})
			opened = ok and type(response) == "table" and tonumber(response.StatusCode) == 200
		end
		if opened then
			Library:Notify({ Title = "Discord", Text = "invite opened in your Discord app", Type = "success", Duration = 3 })
		else
			pcall(setclipboard, "https://discord.gg/" .. code)
			Library:Notify({ Title = "Discord", Text = "discord.gg/" .. code .. " copied to clipboard", Type = "info", Duration = 3 })
		end
	end)
end

local Blur = nil
local function setBlur(state)
	if state and Library.BlurEnabled then
		if not Blur or not Blur.Parent then
			Blur = Instance.new("BlurEffect")
			Blur.Name = "CommissionBlur"
			Blur.Size = 0
			Blur.Parent = Lighting
		end
		tween(Blur, { Size = 14 }, 0.25)
	elseif Blur then
		local current = Blur
		tween(current, { Size = 0 }, 0.2)
		task.delay(0.22, function()
			if current and not Library.Open then
				current:Destroy()
				if Blur == current then
					Blur = nil
				end
			end
		end)
	end
end

function Library:SetBlur(state)
	Library.BlurEnabled = state == true
	setBlur(Library.Open and Library.BlurEnabled)
end

function Library:SetGlow(state)
	Library.GlowEnabled = state == true
	for _, window in ipairs(Library.Windows) do
		window.Glow.Visible = Library.GlowEnabled
	end
end

function Library:Toggle(value)
	if value == nil then
		value = not Library.Open
	end
	Library.Open = value
	for _, window in ipairs(Library.Windows) do
		window.Holder.Visible = value
	end
	if not value then
		closePopup()
		if Tooltip then
			Tooltip:Destroy()
			Tooltip = nil
		end
	end
	setBlur(value)
	for _, fn in ipairs(Library.OpenChanged) do
		task.spawn(fn)
	end
end

local NOTIFY_COLORS = {
	info = function()
		return Theme.Accent
	end,
	success = function()
		return Color3.fromRGB(70, 210, 120)
	end,
	warning = function()
		return Color3.fromRGB(240, 180, 40)
	end,
	error = function()
		return Color3.fromRGB(240, 70, 80)
	end,
}
local NOTIFY_ICONS = { info = "info", success = "circle-check", warning = "triangle-alert", error = "circle-x" }
local NotifyHolder = create("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -16, 1, -16),
	Size = UDim2.fromOffset(300, 600),
	Parent = Library.HudGui,
})
list(NotifyHolder, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
scaled(NotifyHolder)

function Library:Notify(opts, duration, kind)
	if type(opts) ~= "table" then
		opts = { Text = tostring(opts), Duration = duration, Type = kind }
	end
	local kindName = string.lower(opts.Type or "info")
	local persistent = opts.Persistent == true or kindName == "persistent"
	if kindName == "persistent" then
		kindName = "info"
	end
	local accent = (NOTIFY_COLORS[kindName] or NOTIFY_COLORS.info)()
	local card = create("Frame", { Size = UDim2.fromOffset(290, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = NotifyHolder })
	local inner = create("Frame", { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(320, 0), Parent = card })
	paint(inner, { BackgroundColor3 = "Groupbox" })
	corner(inner, 6)
	local s = create("UIStroke", { Color = accent, Transparency = 0.5, Parent = inner })
	padding(inner, 14, 34, 10, 12)
	local bar = create("Frame", { BackgroundColor3 = accent, Position = UDim2.new(0, -14, 0, -10), Size = UDim2.new(0, 3, 1, 22), Parent = inner })
	corner(bar, 2)
	local iconImage = create("ImageLabel", { BackgroundTransparency = 1, ImageColor3 = accent, Position = UDim2.fromOffset(0, 1), Size = UDim2.fromOffset(16, 16), Parent = inner })
	applyIcon(iconImage, NOTIFY_ICONS[kindName] or "info")
	local body = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -24, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = inner })
	list(body, 2)
	text({ Text = opts.Title or Library.Name, TextSize = 14, Weight = Enum.FontWeight.SemiBold, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, Parent = body })
	text({ Text = opts.Text or "", TextSize = 13, ColorKey = "SubText", TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = body })
	local progress = create("Frame", { BackgroundColor3 = accent, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, -14, 1, 12), Size = UDim2.new(1, 48, 0, 2), Visible = not persistent, Parent = inner })
	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		tween(inner, { Position = UDim2.fromOffset(320, 0) }, 0.25)
		task.delay(0.26, function()
			card:Destroy()
		end)
	end
	local closeButton = create("ImageButton", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 24, 0, 0), Size = UDim2.fromOffset(14, 14), Parent = inner })
	paint(closeButton, { ImageColor3 = "SubText" })
	applyIcon(closeButton, "x")
	closeButton.MouseButton1Click:Connect(close)
	tween(inner, { Position = UDim2.fromOffset(0, 0) }, 0.3, Enum.EasingStyle.Quart)
	if not persistent then
		local life = opts.Duration or 4
		tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, life, Enum.EasingStyle.Linear)
		task.delay(life, close)
	end
	return { Close = close }
end

local function hudPanel(titleText, position)
	local frame = create("Frame", { Position = position, Size = UDim2.fromOffset(200, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, Parent = Library.HudGui })
	paint(frame, { BackgroundColor3 = "Groupbox" })
	corner(frame, 6)
	stroke(frame, "Border")
	scaled(frame)
	local header = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Parent = frame })
	text({ Text = titleText, TextSize = 13, Weight = Enum.FontWeight.SemiBold, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), Parent = header })
	local accentLine = create("Frame", { Position = UDim2.fromOffset(12, 29), Size = UDim2.new(1, -24, 0, 1), Parent = frame })
	paint(accentLine, { BackgroundColor3 = "Accent" })
	local holder = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 34), Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = frame })
	padding(holder, 12, 12, 0, 8)
	list(holder, 2)
	makeDraggable(header, frame)
	return frame, holder
end

function refreshHudLists()
	if KeybindList.frame then
		for _, child in ipairs(KeybindList.holder:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		local order = 0
		for _, option in pairs(Library.Options) do
			if option.Type == "KeyPicker" and option.Value ~= "None" then
				order += 1
				local on = option:GetState()
				local rowFrame = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = order, Parent = KeybindList.holder })
				text({ Text = option.Text, TextSize = 12, ColorKey = on and "Text" or "SubText", Size = UDim2.new(1, -70, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = rowFrame })
				text({ Text = "[" .. option.Value .. "] " .. option.Mode:sub(1, 1), TextSize = 12, ColorKey = on and "Accent" or "SubText", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 70, 1, 0), Parent = rowFrame })
			end
		end
	end
	if ActiveList.frame then
		for _, child in ipairs(ActiveList.holder:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		local order = 0
		for _, toggle in pairs(Library.Toggles) do
			if toggle.Value then
				order += 1
				text({ Text = toggle.Text, TextSize = 12, ColorKey = "Text", Size = UDim2.new(1, 0, 0, 18), LayoutOrder = order, TextTruncate = Enum.TextTruncate.AtEnd, Parent = ActiveList.holder })
			end
		end
	end
end

function Library:SetKeybindList(state)
	if not KeybindList.frame then
		KeybindList.frame, KeybindList.holder = hudPanel("Keybinds", UDim2.fromOffset(16, 260))
	end
	KeybindList.frame.Visible = state == true
	refreshHudLists()
end

function Library:SetActiveList(state)
	if not ActiveList.frame then
		ActiveList.frame, ActiveList.holder = hudPanel("Active", UDim2.fromOffset(16, 420))
	end
	ActiveList.frame.Visible = state == true
	refreshHudLists()
end

function Library:SetWatermark(state, label)
	if not Library.Watermark then
		local frame = create("Frame", { Position = UDim2.fromOffset(16, 16), Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X, Parent = Library.HudGui })
		paint(frame, { BackgroundColor3 = "Groupbox" })
		corner(frame, 6)
		stroke(frame, "Border")
		scaled(frame)
		padding(frame, 12, 12, 0, 0)
		local bar = create("Frame", { Position = UDim2.new(0, -12, 0, 6), Size = UDim2.new(0, 2, 1, -12), Parent = frame })
		paint(bar, { BackgroundColor3 = "Accent" })
		local labelInst = text({ Text = "", TextSize = 13, Weight = Enum.FontWeight.Medium, RichText = true, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X, Parent = frame })
		makeDraggable(frame, frame)
		Library.Watermark = { Frame = frame, Label = labelInst, Text = label or Library.Name }
	end
	local wm = Library.Watermark
	wm.Text = label or wm.Text
	wm.Frame.Visible = state == true
	if state and not wm.Running then
		wm.Running = true
		task.spawn(function()
			local frames, last = 0, os.clock()
			local counter = RunService.RenderStepped:Connect(function()
				frames += 1
			end)
			while wm.Frame.Visible and not Library.Unloaded do
				task.wait(0.5)
				local now = os.clock()
				local fps = math.floor(frames / (now - last) + 0.5)
				frames, last = 0, now
				local ping = 0
				pcall(function()
					ping = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5)
				end)
				wm.Label.Text = string.format('<font color="#%s"><b>%s</b></font>  |  %d fps  |  %d ms  |  %s', Theme.Accent:ToHex(), wm.Text, fps, ping, os.date("%H:%M:%S"))
			end
			counter:Disconnect()
			wm.Running = false
		end)
	end
end

function Library:CreateTargetIndicator()
	local frame = create("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -110), Size = UDim2.fromOffset(280, 86), Visible = false, Parent = Library.HudGui })
	paint(frame, { BackgroundColor3 = "Groupbox" })
	corner(frame, 6)
	stroke(frame, "Accent", 0.4)
	scaled(frame)
	makeDraggable(frame, frame)
	local avatar = create("ImageLabel", { Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(66, 66), Parent = frame })
	paint(avatar, { BackgroundColor3 = "Element" })
	corner(avatar, 5)
	local name = text({ Text = "", TextSize = 14, Weight = Enum.FontWeight.SemiBold, Position = UDim2.fromOffset(86, 8), Size = UDim2.new(1, -96, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, Parent = frame })
	local info = text({ Text = "", TextSize = 12, ColorKey = "SubText", Position = UDim2.fromOffset(86, 26), Size = UDim2.new(1, -96, 0, 14), Parent = frame })
	local function bar(y, colorA, colorB)
		local back = create("Frame", { Position = UDim2.fromOffset(86, y), Size = UDim2.new(1, -96, 0, 12), Parent = frame })
		paint(back, { BackgroundColor3 = "Element" })
		corner(back, 3)
		local fill = create("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), Parent = back })
		corner(fill, 3)
		create("UIGradient", { Color = ColorSequence.new(colorA, colorB), Parent = fill })
		local valueText = text({ Text = "", TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = back })
		return fill, valueText
	end
	local hpFill, hpText = bar(46, Color3.fromRGB(255, 80, 90), Color3.fromRGB(90, 255, 140))
	local arFill, arText = bar(62, Color3.fromRGB(70, 110, 255), Color3.fromRGB(130, 200, 255))
	local indicator = { Target = nil, GetArmor = nil, GetHealth = nil }
	local conn = nil
	local function stop()
		if conn then
			conn:Disconnect()
			conn = nil
		end
		frame.Visible = false
	end
	function indicator:SetTarget(player)
		indicator.Target = player
		if not player then
			stop()
			return
		end
		avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
		name.Text = player.DisplayName .. "  (@" .. player.Name .. ")"
		frame.Visible = true
		if not conn then
			conn = RunService.RenderStepped:Connect(function()
				local target = indicator.Target
				local char = target and target.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not target or target.Parent ~= Players then
					stop()
					return
				end
				local hp, maxHp = 0, 100
				if hum then
					hp = indicator.GetHealth and indicator.GetHealth(target, hum) or hum.Health
					maxHp = hum.MaxHealth > 0 and hum.MaxHealth or 100
				end
				local armor, maxArmor = 0, 100
				if indicator.GetArmor then
					armor, maxArmor = indicator.GetArmor(target)
					maxArmor = maxArmor or 100
				else
					local effects = char and char:FindFirstChild("BodyEffects")
					local value = effects and effects:FindFirstChild("Armor")
					armor = value and tonumber(value.Value) or 0
				end
				local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local theirRoot = char and char:FindFirstChild("HumanoidRootPart")
				local distance = (myRoot and theirRoot) and math.floor((myRoot.Position - theirRoot.Position).Magnitude) or 0
				info.Text = distance .. " studs  |  ID " .. target.UserId
				hpFill.Size = UDim2.fromScale(math.clamp(hp / maxHp, 0, 1), 1)
				hpText.Text = math.floor(hp) .. " / " .. math.floor(maxHp)
				arFill.Size = UDim2.fromScale(math.clamp(armor / maxArmor, 0, 1), 1)
				arText.Text = math.floor(armor) .. " / " .. math.floor(maxArmor)
			end)
		end
	end
	return indicator
end

local function configFolder()
	pcall(function()
		if not isfolder(Library.Folder) then
			makefolder(Library.Folder)
		end
		if not isfolder(Library.Folder .. "/configs") then
			makefolder(Library.Folder .. "/configs")
		end
		if not isfolder(Library.Folder .. "/themes") then
			makefolder(Library.Folder .. "/themes")
		end
	end)
	return Library.Folder .. "/configs"
end

local function cleanName(name)
	if type(name) ~= "string" then
		return nil
	end
	local cleaned = name:gsub("[^%w _%-]", "")
	cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
	return cleaned ~= "" and cleaned or nil
end

function Library:GetConfig()
	local data = {}
	for flag, option in pairs(Library.Options) do
		local kind = option.Type
		if kind == "Toggle" or kind == "Slider" or kind == "Input" then
			data[flag] = option.Value
		elseif kind == "RangeSlider" then
			data[flag] = { Min = option.Value.Min, Max = option.Value.Max }
		elseif kind == "Dropdown" or kind == "List" or kind == "PartPicker" then
			if type(option.Value) == "table" then
				local out = {}
				for key, on in pairs(option.Value) do
					if on then
						table.insert(out, key)
					end
				end
				data[flag] = { __multi = true, Values = out }
			else
				data[flag] = option.Value
			end
		elseif kind == "ColorPicker" then
			data[flag] = { Color = option.Value:ToHex(), Alpha = option.Alpha, Rainbow = option.Rainbow }
		elseif kind == "KeyPicker" then
			data[flag] = { Key = option.Value, Mode = option.Mode }
		end
	end
	local statuses = {}
	for userId, status in pairs(Library.Statuses) do
		statuses[tostring(userId)] = status
	end
	data.__statuses = statuses
	if Library.Flags.__esp_layout then
		data.__esp_layout = Library.Flags.__esp_layout
	end
	return HttpService:JSONEncode(data)
end

function Library:LoadConfigData(json)
	local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
	if not ok or type(data) ~= "table" then
		return false
	end
	for flag, value in pairs(data) do
		local option = Library.Options[flag]
		if option then
			pcall(function()
				if type(value) == "table" and value.__multi then
					option:SetValue(value.Values)
				else
					option:SetValue(value)
				end
			end)
		end
	end
	if type(data.__statuses) == "table" then
		Library.Statuses = {}
		for userId, status in pairs(data.__statuses) do
			Library.Statuses[tonumber(userId)] = status
		end
	end
	if type(data.__esp_layout) == "table" then
		Library.Flags.__esp_layout = data.__esp_layout
		for _, fn in ipairs(Library.LayoutLoaded or {}) do
			task.spawn(fn, data.__esp_layout)
		end
	end
	return true
end

function Library:SaveConfig(name)
	name = cleanName(name)
	if not name or type(writefile) ~= "function" then
		return false
	end
	return (pcall(writefile, configFolder() .. "/" .. name .. ".json", Library:GetConfig()))
end

function Library:LoadConfig(name)
	name = cleanName(name)
	if not name or type(readfile) ~= "function" then
		return false
	end
	local ok, body = pcall(readfile, configFolder() .. "/" .. name .. ".json")
	return ok and Library:LoadConfigData(body) or false
end

function Library:DeleteConfig(name)
	name = cleanName(name)
	if not name or type(delfile) ~= "function" then
		return false
	end
	return (pcall(delfile, configFolder() .. "/" .. name .. ".json"))
end

function Library:ListConfigs()
	local out = {}
	if type(listfiles) ~= "function" then
		return out
	end
	pcall(function()
		for _, file in ipairs(listfiles(configFolder())) do
			local name = tostring(file):match("([^/\\]+)%.json$")
			if name then
				table.insert(out, name)
			end
		end
	end)
	table.sort(out)
	return out
end

function Library:SetAutoload(name)
	if type(writefile) ~= "function" then
		return false
	end
	configFolder()
	if name then
		return (pcall(writefile, Library.Folder .. "/autoload.txt", name))
	end
	return (pcall(delfile, Library.Folder .. "/autoload.txt"))
end

function Library:LoadAutoload()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then
		return false
	end
	local path = Library.Folder .. "/autoload.txt"
	if not isfile(path) then
		return false
	end
	local name = readfile(path)
	local ok = Library:LoadConfig(name)
	if ok then
		Library:Notify({ Title = "Config", Text = "autoloaded " .. name, Type = "success", Duration = 3 })
	end
	return ok
end

function Library:SaveTheme(name)
	name = cleanName(name)
	if not name or type(writefile) ~= "function" then
		return false
	end
	configFolder()
	local data = { Font = Library.FontName }
	for _, zone in ipairs(Library.ThemeZones) do
		data[zone[1]] = Theme[zone[1]]:ToHex()
	end
	return (pcall(writefile, Library.Folder .. "/themes/" .. name .. ".json", HttpService:JSONEncode(data)))
end

function Library:LoadTheme(name)
	name = cleanName(name)
	if not name or type(readfile) ~= "function" then
		return false
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(Library.Folder .. "/themes/" .. name .. ".json"))
	end)
	if not ok or type(data) ~= "table" then
		return false
	end
	for _, zone in ipairs(Library.ThemeZones) do
		if type(data[zone[1]]) == "string" then
			local okColor, color = pcall(Color3.fromHex, data[zone[1]])
			if okColor then
				Library:SetThemeColor(zone[1], color)
			end
		end
	end
	if data.Font then
		Library:SetFont(data.Font)
	end
	return true
end

function Library:ListThemes()
	local out = {}
	if type(listfiles) ~= "function" then
		return out
	end
	configFolder()
	pcall(function()
		for _, file in ipairs(listfiles(Library.Folder .. "/themes")) do
			local name = tostring(file):match("([^/\\]+)%.json$")
			if name then
				table.insert(out, name)
			end
		end
	end)
	table.sort(out)
	return out
end

function Library:BuildSettings(owner)
	local themeBox = owner:AddLeftGroupbox("Theme", "palette")
	local presetNames = {}
	for name in pairs(Library.ThemePresets) do
		table.insert(presetNames, name)
	end
	table.sort(presetNames)
	themeBox:AddDropdown("__theme_preset", { Text = "Preset", Values = presetNames, Default = "Chrome Pink", Callback = function(value)
		if value then
			Library:ApplyPreset(value)
		end
	end })
	for _, zone in ipairs(Library.ThemeZones) do
		local key = zone[1]
		themeBox:AddLabel(zone[2]):AddColorPicker("__theme_" .. key, { Default = Theme[key], Title = zone[2], Callback = function(color)
			Library:SetThemeColor(key, color)
		end })
		local picker = Library.Options["__theme_" .. key]
		onTheme(function()
			if picker.Value ~= Theme[key] then
				picker.Value = Theme[key]
				picker.Swatch.BackgroundColor3 = Theme[key]
			end
		end)
	end
	themeBox:AddDivider("custom themes")
	themeBox:AddInput("__theme_name", { Text = "Theme Name", Placeholder = "my theme" })
	local savedThemes = themeBox:AddDropdown("__theme_saved", { Text = "Saved Themes", Values = Library:ListThemes(), AllowNull = true })
	themeBox:AddButtons({
		{ Text = "Save", Func = function()
			if Library:SaveTheme(Library.Flags.__theme_name) then
				savedThemes:SetValues(Library:ListThemes())
				Library:Notify({ Title = "Theme", Text = "saved", Type = "success", Duration = 2 })
			end
		end },
		{ Text = "Load", Func = function()
			if Library:LoadTheme(Library.Flags.__theme_saved) then
				Library:Notify({ Title = "Theme", Text = "loaded", Type = "success", Duration = 2 })
			end
		end },
	})

	local interface = owner:AddRightGroupbox("Interface", "monitor")
	interface:AddDropdown("__ui_font", { Text = "Font", Values = Library.Fonts, Default = Library.FontName, Callback = function(value)
		if value then
			Library:SetFont(value)
		end
	end })
	interface:AddSlider("__ui_scale", { Text = "UI Scale", Min = 50, Max = 150, Default = 100, Suffix = "%", Callback = function(value)
		Library:SetUserScale(value / 100)
	end })
	interface:AddToggle("__ui_blur", { Text = "Menu Blur", Default = true, Callback = function(value)
		Library:SetBlur(value)
	end })
	interface:AddToggle("__ui_glow", { Text = "Window Glow", Default = true, Callback = function(value)
		Library:SetGlow(value)
	end })
	interface:AddToggle("__ui_watermark", { Text = "Watermark", Default = false, Callback = function(value)
		Library:SetWatermark(value)
	end })
	interface:AddToggle("__ui_keybinds", { Text = "Keybind List", Default = false, Callback = function(value)
		Library:SetKeybindList(value)
	end })
	interface:AddToggle("__ui_active", { Text = "Active Toggles List", Default = false, Callback = function(value)
		Library:SetActiveList(value)
	end })
	interface:AddLabel("Menu Toggle Key"):AddKeyPicker("__ui_toggle_key", { Default = Library.ToggleKey.Name, Text = "Menu", Mode = "Toggle", Callback = function(value)
		local ok, code = pcall(function()
			return Enum.KeyCode[value]
		end)
		if ok and code then
			Library.ToggleKey = code
		end
	end })
	interface:AddButton({ Text = "Unload", Func = function()
		Library:Unload()
	end })

	local configBox = owner:AddRightGroupbox("Configs", "folder")
	configBox:AddInput("__cfg_name", { Text = "Config Name", Placeholder = "name" })
	local configList = configBox:AddList("__cfg_list", { Text = "Configs", Values = Library:ListConfigs(), Height = 130 })
	local function selectedConfig()
		return Library.Flags.__cfg_list or Library.Flags.__cfg_name
	end
	local function refresh()
		configList:SetValues(Library:ListConfigs())
	end
	configBox:AddButtons({
		{ Text = "Save", Func = function()
			local name = Library.Flags.__cfg_name ~= "" and Library.Flags.__cfg_name or Library.Flags.__cfg_list
			if Library:SaveConfig(name) then
				refresh()
				Library:Notify({ Title = "Config", Text = "saved " .. tostring(name), Type = "success", Duration = 2 })
			else
				Library:Notify({ Title = "Config", Text = "type a config name first", Type = "warning", Duration = 2 })
			end
		end },
		{ Text = "Load", Func = function()
			if Library:LoadConfig(selectedConfig()) then
				Library:Notify({ Title = "Config", Text = "loaded " .. tostring(selectedConfig()), Type = "success", Duration = 2 })
			else
				Library:Notify({ Title = "Config", Text = "could not load config", Type = "error", Duration = 2 })
			end
		end },
		{ Text = "Delete", Func = function()
			Library:DeleteConfig(selectedConfig())
			refresh()
		end },
	})
	configBox:AddButtons({
		{ Text = "Set Autoload", Func = function()
			local name = selectedConfig()
			if name and Library:SetAutoload(name) then
				Library:Notify({ Title = "Config", Text = "autoload: " .. name, Type = "info", Duration = 2 })
			end
		end },
		{ Text = "Clear Autoload", Func = function()
			Library:SetAutoload(nil)
		end },
		{ Text = "Refresh", Func = refresh },
	})
	configBox:AddButtons({
		{ Text = "Export", Func = function()
			local ok = pcall(function()
				setclipboard(Library:GetConfig())
			end)
			Library:Notify({ Title = "Config", Text = ok and "copied to clipboard" or "clipboard not supported", Type = ok and "success" or "error", Duration = 2 })
		end },
		{ Text = "Import", Func = function()
			local raw = Library.Flags.__cfg_import
			if Library:LoadConfigData(raw or "") then
				Library:Notify({ Title = "Config", Text = "imported", Type = "success", Duration = 2 })
			else
				Library:Notify({ Title = "Config", Text = "paste a config in the import box", Type = "warning", Duration = 2 })
			end
		end },
	})
	configBox:AddInput("__cfg_import", { Text = "Import Config", Placeholder = "paste exported config here" })
end

function Library:Unload()
	Library.Unloaded = true
	closePopup()
	for _, fn in ipairs(Library.OnUnload) do
		pcall(fn)
	end
	for _, conn in ipairs(Library.Connections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	if Rainbow.conn then
		Rainbow.conn:Disconnect()
	end
	if Blur then
		pcall(function()
			Blur:Destroy()
		end)
	end
	for _, gui in ipairs({ Library.Gui, Library.HudGui, Library.PopupGui }) do
		pcall(function()
			gui:Destroy()
		end)
	end
end

function Library:OnUnloadCallback(fn)
	table.insert(Library.OnUnload, fn)
end

connect(UserInputService.InputBegan, function(input, processed)
	if processed or UserInputService:GetFocusedTextBox() then
		return
	end
	if input.KeyCode == Library.ToggleKey then
		Library:Toggle()
	end
end)

do
	local camera = workspace.CurrentCamera
	if camera then
		connect(camera:GetPropertyChangedSignal("ViewportSize"), refreshScale)
	end
	refreshScale()
end

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	local mobileButton = create("ImageButton", { Position = UDim2.fromOffset(16, 80), Size = UDim2.fromOffset(48, 48), AutoButtonColor = false, Parent = Library.HudGui })
	paint(mobileButton, { BackgroundColor3 = "Sidebar", ImageColor3 = "Accent" })
	corner(mobileButton, "full")
	stroke(mobileButton, "Accent", 0.2)
	applyIcon(mobileButton, "eye")
	makeDraggable(mobileButton, mobileButton, function()
		Library:Toggle()
	end)
end

task.defer(function()
	if Library.Open then
		setBlur(true)
	end
end)

return Library
