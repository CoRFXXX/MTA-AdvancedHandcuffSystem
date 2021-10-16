--[[
    @Code author: Jan "sally." Szmyt
    @Email contact: inowerdevelopment@gmail.com / office.sallymembership@gmail.com
    @Discord tag: sally.#4722 
    @Basic rights reserved tag: 2018 - 2021 © Jan Szmyt
    =============================================

    Multi Theft Auto LUA development: since 2018;
]]

init={};
init.eventIndex = "handcuffSystem:";


function init.start()
    outputDebugString(getResourceName(getThisResource()).." initialized and successfully started");
    if(cuffSync)then cuffSync.init() end;
    if(Exception)then Exception.init() end;
    if(clientCuff)then clientCuff.init() end;
end
addEventHandler("onClientResourceStart", resourceRoot, init.start);
addEventHandler("onResourceStart", resourceRoot, init.start);