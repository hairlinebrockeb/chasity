if shared.Chrysalism then
	shared.Chrysalism.Close();
end;

local Chrysalism = {Active = true, Connections = {}, Environment = {Logs = {}}};

local httpget=game.HttpGet;local function HttpGet(...)return httpget(game, ...)end;
local function HttpLoad(Url)
	return loadstring(HttpGet(Url))();
end;

local RepUrl = "https://gitlab.com/te4224/Scripts/-/raw/main/Chrysalism/V1/"
local function import(path)
	return HttpLoad(RepUrl .. path);
end;
local ScriptUrl = RepUrl .. "script/";
local function importscript(path)
	return import(path);
end;

local tostring2, Types, DataTypes = importscript("tostring2.lua");
assert(type(tostring2) == "function" and type(Types) == "table" and type(DataTypes) == "table", "Failed to get 'tostring2' / 'tostring2.Types' / 'tostring2.DataTypes'.");

local FormatTable = importscript("format table.lua");
assert(type(FormatTable) == "function", "Failed to get 'format table'.");

local Highlighter = importscript("syntax highlighter.lua");
assert(type(Highlighter) == "table", "Failed to get highlighter");

-- local GetConfig = importscript("confighandler.lua");
-- assert(type(GetConfig) == "function", "Failed to get GetConfig.");
-- local Config = GetConfig("ChrysalismV1/configs/main.config");

local FFC = game.FindFirstChild;
local GetChildren = game.GetChildren;
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;

local GUI = importscript("ui2.lua");
local MainFrame = GUI.Main;

local sub = string.sub;
local gmatch = string.gmatch;
local gsub = string.gsub;
local find = string.find;
local split = string.split;
local lower = string.lower;

local insert = table.insert;
local remove = table.remove;
local concat = table.concat;

local tfind = function(Table, Value)
	for I, V in next, Table do
		if V == Value then
			return I;
		end;
	end;
end;

local UIS = game:GetService("UserInputService");

local TweenService = game:GetService"TweenService";
local tscreate = TweenService.Create;

local Part = Instance.new"Part";local twplay = tscreate(TweenService, Part, TweenInfo.new(0), {Transparency = 0}).Play;Part:Destroy();
local function PlayTween(...)
	twplay(tscreate(TweenService, ...));
end;

local function CheckProperty(Object, Property)
	return typeof(Object) == "Instance" and (pcall(function()return Object[Property];end));
end;

