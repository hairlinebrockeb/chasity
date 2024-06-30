local Connection = {};
Connection.__index = Connection;
Connection.__tostring = function(self : Connection) : String
	return self.Name;
end;

Connection.new = function(Event : Event, Func : func, Once : boolean) : Connection
	return setmetatable({Name = Event.Name .. ".Connection", Event = Event, Func = Func, Once = Once}, Connection);
end;

Connection.Disconnect = function(self : Connection)
	table.remove(self.Event._connections, table.find(self.Event._connections, self));
end;

local _Wait = {};
_Wait.__index = _Wait;

_Wait.new = function(Event : Event) : _Wait
	return setmetatable({Event = Event}, _Wait);
end;
_Wait.__call = function(self, Results : table)
	self._called = true;
	self._results = Results;
end;


local Event = {};
Event.__index = Event;
Event.__tostring = function(self : Event) : string
	return self.Name;
end;

Event.new = function(Name : string) : Event
	return setmetatable({Name = Name or "Event", _connections={}, _waits={}}, Event);
end;

Event.Connect = function(self : Event, Func : func) : Connection
	local connection = Connection.new(self, Func);
	table.insert(self._connections, connection);
	return connection;
end;
Event.ConnectOnce = function(self : Event, Func : func) : Connection
	local connection = Connection.new(self, Func, true);
	table.insert(self._connections, connection);
	return connection;
end;
Event.Wait = function(self : Event, callback : func)
	local _wait = _Wait.new();
	table.insert(self._waits, _wait);
	if callback then
		repeat callback();task.wait();until _wait._called;
	else
		repeat task.wait();until _wait._called;
	end;
	return unpack(_wait._results);
end;
Event.Fire = function(self : Event, ...)
	local Args = {...};
	task.spawn(function()
		for I, Con in next, self._connections do
			Con.Func(unpack(Args));
			if Con.Once then
				Con:Disconnect();
			end;
		end;
	end);
	for I, V in next, self._waits do
		V(Args);
	end;
	self._waits={};
end;

return Event;
