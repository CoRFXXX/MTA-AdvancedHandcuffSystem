--[[
    @Code author: Jan "sally." Szmyt
    @Email contact: inowerdevelopment@gmail.com / office.sallymembership@gmail.com
    @Discord tag: sally.#4722 
    @Basic rights reserved tag: 2018 - 2021 © Jan Szmyt
    =============================================

    Multi Theft Auto LUA development: since 2018;

    #TODO:

]]


cuffSync={
    cuffDistance = 5;
    cuffSnapPosition = {0, 0.5, 0};
    validFractions = {
        ["Policja"] = true;
    };
    commands = {
        cuffCommand = {
            ["zakuj"] = true,  
            ["cuff"] = true,  
            ["kajdanki"] = true,  
        };        
        unCuffCommand = {
            ["odkuj"] = true,  
            ["uncuff"] = true,  
            ["kajdanki"] = true,  
        };
        vehiclePlaceCommand = {
            ["wloz"] = true,  
            ["dopojazdu"] = true,  
        };
    };
    controlList = {
        ["cuffing"] = {"next_weapon", "previous_weapon", "jump", "crouch", "enter_passenger", "sprint", "enter_exit", "vehicle_fire", "special_control_down", "special_control_up", "vehicle_secondary_fire", "vehicle_left", "vehicle_right", "steer_forward", "steer_back", "accelerate", "brake_reverse"};
        ["cuffed"] = {"next_weapon", "previous_weapon", "jump", "crouch", "enter_passenger", "forwards", "backwards", "sprint", "enter_exit", "vehicle_fire", "special_control_down", "special_control_up", "vehicle_secondary_fire", "vehicle_left", "vehicle_right", "steer_forward", "steer_back", "accelerate", "brake_reverse"};
    };
    instances = {-- list that holds all handcuff actions made by users
        --[[
            [player] -- index is a player;
            {
                interactUser = player -- player that is interacting with this player (cuffed or cuffing);
                cuffType = "cuffed/cuffing" -- describes what actions was made by interactUser on this;
                attached = boolean state - contains boolean of attachment (is cuffed target attached to player);
                placedInVehicle = false; -- contains if interactUser/player (depends on cuffType (cuffing/cuffed)) is placed in vehicle;
            }
        ]]

    }; 

}; 

function cuffSync.createAnnoucement(player, text, annoucementType)
    if(player and isElement(player))then 
        return exports["bm_komunikaty"]:addCommunique(text, player, (annoucementType or false));
        --return outputChatBox(text, player);
    end
end

function cuffSync.hasCuffInstance(player)
    if(player)then 
        return cuffSync.instances[player];
    end
end

function cuffSync.createInteractionForPlayer(player, argArray, interactArgArray)
    if(player and isElement(player) and argArray and interactArgArray)then 
        --[[
            argArray {
                interactUser = object Player - contains target that player is interacting with
                cuffType = string CuffType - contains the type of cuff used on interactUser (Default: "cuffing")
                attached = boolean state - contains boolean of attachment (is cuffed target attached to player);
                placedInVehicle = false; -- contains if interactUser is placed in vehicle;
            }
            interactArgArray {
                interactUser = object Player - contains player that target is interacting with
                cuffType = string CuffType - contains the type of cuff used on interactUser (Default: "cuffing")
                attached = boolean state - contains boolean of attachment (is cuffed target attached to player);
                placedInVehicle = false; -- contains if player is placed in vehicle;
            }
        ]]
        if(cuffSync.hasCuffInstance(player))then 
            return Exception.throw("Trying to create cuff interaction instance for "..getPlayerName(player)..", but it is already created"); end
        if(cuffSync.instances[argArray.interactUser])then 
            return Exception.throw("Trying to create cuff interaction instance for "..getPlayerName(argArray.interactUser)..", but it is already created"); end
        if(player ~= interactArgArray.interactUser)then 
            return Exception.throw("Trying to create cuff interaction instance for "..getPlayerName(player).." and "..getPlayerName(interactArgArray.interactUser)..", but given functions-params players are different"); end
        -- if(player == argArray.interactUser)then 
        --     return Exception.throw("Trying to create cuff interaction instance for "..getPlayerName(player)..", but given functions-params players are the same"); end
        cuffSync.instances[player] = argArray;
        cuffSync.instances[argArray.interactUser] = interactArgArray;
        -- outputDebugString("Created cuffInstance between "..getPlayerName(player).."("..cuffSync.instances[player].cuffType..") and "..getPlayerName(cuffSync.instances[argArray.interactUser].interactUser).."("..cuffSync.instances[argArray.interactUser].cuffType..")", 0, 0, 255, 0);
        if(isPedInVehicle(argArray.interactUser))then 
            removePedFromVehicle(argArray.interactUser);
        end
        cuffSync.setDefinedControlsToggleState(player, argArray.cuffType, false);
        cuffSync.setDefinedControlsToggleState(argArray.interactUser, interactArgArray.cuffType, false);
        cuffSync.setAttachmentState(player, argArray.interactUser, true);
        return true;
    end
