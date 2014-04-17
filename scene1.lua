-- Abstract: Aliens vs Mutant Mice Skeleton 
--
-- Demonstrates Composer GUI
-- 
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2014 Corona Labs Inc. All Rights Reserved.
--
---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local target = display.newImage( "assets/target.png" )
target:scale( 0.25, 0.25 )

-- Shoot the  ball, using a visible force vector
function fireLogo( event )

    local t = event.target
    local phase = event.phase
    local startRotation -- fwd decl
        
    if "began" == phase then
        display.getCurrentStage():setFocus( t )
        t.isFocus = true

        target.x = t.x
        target.y = t.y
        
        startRotation = function()
            target.rotation = target.rotation + 4
        end
        
        Runtime:addEventListener( "enterFrame", startRotation )
        
        local showTarget = transition.to( target, { alpha=0.4, xScale=0.4, yScale=0.4, time=200 } )
        myLine = nil

    elseif t.isFocus then
        
        if "moved" == phase then
            
            if ( myLine ) then
                myLine.parent:remove( myLine ) -- erase previous line, if any
            end
            myLine = display.newLine( t.x,t.y, event.x,event.y )
            myLine:setStrokeColor( 1, 1, 1, 50/255 )
            myLine.strokeWidth = 15

        elseif "ended" == phase or "cancelled" == phase then
        
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
            
            local stopRotation = function()
                Runtime:removeEventListener( "enterFrame", startRotation )
            end
            
            local hideTarget = transition.to( target, { alpha=0, xScale=1.0, yScale=1.0, time=200, onComplete=stopRotation } )
            
            if ( myLine ) then
                myLine.parent:remove( myLine )
            end
            
            -- Strike the ball!
            local ball = display.newImage( "assets/plasma.png" )
            ball.width = 30
            ball.height = 30
            ball.x = t.x
            ball.y = t.y
            physics.addBody( ball, { density=1, friction=1.0, bounce=.2, radius=15 } )
            ball:applyForce( 5*(t.x - event.x), 5*(t.y - event.y), t.x, t.y ) 
        end
    end

    return true -- Stop further propagation of touch event
end

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc

    local frontUFO = self:getObjectByTag( "ufo1" )
    frontUFO:addEventListener( "touch", fireLogo )
end

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then

    elseif phase == "did" then

        --Add this code...
        local plasma = self:getObjectByTag( "plasma" )
        local frontUFO = self:getObjectByTag( "ufo1" )

        local function onObjectTap( event )
            plasma:applyForce( 2500, 0, plasma.x, plasma.y )
            return true
        end
        frontUFO:addEventListener( "tap", onObjectTap )

    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
    elseif phase == "did" then
        -- Called when the scene is now off screen
    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
