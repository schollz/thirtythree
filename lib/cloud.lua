local Cloud={}


function Cloud:debug(s)
  if mode_debug then
    print("cloud: "..s)
  end
end


function Cloud:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  self.enabled=false
  return o
end

function Cloud:init()
  self:debug("initializing cloud")
  local current_time=os.time2()
  if not util.file_exists(_path.code.."norns.online") then
    print("need to donwload norns.online")
    do return end
  end

  local script_name="thirtythree"
  local share=include("norns.online/lib/share")

  -- start uploader with name of your script
  local uploader=share:new{script_name=script_name}
  if uploader==nil then
    print("uploader failed, no username?")
    do return end
  end

  -- add parameters
  params:add_group("SHARE",4)

  -- uploader (CHANGE THIS TO FIT WHAT YOU NEED)
  -- select a save
  local names_dir=_path.data.."thirtythree/backups/"
  params:add_file("share_upload","upload",names_dir)
  params:set_action("share_upload",function(y)
    -- prevent banging
    local x=y
    -- params:set("share_upload",names_dir,true)
    if #x<=#names_dir or math.abs(os.time2()-current_time)<2 then
      print("returning")
      do return end
    end

    -- choose data name
    -- (here dataname is from the selector)
    local dataname=share.trim_prefix(x,names_dir)
    params:set("share_message","uploading...")
    _menu.redraw()
    print("uploading "..x.." as "..dataname)

    -- upload json
    pathtofile=x
    target=x
    uploader:upload{dataname=dataname,pathtofile=pathtofile,target=target}

    -- find the pset and upload it as temporary name
    -- loop through thirtythree-XX.pset and find which has the name dataname

    -- when downloading, loop through the psets and find which has the last name available

    sounds=snapshot:list_sounds(x)
    for _,snd_file in ipairs(sounds) do
      if not string.find(snd_file,"code/thirtythree") then
        self:debug("uploading "..snd_file)
        pathtofile=snd_file
        target=snd_file
        uploader:upload{dataname=dataname,pathtofile=pathtofile,target=target}
      end
    end

    -- goodbye
    params:set("share_message","uploaded.")
  end)

  -- downloader
  download_dir=share.get_virtual_directory(script_name)
  params:add_file("share_download","download",download_dir)
  params:set_action("share_download",function(y)
    -- prevent banging
    local x=y
    params:set("share_download",download_dir,true)
    if #x<=#download_dir or math.abs(os.time2()-current_time)<2 then
      do return end
    end

    -- download
    print("downloading!")
    params:set("share_message","downloading...")
    _menu.redraw()
    local msg=share.download_from_virtual_directory(x)
    params:set("share_message",msg)
  end)
  params:add{type='binary',name='refresh directory',id='share_refresh',behavior='momentary',action=function(v)
    print("updating directory")
    params:set("share_message","refreshing directory.")
    _menu.redraw()
    share.make_virtual_directory()
    params:set("share_message","directory updated.")
  end
}
params:add_text('share_message',">","")
self.enabled=true
end

function Cloud:reset()
  if not self.enabled then
    do return end
  end
  params:set("share_upload",_path.data.."thirtythree/backups/",true)
end


return Cloud
