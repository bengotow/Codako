
class ContentManager


  constructor: (stage, width, height) ->
    @numElementsQueued = 0
    @numElementsLoaded = 0
    @stage = stage
    @width = width
    @height = height
    @elements =
      images: {}
      sounds: {}


  # public method to launch the download process
  startDownload: () ->
    window.Socket.emit('join', { my: 'data' })
    window.Socket.on 'assetlist', (resources) =>
      # add a text object to output the current donwload progression
      @downloadProgress = new Text("-- %", "bold 14px Arial", "#FFF")
      @downloadProgress.x = (@width / 2) - 50
      @downloadProgress.y = @height / 2
      @stage.addChild(@downloadProgress)

      # If the browser supports either MP3 or OGG
      @soundFormat = @soundFormatForBrowser()

      if @soundFormat != '.none'
        @downloadSound(key, info, @soundFormat) for key, info of resources.sounds
      @downloadImage(key, info) for key, info of resources.images

      Ticker.addListener(@)
      Ticker.setInterval(50)


  setDownloadCompletionCallback: (callbackMethod) ->
    @ondownloadcompleted = callbackMethod


  downloadImage: (key, info) ->
    @numElementsQueued += 1
    @asset = new Image()
    @asset.src = info.src || info
    @asset.onload = (e) =>
      @numElementsLoaded += 1
      @downloadsComplete() if (@numElementsLoaded == @numElementsQueued)
    @asset.onerror = (e) =>
      console.log("Error Loading Asset : " + e.target.src)
    @elements.images[key] = @asset

  downloadSound: (key, info, extension) ->
    for i in [0..(info.channels || 1)]
      asset = new Audio()
      asset.src = "#{info.src || info}#{extension}"
      asset.load()
      @elements.sounds[key] ||= {channels: [], next: 0}
      @elements.sounds[key].channels.push(asset)

  downloadsComplete: () ->
    Ticker.removeAllListeners()
    @stage.removeChild(@downloadProgress)
    @ondownloadcompleted()

  imageNamed: (name) ->
    @elements.images[name]


  soundFormatForBrowser: () ->
    # Need to check the canPlayType first or an exception
    # will be thrown for those browsers that don't support it
    myAudio = document.createElement('audio')

    # Currently canPlayType(type) returns: "", "maybe" or "probably"
    canPlayMp3 = !!myAudio.canPlayType && "" != myAudio.canPlayType('audio/mpeg')
    canPlayOgg = !!myAudio.canPlayType && "" != myAudio.canPlayType('audio/ogg codecs="vorbis"')

    if (canPlayMp3)
      return ".mp3"
    else if (canPlayOgg)
      return ".ogg"
    return ".none"


  tick: () ->
    return unless @downloadProgress
    @downloadProgress.text = "Downloading " + Math.round((@numElementsLoaded / @numElementsQueued) * 100) + " %"
    @stage.update()


  playSound: (name) ->
    sound = @elements.sounds[name]
    return unless sound
    
    sound.channels[sound.next].play()
    sound.next = (sound.next + 1) % sound.channels.length
    
  pauseSound: (name) ->
    sound = @elements.sounds[name]
    return unless sound
    sound.channels[i].pause() for i in sound.channels.length
    

window.ContentManager = ContentManager