end 

function cuffSync.setDefinedControlsToggleState(player, cuffType, state)
    if(player and isElement(player))then 
        if(cuffType and cuffSync.controlList[cuffType])then 
            for index, value in ipairs(cuffSync.controlList[cuffType])do 
                if(value)then 
                    toggleControl(player, value, state);
                end
            end
        end
    end
end

function cuffSync.setAttachmentState(player, target, state, preventEventSend)
    if(player and isElement(player) and target and isElement(target))then 
        -- if(player ~= target)then
            if(cuffSync.hasCuffInstance(player) and cuffSync.hasCuffInstance(target))then 
                if(state)then 
                    cuffSync.instances[player].attached = true;
                    cuffSync.instances[target].attached = true;
                    if(not preventEventSend)then 
                        triggerClientEvent(player, init.eventIndex.."attachTo", player, cuffSync.instances[player]); -- sending to cuffer (Synchronise purposes)
                        triggerClientEvent(target, init.eventIndex.."attachTo", target, cuffSync.instances[target]); -- sending to target (Changing rotation and synchronize interiors/dimensions)
                    end
                    attachElements(target, player, cuffSync.cuffSnapPosition[1], cuffSync.cuffSnapPosition[2], cuffSync.cuffSnapPosition[3]);
                    setElementCollisionsEnabled(target, false);
                else
                    cuffSync.instances[player].attached = false;
                    cuffSync.instances[target].attached = false;
                    if(not preventEventSend)then 
                        triggerClientEvent(player, init.eventIndex.."detachFrom", player, cuffSync.instances[player]); -- sending to cuffer (Synchronise purposes)
                        triggerClientEvent(target, init.eventIndex.."detachFrom", target, cuffSync.instances[target]); -- sending to target (Changing rotation and synchronize interiors/dimensions)
                    end
                    detachElements(target, player);
                    setElementCollisionsEnabled(target, true);

                end
            end
        -- end
    end
end

function cuffSync.setVehiclePlayerStanceMode(player, target, state, vehicle)
    if(player and isElement(player) and target and isElement(target) and player ~= target)then 
        --[[
            player - cuffing element    
            target -- cuffed element 
        ]]
        if(state and vehicle and isElement(vehicle))then 
            if(getVehicleMaxPassengers(vehicle) >= 3)then 
                local startSeat = 2;
                if(getVehicleOccupant(vehicle, startSeat))then startSeat = startSeat + 1; end
                if(not getVehicleOccupant(vehicle, startSeat))then 
                    --[[
                        #TODO #2
                            -detach target from player;
                            -place target in vehicle at startSeat;
                    ]]
                    cuffSync.setAttachmentState(player, target, false, true);
                    warpPedIntoVehicle(target, vehicle, startSeat);
                    cuffSync.setDefinedControlsToggleState(player, cuffSync.instances[player].cuffType, true);
                    if(cuffSync.instances[player])then 
                        cuffSync.instances[player].placedInVehicle = {
                            vehicle = vehicle;
                            seat = startSeat;
                        }
                        triggerClientEvent(player, init.eventIndex.."setPlacedVehicle", player, cuffSync.instances[player].placedInVehicle); -- sending to cuffer (Synchronise purposes)
                    end
                    if(cuffSync.instances[target])then 
                        cuffSync.instances[target].placedInVehicle = {
                            vehicle = vehicle;
                            seat = startSeat;
                        }
                        triggerClientEvent(target, init.eventIndex.."setPlacedVehicle", target, cuffSync.instances[target].placedInVehicle); -- sending to target (Changing rotation and synchronize interiors/dimensions)
                    end
                else
                    cuffSync.createAnnoucement(player, "W pojeździe nie ma wolnych miejsc", "negative");
                end
            else
                cuffSync.createAnnoucement(player, "Pojazd musi mieć minimum 3 miejsca siedzące", "negative");
                return false;
            end
        else
            removePedFromVehicle(target);
            if(cuffSync.instances[player])then 
                cuffSync.instances[player].placedInVehicle = nil;
                triggerClientEvent(player, init.eventIndex.."setPlacedVehicle", player, false);
            end
            if(cuffSync.instances[target])then 
                cuffSync.instances[target].placedInVehicle = nil;
                triggerClientEvent(target, init.eventIndex.."setPlacedVehicle", target, false);

            end
            return true;
        end
    end
