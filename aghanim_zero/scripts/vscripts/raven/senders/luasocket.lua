-- vim: st=4 sts=4 sw=4 et:
--- Network backend using [LuaSocket](http://w3.impa.br/~diego/software/luasocket/home.html).
-- This module should be used when the LuaSocket library is available. Note
-- that the HTTPS support depends on the [LuaSec](https://github.com/brunoos/luasec)
-- library. This libary is not required for plain HTTP.
--
-- @module raven.senders.luasocket
-- @copyright 2014-2017 CloudFlare, Inc.
-- @license BSD 3-clause (see LICENSE file)

local util = require 'raven.util'
-- local http = require 'socket.http'
-- local ltn12 = require 'ltn12'

-- try to load luassl (not mandatory, so do not hard fail if the module is
-- not there
-- local _, https = pcall(require, 'ssl.https')

local assert = assert
local pairs = pairs
local setmetatable = setmetatable
local table_concat = table.concat
-- local source_string = ltn12.source.string
-- local table_sink = ltn12.sink.table
local parse_dsn = util.parse_dsn
local generate_auth_header = util.generate_auth_header
local _VERSION = util._VERSION
local _M = {}

local mt = {}
mt.__index = mt

function mt:send(json_str)
    print(self.server)
    local request = CreateHTTPRequestScriptVM("POST", self.server)
    request:SetHTTPRequestHeaderValue("Content-Type", 'applicaion/json')
    request:SetHTTPRequestHeaderValue("User-Agent", "raven-lua-socket/" .. _VERSION)
    request:SetHTTPRequestHeaderValue('X-Sentry-Auth', generate_auth_header(self))
    request:SetHTTPRequestHeaderValue("Content-Length", tostring(#json_str))
    request:SetHTTPRequestRawPostBody('application/json', json_str)
    request:Send(function(res)
        DeepPrintTable(res)
    end)

    return true
end

--- Configuration table for the nginx sender.
-- @field dsn DSN string
-- @field verify_ssl Whether or not the SSL certificate is checked (boolean,
--  defaults to false)
-- @field cafile Path to a CA bundle (see the `cafile` parameter in the
--  [newcontext](https://github.com/brunoos/luasec/wiki/LuaSec-0.6#ssl_newcontext)
--  docs)
-- @table sender_conf

--- Create a new sender object for the given DSN
-- @param conf Configuration table, see @{sender_conf}
-- @return A sender object
function _M.new(conf)
    local obj, err = parse_dsn(conf.dsn)
    if not obj then
        return nil, err
    end

    return setmetatable(obj, mt)
end

return _M
