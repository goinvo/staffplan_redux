window.StaffPlanIndex = (function(window, document, $) {
  var StaffPlanIndex = function() {
    var self = this;
    var usersData = JSON.parse($('#users').remove().text())
    
    this.startHash = ko.observable(initialStartHash);
    var initialStartHash = this.getStartHash();
    
    this.weekRange = ko.observableArray(this.calculateWorkWeekRange());
    this.users = ko.observableArray(usersData);
    
    this.nextPreviousWeeks = ko.computed(function() {
      var columnCount = self.getColumnCount()
        startParam = self.startHash();
      
      return {
        next: "#start=" + moment(startParam).add(columnCount, 'weeks').unix() * 1000,
        previous: "#start=" + moment(startParam).subtract(columnCount, 'weeks').unix() * 1000
      }
    })
    
    $(window).on('hashchange', _.bind(this.changeWorkWeeks, this));
    
    // debounce for window.resize
    var debouncedWeekRangeChange = _.debounce(_.bind(this.changeWorkWeeks, this), 200);
    $(window).on('resize', debouncedWeekRangeChange);
  }

  _.extend(StaffPlanIndex.prototype, {
    // calculates the range of beginning_of_weeks we should be show
    calculateWorkWeekRange: function(startParam, count) {
      var count = this.getColumnCount()
        , startParam = this.getStartHash();
      
      return _.range(startParam, (startParam + (count * 604800000)), 604800000)
    },
    // helper for getting/setting the initial beginning_of_day
    getStartHash: function() {
      var startParam = hashParam("start")
      
      if(startParam == null) {
        m = moment()
        // default to last week
        startParam = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1).unix() * 1000
        window.location.hash = "start=" + startParam;
      }
      
      this.startHash(parseInt(startParam, 10))
      return this.startHash();
    },
    // called whenever we should be recalculating/rendering the workWeek range
    changeWorkWeeks: function() {
      var newWeekRange = this.calculateWorkWeekRange();
      this.weekRange.removeAll();
      
      _.each(newWeekRange, function(week) {
        this.weekRange.push(week);
      }, this);
      
      return true;
    },
    getColumnCount: function() {
      var documentWidth = $(document.body).width()
        , inputWidth = 120;
      return Math.floor((documentWidth - 280) / inputWidth);;
    }
  });
  
  return StaffPlanIndex;
})(window, window.document, jQuery);
