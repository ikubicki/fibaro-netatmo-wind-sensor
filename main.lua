--[[
Netatmo Wind Sensor
@author ikubicki
]]

function QuickApp:onInit()
    self.config = Config:new(self)
    self.auth = Auth:new(self.config)
    self.http = HTTPClient:new({
        baseUrl = 'https://api.netatmo.com/api'
    })
    self.i18n = i18n:new(api.get("/settings/info").defaultLanguage)
    self:trace('')
    self:trace('Netatmo wind sensor')
    self:trace('User:', self.config:getUsername())
    self:updateProperty('manufacturer', 'Netatmo')
    self:updateProperty('manufacturer', 'Wind sensor')
    self:run()
    self:updateView("button2_1", "text", self.i18n:get('Wind Strength'))
    self:updateView("button2_2", "text", self.i18n:get('Wind Angle')) 
    self:updateView("button2_3", "text", self.i18n:get('Gust Strength'))
    self:updateView("button2_4", "text", self.i18n:get('Gust Angle'))
    self.data = {["0"] = 0, ["1"] = 0, ["24"] = 0}
end

function QuickApp:run()
    self:pullNetatmoData()
    local interval = self.config:getTimeoutInterval()
    if (interval > 0) then
        fibaro.setTimeout(interval, function() self:run() end)
    end
end

function QuickApp:pullNetatmoData()
    local url = '/getstationsdata'
    self:updateView("button1", "text", self.i18n:get('please-wait'))
    if string.len(self.config:getDeviceID()) > 3 then
        -- QuickApp:debug('Pulling data for device ' .. self.config:getDeviceID())
        url = url .. '?device_id=' .. self.config:getDeviceID()
    else
        -- QuickApp:debug('Pulling data')
    end
    local callback = function(response)
        local data = json.decode(response.data)
        if data.error and data.error.message then
            QuickApp:error(data.error.message)
            return false
        end

        local device = data.body.devices[1]
        local module = nil

        for _, deviceModule in pairs(device.modules) do
            if deviceModule.type == "NAModule2" then
                if string.len(self.config:getModuleID()) < 4 or self.config:getModuleID() == deviceModule["_id"] then
                    module = deviceModule
                end
            end
        end

        if module ~= nil then
            if self.config:getDataType() == 'gust' then
                self:updateProperty("value", module.dashboard_data.GustStrength)
                self:updateProperty("unit", "km/h")
            elseif self.config:getDataType() == 'gust-angle' then
                self:updateProperty("value", module.dashboard_data.GustAngle)
                self:updateProperty("unit", "°")
            elseif self.config:getDataType() == 'wind-angle' then
                self:updateProperty("value", module.dashboard_data.WindAngle)
                self:updateProperty("unit", "°")
            else
                self:updateProperty("value", module.dashboard_data.WindStrength)
                self:updateProperty("unit", "km/h")
            end
            
            self.data = {
                wind = {
                    strength = module.dashboard_data.WindStrength,
                    angle = module.dashboard_data.WindAngle
                },
                gust = {
                    strength = module.dashboard_data.GustStrength,
                    angle = module.dashboard_data.GustAngle
                }
            }

            self:trace('Module ' .. module["_id"] .. ' updated')
            self:updateView("label1", "text", string.format(self.i18n:get('last-update'), os.date('%Y-%m-%d %H:%M:%S')))
            self:updateView("button1", "text", self.i18n:get('refresh'))
            
            if string.len(self.config:getDeviceID()) < 4 then
                self.config:setDeviceID(device["_id"])
            end
            if string.len(self.config:getModuleID()) < 4 then
                self.config:setModuleID(module["_id"])
            end
        else
            self:error('Unable to retrieve module data')
        end
    end
    
    self.http:get(url, callback, nil, self.auth:getHeaders({}))
    
    return {}
end

function QuickApp:button1Event()
    self:pullNetatmoData()
end

function QuickApp:showWindStrength()
    self:updateView("button2_1", "text", self.data.wind.strength .. " km/h")
    fibaro.setTimeout(5000, function() 
        self:updateView("button2_1", "text", self.i18n:get('Wind Strength')) 
    end)
end

function QuickApp:showWindAngle()
    self:updateView("button2_2", "text", self.data.wind.strength .. " °")
    fibaro.setTimeout(5000, function() 
        self:updateView("button2_2", "text", self.i18n:get('Wind Angle')) 
    end)
end

function QuickApp:showGustStrength()
    self:updateView("button2_3", "text", self.data.gust.strength .. " km/h")
    fibaro.setTimeout(5000, function() 
        self:updateView("button2_3", "text", self.i18n:get('Gust Strength')) 
    end)
end

function QuickApp:showGustAngle()
    self:updateView("button2_4", "text", self.data.gust.angle .. " °")
    fibaro.setTimeout(5000, function() 
        self:updateView("button2_4", "text", self.i18n:get('Gust Angle')) 
    end)
end