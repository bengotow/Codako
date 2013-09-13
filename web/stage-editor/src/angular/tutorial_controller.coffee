
TutorialCtrl = ($scope) ->
  $scope.tutorialTimer = null
  $scope.audioSource = null
  $scope.tutorial = [
    {
      text: "Hi there! Welcome to Codako.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-01.mp3'
    },
    {
      text: "I'm Preethi, and this is a game I've been working on! It takes place
      in a cave where the hero has to avoid the lava and escape. I'm not quite
      done yet, but let me show you what I have so far!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-02.mp3'
    },
    {
      text: "These are the buttons that start and stop the game. When you play a normal
      computer game, you can't pause and rewind, but since we're making our own game,
      we can stop it or rewind whenever we want. It's helpful to go back when something
      doesn't work the way you thought it would.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-03.mp3',
      action: () -> $scope.highlight('.controls div.center')
    },
    {
      text: "Click the 'Run' button to start my game.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-04.mp3',
      action: () ->
        $scope.highlight('#button-run')
    },
    {
      trigger: () -> window.Game?.running
      text: "You can move the hero around with the arrow keys. Go ahead and try it!"
      soundURL: '/stage-editor/sounds/tutorial/tutorial-05.mp3',
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
      soundURL: '/stage-editor/sounds/tutorial/tutorial-06.mp3',
    },
    {
      text: "This is called the stage - it's where we design our game world.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-07.mp3',
      action: () ->
        window.Game.running = false
        $scope.highlight('#platformerCanvasPane1')
    },
    {
      text: "This is the character library. It shows all of the game pieces we've made.
      In Codako, you get to draw your own game pieces, so they can be anything you want!
      I've already drawn dirt and lava since this is a cave world. To make a bridge for
      our hero to get over the lava, we need to make a new bridge piece.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-08.mp3'
      action: () -> $scope.highlight('#definitions')
    },
    {
      text: "Go ahead and click on the + sign in the library. You can help me draw it!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-09.mp3'
      action: () -> $scope.highlight('#definitions .icon-plus')
    },
    {
      trigger: () -> $('#pixelArtModal').offset().top != 0
      text: "Use the tools on the left side to draw a piece of a bridge. It can look like
      anything you want, and you can always come back and change it later.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-10.mp3'
      action: () -> $scope.highlight('.sidebar')
    },
    {
      text: "When you're done, click the blue button down here.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-11.mp3'
      action: () -> $scope.highlight('#pixelArtModal .modal-footer .btn-primary')
    },
    {
      trigger: () -> $('#pixelArtModal').is(':visible') == false
      text: "Wow! That looks cool. See how that bridge block is down in our library now?
      Move the mouse over the bridge piece and drag it up into our game world. You can
      drag pieces around the world to set it up the way you want. Drag enough blocks
      out from the library to create a bridge over the lava.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-12.mp3'
      action: () -> $scope.highlight('#definitions .item.active')
    },
    {
      text: "If you make a mistake, click on the trash can tool and click on the block you
      want to get rid of.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-13.mp3'
      action: () -> $scope.highlight('#tool-delete', {temporary: true})
    },
    {
      trigger: () ->
        ids = window.Game.library.actorDefinitionIDs()
        descriptor = { definition_id: ids[ids.length-1] } # new bridge
        return window.Game.mainStage.actorsMatchingDescriptor(descriptor).length == 5
      text: "Let's see how your bridge does! Click 'Run' again to play our game. Try using the arrow keys
      to walk over the lava. Can you get to the door? If you can't, try moving the bridge pieces around.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-14.mp3'
      action: () -> $scope.highlight('#button-run', {temporary: true})
    },
    {
      trigger: () -> $scope.mainCharacter().worldPos.x == 9
      text: "Great job! You made it over the lava! It doesn't look like our character can make
      it to the exit, though. I forgot - I never told him how to climb over that rock! Since we're
      creating this game, we can decide what he should do. Let's teach him to climb over the rock
      so he can get to the exit.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-15.mp3',
    },
    {
      text: "Okay - let's see. Click on the rule recording icon in the sidebar. Using the recording tool,
      we can create a rule for our character that teaches him what to do when he's next to a rock.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-16.mp3',
      action: () -> $scope.highlight('#tool-record')
    },
    {
      trigger: () -> $('#tool-record').hasClass('btn-info') || $('#button-start-recording').length > 0
      text: "Tap on our hero - we want to show him how to climb, so we'll focus on him.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-17.mp3',
      action: () ->
        $scope.highlightStageTile($scope.mainCharacter().worldPos, {temporary: true})
    },
    {
      trigger: () -> $('#button-start-recording').length > 0
      text: "Perfect. See how the stage has been grayed out? When we're showing our hero a
      new rule, it's important for us to show him what he should pay attention to. We don't
      want him getting distracted by what's going on in the rest of the world.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-18.mp3',
    },
    {
      text: "These handles let us expand the area our hero will focus on. For this rule,
      it's important that there's an obstacle in front of him! Drag the right handle
      so it includes the block he has to climb.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-19.mp3',
      action: () ->
        p = $scope.mainCharacter().worldPos
        $scope.highlightStageTile(new Point(p.x + 1, p.y), {temporary: true})
    },
    {
      trigger: () -> window.Game.mainStage.recordingExtent.right - window.Game.mainStage.recordingExtent.left > 0
      text: "Great! Go ahead and drag the top handle up by one block, too. Since we're going
      to teach him to climb, he needs to make sure he has space above him!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-20.mp3',
      action: () ->
        p = $scope.mainCharacter().worldPos
        $scope.highlightStageTile(new Point(p.x, p.y - 1), {temporary: true})
    },
    {
      trigger: () -> window.Game.mainStage.recordingExtent.bottom - window.Game.mainStage.recordingExtent.top > 0
      text: "Perfect. Now we're ready to show our hero what to do! Click the Start Recording button.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-21.mp3',
      action: () -> $scope.highlight('#button-start-recording', {temporary:true})
    },
    {
      trigger: () -> $('#button-save-recording').length > 0
      text: "Okay good!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-22.mp3',
    },
    {
      text: "Whenever our hero is walking around, he'll look at the picture on the left
      and see if his surroundings look like that.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-23.mp3',
      action: () -> $scope.highlight('#platformerCanvasPane1', {temporary: true})
    },
    {
      text: "If they do, he'll follow the instructions we give him here!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-24.mp3',
      action: () -> $scope.highlight('#platformerCanvasPane2', {temporary: true})
    },
    {
      text: "To tell our hero to climb the block, drag him on top of the block here.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-25.mp3',
    },
    {
      trigger: () -> window.Game.selectedRule?.actions?.length > 0
      text: "Great! See how that created an instruction for our character? Now he knows what he should do!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-26.mp3',
      action: () -> $scope.highlight('.panel.actions .action', {temporary: true})
    },
    {
      text: "Click 'Save Recording' and let's try out your new rule.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-27.mp3',
      action: () -> $scope.highlight('#button-save-recording', {temporary:true})
    },
    {
      trigger: () -> $('#button-run').is(':visible')
      text: "Press 'Run'! If we did it right, our hero should climb the block now.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-28.mp3',
      action: () -> $scope.highlight('#button-run', {temporary: true})
    },
    {
      trigger: () -> $scope.mainCharacter().worldPos.x > 9
      text: "Wow that was great! We taught the hero how to climb up over the block,
      and now we can use the arrow keys to guide him to the exit.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-29.mp3',
    },
    {
      text: "You know, since we're making a game, we should probably make our hero
      climb when you press the space bar. Right now, he climbs all by himself and
      we might not want him to!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-30.mp3',
    },
    {
      text: "Double-click on our hero and let's look at the rules we've taught him.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-31.mp3',
      action: () ->
        p = $scope.mainCharacter().worldPos
        $scope.highlightStageTile(new Point(p.x + 0.5, p.y - 1), {temporary: true})
    },
    {
      trigger: () -> $('#rules').hasClass('active')
      text: "Each time our hero thinks about his next step, he starts with the first
      rule and moves down the list. He looks at each one to see if his surroundings
      match the picture in that rule. If it does, he does what the rule tells him and stops.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-32.mp3',
      action: () -> $scope.arrow($($('.rules-list:first li')[0]), $($('.rules-list:first li')[2]))
    },
    {
      text: "Sometimes, we only want our hero to follow a rule if we tell him to. He
      knows how to walk to the right, but we can't have him walking into danger. He may be fearless,
      but there's lava! To make sure he only walks when we want him to, we can use
      event containers. They're the green blocks. Our hero knows not to look inside them
      until we tell him to!"
      soundURL: '/stage-editor/sounds/tutorial/tutorial-33.mp3',
    },
    {
      text: "See? Here's the rule that tells our hero to walk left. You can tell the rule is
      showing him how to walk left, because the picture shows him starting in the first square,
      and ending in the second square."
      soundURL: '/stage-editor/sounds/tutorial/tutorial-34.mp3',
      action: () -> $scope.highlight('.rule-container.event:first')
    },
    {
      text: "That rule is inside a green block that says 'when the right arrow key is pressed.' Our hero
      will only think about walking left when we're pressing that key!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-35.mp3',
      action: () -> $scope.highlight(".rule-container:first .header .name")
    },
    {
      text: "We taught our hero to climb, but we didn't tell him to wait us to press a key. Our climbing
      rule is down at the bottom with the other rules our hero looks at when he's not busy.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-36.mp3',
    },
    {
      text: "We'll need a new green block. Click 'Add' up here.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-37.mp3',
      action: () -> $scope.highlight('#buton-add-rule')
    },
    {
      trigger: () -> $('#menu-key-pressed').is(':visible')
      text: "Choose 'When a Key is Pressed' from the menu.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-38.mp3',
      action: () -> $scope.highlight('#menu-key-pressed', {temporary: true})
    },
    {
      trigger: () -> $('#keyInputModal').is(':visible')
      text: "Okay. What key should we use? Maybe the space bar? Press a key you want
      to use and then click the done button.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-39.mp3',
      action: () ->
        setTimeout ()->
          $scope.highlight('#keyInputModal .modal-footer .btn-primary')
        ,500
    },
    {
      trigger: () -> !$('#keyInputModal').is(':visible')
      text: "Great! There's our new green block. Let's put our climbing rule in there
      so the hero will only climb when we press that key.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-40.mp3',
      action: () -> $scope.highlight('.rule-container.event:first', {temporary:true})
    },
    {
      text: "Drag and drop the climbing rule into the empty space inside our new green block.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-41.mp3',
      action: () -> $scope.arrow($('.rule-container.event:last').find('.rule:last'), $('.rule-container.event:first .rules-list'))
    },
    {
      trigger: () -> $('.rule-container.event:first li').length > 0
      text: "We've just told our hero that he should only climb when you press
      the key. Move the hero back to the left side of the stage and let's try this out!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-42.mp3',
    },
    {
      text: "Click the 'Run' button to start the game. Try climbing over the barrier now.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-43.mp3',
      action: () ->
        $scope.mainCharacter().setWorldPos(1, 5)
        $scope.highlight('#button-run')
    },
    {
      trigger: () -> $scope.mainCharacter().worldPos.x > 9
      text: "Nice - it worked! This game is getting cool! To make the game harder I was going to make this boulder fall off the mountain as the hero walked by. The person playing the game would have to dodge the boulder to get to the exit! The boulder doesn't do anything yet. Want to help me?",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-44.mp3',
      action: () ->
        $scope.highlight('#button-run')
    },
    {
      text: "This time, I think we need to teach the boulder a new rule. When the hero gets close, it should slip off the ledge and start falling! Let's say the hero should be...",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-45.mp3',
    },
    {
      text: "here when the boulder starts to fall. Remember how we created our first rule?"
      soundURL: '/stage-editor/sounds/tutorial/tutorial-46.mp3',
      action: () ->
        $scope.mainCharacter().setWorldPos(11, 9)
    }
    {
      text: "Switch to the recording tool again. This time, click on the boulder!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-47.mp3',
      action: () -> $scope.highlight('#tool-record')
    },
    {
      trigger: () -> $('#tool-record').hasClass('btn-info') || $('#button-start-recording').length > 0
      action: () -> $scope.highlightStageTile($scope.boulderCharacter().worldPos, {temporary: true})
    },
    {
      trigger: () -> $('#button-start-recording').length > 0
      text: "Perfect. Let's think about this for a minute... See how the stage has been grayed out?
      We want our boulder to focus on where the hero is down below, so let's use the handles to
      expand the area we're focusing on. Can you expand them so that the hero is inside the box?",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-48.mp3',
      action: () ->
        p = $scope.boulderCharacter().worldPos
        $scope.highlightStageTile(new Point(p.x - 1, p.y), {temporary: true})
    },
    {
      trigger: () -> window.Game.mainStage.recordingExtent.bottom >= $scope.mainCharacter().worldPos.y && window.Game.mainStage.recordingExtent.left <= $scope.mainCharacter().worldPos.x
      text: "Perfect. Now we're ready to show the boulder what to do. Click the Start Recording button.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-49.mp3',
      action: () -> $scope.highlight('#button-start-recording', {temporary:true})
    },
    {
      trigger: () -> $('#button-save-recording').length > 0
      text: "Okay good!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-50.mp3',
    },
    {
      text: "To make our boulder fall off the ledge, drag it over by one square.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-51.mp3',
    },
    {
      trigger: () -> window.Game.selectedRule?.actions?.length > 0
      text: "Great! Now the boulder will slip off the ledge when our hero walks over and the picture on the left matches!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-52.mp3',
      action: () -> $scope.highlight('.panel.actions .action', {temporary: true})
    },
    {
      text: "Click 'Save Recording' and let's try out your new rule.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-53.mp3',
      action: () ->
        $scope.highlight('#button-save-recording', {temporary:true})
    },
    {
      trigger: () -> $('#button-run').is(':visible')
      text: "Press 'Run'! Walk the hero toward the block and let's see if it falls.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-54.mp3',
      action: () ->
        $scope.highlight('#button-run', {temporary: true})
        $scope.mainCharacter().setWorldPos(8, 5)
        $scope.boulderStartX = $scope.boulderCharacter().worldPos.x
    },
    {
      trigger: () ->
        $scope.boulderCharacter().worldPos.x != $scope.boulderStartX
      text: "Hmm... The boulder moved over, but it didn't fall! I wonder what we forgot? Oh - I know! we made the boulder slip off the ledge, but we never programmed it to fall down! In the real world, gravity makes everything fall down. In our game, we need to program things to fall. Maybe next time we can make a space game and we won't need gravity!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-55.mp3',
    },
    {
      text: "Switch to the recording tool again. Let's teach the boulder to fall!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-56.mp3',
      action: () -> $scope.highlight('#tool-record')
    },
    {
      trigger: () -> $('#tool-record').hasClass('btn-info') || $('#button-start-recording').length > 0
      action: () -> $scope.highlightStageTile($scope.boulderCharacter().worldPos, {temporary: true})
    },
    {
      trigger: () -> $('#button-start-recording').length > 0
      text: "Perfect. Let's think about this for a minute..
      We want our boulder to fall whenever there's an empty square beneath it.
      Can you expand the box to include the empty space beneath the boulder?",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-57.mp3',
    },
    {
      trigger: () -> window.Game.mainStage.recordingExtent.top != window.Game.mainStage.recordingExtent.bottom
      text: "Perfect. Now we're ready to show the boulder what to do. Click the Start Recording button.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-58.mp3',
      action: () -> $scope.highlight('#button-start-recording', {temporary:true})
    },
    {
      trigger: () -> $('#button-save-recording').length > 0
      text: "Okay good!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-59.mp3',
    },
    {
      text: "In the picture on the right, drag the boulder down into the empty space just beneath it.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-60.mp3',
    },
    {
      trigger: () -> window.Game.selectedRule?.actions?.length > 0
      text: "Great! I think that will do the trick. The boulder will fall down until it reaches the ground. If it's on the ground, the picture on the left won't match - there won't be any empty space for the boulder to fall into!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-61.mp3',
    },
    {
      text: "Click 'Save Recording' and let's try out your new rule.",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-62.mp3',
      action: () ->
        $scope.highlight('#button-save-recording', {temporary:true})
    },
    {
      trigger: () -> $('#button-run').is(':visible')
      text: "Okay let's try rtunning it again. This time when our hero walks toward the ledge, the boulder should slip off and fall! Can you get him past the boulder before it blocks his path?",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-63.mp3',
      action: () ->
        $scope.highlight('#button-run', {temporary: true})
        $scope.mainCharacter().setWorldPos(new Point(1, 5))
        $scope.boulderCharacter().setWorldPos(new Point(14, 5))
        $scope.boulderStartX = $scope.boulderCharacter().worldPos.x
    },
    {
      trigger: () -> $scope.mainCharacter().worldPos.x >= 12
      text: "That was pretty cool, huh? I don't really know what we should do next. Why don't you make your own rules! You could make our hero jump over the boulder, or teach him to dig into the dirt, or create a whole new game piece!",
      soundURL: '/stage-editor/sounds/tutorial/tutorial-64.mp3',
    },


  ]

  $scope.$root.$on 'tutorial_content_ready', () ->
    window.AudioContext = window.AudioContext || window.webkitAudioContext
    $scope.audioContext = new AudioContext()

    async.eachSeries $scope.tutorial, (step, callback) ->
        return callback() unless step.soundURL
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
    descriptor = { definition_id: 'aamlcui8uxr' } # main character
    options = window.Game.mainStage.actorsMatchingDescriptor(descriptor)
    return options[options.length - 1] if options.length > 0
    return null


  $scope.boulderCharacter = () ->
    descriptor = { definition_id: 'oou4u6jemi' } # main character
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


  $scope.arrow = (fromEl, toEl) ->


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
      stage = options.stage || window.Game.mainStage
      offset = stage.screenPointForTile(tile)
      $('#platformerCanvasPane1').highlighter('show', {offset: {top: offset.y-30, left: offset.x-30}, width: Tile.WIDTH+60, height: Tile.HEIGHT+60})
      $scope.highlighted = '#platformerCanvasPane1'
      if (options.temporary)
        setTimeout () ->
          if $scope.highlighted == '#platformerCanvasPane1'
            $('#platformerCanvasPane1').highlighter('erase')
            $scope.highlighted = null
        ,2000


  $scope.advanceByStep = () ->
    clearTimeout($scope.tutorialTimer)

    if window.Game.tutorial_step >= $scope.tutorial.length - 1
      return;

    window.Game.tutorial_step += 1
    step = $scope.currentStep()
    step.action() if step.action

    if step.text
      initialDelay = 1500 + step.text.length * 23
    else
      initialDelay = 1500

    if $scope.audioSource
      if $scope.audioSource.stop then $scope.audioSource.stop() else $scope.audioSource.noteOff()

    if step.soundBuffer
      try
        initialDelay = step.soundBuffer.duration * 1000
        $scope.audioSource = $scope.audioContext.createBufferSource()
        $scope.audioSource.buffer = step.soundBuffer
        $scope.audioSource.connect($scope.audioContext.destination)
        if $scope.audioSource.start then $scope.audioSource.start(0) else $scope.audioSource.noteOn()

      catch e
        console.log(e)

    # wait until finished speaking instructions
    $scope.tutorialTimer = setTimeout($scope.checkShouldAdvance, initialDelay)

    $scope.$apply() unless $scope.$$phase



  $scope.checkShouldAdvance = () ->
    nextStep = $scope.tutorial[window.Game.tutorial_step+1]

    if nextStep && (!nextStep.trigger || nextStep.trigger() == true)
      $scope.advanceByStep()
    else
      $scope.tutorialTimer = setTimeout($scope.checkShouldAdvance, 500)


window.TutorialCtrl = TutorialCtrl