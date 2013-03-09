
ContentManager = (stage, width, height) ->
    ondownloadcompleted = undefined
    NUM_ELEMENTS_TO_DOWNLOAD = 29
    numElementsLoaded = 0

    canPlayMp3 = undefined
    canPlayOgg = undefined

    downloadProgress = undefined

    # Need to check the canPlayType first or an exception
    # will be thrown for those browsers that don't support it
    myAudio = document.createElement('audio')

    if (myAudio.canPlayType)
        # Currently canPlayType(type) returns: "", "maybe" or "probably"
        canPlayMp3 = !!myAudio.canPlayType && "" != myAudio.canPlayType('audio/mpeg')
        canPlayOgg = !!myAudio.canPlayType && "" != myAudio.canPlayType('audio/ogg codecs="vorbis"')

    # setting the callback method
    # Triggered once everything is ready to be drawned on the canvas
    this.SetDownloadCompleted = (callbackMethod) ->
        ondownloadcompleted = callbackMethod

    # All the Images & Sounds of our game
    this.imgMonsterA = new Image()
    this.imgMonsterB = new Image()
    this.imgMonsterC = new Image()
    this.imgMonsterD = new Image()
    this.imgBlockA0 = new Image()
    this.imgBlockA1 = new Image()
    this.imgBlockA2 = new Image()
    this.imgBlockA3 = new Image()
    this.imgBlockA4 = new Image()
    this.imgBlockA5 = new Image()
    this.imgBlockA6 = new Image()
    this.imgBlockB0 = new Image()
    this.imgBlockB1 = new Image()
    this.imgExit = new Image()
    this.imgPlatform = new Image()
    this.imgPlayer = new Image()
    this.imgGem = new Image()
    this.winOverlay = new Image()
    this.loseOverlay = new Image()
    this.diedOverlay = new Image()
    this.globalMusic = new Audio()
    this.playerKilled = new Audio()
    this.playerJump = new Audio()
    this.playerFall = new Audio()
    this.exitReached = new Audio()
    this.gemCollected = []

    # the background can be created with 3 differents layers
    # those 3 layers exist in 3 versions
    this.imgBackgroundLayers = new Array()

    # public method to launch the download process
    this.StartDownload = () ->
        # add a text object to output the current donwload progression
        downloadProgress = new Text("-- %", "bold 14px Arial", "#FFF")
        downloadProgress.x = (width / 2) - 50
        downloadProgress.y = height / 2
        stage.addChild(downloadProgress)

        audioExtension = ".none"

        if (canPlayMp3)
            audioExtension = ".mp3"
        else if (canPlayOgg)
            audioExtension = ".ogg"

        # If the browser supports either MP3 or OGG
        if (audioExtension != ".none")
            SetAudioDownloadParameters(this.globalMusic, "sounds/Music" + audioExtension)
            SetAudioDownloadParameters(this.playerKilled, "sounds/PlayerKilled" + audioExtension)
            SetAudioDownloadParameters(this.playerJump, "sounds/PlayerJump" + audioExtension)
            SetAudioDownloadParameters(this.playerFall, "sounds/PlayerFall" + audioExtension)
            SetAudioDownloadParameters(this.exitReached, "sounds/ExitReached" + audioExtension)
            # Used to simulate multi-channels audio
            # As HTML5 Audio in browsers is today too limited
            # Yes, I know, we're forced to download N times to same file...
            for a in [0..8]
                this.gemCollected[a] = new Audio()
                SetAudioDownloadParameters(this.gemCollected[a], "sounds/GemCollected" + audioExtension)

        # download the 3 layers * 3 versions
        for i in [0..2]
            this.imgBackgroundLayers[i] = new Array()
            for j in [0..2]
                this.imgBackgroundLayers[i][j] = new Image()
                SetDownloadParameters(this.imgBackgroundLayers[i][j], "img/Backgrounds/Layer" + i + "_" + j + ".png")

        SetDownloadParameters(this.imgPlayer, "img/Player.png")
        SetDownloadParameters(this.imgMonsterA, "img/MonsterA.png")
        SetDownloadParameters(this.imgMonsterB, "img/MonsterB.png")
        SetDownloadParameters(this.imgMonsterC, "img/MonsterC.png")
        SetDownloadParameters(this.imgMonsterD, "img/MonsterD.png")

        SetDownloadParameters(this.winOverlay, "overlays/you_win.png")
        SetDownloadParameters(this.loseOverlay, "overlays/you_lose.png")
        SetDownloadParameters(this.diedOverlay, "overlays/you_died.png")

        SetDownloadParameters(this.imgBlockA0, "img/Tiles/BlockA0.png")
        SetDownloadParameters(this.imgBlockA1, "img/Tiles/BlockA1.png")
        SetDownloadParameters(this.imgBlockA2, "img/Tiles/BlockA2.png")
        SetDownloadParameters(this.imgBlockA3, "img/Tiles/BlockA3.png")
        SetDownloadParameters(this.imgBlockA4, "img/Tiles/BlockA4.png")
        SetDownloadParameters(this.imgBlockA5, "img/Tiles/BlockA5.png")
        SetDownloadParameters(this.imgBlockA6, "img/Tiles/BlockA6.png")
        SetDownloadParameters(this.imgBlockB0, "img/Tiles/BlockB0.png")
        SetDownloadParameters(this.imgBlockB1, "img/Tiles/BlockB1.png")
        SetDownloadParameters(this.imgGem, "img/Tiles/Gem.png")
        SetDownloadParameters(this.imgExit, "img/Tiles/Exit.png")
        SetDownloadParameters(this.imgPlatform, "img/Tiles/Platform.png")

        Ticker.addListener(this)
        Ticker.setInterval(50)


    SetDownloadParameters = (assetElement, url) ->
        assetElement.src = url
        assetElement.onload = handleElementLoad
        assetElement.onerror = handleElementError

    SetAudioDownloadParameters = (assetElement, url) ->
        assetElement.src = url
        # Precharging the sound
        assetElement.load()

    # our global handler
    handleElementLoad = (e) ->
        numElementsLoaded++

        # If all elements have been downloaded
        if (numElementsLoaded == NUM_ELEMENTS_TO_DOWNLOAD)
            stage.removeChild(downloadProgress)
            Ticker.removeAllListeners()
            numElementsLoaded = 0
            # we're calling back the method set by SetDownloadCompleted
            ondownloadcompleted()

    # called if there is an error loading the image (usually due to a 404)
    handleElementError = (e) ->
        console.log("Error Loading Asset : " + e.target.src)

    # Update methid which simply shows the current % of download
    this.tick = () ->
        downloadProgress.text = "Downloading " + Math.round((numElementsLoaded / NUM_ELEMENTS_TO_DOWNLOAD) * 100) + " %"

        # update the stage:
        stage.update()

    this

window.ContentManager = ContentManager
