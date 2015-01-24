function UserAggregateChart(params) {
  var self = this;
  this.user = params.user;
  this.weekRange = params.weekRange;
  this.showAssignmentTotals = typeof params.showAssignmentTotals === "undefined" ? true : params.showAssignmentTotals;
  this.wide = typeof params.wide === "undefined" ? false : params.wide;
  this.staffPlanURL = "/staffplans/" + this.user.id;

  this.userWorkWeeks = ko.computed(function() {
    // debugger
    var match = _.find(params.usersData(), function(userData) { return userData.id == this.user.id; }, this);
    return _.isUndefined(match) ? [] : match.work_weeks;
  }, this);

  this.visibleWorkWeeks = ko.observableArray([]);
  this.visibleWorkWeeks.extend({rateLimit: 25});

  ko.computed(function() {
    _.each(this.weekRange(), function(beginningOfWeek, index) {
      if(_.isUndefined(this.visibleWorkWeeks()[index])) {
        this.visibleWorkWeeks()[index] = {
          cweek: ko.observable(beginningOfWeek.cweek()),
          year: ko.observable(beginningOfWeek.year()),
          actual_hours: ko.observable(0),
          estimated_hours: ko.observable(0),
          estimated_proposed: ko.observable(0),
          estimated_planned: ko.observable(0),
          beginning_of_week: ko.observable(beginningOfWeek.beginning_of_week())
        }
      } else {
        this.visibleWorkWeeks()[index].year(beginningOfWeek.year());
        this.visibleWorkWeeks()[index].cweek(beginningOfWeek.cweek())
        this.visibleWorkWeeks()[index].beginning_of_week(beginningOfWeek.beginning_of_week());
      }
    }, this);

  }, this)

  // use a computed to watch userWorkWeeks for changes, then propagate to observedWorkWeeks
  ko.computed(function() {
    _.each(this.visibleWorkWeeks(), function(observedWorkWeek) {
      var matchingWeek = _.find(this.userWorkWeeks(), function(userWorkWeek) { return userWorkWeek.beginning_of_week == observedWorkWeek.beginning_of_week(); });

      if(_.isUndefined(matchingWeek)) return
      else {
        observedWorkWeek.actual_hours(matchingWeek.actual_hours);
        observedWorkWeek.estimated_hours(matchingWeek.estimated_hours);
        observedWorkWeek.estimated_planned(matchingWeek.estimated_planned);
        observedWorkWeek.estimated_proposed(matchingWeek.estimated_proposed);
      }
    }, this);
  }, this);
}

ko.components.register("index-aggregate-chart", {
  viewModel: UserAggregateChart,
  template: HandlebarsTemplates["index-aggregate-chart"]()
});
