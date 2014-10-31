window.StaffPlanIndex = (function(window, document, $) {
  var StaffPlanIndex = function() {
    var self = this;

    self.sortOrder = "asc";
    self.sortField = "workload";
    self.usersData = JSON.parse($('#users').remove().text());
    self.usersData = _.sortBy(self.usersData, function(user) { return user.upcoming_estimated_hours; });

    this.startHash = ko.observable(initialStartHash);
    var initialStartHash = this.getStartHash();

    this.weekRange = ko.observableArray();
    this.weekRange.extend({rateLimit: 25});
    this.calculateWorkWeekRange();

    this.users = ko.observableArray(self.usersData);
    this.users.extend({rateLimit: 25});

    this.nextPreviousWeeks = ko.computed(function() {
      var columnCount = self.getColumnCount()
        startParam = self.startHash();

      return {
        next: "#start=" + moment(startParam).add(columnCount, 'weeks').unix() * 1000,
        previous: "#start=" + moment(startParam).subtract(columnCount, 'weeks').unix() * 1000
      }
    });

    $(window).on('hashchange', _.bind(this.calculateWorkWeekRange, this));

    // debounce for window.resize
    var debouncedWeekRangeChange = _.debounce(_.bind(this.calculateWorkWeekRange, this), 200);
    $(window).on('resize', debouncedWeekRangeChange);
  }

  _.extend(StaffPlanIndex.prototype, {
    sortByWorkload: function() {
      if(this.sortField == "workload") {
        this.sortOrder = (this.sortOrder == "asc" ? "desc" : "asc");
      }
      this.sortField = "workload";

      this.users.sort(_.bind(function(left, right) {
        console.log('left: ' + left.full_name);
        console.log('left.upcoming_estimated_hours: ' + left.upcoming_estimated_hours);
        console.log('right: ' + right.full_name);
        console.log('right.upcoming_estimated_hours: ' + right.upcoming_estimated_hours);

        return this.sortOrder == "asc" ?
          (parseInt(left.upcoming_estimated_hours, 10) > parseInt(right.upcoming_estimated_hours, 10)) ? 1 : -1 :
          (parseInt(right.upcoming_estimated_hours, 10) < parseInt(left.upcoming_estimated_hours, 10)) ? -1 : 1
      }, this));
    },
    sortByName: function() {
      if(this.sortField == "name") {
        this.sortOrder = (this.sortOrder == "asc" ? "desc" : "asc");
      }
      this.sortField = "name";

      this.users.sort(_.bind(function(left, right) {
        return this.sortOrder == "asc" ?
          (left.full_name.localeCompare(right.full_name)) :
          (right.full_name.localeCompare(left.full_name))
      }, this));
    },
    // calculates the range of beginning_of_weeks we should be show
    calculateWorkWeekRange: function(startParam, count) {
      var count = this.getColumnCount()
        , startParam = this.getStartHash()
        , timestampRange = _.range(startParam, (startParam + (count * 604800000)), 604800000);

      _.each(timestampRange, function(timestamp, index) {
        var momentTimestamp = moment(timestamp);

        if(_.isUndefined(this.weekRange()[index])) {
          // add
          this.weekRange()[index] = {
              cweek: ko.observable(momentTimestamp.isoWeek())
            , year: ko.observable(momentTimestamp.year())
            , beginning_of_week: ko.observable(timestamp)
          }
        } else {
          // update
          this.weekRange()[index].cweek(momentTimestamp.isoWeek())
          this.weekRange()[index].year(momentTimestamp.year())
          this.weekRange()[index].beginning_of_week(timestamp)
        }
      }, this);

      // lastly, prune any unnecessary indices from weekRange
      this.weekRange().splice(timestampRange.length, this.weekRange().length);
    },
    // helper for getting/setting the initial beginning_of_day
    getStartHash: function() {
      var startParam = hashParam("start")

      if(startParam == null) {
        m = moment()
        // default to last week
        startParam = m.utc().startOf('day').subtract(m.day() - 1, 'days').subtract(1, 'week').unix() * 1000
        window.location.hash = "start=" + startParam;
      }

      this.startHash(parseInt(startParam, 10))
      return this.startHash();
    },
    getColumnCount: function() {
      var documentWidth = $(document.body).width()
        , inputWidth = 44;
      return Math.floor((documentWidth - 280) / inputWidth);;
    }
  });

  return StaffPlanIndex;
})(window, window.document, jQuery);