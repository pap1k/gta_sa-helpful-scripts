function send(aim)
	local bs = raknetNewBitStream()
	raknetBitStreamWriteInt8(bs, 221)
	raknetBitStreamWriteInt8(bs, 0x10)
	raknetBitStreamWriteInt8(bs, tonumber(aim ~= nil))
	raknetSendBitStream(bs)
end