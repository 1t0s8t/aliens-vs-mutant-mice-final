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

function scene:create( event )
    local sceneGroup = self.view
    
--     --------------------------------------------------------------------------------
--     -- Build Camera
--     --------------------------------------------------------------------------------
    local perspective = require("perspective")  -- Code Exchange library to manage camera view
    local camera = perspective.createView(3)
    
--     --------------------------------------------------------------------------------

    local target = display.newImage( "640x1136/target.png" )
    target:scale( 0.25, 0.25 )
--     -- Shoot the  ball, using a visible force vector
    function shootPlasma( event )

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
                
                local plasma = display.newImage( "640x1136/AlienHead.png" )
                plasma.width = 80
                plasma.height = 80
                plasma.x = t.x
                plasma.y = t.y
                physics.addBody( plasma, { density=3, friction=1.0, bounce=.2, radius=40 } )
                plasma:applyForce( 70*(t.x - event.x), 70*(t.y - event.y), t.x, t.y ) 
                
                camera:add(plasma, 1)
                camera.damping = 10 -- A bit more fluid tracking
                
                -- Only start the camera tracking when the penguin has moved pasted the center of the view port
                local function trackPlasma( event )
                    if plasma.x > 600 then
                        camera:setFocus(plasma) -- Set the focus to the penguin so it tracks it
                    end
                end

                Runtime:addEventListener( 'enterFrame', trackPlasma )
            end
        end
        return true -- Stop further propagation of touch event
    end

    local background = self:getObjectByTag( "background" )
    local gameGroup = self:getObjectByTag( "gameGroup" )

    local ufo = self:getObjectByTag( "ufo" )

    ufo:addEventListener( "touch", shootPlasma )
    
    

    ------------------------------------------------------------
    -- Camera code

    camera:setParallax(1,.6)
    camera:add( background, 2 ) 
    camera:add( gameGroup, 1 )
    
    camera:setBounds( 0, 1480, 320, 320 ) -- used to keep our view from going outside the background
    -- print (camera:layerCount())
    ------------------------------------------------------------


end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen

    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
        
        -- we obtain the object by id from the scene's object hierarchy

        
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
