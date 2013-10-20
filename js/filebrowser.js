if (window.app == null) {
  window.app = {};
}

app.Browser = (function() {
  function _Class(page, enumerate) {
    var _this = this;
    this.page = page;
    this.enumerate = enumerate;
    page.bind('pageshow', function() {
      return enumerate(_this);
    });
  }

  _Class.prototype.files = {};

  _Class.prototype.addFile = function(directory, filename, data) {
    var directoryName, slashPosition;
    slashPosition = filename.indexOf('/');
    if (slashPosition !== -1) {
      directoryName = filename.substr(0, slashPosition + 1);
      filename = filename.substr(slashPosition + 1);
      if (!directory[directoryName]) {
        directory[directoryName] = {};
      }
      this.addFile(directory[directoryName], filename);
      return;
    }
    return directory[filename] = data;
  };

  _Class.prototype.showDirectory = function(dirname) {
    var addItem, data, directory, name, part, _i, _len, _ref,
      _this = this;
    directory = this.files;
    if ((dirname != null ? dirname[0] : void 0) === '/') {
      dirname = dirname.slice(1);
    }
    if ((dirname != null ? dirname[dirname.length - 1] : void 0) === '/') {
      dirname = dirname.slice(0, dirname.length - 1);
    }
    if (dirname) {
      _ref = dirname.split('/');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        part = _ref[_i];
        directory = directory[part + '/'];
      }
    } else {
      dirname = '';
    }
    this.page.find('ul').html('');
    addItem = function(name, path, isDir) {
      var element;
      element = $('<li>').html("<a>" + name + "</a>");
      if (isDir) {
        element.bind('vclick', function() {
          return _this.showDirectory(path);
        });
      }
      return _this.page.find('ul').append(element).listview('refresh');
    };
    if (dirname !== '') {
      addItem('..', '/' + dirname.slice(0, ('/' + dirname).lastIndexOf('/')), true);
    }
    for (name in directory) {
      data = directory[name];
      addItem(name, "" + dirname + "/" + name, name.indexOf('/') !== -1);
    }
  };

  return _Class;

})();

$(document).bind('pageinit', function() {
  var enumerate, page;
  page = $('#filebrowser');
  enumerate = function(browser) {
    var cursor, sdcard;
    sdcard = navigator.getDeviceStorage('sdcard');
    cursor = sdcard.enumerate();
    $('.ui-loading').show();
    return cursor.onsuccess = function() {
      if (!this.result) {
        $('.ui-loading').hide();
        browser.showDirectory();
        return;
      }
      if (this.result.type === 'application/zip') {
        browser.addFile(browser.files, this.result.name, this.result);
      }
      this["continue"]();
    };
  };
  return new app.Browser(page, enumerate);
});
