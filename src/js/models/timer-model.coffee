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
            @set 'toStartStr', "#{ @parseHours toStart } ч : #{ @parseMunutes toStart } м"
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
                    HappySliderEvents.trigger 'actiontimer:started'
                if timeLeft > 0
                    @trigger 'timer:updated'
            @timer = setTimeout @update, 1000

    start: =>
        @update()
        @trigger 'timer:inited'

    parseSeconds: (time)-> ('0' + Math.floor((time % 6e4) / 1e3)).slice(-2)
    parseMunutes: (time)-> ('0' + Math.floor((time % 36e5) / 6e4)).slice(-2)
    parseHours: (time)-> Math.floor(time / 36e5)