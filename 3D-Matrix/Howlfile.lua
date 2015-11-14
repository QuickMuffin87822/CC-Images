Options:Default "trace"

do -- Generation files
	local matrix = Dependencies()
	matrix:File "generation/matrix.lua"
		:Name "generation"
	matrix:Main "tools/matrix.lua"
		:Depends "generation"

	Tasks:Combine("matrix", matrix, "build/matrix.lua")
		:Description "Matrix codegen"
end

do -- Generated files
	local insert, concat = table.insert, table.concat

	Tasks:AddTask("matrix4x4", {}, function()
		local builder = {}
		local matrix = dofile(File "generation/matrix.lua")

		insert(builder, "return {\n")

		insert(builder, "matrix = ")
		insert(builder, matrix.createMultiply(4, 4, 4, 4))
		insert(builder, ",\n")

		insert(builder, "vector = ")
		insert(builder, matrix.createMultiply(4, 4, 4, 1))
		insert(builder, ",\n")

		insert(builder, "}")

		assert(loadstring(concat(builder)))
		local handle = fs.open(File "build/matrix4x4.lua", "w")
		handle.write(concat(builder))
		handle.close()
	end)
		:Description("4x4 and 4x1 matrix multiplication")
		:Produces("build/matrix4x4.lua")

	Tasks:AddTask("graphics", {}, function()
		local builder = {}
		local buffer = dofile(File "generation/buffer.lua")
		local graphics = dofile(File "generation/graphics.lua")

		insert(builder, "local width, height if term then width, height = term.getSize() else width, height = 400, 300 end\n")
		insert(builder, "local buffer = (function(...)\n")
		insert(builder, buffer(true, false))
		insert(builder, "\nend)(width, height)\n")

		insert(builder, "buffer.line = (function(...)\n")
		insert(builder, graphics.line(nil, {{-1, 1}}, {4}))
		insert(builder, "\nend)(buffer.pixel, width, height)\n")

		insert(builder, "buffer.lineBlended = (function(...)\n")
		insert(builder, graphics.line(nil, {{-1, 1}, 4}))
		insert(builder, "\nend)(buffer.pixel, width, height)\n")

		insert(builder, "buffer.triangle = (function(...)\n")
		insert(builder, graphics.triangle(nil, {{-1, 1}}, {4}))
		insert(builder, "\nend)(buffer.pixel, width, height)\n")

		insert(builder, "buffer.triangleBlended = (function(...)\n")
		insert(builder, graphics.triangle(nil, {{-1, 1}, 4}))
		insert(builder, "\nend)(buffer.pixel, width, height)\n")

		insert(builder, "return buffer\n")

		local handle = fs.open(File "build/graphics.lua", "w")
		handle.write(concat(builder))
		handle.close()
	end)
		:Produces("build/graphics.lua")
		:Description("Basic graphics package")
end

do -- Main Script
	local main = Dependencies()
	main:File "../Utils/Colors.lua" :Name "colors"
	main:File "build/graphics.lua" :Name "graphics" :Depends "colors"
	main:File "build/matrix4x4.lua" :Name "matrix"
	main:File "tools/transform.lua" :Name "transform"
	main:Main "main.lua" :Depends {"graphics", "matrix", "transform"}

	Tasks:Combine("main", main, "build/main.lua")
		:Description "Example program"
end

Tasks:Clean("clean", "build")

Tasks:MinifyAll()

Tasks:AddTask("build", {"clean"})
	:Requires {"build/main.min.lua"}

Tasks:Default "build"
