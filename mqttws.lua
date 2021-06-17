local mqttws = Proto("mqttws", "MqttOnWebsocket");

local f_proto = ProtoField.uint8("mqttws.protocol", "Protocol", base.DEC, vs_protos)
local f_dir = ProtoField.uint8("mqttws.direction", "Direction", base.DEC, { [1] = "incoming", [0] = "outgoing"})
local f_text = ProtoField.string("mqttws.text", "Text")

mqttws.fields = { f_proto, f_dir, f_text }

wsField = Field.new("websocket")
wsDataField = Field.new("data.data")

pParsed = {}
pMqttMsgIndex = {}
mqttMsgTable = {}
mqttMsgIndex = 0

function mqttws.dissector(tvb, pinfo, tree)
	if wsField() ~= nil then
		local dataField = wsDataField()
		if dataField ~= nil then
			if pParsed[pinfo.number] == nil then
				pParsed[pinfo.number] = true
				local mqttData = mqttMsgTable[mqttMsgIndex]
				if mqttData == nil then
					mqttData = dataField.range:tvb():bytes()
				else
					mqttData:append(dataField.range:tvb():bytes())
				end
				mqttMsgTable[mqttMsgIndex] = mqttData
				if mqttData:len() >= 2 then
					local mqttMsgLength = tonumber(mqttData:get_index(1)) + 2
					if mqttMsgLength <= mqttData:len() then
						pMqttMsgIndex[pinfo.number] = mqttMsgIndex
						mqttMsgIndex = mqttMsgIndex + 1
					end
				end
			end
			local msgIndex = pMqttMsgIndex[pinfo.number]
			if msgIndex ~= nil then
				local mqttData = mqttMsgTable[msgIndex]
				local mqttTvb = ByteArray.tvb(mqttData, "Reassembled mqtt data")
				local mqtt = Dissector.get("mqtt")
				mqtt:call(mqttTvb, pinfo, tree)
			end
		end
	end
end

register_postdissector(mqttws)
--local websocket = Dissector.get("websocket")
--local tcp_dissector_table = DissectorTable.get("tcp.port")
--tcp_dissector_table:add(9001, websocket)
--local ws_dissector_table = DissectorTable.get("ws.protocol")
--ws_dissector_table:add("mqtt", mqttws)
