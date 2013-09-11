
TutorialCtrl = ($scope) ->
  $scope.tutorial = [
    {
      text: "Hi there! Welcome to Codako.",
      soundURL: '/stage-editor/sounds/tutorial/1.mp3'
    },
    {
      text: "I'm Preethi, and this is a game I've been working on! It takes place
      in a cave where the hero has to avoid the lava and escape. I'm not quite
      done yet, but let me show you what I have so far!",
      soundURL: '/stage-editor/sounds/tutorial/2.mp3'
    },
    {
      text: "These are the buttons that start and stop the game. When you play a normal
      computer game, you can't pause and rewind, but since we're making our own game,
      we can stop it or rewind whenever we want. It's helpful to go back when something
      doesn't work the way you thought it would.",
      action: () -> $scope.highlight('.controls div.center')
    },
    {
      text: "Click the 'Run' button to start my game.",
      action: () ->
        $scope.highlight('#button-run')
    },
    {
      trigger: () -> window.Game?.running
      text: "You can move the hero around with the arrow keys. Go ahead and try it!"
      action: () ->
        $scope.clearHighlights()
        setTimeout () ->
          $scope.hasExploredGame = true
        , 12000
    },
    {
      trigger: () -> $scope.hasExploredGame
      text: "Oops—you can't get to the exit yet! I need to make a bridge over the lava
      so the hero can walk across. Want to help me add the bridge? Let's do it together.
      Okay. Let's see...",
    },
    {
      text: "This is called the stage - it's where we design our game world.",
      soundURL: '/stage-editor/sounds/tutorial/3.mp3'
      action: () ->
        window.Game.running = false
        $scope.highlight('#platformerCanvasPane1')
    },
    {
      text: "This is the character library. It shows all of the game pieces we've made.
      In Codako, you get to draw your own game pieces, so they can be anything you want!
      I've already drawn dirt and lava since this is a cave world. To make a bridge for
      our hero to get over the lava, we need to make a new bridge piece.",
      soundURL: '/stage-editor/sounds/tutorial/4.mp3'
      action: () -> $scope.highlight('#definitions')
    },
    {
      text: "Go ahead and click on the + sign in the library. You can help me draw it!",
      soundURL: '/stage-editor/sounds/tutorial/5.mp3'
      action: () -> $scope.highlight('#definitions .icon-plus')
    },
    {
      trigger: () -> $('#pixelArtModal').offset().top != 0
      text: "Use the tools on the left side to draw a piece of a bridge. It can look like
      anything you want, and you can always come back and change it later.",
      soundURL: '/stage-editor/sounds/tutorial/6.mp3'
      action: () -> $scope.highlight('.sidebar')
    },
    {
      text: "When you're done, click the blue button down here.",
      soundURL: '/stage-editor/sounds/tutorial/7.mp3'
      action: () -> $scope.highlight('#pixelArtModal .modal-footer .btn-primary')
    },
    {
      trigger: () -> $('#pixelArtModal').is(':visible') == false
      text: "Wow! That looks cool. See how that bridge block is down in our library now?
      Move the mouse over the bridge piece and drag it up into our game world. You can
      drag pieces around the world to set it up the way you want. Drag enough blocks
      out from the library to create a bridge over the lava.",
      soundURL: '/stage-editor/sounds/tutorial/8.mp3'
      action: () -> $scope.highlight('#definitions .item.active')
    },
    {
      text: "If you make a mistake, click on the trash can tool and click on the block you
      want to get rid of.",
      soundURL: '/stage-editor/sounds/tutorial/9.mp3'
      action: () -> $scope.highlight('#tool-delete', {temporary: true})
    },
    {
      trigger: () ->
        ids = window.Game.library.actorDefinitionIDs()
        descriptor = { definition_id: ids[ids.length-1] } # new bridge
        return window.Game.mainStage.actorsMatchingDescriptor(descriptor).length == 5
      text: "Let's see how your bridge does! Click 'Run' again to play our game. Try using the arrow keys
      to walk over the lava. Can you get to the door? If you can't, try moving the bridge pieces around.",
      soundURL: '/stage-editor/sounds/tutorial/10.mp3'
      action: () -> $scope.highlight('#button-run', {temporary: true})
    },
    {
      trigger: () -> $scope.mainCharacter().worldPos.x == 12
      text: "Great job! You made it over the lava! It doesn't look like our character can make
      it to the exit, though. I forgot - I never told him how to climb over that rock! Since we're
      creating this game, we can decide what he should do. Let's teach him to climb over the rock
      so he can get to the exit.",
    },
    {
      text: "Okay - let's see. Click on the rule recording icon in the sidebar. Using the recording tool,
      we can create a rule for our character that teaches him what to do when he's next to a rock.",
      action: () -> $scope.highlight('#button-record')
    },
    {
      trigger: () -> $('#tool-record').hasClass('btn-info')
      text: "Tap on our hero - we want to show him how to climb, so we'll focus on him.",
      action: () ->
        $scope.highlightStageTile($scope.mainCharacter().worldPos, {temporary: true})
    },
    {
      trigger: () -> $('#button-start-recording').length > 0
      text: "Perfect. See how the stage has been grayed out? When we're showing our hero a
      new rule, it's important for us to show him what he should pay attention to. We don't
      want him getting distracted by what's going on in the rest of the world.",
    },
    {
      text: "These handles let us expand the area our hero will focus on. For this rule,
      it's important that there's an obstacle in front of him! Drag the right handle
      so it includes the block he has to climb.",
      action: () ->
        p = $scope.mainCharacter().worldPos
        $scope.highlightStageTile(new Point(p.x + 1, p.y), {temporary: true})
    },
    {
      trigger: () -> window.Game.mainStage.recordingExtent.right - window.Game.mainStage.recordingExtent.left > 0
      text: "Great! Go ahead and drag the top handle up by one block, too. Since we're going
      to teach him to climb, he needs to make sure he has space above him!",
      action: () ->
        p = $scope.mainCharacter().worldPos
        $scope.highlightStageTile(new Point(p.x, p.y - 1), {temporary: true})
    },
    {
      trigger: () -> window.Game.mainStage.recordingExtent.bottom - window.Game.mainStage.recordingExtent.top > 0
      text: "Perfect. Now we're ready to show our hero what to do! Click the Start Recording button.",
      action: () -> $scope.highlight('#button-start-recording', {temporary:true})
    },
    {
      trigger: () -> $('#button-save-recording').length > 0
      text: "Okay good!",
    },
    {
      text: "Whenever our hero is walking around, he'll look at the picture on the left
      and see if his surroundings look like that.",
      action: () -> $scope.highlight('#platformerCanvasPane1', {temporary: true})
    },
    {
      text: "If they do, he'll follow the instructions we give him here!",
      action: () -> $scope.highlight('#platformerCanvasPane2', {temporary: true})
    },
    {
      text: "To tell our hero to climb the block, drag him on top of the block here.",
    },
    {
      trigger: () -> window.Game.selectedRule?.actions?.length > 0
      text: "Great! See how that created an instruction for our character? Now he knows what he should do!",
      action: () -> $scope.highlight('.panel.actions .action', {temporary: true})
    },
    {
      text: "Click 'Save Recording' and let's try out your new rule.",
      action: () -> $scope.highlight('#button-save-recording', {temporary:true})
    },
    {
      trigger: () -> $('#button-run').is(':visible')
      text: "Press 'Run'! If we did it right, our hero should climb the block now.",
      action: () -> $scope.highlight('#button-run', {temporary: true})
    },
    {
      trigger: () -> $scope.mainCharacter().worldPos.x > 12
      text: "Wow that was great! We taught the hero how to climb up over the block,
      and now we can use the arrow keys to guide him to the exit.",
    },
    {
      text: "You know, since we're making a game, we should probably make our hero
      climb when you press the space bar. Right now, he climbs all by himself and
      we might not want him to!",
    },
    {
      text: "Double-click on our hero and let's look at the rules we've taught him.",
      action: () ->
        p = $scope.mainCharacter().worldPos
        $scope.highlightStageTile(new Point(p.x + 0.5, p.y - 1), {temporary: true})
    },
    {
      trigger: () -> $('#rules').hasClass('active')
      text: "Each time our hero thinks about his next step, he starts with the first
      rule and moves down the list. He looks at each one to see if his surroundings
      match the picture. If it does, he does what the rule tells him and stops.",
      action: () -> $scope.arrow($($('.rules-list:first li')[0]), $($('.rules-list:first li')[2]))
    },
    {
      text: "Some of our hero's rules are in green blocks, telling him he should only
      look at them when a key is pressed. Here's the rule that tells our hero to walk left.",
      action: () -> $scope.highlight('.rule-container.event:first')
    },
    {
      text: "Our climbing rule isn't inside a green block, so our hero will always try
      to climb. Let's make it so you have to press the space bar for him to climb!",
    },
    {
      text: "We'll need a new green block. Click 'Add' up here.",
      action: () -> $scope.highlight('#buton-add-rule')
    },
    {
      trigger: () -> $('#menu-key-pressed').is(':visible')
      text: "Choose 'When a Key is Pressed' from the menu.",
      action: () -> $scope.highlight('#menu-key-pressed', {temporary: true})
    },
    {
      trigger: () -> $('#keyInputModal').is(':visible')
      text: "Okay. What key should we use? Maybe the space bar? Press a key you want
      to use and then click the done button.",
      action: () -> $scope.highlight('#keyInputModal .modal-footer .btn-primary')
    },
    {
      trigger: () -> !$('#keyInputModal').is(':visible')
      text: "Great! There's our new green block. Let's put our climbing rule in there
      so the hero will only climb when we press that key.",
      action: () -> $scope.highlight('.rule-container.event:first', {temporary:true})
    },
    {
      text: "Drag and drop the climbing rule into the empty space inside our new green block.",
      action: () -> $scope.arrow($('.rule-container.event:last').find('.rule:last'), $('.rule-container.event:first .rules-list'))
    },
    {
      trigger: () -> $('.rule-container.event:first li').length > 0
      text: "Great! We've just told our hero that he should only climb when you press
      the key. Move the hero back to the left side of the stage and let's try this out!",
    }
  ]

  $scope.$root.$on 'tutorial_content_ready', () ->
    window.AudioContext = window.AudioContext || window.webkitAudioContext
    $scope.audioContext = new AudioContext()

    async.eachSeries $scope.tutorial, (step, callback) ->
        return unless step.soundURL
        request = new XMLHttpRequest()
        request.open('GET', step.soundURL, true)
        request.responseType = 'arraybuffer'
        request.onload = () ->
          $scope.audioContext.decodeAudioData @response,
          (buffer) ->
            step.soundBuffer = buffer
            callback(null)
          ,
          (buffer) ->
            console.log("Failed to load sound #{step.soundURL}")
            callback(null)
        request.send()

    if window.Game.tutorial_step >= 0
      $scope.checkShouldAdvance()


  $scope.isInTutorial = () ->
    window.Game.tutorial_name != null


  $scope.currentStep = () ->
    $scope.tutorial[window.Game.tutorial_step]


  $scope.mainCharacter = () ->
    descriptor = { definition_id: '522e39221b2d9b94c0000017' } # main character
    options = window.Game.mainStage.actorsMatchingDescriptor(descriptor)
    return options[options.length - 1] if options.length > 0
    return null


  $scope.clearHighlights = (callback = null) ->
    if $scope.highlighted
      $($scope.highlighted).highlighter('erase')
      $scope.highlighted = null
      setTimeout(callback, 500) if callback
    else
      callback() if callback


  $scope.highlight = (selector, options = {}) ->
    $scope.clearHighlights () ->
      $(selector).highlighter('show')
      $scope.highlighted = selector
      if (options.temporary)
        setTimeout () ->
          if $scope.highlighted == selector
            $(selector).highlighter('erase')
            $scope.highlighted = null
        ,2000


  $scope.highlightStageTile = (tile, options = {}) ->
    $scope.clearHighlights () ->
      offset = window.Game.mainStage.screenPointForTile(tile)
      $('#platformerCanvasPane1').highlighter('show', {offset: {top: offset.y-30, left: offset.x-30}, width: Tile.WIDTH+60, height: Tile.HEIGHT+60})
      $scope.highlighted = '#platformerCanvasPane1'
      if (options.temporary)
        setTimeout () ->
          if $scope.highlighted == '#platformerCanvasPane1'
            $('#platformerCanvasPane1').highlighter('erase')
            $scope.highlighted = null
        ,2000


  $scope.advanceByStep = () ->
    window.Game.tutorial_step += 1
    step = $scope.currentStep()
    step.action() if step.action

    initialDelay = 1500 + step.text.length * 23

    if step.soundBuffer
      initialDelay = step.soundBuffer.duration * 1000
      source = $scope.audioContext.createBufferSource()
      source.buffer = step.soundBuffer
      source.connect($scope.audioContext.destination)
      source.start(0)

    # wait until finished speaking instructions
    setTimeout $scope.checkShouldAdvance, initialDelay

    $scope.$apply() unless $scope.$$phase



  $scope.checkShouldAdvance = () ->
    nextStep = $scope.tutorial[window.Game.tutorial_step+1]

    if nextStep && (!nextStep.trigger || nextStep.trigger() == true)
      $scope.advanceByStep()
    else
      setTimeout $scope.checkShouldAdvance, 500


window.TutorialCtrl = TutorialCtrl