

window.onload =->

    LMDA.Events.on 'app:ready', ->
        HappySliderEvents = {}
        _.extend HappySliderEvents, Backbone.Events

        #=include models/timer-model.coffee
        #=include views/slider-view.coffee
        #=include views/slider-item-view.coffee
        
        slider = new HappySliderView
            el: '.js-happy-hours-slider'