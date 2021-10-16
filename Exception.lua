--[[
    @Code author: Jan "sally." Szmyt
    @Email contact: inowerdevelopment@gmail.com / office.sallymembership@gmail.com
    @Discord tag: sally.#4722 
    @Basic rights reserved tag: 2018 - 2021 © Jan Szmyt
    =============================================

    Multi Theft Auto LUA development: since 2018;
]]

Exception={};

function Exception.throw(message)
    if(message and message ~= "")then 
        assert(false, message);
    end
end

function Exception.init(...)
    return true;
end