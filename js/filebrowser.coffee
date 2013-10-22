window.app ?= {
  currentFile: 'lesson32.zip'
}

class app.File
	name: ''
	path: ''
	data: null
	isDirectory: false
	constructor: (@name, @path, @data, @isDirectory) ->
		@files = {}

class app.Browser

    constructor: (@page) ->
      @root = new app.File('', '', null, true)
      page.bind 'pageshow', () => @enumerate()
    
    addFile: (directory, filename, data) ->
      if filename is ''
        return
      slashPosition = filename.indexOf('/')
      if slashPosition != -1
        directoryName = filename.substr(0, slashPosition)
        filename = filename.substr(slashPosition + 1)
        unless directory.files[directoryName]
          directory.files[directoryName] = new app.File(directoryName, directory.path + '/' + directoryName, data, true)
        @addFile(directory.files[directoryName], filename, data)
        return
      directory.files[filename] = new app.File(filename, directory.path + '/' + filename, data, false)
      
    addItem: (name, path, data, isDir) =>
      element = $('<li>').html("<a>#{name}</a>")
      if isDir
        element.bind 'vclick', =>
          @showDirectory(path)
      @page.find('ul').append(element).listview('refresh')
      return element
    
    showDirectory: (dirname) ->
      directory = @root
      
      if dirname?[0] == '/'
          dirname = dirname[1..]
      if dirname?[dirname.length - 1] == '/'
        dirname = dirname[...dirname.length - 1]
      if dirname
        for part in dirname.split('/')
          directory = directory.files[part]
      else
        dirname = ''
      @page.find('ul').html('')
        
      
      if dirname != ''
        @addItem('..', '/' + dirname[0...('/' + dirname).lastIndexOf('/')], {}, true)
      for _, file of directory.files
        @addItem(file.name, file.path, file.data, file.isDirectory)
      
      return

class app.FileBrowser extends app.Browser
    enumerate: -> 
      sdcard = navigator.getDeviceStorage('sdcard')
      cursor = sdcard.enumerate()
      $('.ui-loading').show()
      browser = this
      cursor.onsuccess = ->
        if !@result
          $('.ui-loading').hide()
          browser.showDirectory()
          
          return
        
        if @result.type == 'application/zip'
          browser.addFile(browser.root, @result.name, @result)
        @continue()
        return
    addItem: (name, path, data, isDir) ->
      element = super
      unless isDir
        element.bind 'vclick', ->
          # ugly :/
          app.currentFile = path
          jQuery.mobile.changePage($('#zipbrowser'))

class app.ZipBrowser extends app.Browser
    enumerate: () ->
      sdcard = navigator.getDeviceStorage('sdcard')
      if app.currentFile.indexOf('/') is 0
        app.currentFile = app.currentFile[1..]
      request = sdcard.get(app.currentFile)
      browser = this
      request.onsuccess = ->
        zip.createReader new zip.BlobReader(@result), (reader) -> 
          reader.getEntries (entries) ->
            for entry in entries
              browser.addFile(browser.root, entry.filename, entry)
            browser.showDirectory()
      return

$(document).bind 'pageinit', ->
  
  new app.FileBrowser($('#filebrowser'))
  new app.ZipBrowser($('#zipbrowser'))
  
