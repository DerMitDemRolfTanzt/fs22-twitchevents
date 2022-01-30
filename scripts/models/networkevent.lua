TwitchServerEvent = {}
TwitchServerEvent_mt = Class(TwitchServerEvent, Event)

InitEventClass(TwitchServerEvent, "TwitchServerEvent")

function TwitchServerEvent.emptyNew()
    local self = Event.new(TwitchServerEvent_mt)
    return self
end

function TwitchServerEvent.new(event)
    local self = TwitchServerEvent.emptyNew()
    self.event = event
    return self
end

function TwitchServerEvent:writeStream(streamId, connection)
    streamWriteString(streamId, self.event.ID)
    streamWriteString(streamId, self.event.FinalCode)
    streamWriteString(streamId, self.event.BaseCode)
    streamWriteString(streamId, self.event.DisplayViewer)
    streamWriteString(streamId, self.event.InventoryItem)
    streamWriteString(streamId, self.event.FormulaVariableType)
    streamWriteBool(streamId, self.event.Test)
    streamWriteBool(streamId, self.event.Elite)
    streamWriteBool(streamId, self.event.Anonymous)
    streamWriteInt32(streamId, self.event.Cost)
    streamWriteString(streamId, self.event.Stamp)
    streamWriteString(streamId, self.event.BlockType)

    streamWriteInt32(streamId, #self.event.ParameterItems)
    for _, parameterItem in ipairs(self.event.ParameterItems) do
        streamWriteString(streamId, parameterItem)
    end

    TwitchEvents.effectManager:getEffect(self.event):writeStream(self.event, streamId, connection)
end

function TwitchServerEvent:readStream(streamId, connection)
    self.event = CrowdControlEvent.new()
    self.event.ID = streamReadString(streamId)
    self.event.FinalCode = streamReadString(streamId)
    self.event.BaseCode = streamReadString(streamId)
    self.event.DisplayViewer = streamReadString(streamId)
    self.event.InventoryItem = streamReadString(streamId)
    self.event.FormulaVariableType = streamReadString(streamId)
    self.event.Test = streamReadBool(streamId)
    self.event.Elite = streamReadBool(streamId)
    self.event.Anonymous = streamReadBool(streamId)
    self.event.Cost = streamReadInt32(streamId)
    self.event.Stamp = streamReadString(streamId)
    self.event.BlockType = streamReadString(streamId)

    local parameterItemCount = streamReadInt32(streamId)
    for i=1, parameterItemCount do
        table.insert(self.event.ParameterItems, streamReadString(streamId))
    end

    TwitchEvents.effectManager:getEffect(self.event):readStream(self.event, streamId, connection)

    self:run(connection)
end

function TwitchServerEvent:run(connection)
    if g_server ~= nil then
        TwitchEvents.effectManager:triggerEffect(self.event)
    end
end

function TwitchServerEvent.sendEvent(event)
    if g_client ~= nil then
        g_client:getServerConnection():sendEvent(TwitchServerEvent.new(event))
    end
end