local SelectedSection, SectionButtons, Sections, BoxFunctions, BoxFunctionButtons, AdminSections, AdminSectionButtons, ButtonFunctions, RspyIndex, RspyIndexBox, RspyCount, SelectedRemoteLabel;
local RemoteSpyBox, RemoteSpyBoxLines, RemoteContainer, RemoteTemplate;
local Minimize, Close, AddOldValues;
do -- handle UI
	--Setup For Animation
	local OldValues = {
		BackgroundTransparency = {},
		TextTransparency = {},
		TextStrokeTransparency = {},
		ScrollBarImageTransparency = {}
	};
	AddOldValues = function(Object)
		if CheckProperty(Object, "BackgroundTransparency") then
			OldValues.BackgroundTransparency[Object] = Object.BackgroundTransparency;
		end;
		if CheckProperty(Object, "TextTransparency") then
			OldValues.TextTransparency[Object] = Object.TextTransparency;
		end;
		if CheckProperty(Object, "TextStrokeTransparency") then
			OldValues.TextStrokeTransparency[Object] = Object.TextStrokeTransparency;
		end;
		if CheckProperty(Object, "ScrollBarImageTransparency") then
			OldValues.ScrollBarImageTransparency[Object] = Object.ScrollBarImageTransparency;
		end;

		for I, Child in next, GetChildren(Object) do
			AddOldValues(Child);
		end;
	end;
	-- for I, Descendant in next, GUI:GetDescendants() do
	-- 	AddOldValues(Descendant);
	-- end;
	AddOldValues(GUI);

	MainFrame.Size = UDim2.new(0, 145, 0, 106); --0, 644, 0, 468
	for I, Child in next, MainFrame.SectionButtons:GetChildren() do
		if Child:IsA"TextButton" then
			Child.TextTransparency = 1; --0
		end;
	end;


	do -- smooth drag
		local TweenService = game:GetService'TweenService';
		local tscreate = TweenService.Create;

		local Part = Instance.new'Part';local twplay = tscreate(TweenService, Part, TweenInfo.new(0), {Transparency = 0}).Play;Part:Destroy();
		local function PlayTween(...)
			twplay(tscreate(TweenService, ...));
		end;
		local DragArea = MainFrame.DragArea;

		local dragToggle = nil
		local dragSpeed = .25
		local dragInput = nil
		local dragStart = nil
		local startPos = nil

		local function updateInput(input)
			local Delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
			PlayTween(MainFrame, TweenInfo.new(dragSpeed, 8), {Position = Position});
		end

		DragArea.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				dragToggle = true
				dragStart = input.Position
				startPos = MainFrame.Position
				input.Changed:Connect(function()
					if (input.UserInputState == Enum.UserInputState.End) then
						dragToggle = false
					end
				end)
			end
		end)

		DragArea.InputChanged:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				dragInput = input
			end
		end)

		table.insert(Chrysalism.Connections, UIS.InputChanged:Connect(function(input)
			if input == dragInput and dragToggle then
				updateInput(input)
			end
		end));
	end;
	SectionButtons = {};
	Sections = {};
	
	BoxFunctions = {};
	BoxFunctionButtons = {};
	RspyIndex = {Button = {}, Box = {}, ButtonFunctions = {}, BoxFunctions = {}};
	
	AdminSections = {};
	AdminSectionButtons = {};

	ButtonFunctions = {};
	
	local PropertyIndexPattern = "([^=]+)=([^,]+)";
	local PropertyValuePattern = "=([^,]+)";
	local function GetProperties(Value)
		local String;
		if find(Value, ":") then
			String = split(Value, ":")[2];
		else
			String = Value;
		end;
		local Indexes = {};
		local Values = {};
		for X in gmatch(String, PropertyIndexPattern) do
			insert(Indexes, X);
		end;
		for X in gmatch(String, PropertyValuePattern) do
			insert(Values, X);
		end;
		if #Indexes == #Values then
			local Properties = {};
			
			for I, Index in next, Indexes do
				Properties[Index] = Values[I];
			end;
			
			return Properties;
		else
			return error("Amount of indexes was not equal to amount of values", 2);
		end;
	end;
	local function QuoteCheck(Str)
		if sub(Str, 1, 1) == '"' and sub(Str, -1, -1) == '"' then
			return sub(Str, 2, -2);
		else
			return error(Str .. " is not encased in quotes!");
		end;
	end;
	local function StartsWith(String, Query)
		return sub(String, 1, #Query) == Query;
	end;

	local TypePattern = "{([^{]+)}";
	for x, Inst in next, MainFrame:GetDescendants() do
		if StartsWith(Inst.Name, "*_") then
			local Name = Inst.Name;
			local Type = gmatch(Name, TypePattern)();
			
			local Properties = GetProperties(Name);
			
			if Type == "button>section" then
				local SectionName = QuoteCheck(Properties.section);
				if SectionName then
					SectionButtons[SectionName] = Inst;
				else
					error("Failed to get section name for section button: " .. Name);
				end;
			elseif Type == "section" then
				local SectionName = QuoteCheck(Properties.name);
				if SectionName then
					Sections[SectionName] = Inst;
				else
					error("Failed to get section name for section: " .. Name);
				end;
			elseif Type == "button>boxfunction" then
				local FunctionName = QuoteCheck(Properties["function"]);
				if FunctionName then
					BoxFunctionButtons[FunctionName] = Inst;
				else
					error("Failed to get function name for boxfunction button: " .. Name);
				end;
			elseif Type == "adminsection" then
				local SectionName = QuoteCheck(Properties.name);
				if SectionName then
					AdminSections[SectionName] = Inst;
				else
					error("Failed to get section name for admin section: " .. Name);
				end;
			elseif Type == "button>adminsection" then
				local SectionName = QuoteCheck(Properties.section);
				if SectionName then
					AdminSectionButtons[SectionName] = Inst;
				else
					error("Failed to get section name for admin section button: " .. Name);
				end;
			elseif Type == "box>rspy_index" then
				local FunctionName = QuoteCheck(Properties["function"]);
				if FunctionName then
					RspyIndex.Box[FunctionName] = Inst;
				else
					error("Failed to get function name for rspy_index box: " .. Name);
				end;
			elseif Type == "button>rspy_index" then
				local FunctionName = QuoteCheck(Properties["function"]);
				if FunctionName then
					RspyIndex.Button[FunctionName] = Inst;
				else
					error("Failed to get function name for rspy_index button: " .. Name);
				end;
			elseif Type == "button" then
				local FunctionName = QuoteCheck(Properties["function"]);
				if FunctionName then
					ButtonFunctions[FunctionName] = Inst;
				else
					error("Failed to get function name for rspy_index box: " .. Name);
				end;
			end;
		end;
	end;

	local VisiblePos = UDim2.new(0, 0, 0, 0); local VisiblePosDict = {Position = VisiblePos};
	local InVisiblePos = UDim2.new(-1, 0, 0, 0); local InVisiblePosDict = {Position = InVisiblePos};
	local UnHighlightedDict = {TextStrokeTransparency = 0.88};
	local HighlightedDict = {TextStrokeTransparency = 0.81};

	local TInfo = TweenInfo.new(0.3, 8);
	
	for Name, Section in next, Sections do
		Section.Visible = true;
		Section.Position = InVisiblePos;
		local Button = SectionButtons[Name];
		if Button then
			Button.MouseButton1Click:Connect(function()
				if SelectedSection then
					PlayTween(SelectedSection, TInfo, InVisiblePosDict);
					PlayTween(SectionButtons[tfind(Sections, SelectedSection)], TInfo, UnHighlightedDict);
				end;
				SelectedSection = Section;
				PlayTween(Section, TInfo, VisiblePosDict);
				PlayTween(Button, TInfo, HighlightedDict);
			end);
		else
			error("Failed to find button for section: " .. Name);
		end;
	end;

	local Section = Sections["Remote Spy"];
	SelectedRemoteLabel = Section.SelectedRemote;
	local Body = Section.Body;
	RemoteSpyBox = Body.BoxFrame.Inner.box;
	RemoteSpyBoxLines = Body.BoxFrame.Inner.Lines;
	RspyIndexBox = Body.Top:FindFirstChildWhichIsA("TextBox");
	RspyCount = Body.Top.Count;

	RemoteContainer = Section.RemoteContainer;
	RemoteTemplate = RemoteContainer.Template;
	RemoteTemplate.Parent = nil;

	local InVisiblePos = UDim2.new(1, 0, 0, 0); local InVisiblePosDict = {Position = InVisiblePos};
	local Section = Sections.Admin;
	local SelectedAdminSection;

	-- local TInfo = TweenInfo.new(0.4, 8);
	local SelectedDict = {TextStrokeTransparency = 0.6};
	local UnSelectedDict = {TextStrokeTransparency = 0.8};
	local HoveredDict = {BackgroundTransparency = 0.85};
	local UnHoveredDict = {BackgroundTransparency = 1};

	for Name, AdminSection in next, AdminSections do
		AdminSection.Visible = true;
		AdminSection.Position = InVisiblePos;
		local Button = AdminSectionButtons[Name];
		if Button then
			Button.MouseButton1Click:Connect(function()
				if SelectedAdminSection then
					PlayTween(SelectedAdminSection, TInfo, InVisiblePosDict);
					PlayTween(AdminSectionButtons[tfind(AdminSections, SelectedAdminSection)], TInfo, UnSelectedDict);
				end;
				PlayTween(Button, TInfo, SelectedDict)
				SelectedAdminSection = AdminSection;
				PlayTween(AdminSection, TInfo, VisiblePosDict);
			end);
			Button.MouseEnter:Connect(function()
				PlayTween(Button, TInfo, HoveredDict);
			end);
			Button.MouseLeave:Connect(function()
				PlayTween(Button, TInfo, UnHoveredDict);
			end);
		else
			error("Failed to find button for admin section: " .. Name);
		end;
	end;

	local CloseButton = ButtonFunctions.close;
	CloseButton.TextTransparency = 1;
	CloseButton.shadow.TextTransparency = 1;

	local MinimizeButton = ButtonFunctions.minimize;
	MinimizeButton.TextTransparency = 1;
	MinimizeButton.shadow.TextTransparency = 1;

	local Title = MainFrame.Title;
	--[Animations]
	--Title Animation

	for I, Child in next, Title:GetChildren() do
		Child.Visible = false;
		Child.TextTransparency = 1;
		Child.shadow.TextTransparency = 1;
	end;

	local Alphabet = {"C", "h", "r", "y", "s1", "a", "l", "i", "s2", "m"};

	local TInfo = TweenInfo.new(0.7, 8);
	local TInfo2 = TweenInfo.new(1, 8);
	local TextTransparency = {TextTransparency = 0};

	for I = #Alphabet, 1, -1 do
		task.spawn(function()
			local Letter = Alphabet[I];
			local Label = Title[Letter];
			Label.Visible = true;
			
			local OldPos = Label.Position;
			Label.Position = UDim2.new(0, -Label.Position.X.Offset, 0, Label.Position.Y.Offset);
			
			PlayTween(Label, TInfo, {Position = OldPos});
			PlayTween(Label, TInfo2, TextTransparency);
			PlayTween(Label.shadow, TInfo2, TextTransparency);
		end);
		task.wait(0.05);
	end;

	--Minimize Animation
	Minimize = function(Status)
		local Number = Status and 1 or 0;
		local TextTransparency = {TextTransparency = Number};
		local Text = Status and "+" or "-";
		MinimizeButton.Text = Text;
		MinimizeButton.shadow.Text = Text;
		if SelectedSection then
			for I, Descendant in next, SelectedSection:GetDescendants() do
				local PropertyTable = {};
				local Has = false;
				if CheckProperty(Descendant, "BackgroundTransparency") then
					if Status then
						PropertyTable.BackgroundTransparency = 1;
					elseif OldValues.BackgroundTransparency[Descendant] then
						PropertyTable.BackgroundTransparency = OldValues.BackgroundTransparency[Descendant];
					end;
					Has = true;
				end;
				if CheckProperty(Descendant, "TextTransparency") then
					if Status then
						PropertyTable.TextTransparency = 1;
					elseif OldValues.TextTransparency[Descendant] then
						PropertyTable.TextTransparency = OldValues.TextTransparency[Descendant];
					end;
					Has = true;
				end;
				if CheckProperty(Descendant, "TextStrokeTransparency") then
					if Status then
						PropertyTable.TextStrokeTransparency = 1;
					elseif OldValues.TextStrokeTransparency[Descendant] then
						PropertyTable.TextStrokeTransparency = OldValues.TextStrokeTransparency[Descendant];
					end;
					Has = true;
				end;
				if CheckProperty(Descendant, "ScrollBarImageTransparency") then
					if Status then
						PropertyTable.ScrollBarImageTransparency = 1;
					elseif OldValues.ScrollBarImageTransparency[Descendant] then
						PropertyTable.ScrollBarImageTransparency = OldValues.ScrollBarImageTransparency[Descendant];
					end;
					Has = true;
				end;
				if Has then
					PlayTween(Descendant, TInfo, PropertyTable);
				end;
			end;
		end;
		
		for I, Child in next, MainFrame.SectionButtons:GetChildren() do
			if Child:IsA"TextButton" then
				PlayTween(Child, TInfo, {
					TextTransparency = Status and 1 or OldValues.TextTransparency[Child],
					TextStrokeTransparency = Status and 1 or OldValues.TextStrokeTransparency[Child]
				});
			end;
		end;
		
		PlayTween(MainFrame, TInfo, {Size = UDim2.new(0, 644, 0, Status and 34 or 468)});
		PlayTween(MainFrame.SectionButtons, TInfo, {BackgroundTransparency = Status and 1 or OldValues.BackgroundTransparency[MainFrame.SectionButtons]});
		if SelectedSection then
			PlayTween(SelectedSection, TInfo, Status and InVisiblePosDict or VisiblePosDict);
			PlayTween(SectionButtons[tfind(Sections, SelectedSection)], TInfo, {TextStrokeTransparency = Status and 1 or 0.81});
		end;
	end;
	local Minimized = false;
	MinimizeButton.MouseButton1Click:Connect(function()
		Minimized = not Minimized;
		Minimize(Minimized);
	end);

	--Closing Animation
	local TInfo = TweenInfo.new(0.4, 8);
	Close = function()
		if not Chrysalism.Active then return end;
		Chrysalism.Active = false;
		for I, Connection in next, Chrysalism.Connections do
			Connection:Disconnect();
		end;
		
		Minimize(true);
		PlayTween(MainFrame, TInfo, {BackgroundTransparency = 1});

		local TextTransparency = {TextTransparency = 1};
		PlayTween(CloseButton, TInfo, TextTransparency);
		PlayTween(CloseButton.shadow, TInfo, TextTransparency);

		PlayTween(MinimizeButton, TInfo, TextTransparency);
		PlayTween(MinimizeButton.shadow, TInfo, TextTransparency);

		for I = 1, #Alphabet do
			task.spawn(function()
				local Letter = Alphabet[I];
				local Label = Title[Letter];
				
				PlayTween(Label, TInfo, {Position = UDim2.new(0, -Label.Position.X.Offset, 0, Label.Position.Y.Offset)});
				PlayTween(Label, TInfo2, TextTransparency);
				PlayTween(Label.shadow, TInfo2, TextTransparency);
			end);
			task.wait(0.05);
		end;

		task.wait(0.6);
		GUI:Destroy();
	end;
	Chrysalism.Close = Close;
	CloseButton.MouseButton1Click:Connect(Close);

	--MainFrame & SectionsButtons Animation
	task.wait(0.2);
	
	TInfo = TweenInfo.new(1, 8);
	PlayTween(MainFrame, TInfo, {Size = UDim2.new(0, 644, 0, 468)});
	
	for I, Child in next, MainFrame.SectionButtons:GetChildren() do
		if Child:IsA"TextButton" then
			PlayTween(Child, TInfo, TextTransparency);
		end;
	end;

	local OldClose, OldMinimize = CloseButton.Position, MinimizeButton.Position;
	local NewPos = CloseButton.Position + UDim2.new(0, CloseButton.Size.X.Offset + 10, 0, 0);

	CloseButton.Position = NewPos;
	MinimizeButton.Position = NewPos;

	task.wait(0.5);
	PlayTween(CloseButton, TInfo, {TextTransparency = 1, Position = OldClose});
	PlayTween(CloseButton.shadow, TInfo, TextTransparency);

	PlayTween(MinimizeButton, TInfo, {TextTransparency = 1, Position = OldMinimize});
	PlayTween(MinimizeButton.shadow, TInfo, TextTransparency);
end;

do --Admin
	assert(type(hookmetamethod) == "function", "hookmetamethod not found.");
	assert(type(newcclosure) == "function", "newcclosure not found.");
	assert(type(getnamecallmethod) == "function", "getnamecallmethod not found.");

	local set_thread_identity = syn and syn.set_thread_identity or set_thread_identity or setthreadidentity;
	assert(type(set_thread_identity) == "function", "set_thread_identity not found.");
	local get_thread_identity = syn and syn.get_thread_identity or get_thread_identity or getthreadidentity;
	assert(type(get_thread_identity) == "function", "get_thread_identity not found.");

	local Prefix = "`";

	local Waypoints = {};

	local SP = game:GetService("StarterPlayer");
	local DefaultWS, DefaultJP = SP.CharacterWalkSpeed, SP.CharacterJumpPower;
	local function GetCharacter()
		return LocalPlayer.Character;
	end;
	local function GetCharacterChild(Name)
		local C = GetCharacter();
		return C and FFC(C, Name);
	end;

	local AddCommand, AddWaypoint, UpdatePrefix; do --UI
		local Title = Sections.Admin.Title;
		UpdatePrefix = function(prefix)
			local P = prefix or Prefix;
			Title.Text = "Admin - Prefix: " .. P;
		end;

		local CommandsSection = AdminSections.Commands;
		
		local CommandContainer = CommandsSection.Container;
		local CommandTemplate = CommandContainer.Template;
		
		CommandTemplate.Parent = nil;
		AddCommand = function(Name, Aliases)
			local Clone = CommandTemplate:Clone();
			Clone.Name = Name;
			Clone.Title.Text = Name;
			Clone.Aliases.Text = table.concat(Aliases, ", ");
			Clone.Parent = CommandContainer;
			AddOldValues(Clone);
		end;

		local WaypointsSection = AdminSections.Waypoints;

		local WaypointContainer = WaypointsSection.Container;
		local WaypointTemplate = WaypointContainer.Template;
		
		WaypointTemplate.Parent = nil;

		--bad function
		local function FormatVector3(V3)
			local X, Y, Z = tostring(V3.X), tostring(V3.Y), tostring(V3.Z);

			local Split = split(X, "."); if Split then 
				local Second = Split[2]; 
				if #Second > 3 then 
					X = Split[1] .. "." .. sub(Second, 1, 3);
				end;
			end;
			Split = split(Y, "."); if Split then 
				local Second = Split[2]; 
				if #Second > 3 then 
					Y = Split[1] .. "." .. sub(Second, 1, 3);
				end;
			end;
			Split = split(Z, "."); if Split then 
				local Second = Split[2]; 
				if #Second > 3 then 
					Z = Split[1] .. "." .. sub(Second, 1, 3);
				end;
			end;
			
			return X .. ", " .. Y .. ", " .. Z;
		end;
		AddWaypoint = function(Name, Position)
			local Clone = WaypointTemplate:Clone();
			Clone.Name = Name;
			Clone.Title.Text = Name;
			Clone.PositionLabel.Text = FormatVector3(Position);
			Clone.Parent = WaypointContainer;
			AddOldValues(Clone);

			local Hover = false;
			local CanClick = false;
			Clone.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					CanClick = true;
				end;
			end);
			Clone.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseMovement then
					CanClick = false;
				end;
				if Input.UserInputType == Enum.UserInputType.MouseButton1 and CanClick then
					local HRP = Name and Waypoints[Name] and GetCharacterChild "HumanoidRootPart";if HRP then
						GetCharacter():MoveTo(Waypoints[Name]);
					end;
				end;
			end);
		end;
	end;
	local Commands = {
		Rejoin = {
			ns = {"Rejoin", "RJ"},
			f = function()
				game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer);
			end
		},
		WalkSpeed = {
			ns = {"WalkSpeed", "WS"},
			f = function(Amount)
				local Amount = tonumber(Amount) or DefaultWS;if Amount then
					local Humanoid = GetCharacterChild "Humanoid";
					if Humanoid then
						Humanoid.WalkSpeed = Amount;
					end;
				end;
			end
		},
		JumpPower = {
			ns = {"JumpPower", "JP"},
			f = function(Amount)
				local Amount = tonumber(Amount) or DefaultJP;if Amount then
					local Humanoid = GetCharacterChild "Humanoid";
					if Humanoid then
						Humanoid.JumpPower = Amount;
					end;
				end;
			end
		},
		ChangePrefix = {
			ns = {"ChangePrefix", "CP"},
			f = function(To)
				if To then
					Prefix = To;
					UpdatePrefix(Prefix);
				end;
			end
		},
		CreateWaypoint = {
			ns = {"CreateWaypoint", "CW", "NewWaypoint", "NW"},
			f = function(Name)
				local HRP = Name and GetCharacterChild "HumanoidRootPart";if HRP then
					local Pos = HRP.Position;
					Waypoints[Name] = Pos;

					AddWaypoint(Name, Pos);
				end;
			end
		},
		ToWaypoint = {
			ns = {"ToWaypoint", "TW", "Waypoint", "W"},
			f = function(Name)
				local HRP = Name and Waypoints[Name] and GetCharacterChild "HumanoidRootPart";if HRP then
					GetCharacter():MoveTo(Waypoints[Name]);
				end;
			end
		}
	};

	for Name, Command in next, Commands do
		local Names = Command.ns;
		AddCommand(Name, Names);
	end;

	local function HandleMessage(String)
		if sub(String, 1, #Prefix) == Prefix then
			local Split = split(String, " ");
			local First = Split and Split[1] and lower(sub(Split[1], #Prefix + 1, -1));
			if First then
				remove(Split, 1);
				for I, Command in next, Commands do
					local Names = Command.ns;
					for I, Name in next, Names do
						if lower(Name) == First then
							task.spawn(Command.f, unpack(Split));
							break;
						end;
					end;
				end;
			end;
		end;
	end;

	--Chat hook
	local ChatRemote = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest");
	local OldMM;
	OldMM = hookmetamethod(game, "__namecall", newcclosure(function(...)
		if type(Chrysalism) == "table" and Chrysalism.Active then
			local OldIdentity = get_thread_identity();
			if getnamecallmethod() == "FireServer" and (...) == ChatRemote then
				local Args = {select(2, ...)};
				local Message = Args[1];
				local Target = Args[2];
				if Target == "All" then
					set_thread_identity(4);
					HandleMessage(Message);
					if sub(Message, -2 , -1) == "-h" then
						return nil;
					end;
				end;
			end;
			set_thread_identity(OldIdentity);
		end;
		return OldMM(...);
	end));
end;

do --RemoteSpy
	assert(type(hookmetamethod) == "function", "hookmetamethod not found.");
	assert(type(newcclosure) == "function", "newcclosure not found.");
	assert(type(getnamecallmethod) == "function", "getnamecallmethod not found.");
	assert(type(setclipboard) == "function", "setclipboard not found.");

	local set_thread_identity = syn and syn.set_thread_identity or set_thread_identity or setthreadidentity;
	assert(type(set_thread_identity) == "function", "set_thread_identity not found.");
	local get_thread_identity = syn and syn.get_thread_identity or get_thread_identity or getthreadidentity;
	assert(type(get_thread_identity) == "function", "get_thread_identity not found.");

	local Remotes = {};
	local SelectedRemote;
	local ChangeIndex, ChangeCount;

	do --UI
		RemoteSpyBox:GetPropertyChangedSignal("Text"):Connect(function()
			local Text = RemoteSpyBox.Text;

			local LinesText = "1\n";
			local Lines = 1;
			gsub(Text, "\n", function()
				Lines += 1;
				LinesText ..= tostring(Lines) .. "\n";
			end);

			RemoteSpyBoxLines.Text = LinesText;
			RemoteSpyBoxLines.Size = UDim2.new(RemoteSpyBoxLines.Size.X.Scale, RemoteSpyBoxLines.Size.X.Offset, RemoteSpyBoxLines.Size.Y.Scale, RemoteSpyBoxLines.TextBounds.Y / 2);
		end);

		BoxFunctions.execute = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			local Current = RemoteInfo and RemoteInfo.Index and RemoteInfo[RemoteInfo.Index];
			if Current then
				local Old = "Execute";
				local Suc, Res = pcall(RemoteInfo.Method == "FireServer" and SelectedRemote.FireServer or SelectedRemote.InvokeServer, SelectedRemote, unpack(Current.Args));
				if Suc then
					Self.Text = "Success!";
					task.wait(1);
					Self.Text = Old;
				else
					Self.Text = "Failed " .. (Res or "[got no error message]");
					task.wait(1);
					Self.Text = Old;
				end;
			end;
		end;
		BoxFunctions.ignore = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			if RemoteInfo then
				RemoteInfo.Ignored = not RemoteInfo.Ignored;
				if RemoteInfo.Ignored then
					Self.Text = "Un-Ignore Remote";
				else
					Self.Text = "Ignore Remote";
				end;
			end;
		end;
		BoxFunctions.block = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			if RemoteInfo then
				RemoteInfo.Blocked = not RemoteInfo.Blocked;
				if RemoteInfo.Blocked then
					Self.Text = "Un-Block Remote";
				else
					Self.Text = "Block Remote";
				end;
			end;
		end;
		BoxFunctions.copypath = function(Self)
			if SelectedRemote then
				local Old = "Copy Remote Path";
				local Path = Remotes[SelectedRemote] and Remotes[SelectedRemote].Path;
				if Path then
					local Suc, Res = pcall(setclipboard, Path);
					if Suc then
						Self.Text = "Success";
						task.wait(1);
						Self.Text = Old;
					else
						Self.Text = "Failed to set clipboard: " .. (Res or "[got no error message]");
						task.wait(1);
						Self.Text = Old;
					end;
				end;
			end;
		end;
		BoxFunctions.copyscript = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			local Current = RemoteInfo and RemoteInfo.Index and RemoteInfo[RemoteInfo.Index];
			local Text = Current and Current.Text;
			local Old = "Copy Script";
			if Text then
				local Suc, Res = pcall(setclipboard, Text);
				if Suc then
					Self.Text = "Success";
					task.wait(1);
					Self.Text = Old;
				else
					Self.Text = "Failed to set clipboard: " .. (Res or "[got no error message]");
					task.wait(1);
					Self.Text = Old;
				end;
			else
				Self.Text = "Failed to get script!";
				task.wait(1);
				Self.Text = Old;
			end;
		end;
		BoxFunctions.copyscriptpath = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			local Current = RemoteInfo and RemoteInfo.Index and RemoteInfo[RemoteInfo.Index];
			local CallingScript = Current and Current.Script;
			local Path = CallingScript and tostring2(CallingScript);
			local Old = "Copy Script Path";
			if Path then
				local Suc, Res = pcall(setclipboard, Path);
				if Suc then
					Self.Text = "Success";
					task.wait(1);
					Self.Text = Old;
				else
					Self.Text = "Failed to set clipboard: " .. (Res or "[got no error message]");
					task.wait(1);
					Self.Text = Old;
				end;
			else
				Self.Text = "Failed to get path!";
				task.wait(1);
				Self.Text = Old;
			end;
		end;
		BoxFunctions.copylogpath = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			local Current = RemoteInfo and RemoteInfo.Index and RemoteInfo[RemoteInfo.Index];
			local Index = Current and Current.EnvironmentIndex;
			local Path = "shared.Chrysalism.Environment.Logs[" .. tostring(Index) .. "]";

			if Path then
				local Old = "Copy Log Path";
				local Suc, Res = pcall(setclipboard, Path);
				if Suc then
					Self.Text = "Success";
					task.wait(1);
					Self.Text = Old;
				else
					Self.Text = "Failed to set clipboard: " .. (Res or "[got no error message]");
					task.wait(1);
					Self.Text = Old;
				end;
			else
				Self.Text = "Failed to get path!";
				task.wait(1);
				Self.Text = Old;
			end;
		end;
		BoxFunctions.clearcalls = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			if RemoteInfo then
				Remotes[SelectedRemote] = nil;
				for I, Info in ipairs(RemoteInfo) do
					RemoteInfo[I] = nil;
				end;

				RemoteSpyBox.Text = "";
				SelectedRemoteLabel.Text = "nil";
				RspyIndexBox.Text = "0";
				RspyCount.Text = "Count: 0";
				SelectedRemote = nil;
				RemoteInfo.Button:Destroy();
			end;
		end;

		ChangeIndex = function(Index)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			if RemoteInfo then
				if Index >= 1 then
					if Index > RemoteInfo.MaxIndex then
						Index = RemoteInfo.MaxIndex;
					end;
				else
					Index = 1;
				end;
				RemoteInfo.Index = Index;
				RemoteSpyBox.Text = Highlighter:Highlight(RemoteInfo[RemoteInfo.Index].Text);
				RspyIndexBox.Text = tostring(Index);
				return true;
			end;
		end;
		ChangeCount = function()
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			if RemoteInfo then
				RspyCount.Text = "Count: " .. tostring(RemoteInfo.MaxIndex);
			end;
		end;

		local OldText;
		RspyIndex.BoxFunctions.change_index = function(Self)
			local Text = Self.Text;
			local Number = Text and tonumber(Text);
			if not(Number and ChangeIndex(Number)) then
				Self.Text = OldText or Text;
			end;
			OldText = Self.Text; 
		end;

		RspyIndex.ButtonFunctions.left = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			if RemoteInfo then
				ChangeIndex(RemoteInfo.Index - 1);
			end;
		end;
		RspyIndex.ButtonFunctions.right = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			if RemoteInfo then
				ChangeIndex(RemoteInfo.Index + 1);
			end;
		end;
		RspyIndex.ButtonFunctions.double_left = function(Self)
			ChangeIndex(1);
		end;
		RspyIndex.ButtonFunctions.double_right = function(Self)
			local RemoteInfo = SelectedRemote and Remotes[SelectedRemote];
			if RemoteInfo then
				ChangeIndex(RemoteInfo.MaxIndex);
			end;
		end;

	
		for Name, Button in next, BoxFunctionButtons do
			local BoxFunction = BoxFunctions[Name];
			if BoxFunction then
				Button.MouseButton1Click:Connect(function()
					task.spawn(BoxFunction, Button);
				end);
			else
				error("Failed to find function for button: " .. Name);
			end;
		end;

		for Name, Box in next, RspyIndex.Box do
			local BoxFunction = RspyIndex.BoxFunctions[Name];
			if BoxFunction then
				Box.FocusLost:Connect(function(EP)
					if EP then
						task.spawn(BoxFunction, Box);
					end;
				end);
			else
				error("Failed to find function for rspyindex box: " .. Name);
			end;
		end;
		for Name, Button in next, RspyIndex.Button do
			local ButtonFunction = RspyIndex.ButtonFunctions[Name]; 
			if ButtonFunction then
				Button.MouseButton1Click:Connect(function()
					task.spawn(ButtonFunction, Button);
				end);
			else
				error("Failed to find function for rspyindex button:" .. Name);
			end;
		end;
	end;

	local function GetCallText(Path, Method, Args)
		local Text = "";
		local Names = {};

		local I = 0;
		for K, V in next, Args do
			I += 1;
			
			local Name = typeof(V) .. tostring(I);
			Names[I] = Name;
			local TS;
			if type(V) == "table" then
				TS = FormatTable(V);
			else
				TS = tostring2(V);
			end;
			Text ..= "local " .. Name .. " = " .. TS .. ";\n";
		end;

		if #Text > 0 then
			Text ..= "\n";
		end;
		Text ..= Path .. ":" .. Method .. "(" .. sub(concat(Names, ", "), 1, -1) .. ");";

		return Text;
	end;

	local TInfo = TweenInfo.new(0.4, 8);
	local SelectedDict = {TextStrokeTransparency = 0.4};
	local UnSelectedDict = {TextStrokeTransparency = 0.8};
	local HoveredDict = {BackgroundTransparency = 0.75};
	local UnHoveredDict = {BackgroundTransparency = 0.85};

	local function LogRemote(Remote, Method, Args, CallingScript, CallingScript2, CallingFunction, Stack)
		local RemoteInfo = Remotes[Remote];
		if RemoteInfo and (RemoteInfo.Ignored or RemoteInfo.Blocked) then return end;
		if RemoteInfo then
			RemoteInfo.MaxIndex += 1;
		else
			local Name = Remote.Name;
			
			local Button = RemoteTemplate:Clone();
			Button.Name = Name;
			Button.Text = Name;
			Button.Parent = RemoteContainer;
			AddOldValues(Button);
			
			Button.MouseButton1Click:Connect(function()
				local OldInfo = SelectedRemote and Remotes[SelectedRemote];
				if OldInfo then
					PlayTween(OldInfo.Button, TInfo, UnSelectedDict);
				end;
				PlayTween(Button, TInfo, SelectedDict);
				SelectedRemote = Remote;
				SelectedRemoteLabel.Text = Name;
				ChangeCount();
				
				local RemoteInfo = Remotes[Remote];
				ChangeIndex(RemoteInfo.Index);
			end);
			Button.MouseEnter:Connect(function()
				PlayTween(Button, TInfo, HoveredDict);
			end);
			Button.MouseLeave:Connect(function()
				PlayTween(Button, TInfo, UnHoveredDict);
			end);

			local Path = Name;
			local Suc, Res = pcall(tostring2, Remote);
			if Suc and Res then
				Path = Res;
			end;
			RemoteInfo = {
				Button =  Button, 
				Index = 1, 
				MaxIndex = 1, 
				Method = Method, 
				Path = Path, 
				Ignored = false, 
				Blocked = false, 
				[0] = {Args = Args}
			};
			Remotes[Remote] = RemoteInfo;
		end;
		RemoteInfo.Method = Method;
		local Log = {
			Args = Args, 
			Text = GetCallText(RemoteInfo.Path or Remote.Name, Method, Args),
			
			Script = CallingScript2 or CallingScript, 
			Script2 = CallingScript,
			Function = CallingFunction,
			Stack = Stack,
		};
		insert(RemoteInfo, Log);
		local EnvironmentIndex = #Chrysalism.Environment.Logs + 1;
		Chrysalism.Environment.Logs[EnvironmentIndex] = Log;
		Log.EnvironmentIndex = EnvironmentIndex;

		if SelectedRemote == Remote then 
			ChangeCount();
			if RemoteInfo.Index == RemoteInfo.MaxIndex - 1 then
				ChangeIndex(RemoteInfo.MaxIndex);
				RemoteInfo.Index = RemoteInfo.MaxIndex;
			end;
		end;
	end;

	--hook the namecall metamethod (":" calls)
	local OldMM;
	OldMM = hookmetamethod(game, "__namecall", newcclosure(function(...)
		if type(Chrysalism) == "table" and Chrysalism.Active then
			local OldIdentity = get_thread_identity();
			local Method = getnamecallmethod();
			local Remote, Args = (...), {select(2, ...)};
			if Remote and (Method == "FireServer" or Method == "InvokeServer") then
				set_thread_identity(4);

				local CallingFunction, CallingScript2, Stack;
				pcall(function()
					CallingFunction = debug.getinfo(5).func;
					Stack = debug.getstack(5);
					if CallingFunction then 
						CallingScript2 = getfenv(CallingFunction).script;
					end;
				end);

				pcall(task.spawn, LogRemote, Remote, Method, Args, getcallingscript(), CallingScript2, CallingFunction, Stack);
			end;

			set_thread_identity(OldIdentity);
			if Remote and Remotes[Remote] and Remotes[Remote].Blocked then
				return nil;
			end;
		end;
		return OldMM(...);
	end));

	--hook the FireServer function ("." calls)
	local OldFireServer;
	OldFireServer = hookfunction(Instance.new"RemoteEvent".FireServer, newcclosure(function(...)
		if type(Chrysalism) == "table" and Chrysalism.Active then
			local OldIdentity = get_thread_identity();
			local Remote, Args = (...), {select(2, ...)};

			if Remote then
				set_thread_identity(4);

				local CallingFunction, CallingScript2, Stack;
				pcall(function()
					CallingFunction = debug.getinfo(5).func;
					if CallingFunction then 
						CallingScript2 = getfenv(CallingFunction).script;
						Stack = debug.getstack(5);
					end;
				end);

				pcall(task.spawn, LogRemote, Remote, "FireServer", Args, getcallingscript(), CallingScript2, CallingFunction, Stack);
			end;

			set_thread_identity(OldIdentity);

			if Remote and Remotes[Remote] and Remotes[Remote].Blocked then
				return nil;
			end;
		end;
		return OldFireServer(...);
	end));

	--hook the InvokeServer function ("." calls)
	local OldInvokeServer;
	OldInvokeServer = hookfunction(Instance.new"RemoteFunction".InvokeServer, newcclosure(function(...)
		if type(Chrysalism) == "table" and Chrysalism.Active then
			local OldIdentity = get_thread_identity();
			local Remote, Args = (...), {select(2, ...)};

			if Remote then
				set_thread_identity(4);

				local CallingFunction, CallingScript2, Stack;
				pcall(function()
					CallingFunction = debug.getinfo(5).func;
					if CallingFunction then 
						CallingScript2 = getfenv(CallingFunction).script;
						Stack = debug.getstack(5);
					end;
				end);

				pcall(task.spawn, LogRemote, Remote, "InvokeServer", Args, getcallingscript(), CallingScript2, CallingFunction, Stack);
			end;

			set_thread_identity(OldIdentity);

			if Remote and Remotes[Remote] and Remotes[Remote].Blocked then
				return nil;
			end;
		end;
		return OldInvokeServer(...);
	end));
end;

shared.Chrysalism = Chrysalism;
