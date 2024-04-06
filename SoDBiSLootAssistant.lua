local AddonName, LootMapSandbox = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_SAY")


frame:SetScript("OnEvent", function(self, event,...)
        local function getTableKeys(tab)
        local keyset = {}
        for k, v in pairs(tab) do
            keyset[#keyset +  1] = k
        end
        return keyset
    end
            -- local command = msg:match("^/bis%s*(%w+)$")



    local addonName = ...
    if addonName == "SoDBiSLootAssistant" then
        local function BiSCommandHandler(msg)
            local itemToClassTable = {}
            for k,v in pairs(LootMapSandbox.lootMap) do
                for _, value in ipairs(v) do
                    if itemToClassTable[value] then
                        table.insert(itemToClassTable[value], k)
                    elseif value then
                        itemToClassTable[value] = {k}
                    end
                end
            end
            
            -- Match Input argument
            -- Display Key Name
            -- Display Items in a list as items

            DEFAULT_CHAT_FRAME:AddMessage(table.concat(getTableKeys(itemToClassTable),"\n"))
        end

        -- Register the slash command
        SLASH_BIS1 = "/bis"
        SlashCmdList["BIS"] = BiSCommandHandler

        local tooltip = GameTooltip
        tooltip:HookScript("OnTooltipSetItem", function(self)
            local function valueInTable(tbl, value)
                for _, v in pairs(tbl) do
                    if v == value then
                        return true
                    end
                end
                return false
            end

            local _, itemLink = self:GetItem()
            if itemLink then
                local itemID = GetItemInfoFromHyperlink(itemLink)
                local keys = getTableKeys(LootMapSandbox.lootMap)

                local function getClassNames(classRoleArr)
                    local classRolesWithColor = "";
                    for _,v in pairs(classRoleArr) do
                        local patterns = {"Resto", "Tank", "Feral", "Balance", "DPS", "Healer", "Holy", "Ret", "Shadow", "Elemental", "Enhancement", "Prot", " "}

                        local classOnly = v:sub(1)
                        for _, pattern in ipairs(patterns) do
                            classOnly = classOnly:gsub(pattern, "")
                        end

                        local classColor = LootMapSandbox.classColors[classOnly]
                        classRolesWithColor = classRolesWithColor .. "|cFF" .. classColor .. v .. "|r\n"
                    end

                    return classRolesWithColor
                end

                if (itemID and valueInTable(keys, itemID)) then
                    self:AddLine("\n|cff00FF99BIS|r\n" .. getClassNames(LootMapSandbox.lootMap[itemID]))
                end
            end
        end)
    end
end)
