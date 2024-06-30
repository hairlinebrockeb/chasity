local Format = (assert(loadstring(game:HttpGet'https://raw.githubusercontent.com/hairlinebrockeb/chasity/main/format%20table.lua'), 'failed to get format table')());
local Event = (assert(loadstring(game:HttpGet"https://raw.githubusercontent.com/hairlinebrockeb/chasity/main/event.lua"), "failed to get event")());

assert(isfile, 'isfile not found.');
assert(loadfile, 'loadfile not found.');
assert(writefile, 'writefile not found.');


local find = string.find;
local gmatch = string.gmatch;
local function GetConfig(path)
	local Config = {};
	if isfile(path) then
		local Suc, Res = pcall(loadfile, path);
		if Suc and Res then
			local Suc2, Res2 = pcall(Res);
			if Suc2 and Res2 then
				Config = Res2;
			end;
		end;
	else
		if find(path, '/') then
			local currentpath = '';
			for x in gmatch(path, '([^/]+)/') do
				makefolder(currentpath .. x .. "/");
				currentpath ..= x .. "/";
			end;
		end;
		writefile(path, 'return{}');
	end;

    local Proxy = newproxy(true);
	local event = Event.new();
	getmetatable(Proxy).__newindex = function(self, index, value)
		Config[index] = value;
		writefile(path, "return " .. Format(Config));
		event:Fire(index, value);
	end;
	getmetatable(Proxy).__index = function(self, index)
		if type(index) == "string" and index == "__iter" then
			return Config;
		end;
		return Config[index];
	end;

	return Proxy, event;
end;

return GetConfig;
