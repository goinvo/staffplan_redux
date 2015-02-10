function StaffplansAggregateChart(params) {
  var self = this;
  this.user = params.user;
  this.estimated_total = ko.observable(0);
  this.actual_total = ko.observable(0);
  this.diff = ko.computed(function() {
    var diffValue = this.estimated_total() - this.actual_total();
    return "Δ " + (diffValue > 0 ? '+' : '') + diffValue;
  }, this)
  this.weekRange = params.weekRange;
  this.wide = typeof params.wide === "undefined" ? false : params.wide;
  this.staffPlanURL = "/staffplans/" + this.user.id;
  this.usersData = params.usersData;

  this.userWorkWeeks = ko.computed(function() {
    var workWeeks,
        match = _.find(this.usersData(), function(userData) { return userData.id == this.user.id; }, this);

    if(_.isUndefined(match)) {
      workWeeks = [];
    } else {
      workWeeks = match.work_weeks;
      // update estiamted/actual totals while we're here
      this.estimated_total(match.estimated_total);
      this.actual_total(match.actual_total);
    }

    return workWeeks;
  }, this);
  this.userWorkWeeks.extend({rateLimit: 50})

  this.visibleWorkWeeks = ko.observableArray([]);
  this.visibleWorkWeeks.extend({rateLimit: 50});

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
        observedWorkWeek.actual_hours(matchingWeek.actual_total);
        observedWorkWeek.estimated_hours(matchingWeek.estimated_total);
        observedWorkWeek.estimated_planned(matchingWeek.estimated_planned);
        observedWorkWeek.estimated_proposed(matchingWeek.estimated_proposed);
      }
    }, this);
  }, this);
}

ko.components.register("staffplans-aggregate-chart", {
  viewModel: StaffplansAggregateChart,
  template: HandlebarsTemplates["staffplans-aggregate-chart"]()
});