end

function cuffSync.isInProperDistance(player, target)
    if(player and isElement(player) and target and isElement(target))then 
        local player_position = {getElementPosition(player)};
        local target_position = {getElementPosition(target)};
        if(getDistanceBetweenPoints3D(player_position[1], player_position[2], player_position[3], unpack(target_position)) <= cuffSync.cuffDistance)then 
            return true;
        else return false; end
    end
end

function cuffSync.isInProperWorld(player, target)
    if(player and isElement(player) and target and isElement(target))then 
        if(getElementDimension(player) == getElementDimension(target) and getElementInterior(player) == getElementInterior(target))then 
            return true;
        else return false; end
    end
end

function cuffSync.stopInteractionForPlayer(player, setAttachmentState_preventEvent)
    if(player)then 
        if(cuffSync.instances[player] and cuffSync.instances[player].interactUser and cuffSync.instances[cuffSync.instances[player].interactUser])then 
            if(cuffSync.instances[player].interactUser and isElement(cuffSync.instances[player].interactUser))then 
                cuffSync.setDefinedControlsToggleState(cuffSync.instances[player].interactUser, cuffSync.instances[cuffSync.instances[player].interactUser].cuffType, true);
                cuffSync.setAttachmentState(player, cuffSync.instances[player].interactUser, false, setAttachmentState_preventEvent)
            end
            cuffSync.instances[cuffSync.instances[player].interactUser] = nil;
        end
        if(cuffSync.hasCuffInstance(player))then
            cuffSync.setDefinedControlsToggleState(player, cuffSync.instances[player].cuffType, true);
            cuffSync.instances[player] = nil;
        end
        return true;
    end
end

function cuffSync.onQuit()
    if(source)then 
        if(cuffSync.hasCuffInstance(source))then 
            if(cuffSync.instances[source] and cuffSync.instances[source].cuffType == "cuffed")then 
                cuffSync.createAnnoucement(cuffSync.instances[source].interactUser, getPlayerName(source).." wyszedł z serwera, kajdanki zostały zdjęte", "positive");
            elseif(cuffSync.instances[source] and cuffSync.instances[source].cuffType == "cuffing")then 
                cuffSync.createAnnoucement(cuffSync.instances[source].interactUser, getPlayerName(source).." wyszedł z serwera, kajdanki zostały zdjęte", "positive");
            end
            cuffSync.stopInteractionForPlayer(source);
            return true;
        end
    end
end

function cuffSync.isOnValidDuty(player)
    if(player and isElement(player))then 
        if(cuffSync.validFractions[getElementData(player, "plr:fraction")] and getElementData(player, "plr:fraction:duty"))then 
            return true;
        end
    end
end

