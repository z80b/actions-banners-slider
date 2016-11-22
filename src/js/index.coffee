

window.onload =->
    class HappyTimerModel extends Backbone.Model
        defaults:
            moscowOffset: 36e5 * 3
            leftTime: 0
            startTime: '00:00:00'
            endTime: '00:00:00'
            started: false

        initialize: ->
            #@start()

        update: =>
            currentTime = new Date().getTime()
            toStart = @get('startTime') - currentTime
            timeLeft = @get('endTime') - currentTime
            @set 'timeLeft', timeLeft
            @set 'toStart', toStart

            if toStart > 6e4
                @set 'toStartStr', "#{ @parseHours toStart }:#{ @parseMunutes toStart }"
            else
                @set 'toStartStr', "минуту"

            @set 'seconds', @parseSeconds timeLeft
            @set 'minutes', @parseMunutes timeLeft
            @set 'hours', @parseHours timeLeft

            if timeLeft <= 0
                @trigger 'timer:finished'
            else
                if toStart > 0
                    @trigger 'timer:notstarted'
                else
                    if !@get 'started'
                        @set 'started', true
                        @trigger 'timer:started'
                        Backbone.trigger 'actiontimer:started'
                    if timeLeft > 0
                        @trigger 'timer:updated'
                @timer = setTimeout @update, 1000

        start: =>
            @update()
            @trigger 'timer:inited'

        parseSeconds: (time)-> ('0' + Math.floor((time % 6e4) / 1e3)).slice(-2)
        parseMunutes: (time)-> ('0' + Math.floor((time % 36e5) / 6e4)).slice(-2)
        parseHours: (time)-> Math.floor(time / 36e5) % 24


    class HappySliderItemView extends Backbone.View
        initialize: ->
            @listenTo @model, 'timer:inited', @init
            @listenTo @model, 'timer:started', @start
            @listenTo @model, 'timer:notstarted', @notstart
            @listenTo @model, 'timer:updated', @update
            @listenTo @model, 'timer:finished', @finish

            @$timer = @$ '.js-happyhours-timer'

            @model.start()

        init: =>
            @$timer.show()

        start: =>
            @$el.addClass 'b-happy-hours__slider-item--current'
            @$el.addClass 'b-happy-hours__slider-item--active'

        notstart: =>
            @$timer.html "Акция стартует через #{ @model.get 'toStartStr' }"

        update: =>
            if @model.get('timeLeft') > 0 and @model.get('toStart') <= 0
                @$timer.html "
                    <div class=\"e-timer-item\">#{ @model.get 'hours' }</div>
                    <div class=\"e-timer-item\">#{ @model.get 'minutes' }</div>
                    <div class=\"e-timer-item\">#{ @model.get 'seconds' }</div>
                "
        finish: =>
            @$el.removeClass 'b-happy-hours__slider-item--current'
            @$el.removeClass 'b-happy-hours__slider-item--active'
            @$el.addClass 'b-happy-hours__slider-item--done'
            @$timer.text 'Акция завершена'


    class HappySliderView extends Backbone.View
        events:
            'click .js-slider-arrow': 'arrowClick'

        initialize: ->
            $(window).bind 'resize', _.throttle(@reinitialize)
            @listenTo Backbone, 'actiontimer:started', @slideToActive

            @$items = @$ '.b-happy-hours__slider-item'
            @$nextArrow = @$el.find '.js-slider-arrow[data-direction="1"]'
            @$prevArrow = @$el.find '.js-slider-arrow[data-direction="-1"]'

            
            @itemWidth = @$items.outerWidth true
            @activeItemWidth = @itemWidth + 170
            @itemsCount = @$items.length

            @sliderTrack = @$ '.js-slider-track'
            @sliderWidth = @$el.outerWidth true
            @trackWidth = 170 + _.reduce @$items, (sum, item)->
                sum + $(item).outerWidth true
            , 0

            @currOffset = 0

            @sliderTrack.css 'width', "#{@trackWidth}px"

            @$items.each (key, $item)=>
                timerModel = new HappyTimerModel
                    startTime: @parseTimeAttr($item.dataset.starttime)
                    endTime: @parseTimeAttr($item.dataset.endtime)

                timerView = new HappySliderItemView
                    el: $item
                    model: timerModel

            @$itemActive = @$ '.b-happy-hours__slider-item--active'
            console.log '@$itemActive', @$itemActive
            @arrowsCheckState()
            _.delay @slideToActive, 2000

        reinitialize: =>
            @activeItemWidth = @$itemActive.outerWidth true
            @itemWidth = @$items.outerWidth true
            @sliderWidth = @$el.outerWidth true          
            @trackWidth = _.reduce @$items, (sum, item)->
                sum + $(item).outerWidth true
            , 0
            @sliderTrack.css 'width', "#{@trackWidth}px"
            @arrowsCheckState()
            @slideToActive()

        parseTimeAttr: (str)->
            dt = new Date()
            t = str.split ':'
            dt.setSeconds t[2]
            dt.setMinutes t[1]
            dt.setHours t[0]
            return dt

        arrowClick: (event)=>
            @$itemActive = @$ '.b-happy-hours__slider-item--active'
            @$itemActive.removeClass 'b-happy-hours__slider-item--active'

            if parseInt(event.currentTarget.getAttribute 'data-direction') > 0
                @$itemActive = @$itemActive.next()
            else
                @$itemActive = @$itemActive.prev()

            if @$itemActive && @$itemActive.length
                @$itemActive.addClass 'b-happy-hours__slider-item--active'

            @arrowsCheckState()
            @slideToActive()

        slideToActive: =>
            @$itemActive = @$ '.b-happy-hours__slider-item--active'
            @currOffset = (@$itemActive.index() * @itemWidth + @activeItemWidth / 2) - @sliderWidth / 2
            @sliderTrack.css
                'transform': "translateX(#{@currOffset * -1}px)"

        arrowsCheckState: =>
            if @$itemActive.index() <= 0
                @$prevArrow.hide()
            else @$prevArrow.show()

            if @$itemActive.index() >= @itemsCount - 1
                @$nextArrow.hide()
            else @$nextArrow.show()

    LMDA.Events.on 'app:ready', ->

        slider = new HappySliderView
                    el: '.js-happy-hours-slider'