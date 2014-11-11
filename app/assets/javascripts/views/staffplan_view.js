function StaffPlanView() {
  var self = this;

  self.showArchived = ko.observable(false);

  self.userData = JSON.parse($('#user').remove().text());
  var assignmentData = JSON.parse($('#assignments').remove().text());

  self.startHash = ko.observable(initialStartHash);
  var initialStartHash = this.getStartHash();

  self.weekRange = ko.observableArray();
  self.weekRange.extend({rateLimit: 25});
  self.calculateWorkWeekRange();

  self.clients = ko.observableArray();
  self.clients.extend({rateLimit: 25});

  _.each(assignmentData, function(assignmentRecord) {
    var client = _.find(self.clients(), function(client) { return client.id === assignmentRecord.client_id; });

    if(_.isUndefined(client)) {
      self.clients.push(new Client(assignmentRecord));
    } else {
      client.addAssignmentRecord(assignmentRecord);
    }
  });

  self.nextPreviousWeeks = ko.computed(function() {
    var columnCount = self.getColumnCount()
      startParam = self.startHash();

    return {
      next: "#start=" + moment(startParam).add(columnCount, 'weeks').unix() * 1000,
      previous: "#start=" + moment(startParam).subtract(columnCount, 'weeks').unix() * 1000
    }
  });

  $(window).on('hashchange', _.bind(self.calculateWorkWeekRange, this));

  // debounce for window.resize
  // TODO: fix this calculation of available width
  var debouncedWeekRangeChange = _.debounce(_.bind(self.calculateWorkWeekRange, this), 200);
  $(window).on('resize', debouncedWeekRangeChange);
}

_.extend(StaffPlanView.prototype, {
  addClientSection: function(viewModel, event) {
    this.clients.push(new Client({
      diff: 0,
      user_id: this.userData.id }
    ));
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
    this.weekRange.splice(timestampRange.length, this.weekRange().length);
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
