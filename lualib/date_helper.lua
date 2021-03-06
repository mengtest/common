local skynet = require "skynet"
local def = require "def"

local assert = assert
local os = os

local M = {}

function M.hour()
    return os.date("*t", os.time()).hour
end

--  计算自然天的最后时刻点秒数(每日0点)
function M.calc_last_daytime( cur_time, cur_date )
    local last_time = cur_time
    return ( last_time + ((23 - cur_date.hour)*3600 + (59 - cur_date.min)*60 + (59 - cur_date.sec)) ) 
end

--  计算自然周的最后时刻点秒数(周一0点)
function M.calc_last_weektime( cur_time, cur_date )
    local last_time = cur_time
    --周日特殊处理
    if cur_date.wday == 1 then
        return calc_last_daytime( cur_time, cur_date )
    else
        return ( last_time + (8 - cur_date.wday)*24*3600 + ((23 - cur_date.hour)*3600 + (59 - cur_date.min)*60 + (59 - cur_date.sec)) ) 
    end
end

function M.is_sameday(time1, time2)
    assert(time1 and time2)

    local ZERO_POINT = def.ZERO_POINT

    time1 = time1 + (8 - ZERO_POINT) * 3600 -- 东八区
    time2 = time2 + (8 - ZERO_POINT) * 3600

    return  time1 // (60 * 60 * 24) == time2 // (60 * 60 * 24)
end

function M.is_sameweek(time1, time2)
    assert(time1 and time2)

    local ZERO_POINT = def.ZERO_POINT

    time1 = time1 + (8 - ZERO_POINT) * 3600 -- 东八区
    time2 = time2 + (8 - ZERO_POINT) * 3600

    return os.date("%Y%W", time1) == os.date("%Y%W", time2)
end

-- 计算是否是同天
function M.is_today(time)
    return M.is_sameday(time, os.time()) 
end

function M.is_this_week(time)
    return M.is_sameweek(time, os.time())
end

--获取当前某个时刻的时间
function M.get_time_today(time, h)
    local t = os.date("*t", time or os.time())
    local todayTime = {year = t.year, month = t.month , day = t.day, hour=h or 0,min=0,sec=0}
    return os.time(todayTime)
end

function M.get_today_zero(cur_time)
    cur_time = cur_time or os.time()

    local t = os.date("*t", cur_time)
    if t.hour < def.ZERO_POINT then
        t = os.date("*t", cur_time-24*3600)
    end
    local zero_date = {  year    = t.year, 
                        month   = t.month , 
                        day     = t.day, 
                        hour    = def.ZERO_POINT,
                        min     = 0,
                        sec     = 0,}
    return os.time(zero_date)
end

function M.get_next_zero(cur_time)
    cur_time = cur_time or os.time()

    local t = os.date("*t", cur_time)
    if t.hour >= def.ZERO_POINT then
        t = os.date("*t", cur_time + 24*3600)
    end
    local zero_date = {  year   = t.year, 
                        month   = t.month , 
                        day     = t.day, 
                        hour    = def.ZERO_POINT,
                        min     = 0,
                        sec     = 0,}
    return os.time(zero_date)
end
function M:get_start_time()
    local date = os.date("*t", os.time())
    if date.hour >= 18 then
        date = os.date("*t", os.time()+24*3600)
    end
    if date.hour <= 5 or date.hour >= 18 then
        date.hour = 9
    elseif date.hour <= 8 then
        date.hour = 12
    elseif date.hour <= 11 then
        date.hour = 15
    elseif date.hour <= 14 then
        date.hour = 18
    elseif date.hour <= 17 then
        date.hour = 21
    end
    date.min = 0
    date.sec = 0
    return os.time(date)
end

return M
