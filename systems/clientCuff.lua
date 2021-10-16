--[[
    @Code author: Jan "sally." Szmyt
    @Email contact: inowerdevelopment@gmail.com / office.sallymembership@gmail.com
    @Discord tag: sally.#4722 
    @Basic rights reserved tag: 2018 - 2021 © Jan Szmyt
    =============================================

    Multi Theft Auto LUA development: since 2018;
]]


clientCuff = {
    arrayList = false;
    vehiclePickupMode = false;

    objects = {};
    positions = nil;
};
function clientCuff.configGui()
    if(not clientCuff.positions)then 
        clientCuff.positions = {
            textDrown = {sx + scaleElement(50), sy - scaleElement(300), scaleElement(0), scaleElement(0), tocolor(255, 255, 255, 255), 1, "OpenSans-Light", "center"};
            textDrownBackground = {sx/2, sy - scaleElement(305), scaleElement(400), scaleElement(50), "images/background.png", 0, 0, 0, tocolor(100, 100, 100, 220), textXOffset = scaleElement(100)};
        };
        clientCuff.positions.textDrownBackground_icon = {0, clientCuff.positions.textDrownBackground[2] + scaleElement(8), scaleElement(35), scaleElement(35), "images/handcuffs.png", 0, 0, 0, tocolor(255, 255, 255, 255), XOffset = scaleElement(20)}
    end
end

function clientCuff.createAnnoucement(player, text, annoucementType)
    if(clientCuff.checkLocalPlayer(player))then
        -- return exports["bm_komunikaty"]:addCommunique(text, player, (annoucementType or false));
        return triggerEvent("addCommunique", player, text, (annoucementType or false));
        --return outputChatBox(text);
    end
end


function clientCuff.checkLocalPlayer(player)
    if(player and isElement(player) and player == getLocalPlayer())then
        return true; 
    end
    return false;
end

function clientCuff.renderElement(elementType, args, drawBackground)
    if(elementType)then 
        local customArgs = args;
        if(elementType == "text")then 
            customArgs[8] = clientCuff.objects[customArgs[8]];
            local textWidth = dxGetTextWidth(customArgs[1], 1, customArgs[8], false);
            if(drawBackground)then 
                local drawBackground_gui = clientCuff.positions.textDrownBackground;
                local drawBackgroundIcon_gui = clientCuff.positions.textDrownBackground_icon;
                drawBackground_gui[1] = sx/2 - (textWidth/2) - (drawBackground_gui.textXOffset/2);
                drawBackground_gui[3] = textWidth + drawBackground_gui.textXOffset;
                dxDrawImage(unpack(drawBackground_gui));
                drawBackgroundIcon_gui[1] = drawBackground_gui[1] + drawBackgroundIcon_gui.XOffset;
                dxDrawImage(unpack(drawBackgroundIcon_gui));
            end
            dxDrawText(unpack(customArgs));
        end
    end
end

function clientCuff.render()
    if(clientCuff.arrayList and clientCuff.arrayList.cuffType)then 
        if(clientCuff.arrayList.interactUser and isElement(clientCuff.arrayList.interactUser))then 
            if(clientCuff.arrayList.cuffType == "cuffed")then 
                --[[
                    #TODO:
                        create gui for cuffed person;
                ]]
                if(clientCuff.arrayList.placedVehicle)then 
                    clientCuff.renderElement("text", {"Zostałeś(-aś) wsadzony(-a) do pojazdu przez "..clientCuff.arrayList.interactUser_name, unpack(clientCuff.positions.textDrown)}, true);
                else
                    -- dxDrawText("Zostałeś(-aś) zakuty przez "..clientCuff.arrayList.interactUser_name, unpack(clientCuff.positions.textDrown));
                    clientCuff.renderElement("text", {"Zostałeś(-aś) zakuty przez "..clientCuff.arrayList.interactUser_name, unpack(clientCuff.positions.textDrown)}, true);

                end
                setElementRotation(localPlayer, getElementRotation(clientCuff.arrayList.interactUser));
            elseif(clientCuff.arrayList.cuffType == "cuffing")then 
                --[[
                    #TODO:
                        create gui for cuffed person;
                ]]
                if(clientCuff.arrayList.placedVehicle)then 
                    clientCuff.renderElement("text", {clientCuff.arrayList.interactUser_name.." jest wsadzony/a w pojeździe", unpack(clientCuff.positions.textDrown)}, true);
                else 
                    clientCuff.renderElement("text", {"Zakułeś/aś "..clientCuff.arrayList.interactUser_name, unpack(clientCuff.positions.textDrown)}, true);

                end
            end
        else
            removeEventHandler("onClientRender", root, clientCuff.render);
        end
    end
end

function clientCuff.attachTo(arrayList)
    --[[
        source - player;
        arrayList - carrying information from cuffSync index array
    ]]
    if(clientCuff.checkLocalPlayer(source))then 
        if(arrayList)then
            clientCuff.arrayList = arrayList;
            clientCuff.arrayList.interactUser_name = getPlayerName(clientCuff.arrayList.interactUser);
            if(not community_isEventHandlerAdded("onClientRender", root, clientCuff.render))then 
                addEventHandler("onClientRender", root, clientCuff.render);
                if(not clientCuff.objects["OpenSans-Light"])then 
                    outputDebugString("fontCreate")
                    clientCuff.objects["OpenSans-Light"] = dxCreateFont("fonts/OpenSans-Light.ttf", 20/zoom, false, "cleartype_natural");
                end
                triggerEvent(init.eventIndex.."setVehiclePickupMode", source, false);
                clientCuff.configGui();
            end
        end
    end
end

