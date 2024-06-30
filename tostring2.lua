local typeof = typeof or type;
local format = string.format;
local sub = string.sub;
local gsub = string.gsub;
local match = string.match;

local tostring2 = nil;

local Types;
do --types
	Types = {
		string = function(Value)
			return format('"%s"', gsub(Value, '"', '\\"'));
		end,
		table = function(Table)
			local InsideStr = '';

			local Iter = 0;

			for Index, Value in next, Table do
				Iter = Iter + 1;
				local Index = Index;
				local Value = tostring2(Value);
				if type(Index) == 'number' and Index == Iter then
					InsideStr = InsideStr .. format('%s, ', Value);
				else
					InsideStr = InsideStr .. format('[%s] = %s, ', tostring2(Index), Value);
				end;
			end;

			return format('{%s}', sub(InsideStr, 1, -3));
		end,
		tuple = function(...)
			local Args = {};
			if select('#', ...) == 1 and type((...)) == 'table' then
				Args = (...);
			else
				Args = {...};
			end;

			local InsideStr = '';
			for Index, Value in next, Args do
				InsideStr = InsideStr .. tostring2(Value) .. ', ';
			end;
			return sub(InsideStr, 1, -3);
		end,
	};
end;

local tuple = Types.tuple;
local DataTypes;
do --datatypes
	DataTypes = {
		Axes = function(Value)
			local InsideStr = '';

			if Value.X then
				InsideStr ..= 'Enum.Axis.X, ';
			end;
			if Value.Y then
				InsideStr ..= 'Enum.Axis.Y, ';
			end;
			if Value.Z then
				InsideStr ..= 'Enum.Axis.Z, ';
			end;

			for I, V in next, Enum.NormalId:GetEnumItems() do
				if V and V.Name and Value[V.Name] then
					InsideStr ..= tostring(V) .. ', ';
				end;
			end;

			return format('Axes.new(%s)', sub(InsideStr, 1, -3));
		end,
		BrickColor = function(Value)
			return format('BrickColor.new(%s)', tostring2(Value.Name));
		end,
		CFrame = function(Value) 
			return format('CFrame.new(%s)', tostring(Value));
		end,
		Color3 = function(Value)
			return format('Color3.fromRGB(%s)', tuple(Value.R * 255, Value.G * 255, Value.B * 255));
		end,
		ColorSequence = function(Value)
			return format('ColorSequence.new%s', tostring2(Value.Keypoints));
		end,
		ColorSequenceKeypoint = function(Value)
			return format('ColorSequenceKeypoint.new(%s)', tuple(Value.Time, Value.Value));
		end,
		EnumItem = function(Value)
			return format('Enum.%s.%s', tostring(Value.EnumType), Value.Name);
		end,
		Faces = function(Value)
			local InsideStr = '';

			for I, V in next, Enum.NormalId:GetEnumItems() do
				if V and V.Name and Value[V.Name] then
					InsideStr = InsideStr .. tostring(V) .. ', ';
				end;
			end;

			return format('Faces.new(%s)', sub(InsideStr, 1, -3));
		end,
		FloatCurveKey = function(Value)
			return format('FloatCurveKey.new(%s)',  tuple(Value.Time, Value.Value, Value.Interpolation));
		end,
		Instance = function(Value)
			if Value == game then 
				return 'game';elseif Value == workspace then
				return 'workspace';elseif game:GetService("Players").LocalPlayer and Value == game:GetService("Players").LocalPlayer then
				return 'game:GetService("Players").LocalPlayer';elseif Value.Parent and Value.Parent == game and Value.ClassName then
				return format('game:GetService(%s)', tostring2(Value.ClassName));
			end;
			if Value.Parent then
				local Result = '';

				repeat 
					local Name = Value.Name;

					if Value.Parent then
						if Value == game then 
							Result = 'game' .. Result;elseif Value == workspace then
							Result = 'workspace' .. Result;elseif game:GetService("Players").LocalPlayer and Value == game:GetService("Players").LocalPlayer then
							Result = '.LocalPlayer' .. Result;elseif Value.Parent and Value.Parent == game and Value.ClassName then
							Result = format('game:GetService(%s)', tostring2(Value.ClassName)) .. Result;
						elseif match(Name, '%W') then
							Result = format('["%s"]', Name:gsub('%W', function(CH)return '\\' .. CH; end)) .. Result;
						else
							Result = format('.%s', Name) .. Result;
						end;
						Value = Value.Parent;
					else
						Value = game;
					end;
				until not Value or Value == game
				return Result;
			else
				return "--[[NO PARENT]]" .. Value.Name;
			end;

			return Value.Name;
		end,
		NumberRange = function(Value)
			return format('NumberRange.new(%s)', tuple(Value.Min, Value.Max));
		end,
		NumberSequence = function(Value)
			return format('NumberSequence.new%s', tostring2(Value.Keypoints));
		end,
		NumberSequenceKeypoint = function(Value)
			return format('NumberSequenceKeypoint.new(%s)', tuple(Value.Time, Value.Value, Value.Envelope));
		end,
		PathWaypoint = function(Value)
			return format('PathWaypoint.new(%s)', tuple(Value.Position, Value.Action));
		end,
		PhysicalProperties = function(Value)
			return format('PhysicalProperties.new(%s)', tuple(Value.Density, Value.Friction, Value.Elasticity, Value.FrictionWeight, Value.ElasticityWeight));
		end,
		Ray = function(Value)
			return format('Ray.new(%s)', tuple(Value.Origin, Value.Direction));
		end,
		Rect = function(Value)
			return format('Rect.new(%s)', tuple(Value.Min, Value.Max));
		end,
		Region3int16 = function(Value)
			return format('Region3int16.new(%s)', tuple(Value.Min, Value.Max));
		end,
		TweenInfo = function(Value)
			return format('TweenInfo.new(%s)', tuple(Value.Time, Value.EasingStyle, Value.EasingDirection, Value.RepeatCount, Value.Reverses, Value.DelayTime));
		end,
		UDim = function(Value)
			return format('UDim.new(%s)', tuple(Value.Scale, Value.Offset));
		end,
		UDim2 = function(Value)
			local X = Value.X;
			local Y = Value.Y;
			return format('UDim2.new(%s)', tuple(X.Scale, X.Offset, Y.Scale, Y.Offset));
		end,
		Vector2 = function(Value)
			return format('Vector2.new(%s)', tuple(Value.X, Value.Y));
		end,
		Vector2int16 = function(Value)
			return format('Vector2int16.new(%s)', tuple(Value.X, Value.Y));
		end,
		Vector3 = function(Value)
			return format('Vector3.new(%s)', tuple(Value.X, Value.Y, Value.Z));
		end,
		Vector3int16 = function(Value)
			return format('Vector3int16.new(%s)', tuple(Value.X, Value.Y, Value.Z));
		end,
	};
end;

tostring2 = function(Value)
	local Type = typeof(Value);
	if DataTypes[Type] then
		return DataTypes[Type](Value);
	end;
	if Types[Type] then
		return Types[Type](Value);
	end;

	return tostring(Value);
end;

return tostring2, Types, DataTypes;
