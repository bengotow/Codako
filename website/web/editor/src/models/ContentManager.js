(function() {
  var ContentManager,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  ContentManager = (function() {

    function ContentManager(statusCallback) {
      this.tick = __bind(this.tick, this);

      this.downloadsComplete = __bind(this.downloadsComplete, this);

      this.fetchLevelAssets = __bind(this.fetchLevelAssets, this);
      this.numElementsQueued = 0;
      this.numElementsLoaded = 0;
      this.contentStatusCallback = statusCallback;
      this.contentFinishedCallback = null;
      this.elements = {
        images: {},
        sounds: {}
      };
      Ticker.addListener(this);
      Ticker.setInterval(50);
    }

    ContentManager.prototype.fetchLevelAssets = function(resources, finishCallback) {
      var info, key, _ref, _ref1, _results;
      this.soundFormat = this._soundFormatForBrowser();
      this.contentStatusCallback({
        progress: 0
      });
      this.contentFinishedCallback = finishCallback;
      if (this.soundFormat !== '.none') {
        _ref = resources.sounds;
        for (key in _ref) {
          info = _ref[key];
          this.downloadSound(key, info, this.soundFormat);
        }
      }
      _ref1 = resources.images;
      _results = [];
      for (key in _ref1) {
        info = _ref1[key];
        _results.push(this.downloadImage(key, info));
      }
      return _results;
    };

    ContentManager.prototype.downloadImage = function(key, info) {
      var _this = this;
      this.numElementsQueued += 1;
      this.asset = new Image();
      this.asset.src = info.src || info;
      this.asset.onload = function(e) {
        _this.numElementsLoaded += 1;
        if (_this.numElementsLoaded === _this.numElementsQueued) {
          return _this.downloadsComplete();
        }
      };
      this.asset.onerror = function(e) {
        return console.log("Error Loading Asset : " + e.target.src);
      };
      return this.elements.images[key] = this.asset;
    };

    ContentManager.prototype.downloadSound = function(key, info, extension) {
      var asset, i, _base, _i, _ref, _results,
        _this = this;
      _results = [];
      for (i = _i = 0, _ref = info.channels || 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        this.numElementsQueued += 1;
        asset = new Audio();
        asset.src = "" + (info.src || info) + extension;
        asset.onload = function(e) {
          _this.numElementsLoaded += 1;
          if (_this.numElementsLoaded === _this.numElementsQueued) {
            return _this.downloadsComplete();
          }
        };
        asset.load();
        (_base = this.elements.sounds)[key] || (_base[key] = {
          channels: [],
          next: 0
        });
        _results.push(this.elements.sounds[key].channels.push(asset));
      }
      return _results;
    };

    ContentManager.prototype.downloadsComplete = function() {
      Ticker.removeListener(this);
      this.contentStatusCallback({
        progress: 100
      });
      if (this.contentFinishedCallback) {
        return this.contentFinishedCallback();
      }
    };

    ContentManager.prototype.tick = function() {
      var percent;
      percent = Math.round((this.numElementsLoaded / this.numElementsQueued) * 100);
      return this.contentStatusCallback({
        progress: percent
      });
    };

    ContentManager.prototype.imageNamed = function(name) {
      var img;
      img = this.elements.images[name];
      if (!img) {
        console.log("image " + name + " not found.");
      }
      return img;
    };

    ContentManager.prototype.playSound = function(name) {
      var sound;
      sound = this.elements.sounds[name];
      if (!sound) {
        return console.log("Sound " + name + " not found.");
      }
      sound.channels[sound.next].play();
      return sound.next = (sound.next + 1) % sound.channels.length;
    };

    ContentManager.prototype.pauseSound = function(name) {
      var i, sound, _i, _len, _ref, _results;
      sound = this.elements.sounds[name];
      if (!sound) {
        return;
      }
      _ref = sound.channels.length;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(sound.channels[i].pause());
      }
      return _results;
    };

    ContentManager.prototype._soundFormatForBrowser = function() {
      var canPlayMp3, canPlayOgg, myAudio;
      myAudio = document.createElement('audio');
      canPlayMp3 = !!myAudio.canPlayType && "" !== myAudio.canPlayType('audio/mpeg');
      canPlayOgg = !!myAudio.canPlayType && "" !== myAudio.canPlayType('audio/ogg codecs="vorbis"');
      if (canPlayMp3) {
        return ".mp3";
      } else if (canPlayOgg) {
        return ".ogg";
      }
      return ".none";
    };

    return ContentManager;

  })();

  window.ContentManager = ContentManager;

}).call(this);
