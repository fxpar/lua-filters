--[[
-- title:  Markdown to Bootstrap Lua filter for Pandoc
-- author: François Parlant
-- with lots of help from tarleb
-- version: 0.1
--]]

local filter_class, normal_filter, special_filter, carousel_filter, tabs_filter, accordion_filter, card_filter, carddeck_filter, alert_filter, jumbotron_filter, quiz_filter
local mytoc=''
local num = 1
local section_num = 0
local paranum = 1
local tabs_title_list = ''
local tabs_h1_num =0
local tabs_h2_num =0


-- jumbo
-- TODO stop section to add "Display-4" from title or stop section
jumbotron_filter = {
  traverse = 'topdown',
  Header = function(el)
    local mytitle = pandoc.utils.stringify(el)
    el.classes = {'display-4'}
	print(make_id(pandoc.Inlines (pandoc.utils.stringify(el))))
    return el
  end,
  Para = function (para) 
      if paranum == 1  then
		  paranum = paranum + 1
		  
        return pandoc.Plain(
			{pandoc.RawInline('html', '<p class="lead">')} ..
			para.content ..
			{pandoc.RawInline('html', '</p>\n<hr class="my-4"/>')}
		)
	  else
	    return para
      end
  end

}

-- alert
alert_filter = {
  traverse = 'topdown',
  print("ALERT")
}


-- card
-- TODO put a card-body div around the content
card_filter = {
  traverse = 'topdown',
  Header = function(el)
    local mytitle = pandoc.utils.stringify(el)
    el.classes = {'specialHeader'}
	print(make_id(pandoc.Inlines (pandoc.utils.stringify(el))))
    return el
  end,
  Div = function (el)
		print('CARD:::'..el.classes[1])
    if el.classes[1] == 'header' then
		-- mylist =  mylist .. '</ul>\n'
		el.classes = {'card-header'}
		return el
	elseif el.classes[1] == 'footer' then
		el.classes = {'card-footer'}
		return el
	else
		return el
	end
  end
}

-- cardddeck
-- NOT DONE
carddeck_filter = {
  traverse = 'topdown',
  Header = function(el)
    local mytitle = pandoc.utils.stringify(el)
    el.classes = {'specialHeader'}
	print(make_id(pandoc.Inlines (pandoc.utils.stringify(el))))
    return el
  end,
  BulletList = function (el)
    local mylist ='<ul >\n'
    for i, item in ipairs(el.content) do
      local first = item[1]
      if first  then
        mylist =  mylist .. '<li class="special-item">' .. pandoc.utils.stringify(first) ..  '</li>\n'
      end
    end
    mylist =  mylist .. '</ul>\n'
    return pandoc.RawInline('html', mylist)
  end
}


-- carousel
carousel_filter = {
  traverse = 'topdown',
  Header = function(el)
    local mytitle = pandoc.utils.stringify(el)
    el.classes = {'specialHeader'}
	print(make_id(pandoc.Inlines (pandoc.utils.stringify(el))))
    return el
  end,
  BulletList = function (el)
    local mylist ='<ul >\n'
    for i, item in ipairs(el.content) do
      local first = item[1]
      if first  then
        mylist =  mylist .. '<li class="special-item">' .. pandoc.utils.stringify(first) ..  '</li>\n'
      end
    end
    mylist =  mylist .. '</ul>\n'
    return pandoc.RawInline('html', mylist)
  end
}

-- Accordion
accordion_filter = {
  traverse = 'topdown',
  Header = function(el)
    local mytitle = pandoc.utils.stringify(el)
    el.classes = {'specialHeader'}
	print(make_id(pandoc.Inlines (pandoc.utils.stringify(el))))
    return el
  end,
  BulletList = function (el)
    local mylist ='<ul >\n'
    for i, item in ipairs(el.content) do
      local first = item[1]
      if first  then
        mylist =  mylist .. '<li class="special-item">' .. pandoc.utils.stringify(first) ..  '</li>\n'
      end
    end
    mylist =  mylist .. '</ul>\n'
    return pandoc.RawInline('html', mylist)
  end
}



-- Tabs
tabs_filter = {
  traverse = 'topdown',
  Header = function(el)
	-- we need to process twice the level 1 headings
	-- once to create the card header
	-- once to process the content
    if el.level==1 then 
	 print("TABS_TITLE_1")
	 -- create the tab header
		local show = ''
		-- we want to add the "show active" class only to the first h1
		tabs_h1_num = tabs_h1_num + 1
		if tabs_h1_num == 1 then show = 'show active' end
		tabs_title_list = tabs_title_list .. '<li class="nav-item"><a class="nav-link '..show..'" data-bs-toggle="tab" href="#menu'..tabs_h1_num..'">'.. pandoc.utils.stringify(el) ..'</a></li>'
			show ='' 
		
	-- create the tab content
		local active = ''
		local pre =''
		tabs_h2_num = tabs_h2_num + 1
		if tabs_h2_num == 1 then
			active = ''
			-- we close the tab header and we add active
			pre = pandoc.RawBlock('html','</ul></div> \n\n<div class="tab-content border-left border-right border-bottom ">\n\t<div id="menu'..tabs_h2_num..'" class="tab-pane fade in active show border p-3"><h1>')
		else
			-- we close previous menu and we start the menu
			pre = pandoc.RawBlock('html','</div><div id="menu'..tabs_h2_num..'" class="tab-pane fade in border p-3"><h1>')
		end
		local post =pandoc.RawBlock('html','</h1>')
		local content = el.content
		table.insert(content,1,pre)
		table.insert(content, post)
		return content
	else
		return el
	end
		

	
  end
}


