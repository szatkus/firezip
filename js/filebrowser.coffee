window.app ?= {
  currentFile: 'lesson32.zip'
}
app.Browser = class

    constructor: (@page) ->
      @files = {}
      page.bind 'pageshow', (data) => @enumerate()
    
    addFile: (directory, filename, data) ->
      if filename is ''
        return
      slashPosition = filename.indexOf('/')
      if slashPosition != -1
        directoryName = filename.substr(0, slashPosition + 1)
        filename = filename.substr(slashPosition + 1)
        if !directory[directoryName]
          directory[directoryName] = {}
        @addFile(directory[directoryName], filename)
        return
      directory[filename] = data
      
    addItem: (name, path, data, isDir) =>
      element = $('<li>').html("<a>#{name}</a>")
      if isDir
        element.bind 'vclick', =>
          @showDirectory(path)
      @page.find('ul').append(element).listview('refresh')
      return element
    
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
        
      
      if dirname != ''
        @addItem('..', '/' + dirname[0...('/' + dirname).lastIndexOf('/')], {}, true)
      for name, data of directory
        @addItem(name, "#{dirname}/#{name}", data, name.indexOf('/') != -1)
      
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
          browser.addFile(browser.files, @result.name, @result)
        @continue()
        return
    addItem: (name, path, data, isDir) ->
      element = super
      if (!isDir)
        element.bind 'vclick', ->
          # ugly :/
          app.currentFile = path
          jQuery.mobile.changePage($('#zipbrowser'))

class app.ZipBrowser extends app.Browser
    enumerate: () ->
      sdcard = navigator.getDeviceStorage('sdcard')
      if app.currentFile.indexOf('/') is 0
        app.currentFile = app.currentFile[1..]
      console.log(app.currentFile)
      request = sdcard.get(app.currentFile)
      browser = this
      request.onsuccess = ->
        zip.createReader new zip.BlobReader(@result), (reader) -> 
          console.log(reader)
          reader.getEntries (entries) ->
            for entry in entries
              browser.addFile(browser.files, entry.filename, entry)
            browser.showDirectory()
      return

$(document).bind 'pageinit', ->
  
  new app.FileBrowser($('#filebrowser'))
  new app.ZipBrowser($('#zipbrowser'))
  
