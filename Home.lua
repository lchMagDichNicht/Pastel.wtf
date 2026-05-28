return function(Tabs, Library)

local HomeLeft = Tabs.Home:AddLeftGroupbox("Welcome", "heart")

HomeLeft:AddLabel("Pastel.wtf loaded :3")

HomeLeft:AddButton("Print Hello", function()
    print("haiii")
end)

end