-- quiz
quiz_filter = {
  traverse = 'topdown',
  Header = function(el)
    local mytitle = pandoc.utils.stringify(el)
    el.classes = {'specialHeader'}
	print(make_id(pandoc.Inlines (pandoc.utils.stringify(el))))
    return el
  end,
  BulletList = function (el)
    local mylist ='<ul >\n'
    for i, item in ipairs(el.content) do
      local first = item[1]
      if first  then
        mylist =  mylist .. '<li class="special-item">' .. pandoc.utils.stringify(first) ..  '</li>\n'
      end
    end
    mylist =  mylist .. '</ul>\n'
    return pandoc.RawInline('html', mylist)
  end
}


--[[
NORMAL FILTER
For everything outside a special filter
--]]
normal_filter = {
  traverse = 'topdown',
  Meta = function(metadata)
  -- Gets the toc and pass it to the template via metadata
	metadata.toc = pandoc.RawInline('html',mytoc)
	if metadata.direction then direction = metadata.direction end
	return metadata
  end,
  Header = function (el)
	local mytitle = pandoc.utils.stringify(el)
	if el.level == 1 then el.classes = {"display-2"} end
	print(make_id(pandoc.Inlines (pandoc.utils.stringify(el))))
	mytoc = mytoc ..'<li><a href="#title'..num..'">'..el.content[1].text..'</a></li>'
    return el
  end,
  Link = function(el)
	local  c ='primary'
	if el.classes[1] then c = el.classes[1] end
		el.classes = {'btn','btn-'..c}
	return el
  end,
  BulletList = function (el)
    local mylist ='<ul >\n'
    for i, item in ipairs(el.content) do
      local first = item[1]
      if first  then
        mylist =  mylist .. '<li class="list-group-item">' .. pandoc.utils.stringify(first) ..  '</li>\n'
      end
    end
    mylist =  mylist .. '</ul>\n'
    return pandoc.RawInline('html', mylist)
  end,

--[[
Very important part. 
This where we assign filters.
--]]
  Div = function (div)
    if div.classes[1] == 'carousel' then
      filter = carousel_filter 
	elseif div.classes[1] == 'quiz' then
      filter = quiz_filter
	elseif div.classes[1] == 'card' then
      filter = card_filter
	elseif div.classes[1] == 'jumbotron' then
		div.classes = {'jumbotron','bg-light','rounded', 'p-2','p-md-5','mt-3'}
      filter = jumbotron_filter
	elseif div.classes[1] == 'accordion' then
      filter = accordion_filter
	  local content = pandoc.walk_block(div,filter).content
	  local pre = pandoc.RawBlock('html','<div class="accordion" id="accordionExample">')
	  local post = pandoc.RawBlock('html','</div>')
	  table.insert(content,1,pre)
	  table.insert(content, post)
	  return content
	elseif div.classes[1] == 'tabs' then
      filter = tabs_filter
	  -- we need to insert the tab header 
	  -- before we add the content
	  local content = pandoc.walk_block(div,filter).content 
	  local pre = pandoc.RawBlock('html','<div class="card-header"><ul class="nav nav-pills card-header-pills" style="list-style-type: none;">'..tabs_title_list..'</ul></div><div class="tab-content border-left border-right border-bottom ">')
	  -- we close last menu and content
	  local post = pandoc.RawBlock('html','</div></div>')
	  table.insert(content,1,pre)
	  table.insert(content, post)
	  return content
	elseif (div.classes[1] == 'primary' or div.classes[1] == 'secondary' or div.classes[1] == 'light' or div.classes[1] == 'dark' or div.classes[1] == 'info' or div.classes[1] == 'danger' or div.classes[1] == 'warning') then
	  div.classes = {'alert','alert-'..div.classes[1]}
      filter = alert_filter
    else
      filter = normal_filter
    end
	-- if cl=='' then cl= div.classes[1] end
    -- return {pandoc.RawInline('html', '<div class="'..cl..'">'), div:walk(filter),pandoc.RawInline('html', '</div>')}, false
    -- return div:walk({filter,{pandoc.RawInline('html', '\n\n')}}, false)
	
	return div:walk(filter), false
  end
}

Pandoc = function (doc)
  return doc:walk(normal_filter)
end




function make_id (inlines, via)
  local via = via or 'html'
  local heading = pandoc.Header(1, inlines)
  local temp_doc = pandoc.Pandoc{heading}
  local roundtripped_doc = pandoc.read(pandoc.write(temp_doc, via), via)
  return roundtripped_doc.blocks[1].identifier
end

function sanitize_string(source)
    return source:gsub("%W", function(ch)
        return string.gsub(string.format("%%%02X", ch:byte())," ","")
    end)
end