function clientCuff.detachFrom(arrayList)
    --[[
        source - player;
        arrayList - carrying information from cuffSync index array
    ]]
    if(clientCuff.checkLocalPlayer(source))then 
        if(arrayList)then
            clientCuff.arrayList = arrayList;
            if(community_isEventHandlerAdded("onClientRender", root, clientCuff.render))then 
                removeEventHandler("onClientRender", root, clientCuff.render);
                if(clientCuff.objects["OpenSans-Light"])then 
                    if(isElement(clientCuff.objects["OpenSans-Light"]))then destroyElement(clientCuff.objects["OpenSans-Light"]) end;
                end; clientCuff.objects["OpenSans-Light"] = nil;
            end
        end
    end
end

function clientCuff.setInterior(newInterior)
    --[[
        source - player;
    ]]
    if(clientCuff.checkLocalPlayer(source))then 
        setElementInterior(source, newInterior);
        return true;
    end
    return false;
end

function clientCuff.setDimension(newDimension)
    --[[
        source - player;
    ]]
    if(clientCuff.checkLocalPlayer(source))then 
        setElementDimension(source, newDimension);
        return true;
    end
    return false;
end

function clientCuff.setPlacedVehicle(arrayList)
    if(clientCuff.checkLocalPlayer(source))then 
        if(clientCuff.arrayList and clientCuff.arrayList.interactUser)then 
            --[[
                Default placedVehicle array looks like:     
                    placedInVehicle = {
                        vehicle = vehicle;
                        seat = startSeat;
                    }
            ]]
            clientCuff.arrayList.placedVehicle = arrayList;
        else 
            clientCuff.arrayList.placedVehicle = nil;
        end
    end
end

function clientCuff.setVehiclePickupMode(state)
    if(clientCuff.checkLocalPlayer(source))then 
        if(clientCuff.vehiclePickupMode and state)then 
            triggerEvent(init.eventIndex.."setVehiclePickupMode", source, false);
            return false; 
        end
        clientCuff.vehiclePickupMode = state;
        if(clientCuff.vehiclePickupMode)then 
            showCursor(true)
            if(not community_isEventHandlerAdded("onClientClick", root, clientCuff.onInteractClick))then
                addEventHandler("onClientClick", root, clientCuff.onInteractClick); 
            end
        else
            showCursor(false)
            if(community_isEventHandlerAdded("onClientClick", root, clientCuff.onInteractClick))then
                removeEventHandler("onClientClick", root, clientCuff.onInteractClick); 
            end;
        end
    end
    return false;
end

function clientCuff.onInteractClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, object)
    if(button) and (state) and (isCursorShowing())then 
        if(button) == ("left") or (button) == ("right")then 
            if(state) == ("down")then 
                if(clientCuff.vehiclePickupMode)then 
                    if(object) and (isElement(object)) and (getElementType(object)) == ("vehicle")then 
                        if(clientCuff.arrayList and clientCuff.arrayList.cuffType == "cuffing")then 
                            triggerEvent(init.eventIndex.."setVehiclePickupMode", localPlayer, false);
                            if(isVehicleBlown(object)) or (isVehicleLocked(object))then
                                return clientCuff.createAnnoucement(getLocalPlayer(), "Nie możesz wsadzić zakutego do tego pojazdu");
                            end
                            if(getVehicleMaxPassengers(object)) < (3) or ((getVehicleOccupant(object, 3)) and (getVehicleOccupant(object, 2)))then
                                return clientCuff.createAnnoucement(getLocalPlayer(), "Pojazd nie ma wolnego miejsca z tył");
                            end
                            if(isPedInVehicle(clientCuff.arrayList.interactUser))then 
                                return clientCuff.createAnnoucement(getLocalPlayer(), getPlayerName(clientCuff.arrayList.interactUser).." jest już w pojeździe");
                            end
                            if(not isElementAttached(clientCuff.arrayList.interactUser))then
                                return clientCuff.createAnnoucement(getLocalPlayer(), "Aby "..getPlayerName(clientCuff.arrayList.interactUser).." wsadzić do pojazdu, musisz mieć go przy sobie");
                            end
                            local distPlayer = {getElementPosition(localPlayer)};
                            local distObject = {getElementPosition(object)};
                            if(getDistanceBetweenPoints3D(distPlayer[1], distPlayer[2], distPlayer[3], unpack(distObject))) <= (4)then 
                                triggerServerEvent(init.eventIndex.."setVehiclePlayerStanceMode", localPlayer, localPlayer, clientCuff.arrayList.interactUser, true, object);
                                return clientCuff.createAnnoucement(getLocalPlayer(), "Wsadzanie do pojazdu");
                            else   
                                return clientCuff.createAnnoucement(getLocalPlayer(), "Pojazd jest za daleko");
                            end
                        end
                    end
                else
                    clientCuff.setVehiclePickupMode(false);
                end
            end
        end
    end
end

function clientCuff.init()
    addEvent(init.eventIndex.."attachTo", true); addEventHandler(init.eventIndex.."attachTo", root, clientCuff.attachTo);
    addEvent(init.eventIndex.."detachFrom", true); addEventHandler(init.eventIndex.."detachFrom", root, clientCuff.detachFrom);
    addEvent(init.eventIndex.."setInterior", true); addEventHandler(init.eventIndex.."setInterior", root, clientCuff.setInterior);
    addEvent(init.eventIndex.."setDimension", true); addEventHandler(init.eventIndex.."setDimension", root, clientCuff.setDimension);
    addEvent(init.eventIndex.."setPlacedVehicle", true); addEventHandler(init.eventIndex.."setPlacedVehicle", root, clientCuff.setPlacedVehicle);
    addEvent(init.eventIndex.."setVehiclePickupMode", true); addEventHandler(init.eventIndex.."setVehiclePickupMode", root, clientCuff.setVehiclePickupMode);
end