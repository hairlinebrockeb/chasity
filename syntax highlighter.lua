--[[built-in functions]]
local insert = table.insert;
local concat = table.concat;

local gsub = string.gsub;
local sub = string.sub;
local format = string.format;
local match = string.match;
local split = function(Str)
	local Split = {};
	gsub(Str, ".", function(c)insert(Split, c)end);
	return Split;
end;

--[[color formats]]
local KeywordColorFormat = "<b><font color = 'rgb(248, 109, 124)'>%s</font></b>"
local StringColorFormat = "<font color = 'rgb(173, 241, 149)'>%s</font>";
local BuiltInFunctionColorFormat = "<font color = 'rgb(132, 214, 247)'>%s</font>";
local NumberColorFormat = "<font color = 'rgb(255, 198, 0)'>%s</font>";

--[[misc]]
local FilterHightlightsPattern = "<font color = 'rgb%(([%d]+), ([%d]+), ([%d]+)%)'>([^<]+)</font>";
local function FilterHighlights(Text)
	return (gsub(Text, FilterHightlightsPattern, function(...)
		local R, G, B, Inside = ...;
		return Inside;
	end));
end;
local function StringToTable(String)
	local Table = {};
	gsub(String, "([^\n]+)", function(Value)
		insert(Table, Value);
	end);
	return Table;
end;

--[[main]]
local Highlighter = {split = split};

Highlighter.BuiltInFunctions = StringToTable[[assert
collectgarbage
error
getfenv
getmetatable
ipairs
loadstring
newproxy
next
pairs
pcall
print
rawequal
rawget
rawset
select
setfenv
setmetatable
tonumber
tostring
type
unpack
xpcall
delay
elapsedTime
LoadLibrary
printidentity
require
settings
spawn
stats
tick
time
typeof
UserSettings
version
wait
warn
]];
Highlighter.Keywords = StringToTable[[local
function
do
for
in
if
then
end
or
and
not
continue
elseif
]];

