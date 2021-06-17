# wireshark-mqtt-websocket-plugin
## description
Wireshark LUA plugin to parse MQTT over websocket.
## feature
The main feature is support reassembled websocket packet.
## how to use
On Windows, add the dofile line in "init.lua" to use, like:
```lua
dofile("C:\\Users\\Administrator\\Desktop\\mqttws.lua")
```
"init.lua" usually in Wireshark install directory, like: "C:\Program Files\Wireshark\init.lua"
