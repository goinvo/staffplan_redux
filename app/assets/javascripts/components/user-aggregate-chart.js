function UserAggregateChart(params) {
  this.user = params.user;
  this.weekRange = params.weekRange;
  this.showAssignmentTotals = typeof params.showAssignmentTotals === "undefined" ? true : params.showAssignmentTotals;
  this.wide = typeof params.wide === "undefined" ? false : params.wide;
  this.staffPlanURL = "/staffplans/" + this.user.id;

  this.observedWorkWeeks = ko.observableArray();
  this.observedWorkWeeks.extend({rateLimit: 25});

  this.visibleWorkWeeks = ko.computed(function() {
    return _.map(this.weekRange(), function(weekData, index) {

      var userWorkWeek = _.find(this.user.work_weeks, function(workWeek) {
        return workWeek.cweek == weekData.cweek() && workWeek.year == weekData.year();
      }, this);

      if(_.isUndefined(this.observedWorkWeeks()[index])) {
        // add to the set
        var date = moment(weekData.beginning_of_week());

        this.observedWorkWeeks()[index] = {
            cweek: ko.observable(weekData.cweek())
          , year: ko.observable(weekData.year())
          , actual: ko.observable(0)
          , estimated: ko.observable(0)
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
      if(_.isUndefined(userWorkWeek)) {
        this.observedWorkWeeks()[index].actual(0);
        this.observedWorkWeeks()[index].estimated(0);
        this.observedWorkWeeks()[index].estimated_planned(0);
        this.observedWorkWeeks()[index].estimated_proposed(0);
      } else {
        this.observedWorkWeeks()[index].actual_hours(userWorkWeek.actual || 0);
        this.observedWorkWeeks()[index].estimated_hours(userWorkWeek.estimated_hours || 0);
        this.observedWorkWeeks()[index].estimated_planned(userWorkWeek.estimated_planned || 0);
        this.observedWorkWeeks()[index].estimated_proposed(userWorkWeek.estimated_proposed || 0);
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