do
	function Highlighter:DoQuotes(Text, Split, Colors)
		local Split = Split or split(Text);

		local QuoteStartOrEndIndexes = {};
		local SingleQuoteStartOrEndIndexes = {};
		
		local Backslashes = {};
		local EscapeSlashes = {};
		for I, Character in next, Split do
			if Character == "\\" then
				Backslashes[I] = Character;
			end;
		end;
		local IndexInBackslashes = 0;
		for I, Slash in next, Backslashes do
			local Before = Backslashes[I - 1];
			if Before then
				Backslashes[I] = nil;
				Backslashes[I - 1] = nil;
				continue;
			end
			local After = Split[I + 1];
			if After and (After == '"' or After == "'") then
				EscapeSlashes[I] = Slash;
			end;
		end;
		
		for I, Character in next, Split do
			local Before = I - 1 > 0 and Split[I - 1];
			
			if not Before or not EscapeSlashes[I - 1] then 
				if Character == '"' then
					insert(QuoteStartOrEndIndexes, I);
				elseif Character == "'" then
					insert(SingleQuoteStartOrEndIndexes, I);
				end;
			end;
		end;

		local QuoteStartToEnd = {};
		local SingleQuoteStartToEnd = {};

		for Start = 1, #Split do
			local QuoteIndex = table.find(QuoteStartOrEndIndexes, Start);
			if QuoteIndex and QuoteIndex % 2 ~= 0 then
				local EndIndex = QuoteStartOrEndIndexes[QuoteIndex + 1];
				if EndIndex then
					for I = Start + 1, EndIndex - 1 do
						local SingleQuoteIndex = table.find(SingleQuoteStartOrEndIndexes, I);
						if SingleQuoteIndex then
							table.remove(SingleQuoteStartOrEndIndexes, SingleQuoteIndex);
						end;
					end;
				end;
				QuoteStartToEnd[Start] = EndIndex or false;
			end;

			local SingleQuoteIndex = table.find(SingleQuoteStartOrEndIndexes, Start);
			if SingleQuoteIndex and SingleQuoteIndex % 2 ~= 0 then
				local EndIndex = SingleQuoteStartOrEndIndexes[SingleQuoteIndex + 1];
				if EndIndex then
					for I = Start + 1, EndIndex - 1 do
						local QuoteIndex = table.find(QuoteStartOrEndIndexes, I);
						if QuoteIndex then
							table.remove(QuoteStartOrEndIndexes, QuoteIndex);
						end;
					end;
				end;
				SingleQuoteStartToEnd[Start] = EndIndex or false;
			end;
		end;

		for StartIndex, EndIndex in next, QuoteStartToEnd do
			local Formatted = "";
			for I = StartIndex, EndIndex or #Split do
				Formatted ..= Split[I];
				Split[I] = "";
			end;
			if #Formatted > 0 then
				Colors[StartIndex] = format(StringColorFormat, Formatted);
			end;
		end;

		for StartIndex, EndIndex in next, SingleQuoteStartToEnd do
			local Formatted = "";
			for I = StartIndex, EndIndex or #Split do
				Formatted ..= Split[I];
				Split[I] = "";
			end;
			if #Formatted > 0 then
				Colors[StartIndex] = format(StringColorFormat, Formatted);
			end;
		end;

		return QuoteStartToEnd, SingleQuoteStartToEnd;
	end;
	function Highlighter:DoBuiltInFunctions(Text, Split, Colors)
		local Split = Split or split(Text);

		local Indexes = {};
		for I, Character in next, Split do
			for _, Func in next, Highlighter.BuiltInFunctions do
				local Length = #Func;
				local Found = 0;
				for X = 1, Length do
					if Split[I + X - 1] == sub(Func, X, X) then
						Found += 1;
					end;
				end;

				if Found == Length then
					Indexes[I] = I + Length - 1;
				end;
			end;
		end;

		for StartIndex, EndIndex in next, Indexes do
			if #Split > EndIndex then
				local CharAfterEnd = Split[EndIndex + 1];
				if CharAfterEnd and not (CharAfterEnd == "" or CharAfterEnd == " " or CharAfterEnd == "\t" or CharAfterEnd == ";" or CharAfterEnd == "(") then
					continue;
				end
			end;

			local Formatted = "";

			for I = StartIndex, EndIndex do
				Formatted ..= Split[I];
				Split[I] = "";
			end

			if #Formatted > 0 then
				Colors[StartIndex] = format(BuiltInFunctionColorFormat, Formatted);
			end;
		end;
	end;
	function Highlighter:DoKeywords(Text, Split, Colors)
		local Split = Split or split(Text);

		local Indexes = {};
		for I, Character in next, Split do
			for _, Func in next, Highlighter.Keywords do
				local Length = #Func;
				local Found = 0;
				for X = 1, Length do
					if Split[I + X - 1] == sub(Func, X, X) then
						Found += 1;
					end;
				end;

				if Found == Length then
					Indexes[I] = I + Length - 1;
				end;
			end;
		end;
		for StartIndex, EndIndex in next, Indexes do
			local CharAfterEnd = Split[EndIndex + 1];
			if #Split > EndIndex and CharAfterEnd then
				if not (CharAfterEnd == "" or CharAfterEnd == " " or CharAfterEnd == "\t" or CharAfterEnd == "\n" or CharAfterEnd == ";") then
					continue;
				end
			end;
			local CharBefore = Split[StartIndex - 1];
			if CharBefore and not (CharBefore == "" or CharBefore == " " or CharBefore == "\t" or CharBefore == "\n" or CharBefore == ";") then
				continue;
			end

			local Formatted = "";

			for I = StartIndex, EndIndex do
				Formatted ..= Split[I];
				Split[I] = "";
			end

			if #Formatted > 0 then
				Colors[StartIndex] = format(KeywordColorFormat, Formatted);
			end;
		end;
	end;
	function Highlighter:DoNumbers(Text, Split, Colors)
		local Split = Split or split(Text);

		local Indexes = {};
		for I, Character in next, Split do
			if match(Character, "%d") then
				local Before = Split[I - 1];
				local ValidNumber = (not Before) or false;
				if Before and match(Before, "%d") then 
					if Indexes[I - 1] then 
						ValidNumber = true; 
					else 
						continue;
					end;
				end;
				if not (ValidNumber or Before == "." or Before == "" or Before == " " or Before == ")" or Before == "\t" or Before == "\n" or Before == ";") then
					continue;
				end
				Indexes[I] = Character;
			elseif Character == "." then
				local Before = Split[I - 1];
				local After = Split[I + 1];

				if (Before and match(Before, "%d")) or (After and match(After, "%d")) then
					Indexes[I] = Character;
				end;
			end;
		end;

		for Index, Character in next, Indexes do		
			Colors[Index] = format(NumberColorFormat, Character);
		end;
	end;
end;

local RichTextEscapeCharacters = {
	["<"] = "&lt;",
	[">"] = "&gt;",
	["&"] = "&amp;"
};

local function RichTextEscapeCharacterGsubHandler(Character)
	return RichTextEscapeCharacters[Character] or Character;
end;
local function InsertRichTextEscapeCharacters(Text)
	return (gsub(Text, ".", RichTextEscapeCharacterGsubHandler));
end;

function Highlighter:Highlight(Text)
	local Text = InsertRichTextEscapeCharacters(Text);
	local Split = Highlighter.split(Text);
	local Colors = {};

	--get colors
	Highlighter:DoQuotes(Text, Split, Colors);
	Highlighter:DoBuiltInFunctions(Text, Split, Colors);
	Highlighter:DoKeywords(Text, Split, Colors);
	Highlighter:DoNumbers(Text, Split, Colors);

	--apply colors
	for Index, Value in next, Colors do
		Split[Index] = Value;
	end;

	return concat(Split);
end;

return Highlighter;
