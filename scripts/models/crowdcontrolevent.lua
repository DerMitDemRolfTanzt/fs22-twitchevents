CrowdControlEvent = {}
local CrowdControlEvent_mt = Class(CrowdControlEvent)

function CrowdControlEvent.new(
    ID,
    FinalCode,
    BaseCode,
    DisplayViewer,
    InventoryItem,
    FormulaVariableType,
    Test,
    Elite,
    Anonymous,
    Cost,
    Stamp,
    BlockType,
    ParameterItems,
    custom_mt
)
    local self = setmetatable({}, custom_mt or CrowdControlEvent_mt)

    self.ID = ID
    self.FinalCode = FinalCode
    self.BaseCode = BaseCode
    self.DisplayViewer = DisplayViewer
    self.InventoryItem = InventoryItem
    self.FormulaVariableType = FormulaVariableType
    self.Test = Test
    self.Elite = Elite
    self.Anonymous = Anonymous
    self.Cost = Cost
    self.Stamp = Stamp
    self.BlockType = BlockType
    self.ParameterItems = ParameterItems or {}

    self.effectDurationMilliseconds = 0

    return self
end