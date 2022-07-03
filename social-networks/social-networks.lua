--[[
Creates a block of social networks links to promote the page or a specific link (for exemple below a video or a for a specific section).

--]]

local social_networks =''
-- if the markown front matter contains a "url" value, we retrieve it

Meta = function(metadata)
	local url=''
	metadata.urlblock = pandoc.RawInline('html','')
	if metadata.url then url = metadata.url end
	return metadata
end

Link = function(el)
	local post = make_social(el)
	table.insert(el.content,post)
	return el.content
end

function urlencode(str)
   str = string.gsub (str, "([^0-9a-zA-Z !'()*._~-])", -- locale independent
      function (c) return string.format ("%%%02X", string.byte(c)) end)
   str = string.gsub (str, " ", "+")
   return str
end

function make_social(el)
	local content = pandoc.utils.stringify(el.content)
	print(content)
	local target = el.target
	local content_e = urlencode(content)
	local target_e = urlencode(target)
	-- recreate the link or embed for the element
	local pre = pandoc.RawInline('html','<a href="'..pandoc.utils.stringify(el.target)..'">'..pandoc.utils.stringify(el.content)..'</a>')
	local post = pandoc.RawInline('html','<div>my link:'..content_e ..'</div>')
	table.insert(el.content,1,pre)
	table.insert(el.content,post)
	return el.content
end
