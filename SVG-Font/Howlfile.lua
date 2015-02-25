Options:Default "trace"

Sources:File "SVGParser.lua"
	:Name "SVGParser"

Sources:File "CommandGraphics.lua"
	:Name "CommandGraphics"

Sources:File "DrawingAPI.lua"
	:Name "DrawingAPI"

Sources:File "TransformationChain.lua"
	:Name "TransformationChain"

Sources:File "FontData.lua"
	:Name "FontData"

Sources:File "FontHelpers.lua"
	:Name "FontHelpers"
	:Depends "SVGParser"

Sources:Main "FontRenderer.lua"
	:Depends "CommandGraphics"
	:Depends "DrawingAPI"
	:Depends "TransformationChain"
	:Depends "FontHelpers"

	:Depends "FontData"

Sources
	:Export()

Tasks:Clean("clean", "build")
Tasks:Combine("combine", Sources, "build/Font.lua", {"clean"})
	:Verify()

Tasks:Minify("minify", "build/Font.lua", "build/Font.min.lua")
	:Description("Produces a minified version of the code")

Tasks:CreateBootstrap("boot", Sources, "build/Boot.lua", {"clean"})
	:Traceback()

Tasks:Task "build"{"minify", "boot"}
	:Description "Minify and bootstrap"
