local folderPath = "Pastel.wtf/themes"
local jsonFileName = "Pastel.json"
local txtFileName = "Default.txt"

local jsonFilePath = folderPath .. "/" .. jsonFileName
local txtFilePath = folderPath .. "/" .. txtFileName

local jsonContent = [[
{
    "MainColor": "191919",
    "FontFace": "Code",
    "AccentColor": "a7fcff",
    "OutlineColor": "282828",
    "BackgroundColor": "0f0f0f",
    "FontColor": "ffffff"
}
]]

local txtContent = "Pastel"

if makefolder then
    if not isfolder(folderPath) then
        makefolder(folderPath)
    end

    if writefile then
        if not isfile(jsonFilePath) then
            writefile(jsonFilePath, jsonContent)
        end

        if not isfile(txtFilePath) then
            writefile(txtFilePath, txtContent)
        end
    end
end