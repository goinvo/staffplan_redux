function UserAggregateChart(params) {
  var self = this;
  this.user = params.user;
  this.weekRange = params.weekRange;
  this.showAssignmentTotals = typeof params.showAssignmentTotals === "undefined" ? true : params.showAssignmentTotals;
  this.wide = typeof params.wide === "undefined" ? false : params.wide;
  this.staffPlanURL = "/staffplans/" + this.user.id;
  this.partitionedWorkWeeks = params.partitionedWorkWeeks;
  this.observedWorkWeeks = ko.observableArray();
  this.observedWorkWeeks.extend({rateLimit: 25});

  this.visibleWorkWeeks = ko.computed(function() {
    return _.map(this.weekRange(), function(weekData, index) {

      var userWorkWeeks = self.partitionedWorkWeeks()[weekData.cweek() + "-" + weekData.year()] || [];

      if(_.isUndefined(this.observedWorkWeeks()[index])) {
        // add to the set
        var date = moment(weekData.beginning_of_week());

        this.observedWorkWeeks()[index] = {
            cweek: ko.observable(weekData.cweek())
          , year: ko.observable(weekData.year())
          , actual_hours: ko.observable(0)
          , estimated_hours: ko.observable(0)
          , estimated_proposed: ko.observable(0)
          , estimated_planned: ko.observable(0)
          , beginning_of_week: ko.observable(weekData.beginning_of_week())
        }
      } else {
        // update
        this.observedWorkWeeks()[index].cweek(weekData.cweek())
        this.observedWorkWeeks()[index].year(weekData.year())
        this.observedWorkWeeks()[index].beginning_of_week(weekData.beginning_of_week())
      }

      // add user data if available
      if(_.isEmpty(userWorkWeeks)) {
        this.observedWorkWeeks()[index].actual_hours(0);
        this.observedWorkWeeks()[index].estimated_hours(0);
        this.observedWorkWeeks()[index].estimated_planned(0);
        this.observedWorkWeeks()[index].estimated_proposed(0);
      } else {
        // TODO: reduce this to one iteration over userWorkWeeks. moar perf.
        this.observedWorkWeeks()[index].actual_hours(_.reduce(userWorkWeeks, function(sum, workWeek) {
          return sum += (workWeek.actual_hours || 0);
        }, 0));
        this.observedWorkWeeks()[index].estimated_hours(_.reduce(userWorkWeeks, function(sum, workWeek) {
          return sum += (workWeek.estimated_hours || 0);
        }, 0));
        this.observedWorkWeeks()[index].estimated_planned(_.reduce(userWorkWeeks, function(sum, workWeek) {
          return sum += (workWeek.estimated_planned || 0)
        }, 0));
        this.observedWorkWeeks()[index].estimated_proposed(_.reduce(userWorkWeeks, function(sum, workWeek) {
          return sum += (workWeek.estimated_proposed || 0);
        }, 0));
      }

      return this.observedWorkWeeks()[index];
    }, this);
  }, this);
  this.visibleWorkWeeks.extend({rateLimit: 25});
}

ko.components.register("user-aggregate-chart", {
  viewModel: UserAggregateChart,
  template: HandlebarsTemplates["user-aggregate-chart"]()
});
