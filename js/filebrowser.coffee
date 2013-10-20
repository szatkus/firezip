window.app ?= {}
app.Browser = class

    constructor: (@page, @enumerate) ->
      page.bind 'pageshow', => enumerate(this)
  
    files: {}
    
    addFile: (directory, filename, data) ->
      
      slashPosition = filename.indexOf('/')
      if slashPosition != -1
        directoryName = filename.substr(0, slashPosition + 1)
        filename = filename.substr(slashPosition + 1)
        if !directory[directoryName]
          directory[directoryName] = {}
        @addFile(directory[directoryName], filename)
        return
      directory[filename] = data
      
    
    
    showDirectory: (dirname) ->
      directory = @files
      if dirname?[0] == '/'
          dirname = dirname[1..]
      if dirname?[dirname.length - 1] == '/'
        dirname = dirname[...dirname.length - 1]
      if dirname
        for part in dirname.split('/')
          directory = directory[part + '/']
      else
        dirname = ''
      @page.find('ul').html('')
      
      
      addItem = (name, path, isDir) =>
        element = $('<li>').html("<a>#{name}</a>")
        if isDir
          element.bind 'vclick', =>
            @showDirectory(path)
        @page.find('ul').append(element).listview('refresh')
      
      if dirname != ''
        addItem('..', '/' + dirname[0...('/' + dirname).lastIndexOf('/')], true)
      for name, data of directory
        addItem(name, "#{dirname}/#{name}", name.indexOf('/') != -1)
      
      return
    
    

$(document).bind 'pageinit', ->

  page = $('#filebrowser')
  
  enumerate = (browser) -> 
    sdcard = navigator.getDeviceStorage('sdcard')
    cursor = sdcard.enumerate()
    $('.ui-loading').show()
    
    cursor.onsuccess = ->
      if !@result
        $('.ui-loading').hide()
        browser.showDirectory()
        return
      
      if @result.type == 'application/zip'
        browser.addFile(browser.files, @result.name, @result)
      @continue()
      return
  new app.Browser(page, enumerate)
  
