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