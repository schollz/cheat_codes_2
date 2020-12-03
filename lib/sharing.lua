local sharing = {}

function sharing.setup(script_name)
  if not util.file_exists(_path.code.."norns.online") then
    print("need to donwload norns.online")
    do return end
  end

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
  local names_dir=DATA_DIR.."names/"
  params:add_file("share_upload","upload",names_dir)
  params:set_action("share_upload",function(y)
    -- prevent banging
    local x=y
    params:set("share_download",names_dir) 
    if #x<=#names_dir then 
      do return end 
    end


    -- choose data name
    -- (here dataname is from the selector)
    local dataname=share.trim_prefix(x,DATA_DIR.."names/")
    params:set("share_message","uploading...")
    _menu.redraw()
    print("uploading "..x.." as "..dataname)

    -- upload each loop
    local pathtofile = "" 
    local target = "" 
    for i=1,6 do
      pathtofile=DATA_DIR..dataname.."/loop"..i..".wav"
      target=DATA_DIR..uploader.upload_username.."-"..dataname.."/loop"..i..".wav"
      if util.file_exists(pathtofile) then
        uploader:upload{dataname=dataname,pathtofile=pathtofile,target=target}
      end
    end

    -- upload paramset
    pathtofile=DATA_DIR..dataname.."/parameters.pset"
    target=DATA_DIR..uploader.upload_username.."-"..dataname.."/parameters.pset"
    uploader:upload{dataname=dataname,pathtofile=pathtofile,target=target}

    -- upload uP
    pathtofile=DATA_DIR..dataname.."/uP.txt"
    target=DATA_DIR..uploader.upload_username.."-"..dataname.."/uP.txt"
    uploader:upload{dataname=dataname,pathtofile=pathtofile,target=target}

    -- upload name file
    pathtofile=DATA_DIR.."names/"..dataname
    target=DATA_DIR.."names/"..uploader.upload_username.."-"..dataname
    uploader:upload{dataname=dataname,pathtofile=pathtofile,target=target}

    -- goodbye
    params:set("share_message","uploaded.")
  end)

  -- downloader
  download_dir=share.get_virtual_directory(script_name)
  params:add_file("share_download","download",download_dir)
  params:set_action("share_download",function(y)
    -- prevent banging
    local x=y
    params:set("share_download",download_dir) 
    if #x<=#download_dir then 
      do return end 
    end

    -- download
    print("downloading!")
    params:set("share_message","please wait...")
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
end

return sharing