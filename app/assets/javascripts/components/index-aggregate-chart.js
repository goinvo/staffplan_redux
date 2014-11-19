function UserAggregateChart(params) {
  var self = this;
  this.user = params.user;
  this.weekRange = params.weekRange;
  this.showAssignmentTotals = typeof params.showAssignmentTotals === "undefined" ? true : params.showAssignmentTotals;
  this.wide = typeof params.wide === "undefined" ? false : params.wide;
  this.staffPlanURL = "/staffplans/" + this.user.id;

  this.partitionedWorkWeeks = _.groupBy(self.user.work_weeks, function(userWorkWeek){
    return userWorkWeek.cweek + "-" + userWorkWeek.year;
  })

  this.observedWorkWeeks = ko.observableArray();
  this.observedWorkWeeks.extend({rateLimit: 25});

  this.visibleWorkWeeks = ko.computed(function() {
    return _.map(this.weekRange(), function(weekData, index) {

      var userWorkWeeks = self.partitionedWorkWeeks[weekData.cweek() + "-" + weekData.year()] || [];

      if(_.isUndefined(this.observedWorkWeeks()[index])) {
        // add to the set
        var date = moment(weekData.beginning_of_week());

        this.observedWorkWeeks()[index] = {
            cweek: weekData.cweek
          , year: weekData.year
          , actual_hours: 0
          , estimated_hours: 0
          , estimated_proposed: 0
          , estimated_planned: 0
          , beginning_of_week: ko.observable(weekData.beginning_of_week())
        }
      } else {
        // update
        this.observedWorkWeeks()[index].cweek =weekData.cweek
        this.observedWorkWeeks()[index].year = weekData.year
        this.observedWorkWeeks()[index].beginning_of_week(weekData.beginning_of_week())
      }

      // add user data if available
      if(_.isEmpty(userWorkWeeks)) {
        this.observedWorkWeeks()[index].actual_hours = 0;
        this.observedWorkWeeks()[index].estimated_hours = 0;
        this.observedWorkWeeks()[index].estimated_planned = 0;
        this.observedWorkWeeks()[index].estimated_proposed = 0;
      } else {
        this.observedWorkWeeks()[index].actual_hours = userWorkWeeks[0].actual_hours;
        this.observedWorkWeeks()[index].estimated_hours = userWorkWeeks[0].estimated_hours;
        this.observedWorkWeeks()[index].estimated_planned = userWorkWeeks[0].estimated_planned;
        this.observedWorkWeeks()[index].estimated_proposed = userWorkWeeks[0].estimated_proposed;
      }

      return this.observedWorkWeeks()[index];
    }, this);
  }, this);
  this.visibleWorkWeeks.extend({rateLimit: 25});
}

ko.components.register("index-aggregate-chart", {
  viewModel: UserAggregateChart,
  template: HandlebarsTemplates["index-aggregate-chart"]()
});
