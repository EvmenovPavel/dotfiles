-- Look for a node.
local rootGraph        = octane.project.getSceneGraph()
local items            = rootGraph:findItemsByName("Render target", true)
local nodeRenderTarget = items[1]

-- Callback called by the renderer, passing intermediate render results.
-- The current result is passed in as a PROPS_RENDER_RESULT.
local function renderCallback(propsRenderResult)

	print("In render callback")
	print("\tsamples: " .. propsRenderResult.samples)

	-- TODO: Test if cancelled, call octane.render.callbackStop().
end

-- Callback called by the renderer, passing intermediate render statistics.
-- The current statistics are passed in as a PROPS_RENDER_RESULT_STATISTICS.
local function statisticsCallback(propsRenderResultStatistics)

	print("In statistics callback")
	print("\tbeautySamplesPerSecond: " .. propsRenderResultStatistics.beautySamplesPerSecond)
	print("\trenderTime: " .. propsRenderResultStatistics.renderTime)
	print("\testimatedRenderTime: " .. propsRenderResultStatistics.estimatedRenderTime)

end-- Look for a node.
local rootGraph        = octane.project.getSceneGraph()
local items            = rootGraph:findItemsByName("Render target", true)
local nodeRenderTarget = items[1]

-- Callback called by the renderer, passing intermediate render results.
-- The current result is passed in as a PROPS_RENDER_RESULT.
local function renderCallback(propsRenderResult)

	print("In render callback")
	print("\tsamples: " .. propsRenderResult.samples)

	-- TODO: Test if cancelled, call octane.render.callbackStop().
end

-- Callback called by the renderer, passing intermediate render statistics.
-- The current statistics are passed in as a PROPS_RENDER_RESULT_STATISTICS.
local function statisticsCallback(propsRenderResultStatistics)

	print("In statistics callback")
	print("\tbeautySamplesPerSecond: " .. propsRenderResultStatistics.beautySamplesPerSecond)
	print("\trenderTime: " .. propsRenderResultStatistics.renderTime)
	print("\testimatedRenderTime: " .. propsRenderResultStatistics.estimatedRenderTime)

end