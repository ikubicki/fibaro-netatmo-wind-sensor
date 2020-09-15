--[[
Internationalization tool
@author ikubicki
]]
class 'i18n'

function i18n:new(langCode)
    self.phrases = phrases[langCode]
    return self
end

function i18n:get(key)
    if self.phrases[key] then
        return self.phrases[key]
    end
    return key
end

phrases = {
    pl = {
        ['refresh'] = 'Odśwież',
        ['last-update'] = 'Ostatnia aktualizacja: %s',
        ['please-wait'] = 'Proszę czekać...',
        ['Wind Strength'] = 'Siła wiatru',
        ['Wind Angle'] = 'Kierunek wiatru',
        ['Gust Strength'] = 'Siła porywu',
        ['Gust Angle'] = 'Kierunek porywu',
    },
    en = {
        ['refresh'] = 'Refresh',
        ['last-update'] = 'Last update at %s',
        ['please-wait'] = 'Please wait...',
        ['Wind Strength'] = 'Wind Strength',
        ['Wind Angle'] = 'Wind Angle',
        ['Gust Strength'] = 'Gust Strength',
        ['Gust Angle'] = 'Gust Angle',
    },
    de = {
        ['refresh'] = 'Aktualisieren',
        ['last-update'] = 'Letztes update: %s',
        ['please-wait'] = 'Ein moment bitte...',
        ['Wind Strength'] = 'Windstärke',
        ['Wind Angle'] = 'Windwinkel',
        ['Gust Strength'] = 'Böenstärke',
        ['Gust Angle'] = 'Böenwinkel',
    }
}