function cuffSync.onCommand(player, command, ...)
    if(player and command and cuffSync.isOnValidDuty(player))then 
        local targetID = table.concat({...}, " ");
        if(cuffSync.commands.cuffCommand[command:lower()])then -- cuffing protocol;
            if(targetID and (tonumber(targetID[1]) or tostring(targetID[1])))then 
                targetID = exports["bm_core"]:findPlayer(player, targetID);
                if(targetID and isElement(targetID))then 
                    if(cuffSync.isInProperDistance(player, targetID) and cuffSync.isInProperWorld(player, targetID))then 
                        if(not cuffSync.hasCuffInstance(player) and not cuffSync.hasCuffInstance(targetID))then 
                            if(isPedWearingJetpack(targetID) or getElementHealth(targetID) < 1)then
                                cuffSync.createAnnoucement(player, "Nie możesz go zakuć", "negative");
                                return false;
                            end 
                            if(player ~= targetID)then 
                                if(not isPedInVehicle(player))then 
                                    local targetID_name = getPlayerName(targetID);
                                    if(isPedInVehicle(targetID))then
                                        removePedFromVehicle(targetID);
                                    end
                                    cuffSync.createInteractionForPlayer(player, 
                                        {
                                            interactUser = targetID;
                                            cuffType = "cuffing";
                                            attached = false;
                                        }, 
                                        {
                                            interactUser = player;
                                            cuffType = "cuffed";
                                            attached = false;
                                        }
                                    );
                                    cuffSync.createAnnoucement(player, "Zakuto "..targetID_name, "positive");
                                    cuffSync.createAnnoucement(targetID, "Zostałeś zakuty przez "..getPlayerName(player), "positive");
                                else
                                    cuffSync.createAnnoucement(player, "Nie możesz być w pojeździe", "negative");
                                end
                                return true;
                            else
                                cuffSync.createAnnoucement(player, "Nie możesz siebie zakuć", "negative");
                            end
                        else
                            if(cuffSync.instances[player].interactUser and cuffSync.instances[targetID].interactUser and (cuffSync.instances[player].interactUser == targetID) and isPedInVehicle(targetID) and (cuffSync.instances[player].placedInVehicle.vehicle == getPedOccupiedVehicle(targetID)))then 
                                cuffSync.setVehiclePlayerStanceMode(player, targetID, false, false);
                                cuffSync.setAttachmentState(player, targetID, true, true);
                                return;
                            else
                                cuffSync.createAnnoucement(player, "Ty lub "..getPlayerName(targetID).." posiadasz już zakutego/jest już zakuty", "negative");
                            end
                        end
                    else
                        cuffSync.createAnnoucement(player, getPlayerName(targetID).." jest za daleko by go zakuć", "negative");
                    end
                else
                    cuffSync.createAnnoucement(player, "Nie znaleziono takiego gracza", "negative");
                end
            else
                cuffSync.createAnnoucement(player, "Kogo chcesz zakuć?", "negative");
            end
            return true;
        elseif(cuffSync.commands.unCuffCommand[command:lower()])then -- unCuffing protocol;
            if(cuffSync.hasCuffInstance(player))then 
                local targetID_name = getPlayerName(cuffSync.instances[player].interactUser);
                cuffSync.createAnnoucement(cuffSync.instances[player].interactUser, "Zostałeś odkuty przez "..getPlayerName(player), "positive");
                if(cuffSync.stopInteractionForPlayer(player))then 
                    cuffSync.createAnnoucement(player, "Odkuto "..targetID_name, "positive");

                end
            end
            return true;
        elseif(cuffSync.commands.vehiclePlaceCommand[command:lower()])then -- placingInVeh protocol;
            if(cuffSync.hasCuffInstance(player) and isElement(cuffSync.instances[player].interactUser))then 
                local targetID_name = getPlayerName(cuffSync.instances[player].interactUser);

                if(cuffSync.instances[player].placedInVehicle)then 
                    cuffSync.createAnnoucement(player, targetID_name.." jest już w pojeździe", "negative");
                    return;
                else
                    triggerClientEvent(player, init.eventIndex.."setVehiclePickupMode", player, true); -- sending to cuffer (Synchronise purposes)
                end
            end
            return true;
        end
    end
end

function cuffSync.createActionCommands()
    for index, value in pairs(cuffSync.commands.cuffCommand) do 
        if(index)then 
            addCommandHandler(index, cuffSync.onCommand);
        end
    end
    for index, value in pairs(cuffSync.commands.unCuffCommand) do 
        if(index)then 
            addCommandHandler(index, cuffSync.onCommand);
        end
    end
    for index, value in pairs(cuffSync.commands.vehiclePlaceCommand) do 
        if(index)then 
            addCommandHandler(index, cuffSync.onCommand);
        end
    end
    return true
end

function cuffSync.onResourceStop()
    for index, value in pairs(cuffSync.instances) do 
        if(index)then 
            cuffSync.stopInteractionForPlayer(index, true);
        end
    end
    cuffSync.instances = nil;
