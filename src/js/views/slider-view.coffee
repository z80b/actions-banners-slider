class HappySliderView extends Backbone.View
    events:
        'click .js-slider-arrow': 'arrowClick'

    initialize: ->
        $(window).bind 'resize', _.throttle(@reinitialize)
        @listenTo HappySliderEvents, 'actiontimer:started', @slideToActive

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

        @$itemActive = @$ '[data-status="active"]'

        if !@$itemActive.length
            @$itemActive = @$items.filter '.b-happy-hours__slider-item--current'
            @$itemActive.attr 'data-status', 'active'

        if !@$itemActive.length
            @$itemActive = @$items.eq Math.ceil(@itemsCount / 2)
            @$itemActive.attr 'data-status', 'active'

        @arrowsCheckState()
        @slideToActive()
        
        _.delay =>
            @$el.addClass 'b-happy-hours__slider--inited'
        , 100

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
        @$itemActive = @$ '.b-happy-hours__slider-item[data-status="active"]'
        @$itemActive.attr 'data-status', ''

        if parseInt(event.currentTarget.getAttribute 'data-direction') > 0
            @$itemActive = @$itemActive.next()
        else
            @$itemActive = @$itemActive.prev()

        if @$itemActive && @$itemActive.length
            @$itemActive.attr 'data-status', 'active'

        @arrowsCheckState()
        @slideToActive()

    slideToActive: =>
        @$itemActive = @$ '.b-happy-hours__slider-item[data-status="active"]'
        @currOffset = (@$itemActive.index() * @itemWidth + @activeItemWidth / 2) - @sliderWidth / 2
        @sliderTrack.css
            'transform': "translateX(#{@currOffset * -1}px)"

    arrowsCheckState: =>
        if @$itemActive.index() <= 0 then @$prevArrow.hide()
        else @$prevArrow.show()

        if @$itemActive.index() >= @itemsCount - 1 then @$nextArrow.hide()
        else @$nextArrow.show()