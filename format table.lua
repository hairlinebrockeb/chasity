local s = string;
local sformat = s.format;

local Tostring2, Types, Datatypes = loadstring(game:HttpGet"https://raw.githubusercontent.com/hairlinebrockeb/chasity/main/tostring2.lua")();

local ConcatKeyItemPattern = "[%s] = %s,\n";
local ConcatItemPattern = "%s,\n";
local function FormatTable(Table, IndentLevel)
    local Formatted = "{\n";

    local IndentLevel, IndentString = IndentLevel or 1, "\t";
    local NumberIndexes = 1;
    local IndexCount = 0;
    for Index, Value in next, Table do
        IndentString = "";
        for i = 1, IndentLevel do
            IndentString ..= "\t";
        end;
        IndexCount += 1;
        local IndexString, ValueString;
        IndexString = Tostring2(Index);

        if type(Value) == "table" then
            ValueString = FormatTable(Value, IndentLevel + 1);
        else
            ValueString = Tostring2(Value);
        end;
        if type(Index) == "number" and Index == NumberIndexes then
            NumberIndexes += 1;
            Formatted ..= IndentString .. sformat(ConcatItemPattern, ValueString);
        else
            Formatted ..= IndentString .. sformat(ConcatKeyItemPattern, IndexString, ValueString);
        end;
    end;

    IndentString = "";
    for i = 2, IndentLevel do
        IndentString ..= "\t";
    end;

    Formatted ..= IndentString .. "}";

    return Formatted;
end;
return FormatTable;
