std = "lua51"
max_line_length = false
exclude_files = {
    "**/Libs",
}
only = {
    "011", -- syntax
    "1", -- globals
}
ignore = {
    "11/SLASH_.*", -- slash handlers
    "1/[A-Z][A-Z][A-Z0-9_]+", -- three letter+ constants
}
globals = {
    -- wow std api
    "abs",
    "acos",
    "asin",
    "atan",
    "atan2",
    "bit",
    "ceil",
    "cos",
    "date",
    "debuglocals",
    "debugprofilestart",
    "debugprofilestop",
    "debugstack",
    "deg",
    "difftime",
    "exp",
    "fastrandom",
    "floor",
    "forceinsecure",
    "foreach",
    "foreachi",
    "format",
    "frexp",
    "geterrorhandler",
    "getn",
    "gmatch",
    "gsub",
    "hooksecurefunc",
    "issecure",
    "issecurevariable",
    "ldexp",
    "log",
    "log10",
    "max",
    "min",
    "mod",
    "rad",
    "random",
    "scrub",
    "securecall",
    "seterrorhandler",
    "sin",
    "sort",
    "sqrt",
    "strbyte",
    "strchar",
    "strcmputf8i",
    "strconcat",
    "strfind",
    "string.join",
    "strjoin",
    "strlen",
    "strlenutf8",
    "strlower",
    "strmatch",
    "strrep",
    "strrev",
    "strsplit",
    "strsub",
    "strtrim",
    "strupper",
    "table.wipe",
    "tan",
    "time",
    "tinsert",
    "tremove",
    "wipe",


    -- everything else
    "GetBuildInfo",
    "LibStub",
    "UIParent",
    "UnitAffectingCombat",
    "UnitAffectingCombat",
    "UnitExists",
    "UnitIsUnit",
    "UnitThreatSituation",
    "UnitGroupRolesAssigned",
    "UnitIsPlayer",
    "UnitPlayerControlled",
    "IsInGroup",
    "IsInInstance",
    "UnitIsPlayer",
    "UnitIsFriend",
    "GetTime",
    "CreateFrame",
    "UnitGUID",
    "oUF",
    "C_NamePlate",
    "UnitClass",
    "UnitIsTapDenied",
    "UnitReaction",
    "IsPlayerSpell",
    "GetShapeshiftForm",
    "UnitGetTotalAbsorbs",
    "UnitGetTotalHealAbsorbs",
    "UnitHealth",
    "UnitHealthMax",
    "UnitThreatPercentageOfLead",
    "UnitDetailedThreatSituation",
    "UnitIsEnemy",
    "UnitIsConnected",
    "UnitAura",
    "UnitFrame_OnEnter",
    "UnitFrame_OnLeave",
    "BackdropTemplateMixin",
    "IsResting",
    "GetSpecialization",
}
