local buffered_random = require("./BufferedRandom")
local optional = require("./Optional")

export type Optional = optional.Optional
export type BufferedRandom = buffered_random.BufferedRandom

local Utilities = { String = {} }

Utilities.Optional = optional
Utilities.BufferedRandom = buffered_random

Utilities.String.IteratorMode = {
	Default = 0,
	Reverse = 1,
}

-- Returns an interator function to iterate over a string by characters.
function Utilities.String.StringIterator(str: string, mode: any)
	if not mode or mode == Utilities.String.IteratorMode.Default then
		local index = 0
		local eos = #str
	
		return function()
			index += 1

			if index > eos then return nil end
			return index, string.sub(str, index, index)
		end
	else
		local index = #str + 1
		local eos = 1

		return function()
			index -= 1

			if index <= eos then return nil end
			return index, string.sub(str, index, index)
		end
	end 
end

return Utilities
