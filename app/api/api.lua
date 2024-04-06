
local cjson = pcall(require, "cjson") and require "cjson"
assert(cjson.decode)

local function post()
	ngx.say("It is a post request") ngx.flush(true)

	local cli_headers = ngx.req.get_headers()
	--for k, v in pairs(cli_headers) do ngx.print(k,": ",v,"\n") end ngx.flush(true)
	--ngx.print("Content-Type == application/json ? ",(cli_headers["Content-Type"] == "application/json"), "\n" ) ngx.flush(true)

	ngx.req.read_body()  -- explicitly read the req body

	if cli_headers["Content-Type"] == "application/json" then
		--ngx.say("processing json...\n") ngx.flush(true)

		local json_data = ngx.req.get_body_data()
		--ngx.print(type(json_data),"\n") ngx.flush(true)

		if not (type(json_data) == "string") then
			--ngx.say("should be a lua string\n") ngx.flush(true)
			ngx.exit(400) -- 400 Bad Request
			return
		end
		local lua_data = cjson.decode(json_data)
		lua_data["reply"]="done"
		ngx.print(cjson.encode(lua_data),"\n") ngx.flush(true)

		return
	end
--[[

	local post_args, err = ngx.req.get_post_args()
	if err == "truncated" then
		ngx.exit(400) -- 400 Bad Request
		return
	end

	if not post_args then
		ngx.say("failed to get post args: ", err)
		ngx.exit(400) -- 400 Bad Request
		return
	end
]]--
--[[
	for key, val in pairs(post_args) do
		if type(val) == "table" then
			ngx.say(key, ": ", table.concat(val, ", "))
		else
			ngx.say(key, ": ", val)
		end
	end
]]--
--[[
	local data = ngx.req.get_body_data()
	if data then
		ngx.say("body data:")
		ngx.print(data.."\n")
		ngx.say("\n")
		ngx.print(tostring(cjson))
		ngx.say("\n")
		ngx.flush(true)
		return
	end
]]--

--[[
	-- body may get buffered in a temp file:
	local file = ngx.req.get_body_file()
	if file then
		ngx.say("body is in file ", file)
	else
		ngx.say("no body found")
	end
]]--
end

assert(ngx, "no such ngx")
assert(ngx.var, "no such ngx.var")
assert(ngx.var.request_method, "no such ngx.var.request_method")
if ngx.var.request_method == "GET" then
	ngx.say("get man!\n")
	ngx.flush(true)
	local fd = io.popen("/bin/sh -c 'sleep 5; echo 5s'")
	ngx.say(fd:read("*a"))
	fd:close()
elseif ngx.var.request_method == "POST" then
	post()
else
	ngx.status = 405 -- http method not allowed
end

-- about headers ...
-- see: lua_transform_underscores_in_response_headers on
