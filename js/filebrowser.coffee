$(document).bind 'pageinit', ->
# dsadsd
  page = $('#filebrowser')
  
  page.bind 'pageshow', ->
  
    files = {}
    
    addFile = (directory, file) ->
      
      if !file.shortName
        file.shortName = file.name
      
      slashPosition = file.shortName.indexOf('/')
      if slashPosition != -1
        directoryName = file.shortName.substr(0, slashPosition)
        file.shortName = file.shortName.substr(slashPosition + 1)
        if !directory[directoryName]
          directory[directoryName] = {}
        addFile(directory[directoryName], file)
        return
      if file.type == 'application/zip'
        directory[file.shortName] = file
    
    
    showDirectory = (dirname) ->
      directory = files
      if dirname?[0] == '/'
          dirname = dirname[1..]
      if dirname?[dirname.length - 1] == '/'
        dirname = dirname[...dirname.length - 1]
      if dirname
        
        for part in dirname.split('/')
          directory = directory[part]
      else
        dirname = ''
      page.find('ul').html('')
      
      
      addItem = (name, path, isDir) ->
        element = $('<li>').html("<a>#{name}</a>")
        if isDir
          element.bind 'vclick', ->
            showDirectory(path)
        page.find('ul').append(element).listview('refresh')
      
      if dirname != ''
        addItem('..', '/' + dirname[0...('/' + dirname).lastIndexOf('/')], true)
      for name, data of directory
        addItem(name, "#{dirname}/#{name}", !(data instanceof File))
      
      return
    
    sdcard = navigator.getDeviceStorage('sdcard')
    cursor = sdcard.enumerate()
    $('.ui-loading').show()
    
    cursor.onsuccess = ->
      if !@result
        $('.ui-loading').hide()
        showDirectory()
        return
      
      addFile(files, @result)
      @continue()
