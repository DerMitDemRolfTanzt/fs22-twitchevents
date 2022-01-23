TEFileIO = {}
local FileIO_mt = Class(TEFileIO)

function TEFileIO.new(custom_mt)
    local self = setmetatable({}, custom_mt or FileIO_mt)

    self.rootFolder = getUserProfileAppPath() .. "twitchEvents/"
    createFolder(self.rootFolder)
    self.connectorFolder = self.rootFolder .. "connector/"
    createFolder(self.rootFolder)
    self.eventIndexIn = self.connectorFolder .. "in.xml"
    self.eventIndexOut = self.connectorFolder .. "out.xml"

    self.xmlSchemaVersion = "0.1.0"

    self.pollIntervalMilliseconds = 500
    self.pollIntervalCurrent = 0

    self.parsedEvents = {}

    return self
end

function TEFileIO:eventPath(index)
    local eventPathFormat = "eventIndex.events.event(%d)"

    return string.format(eventPathFormat, index)
end

function TEFileIO:checkPollInterval(dt)
    self.pollIntervalCurrent = self.pollIntervalCurrent + dt
    if self.pollIntervalCurrent < self.pollIntervalMilliseconds then
        return false
    else
        self.pollIntervalCurrent = 0
        return true
    end
end

function TEFileIO:pollEvents(dt)
    local result = {}

    if self:checkPollInterval(dt) and fileExists(self.eventIndexIn) then
        local eventIndex = loadXMLFile("twitchEventIndexIn", self.eventIndexIn)

        if not hasXMLProperty(eventIndex, "eventIndex.xmlSchemaVersion") then
            Logging.error("[TwitchEvents] EventIndex contains no XML Spec Version. Aborting.")
            return result
        end
        local xmlSchemaVersion = getXMLString(eventIndex, "eventIndex.xmlSchemaVersion")
        if xmlSchemaVersion ~= self.xmlSchemaVersion then
            Logging.error(string.format("[TwitchEvents] EventIndex contains unexpected XML Spec Version. Either this mod or the CrowdControl Event Pack is outdated. Mod-XML Version: \"%s\" CC-XML Version: \"%s\"", self.xmlSchemaVersion, xmlSchemaVersion))
            return result
        end

        -- loop through events in xml
        local i = 0
        while hasXMLProperty(eventIndex, self:eventPath(i)) do

            local event = self:parseEvent(eventIndex, i)

            if self.parsedEvents[event.ID] == nil then
                -- mark event ID as already parsed
                self.parsedEvents[event.ID] = true

                table.insert(result, event)
            end

            i = i + 1
        end

        removeXMLProperty(eventIndex, "eventIndex.events")
    end

    return result
end

function TEFileIO:parseEvent(xmlFile, index)
    local event = CrowdControlEvent.new()

    event.InventoryItem = getXMLString(xmlFile, self:eventPath(index) .. ".InventoryItem")
    event.FormulaVariableType = getXMLString(xmlFile, self:eventPath(index) .. ".FormulaVariableType")
    event.FinalCode = getXMLString(xmlFile, self:eventPath(index) .. ".FinalCode")
    event.BaseCode = getXMLString(xmlFile, self:eventPath(index) .. ".BaseCode")
    event.DisplayViewer = getXMLString(xmlFile, self:eventPath(index) .. ".DisplayViewer")
    event.Test = getXMLBool(xmlFile, self:eventPath(index) .. ".Test")
    event.Queued = getXMLBool(xmlFile, self:eventPath(index) .. ".Queued")
    event.Elite = getXMLBool(xmlFile, self:eventPath(index) .. ".Elite")
    event.Anonymous = getXMLBool(xmlFile, self:eventPath(index) .. ".Anonymous")
    event.Cost = getXMLInt(xmlFile, self:eventPath(index) .. ".Cost")
    event.ID = getXMLString(xmlFile, self:eventPath(index) .. ".ID")
    event.Stamp = getXMLString(xmlFile, self:eventPath(index) .. ".Stamp")
    event.BlockType = getXMLString(xmlFile, self:eventPath(index) .. ".BlockType")

    local i = 0
    local parameterItemsFormat = "%s.ParameterItems.ParameterItem(%d)"
    while hasXMLProperty(xmlFile, string.format(parameterItemsFormat, self:eventPath(index), i)) do
        table.insert(event.ParameterItems, getXMLString(xmlFile, string.format(parameterItemsFormat, self:eventPath(index), i)))
    end

    return event
end

function TEFileIO:answerEvent(event, executed)
    local eventOut = createXMLFile("twitchEventIndexOut", self.eventIndexOut, "eventIndex")

    setXMLString(eventOut, "eventIndex.xmlSchemaVersion", self.xmlSchemaVersion)

    setXMLString(eventOut, "eventIndex.events.event(0).ID", event.ID)
    setXMLBool(eventOut, "eventIndex.events.event(0).executed", executed)

    saveXMLFile(eventOut)
end