end
function cuffSync.onElementInteriorChange(oldInterior, newInterior)
    if(source and isElement(source) and getElementType(source) == "player")then 
        local cuffInstance = cuffSync.hasCuffInstance(source);
        if(cuffInstance and cuffInstance.interactUser and isElement(cuffInstance.interactUser))then  
            if(cuffInstance.cuffType == "cuffing")then  
                if(triggerClientEvent(cuffInstance.interactUser, init.eventIndex.."setInterior", cuffInstance.interactUser, newInterior))then  
                    setElementInterior(cuffInstance.interactUser, newInterior);
                end
            else
                if(triggerClientEvent(player, init.eventIndex.."setInterior", player, getElementInterior(cuffInstance.interactUser)))then 
                    setElementInterior(player, getElementInterior(cuffInstance.interactUser));
                end
            end
            return true;
        else
            if(cuffInstance)then  
                cuffSync.stopInteractionForPlayer(source);
            end
        end
    end
    return false;
end

function cuffSync.onElementDimensionChange(oldDimension, newDimension)
    if(source and isElement(source) and getElementType(source) == "player")then 
        local cuffInstance = cuffSync.hasCuffInstance(source);
        if(cuffInstance and cuffInstance.interactUser and isElement(cuffInstance.interactUser))then  
            if(cuffInstance.cuffType == "cuffing")then  
                if(triggerClientEvent(cuffInstance.interactUser, init.eventIndex.."setDimension", cuffInstance.interactUser, newDimension))then  
                    setElementDimension(cuffInstance.interactUser, newDimension);
                end
            else
                if(triggerClientEvent(player, init.eventIndex.."setDimension", player, getElementDimension(cuffInstance.interactUser)))then 
                    setElementDimension(player, getElementDimension(cuffInstance.interactUser));
                end
            end
            return true;
        else
            if(cuffInstance)then  
                cuffSync.stopInteractionForPlayer(source);
            end
        end
    end
    return false;
end

-- function cuffSync.checkHaving(player)
--     outputChatBox(cuffSync.instances[player] and "true" or "false")
-- end; addCommandHandler("test1", cuffSync.checkHaving)

function cuffSync.onPlayerWasted()
    if(source and cuffSync.hasCuffInstance(source))then 
        if(cuffSync.instances[source] and cuffSync.instances[source].cuffType == "cuffing")then 
            cuffSync.createAnnoucement(cuffSync.instances[source].interactUser, getPlayerName(source).." zginął, zostajesz automatycznie odkuty/a", "positive");
            cuffSync.createAnnoucement(source, getPlayerName(cuffSync.instances[source].interactUser).." został automatycznie odkuty/a z powodu twojej śmierci", "positive");
            cuffSync.stopInteractionForPlayer(source, setAttachmentState_preventEvent);
        else
            if(cuffSync.instances[source] and isElement(cuffSync.instances[source].interactUser))then 
                cuffSync.createAnnoucement(cuffSync.instances[source].interactUser, getPlayerName(source).." zginął, kajdanki zostały automatycznie zdjęte", "positive");
                cuffSync.stopInteractionForPlayer(cuffSync.instances[source].interactUser, setAttachmentState_preventEvent);

            else
                cuffSync.stopInteractionForPlayer(source, setAttachmentState_preventEvent);
            end
        end
    end
end

function cuffSync.init()
    addEvent(init.eventIndex.."setVehiclePlayerStanceMode", true); addEventHandler(init.eventIndex.."setVehiclePlayerStanceMode", root, cuffSync.setVehiclePlayerStanceMode);
    addEvent(init.eventIndex.."onElementInteriorChange", true); addEventHandler(init.eventIndex.."onElementInteriorChange", root, cuffSync.onElementInteriorChange);
    addEvent(init.eventIndex.."onElementDimensionChange", true); addEventHandler(init.eventIndex.."onElementDimensionChange", root, cuffSync.onElementDimensionChange);

    addEventHandler('onResourceStop', resourceRoot, cuffSync.onResourceStop);
    addEventHandler('onPlayerQuit', root, cuffSync.onQuit);
    addEventHandler("onPlayerWasted", root, cuffSync.onPlayerWasted);
    cuffSync.createActionCommands();
    -- setTimer(function()
    --     cuffSync.createInteractionForPlayer(getPlayerFromName("BeautifullCat51"), {interactUser = getPlayerFromName("PainfulPad72"), cuffType="cuffing"}, {interactUser = getPlayerFromName("BeautifullCat51"), cuffType="cuffed"})
    -- end, 100, 1);
    return true;
end