
local generator = require "comgen.generator"

local types = generator.types

local IUnknown =  { name = "IUnknown", iid = "{00000000-0000-0000-C000-000000000046}" }

local FILETIME = types.struct("FILETIME", {
  { type = types.dword, name = "dwLowDateTime" },
  { type = types.dword, name = "dwHighDateTime" },
})

local OPCDATASOURCE = {
  name = "OPCDATASOURCE",
  fields = {
    { name = "OPC_DS_CACHE", value = 1 },
    { name = "OPC_DS_DEVICE", value = 2 },
  }
}

local OPCITEMSTATE = types.struct("OPCITEMSTATE", {
  { type = types.dword, name = "hClient" },
  { type = FILETIME, name = "ftTimeStamp" },
  { type = types.word, name = "wQuality" },
  { type = types.word, name = "wReserved" },
  { type = types.variant, name = "vDataValue" }
})

local OPCITEMDEF = types.struct("OPCITEMDEF", {
  { type = types.wstring, name = "szAccessPath" },
  { type = types.wstring, name = "szItemID" },
  { type = types.bool, name = "bActive" },
  { type = types.dword, name = "hClient" },
  { type = types.dword, name = "dwBlobSize" },
  { type = types.array(types.byte,  { size_is = "dwBlobSize" }), name = "pBlob" },
  { type = types.enum("VARTYPE"), name = "vtRequestedDataType" },
  { type = types.word, name = "wReserved" }
})

local OPCITEMRESULT = types.struct("OPCITEMRESULT", {
  { type = types.dword, name = "hServer" },
  { type = types.enum("VARTYPE"), name = "vtCanonicalDataType" },
  { type = types.word, name = "wReserved" },
  { type = types.dword, name = "dwAccessRights" },
  { type = types.dword, name = "dwBlobSize" },
  { type = types.array(types.byte,  { size_is = "dwBlobSize" }), name = "pBlob" },
})

local IOPCServer = {
  name = "IOPCServer",
  iid = "{39C13A4D-011E-11D0-9675-0020AFD8ADB3}",
  parent = IUnknown,
  methods = {
    {
      name = "AddGroup",
      parameters = {
	{ type = types.wstring, attributes = { ["in"] = true }, name = "szName" },
	{ type = types.bool, attributes = { ["in"] = true }, name = "bActive" },
	{ type = types.dword, attributes = { ["in"] = true }, name = "dwRequestedUpdateRate" },
	{ type = types.dword, attributes = { ["in"] = true }, name = "hClientGroup" },
	{ type = types.long, attributes = { ["in"] = true, unique = true }, name = "pTimeBias" },
	{ type = types.float, attributes = { ["in"] = true, unique = true }, name = "pPercentDeadBand" },
	{ type = types.dword, attributes = { ["in"] = true }, name = "dwLCID" },
	{ type = types.dword, attributes = { out = true }, name = "phServerGroup" },
	{ type = types.dword, attributes = { out = true }, name = "pRevisedUpdateRate" },
	{ type = types.refiid, attributes = { ["in"] = true }, name = "riid" },
	{ type = types.interface(IUnknown), attributes = { ["out"] = true, iid_is = "riid" }, name = "ppUnk" },
      }
    },
    {
      name = "RemoveGroup",
      parameters = {
	{ type = types.dword, attributes = { ["in"] = true }, name = "hServerGroup" },
	{ type = types.bool, attributes = { ["in"] = true }, name = "bForce" },
      }
    }
  }
}

local IOPCItemMgt = {
  name = "IOPCItemMgt",
  iid = "{39C13A54-011E-11D0-9675-0020AFD8ADB3}",
  parent = IUnknown,
  methods = {
    {
      name = "AddItems",
      parameters = {
	{ type = types.dword, attributes = { ["in"] = true }, name = "dwCount" },
	{ type = types.array(OPCITEMDEF), attributes = { ["in"] = true, size_is = "dwCount" }, name = "pItemArray" },
	{ type = types.array(OPCITEMRESULT), attributes = { out = true, size_is = "dwCount" }, name = "ppAddResults" },
	{ type = types.array(types.hresult), attributes = { out = true, size_is = "dwCount" }, name = "ppErrors" },
      }
    },
    {
      name = "RemoveItems",
      parameters = {
	{ type = types.dword, attributes = { ["in"] = true }, name = "dwCount" },
	{ type = types.array(types.dword), attributes = { ["in"] = true, size_is = "dwCount" }, name = "phServer" },
	{ type = types.array(types.hresult), attributes = { out = true, size_is = "dwCount" }, name = "ppErrors" },
      }
    }
  }
}

local IOPCSyncIO = {
  name = "IOPCSyncIO",
  iid = "{39C13A52-011E-11D0-9675-0020AFD8ADB3}",
  parent = IUnknown,
  methods = {
    {
      name = "Read",
      parameters = {
	{ type = types.enum("OPCDATASOURCE"), attributes = { ["in"] = true }, name = "dwSource" },
	{ type = types.dword, attributes = { ["in"] = true }, name = "dwCount" },
	{ type = types.array(types.dword), attributes = { ["in"] = true, size_is = "dwCount" }, name = "phServer" },
	{ type = types.array(OPCITEMSTATE), attributes = { out = true, size_is = "dwCount" }, name = "ppItemValues" },
	{ type = types.array(types.hresult), attributes = { out = true, size_is = "dwCount" }, name = "ppErrors" },
      }
    },
    {
      name = "Write",
      parameters = {
	{ type = types.dword, attributes = { ["in"] = true }, name = "dwCount" },
	{ type = types.array(types.dword), attributes = { ["in"] = true, size_is = "dwCount" }, name = "phServer" },
	{ type = types.array(types.variant), attributes = { ["in"] = true, size_is = "dwCount" }, name = "pItemValues" },
	{ type = types.array(types.hresult), attributes = { out = true, size_is = "dwCount" }, name = "ppErrors" },
      }
    }
  }
}

local opcda = {
  modname = "opclib",
  header = "opc",
  interfaces = { IOPCServer, IOPCSyncIO, IOPCItemMgt },
  enums = { OPCDATASOURCE, types.vartype }
}

local source, def = generator.compile(opcda)

generator.writefile("opclib.cpp", source)
generator.writefile("opclib.def", def)
