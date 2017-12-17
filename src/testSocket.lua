local socket = require("socket")
print(os.time())
function GetAdd(hostname)
    local ip, resolved = socket.dns.toip(hostname)
    local ListTab = {}
    for k, v in ipairs(resolved.ip) do
        table.insert(ListTab, v)
    end
    return ListTab
end

print(unpack(GetAdd('localhost')))
print(unpack(GetAdd(socket.dns.gethostname())))