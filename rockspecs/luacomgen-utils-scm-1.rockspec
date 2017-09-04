package = "luacomgen-utils"
version = "scm-1"
source = {
	url = "https://github.com/renatomaia/luacomgen/archive/master.zip",
	dir = "luacomgen-master",
}
description = {
	summary = "Utilitary functions to use interfaces generated by LuaComGen.",
	homepage = "https://github.com/mascarenhas/luacomgen/",
	license = "MIT",
}
dependencies = {
	"lua >= 5.2, < 5.4"
}
build = {
	type = "builtin",
	modules = {
		comgen = {
			sources = { "comgen.cpp" },
			libraries = { "user32", "ole32" },
		},
	}
}
