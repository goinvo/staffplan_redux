function AssignmentsListItem(data) {
  this.assignment = data.assignment;
  this.weekRange = data.weekRange;

  this.projectURL = "/projects/" + this.assignment.project_id;
  this.clientURL = "/clients/" + this.assignment.client_id;

  this.observedWorkWeeks = ko.observableArray();
  this.observedWorkWeeks.extend({rateLimit: 25});

  this.visibleWorkWeeks = ko.computed(function() {
    return _.map(this.weekRange(), function(weekData, index) {

      var assignmentWorkWeek = _.find(this.assignment.work_weeks, function(workWeek) {
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
          , beginning_of_week: ko.observable(weekData.beginning_of_week())
        }
      } else {
        // update
        this.observedWorkWeeks()[index].cweek(weekData.cweek())
        this.observedWorkWeeks()[index].year(weekData.year())
        this.observedWorkWeeks()[index].beginning_of_week(weekData.beginning_of_week())
      }

      // add user data if available
      if(_.isUndefined(assignmentWorkWeek)) {
        this.observedWorkWeeks()[index].actual(0);
        this.observedWorkWeeks()[index].estimated(0);
      } else {
        this.observedWorkWeeks()[index].actual(assignmentWorkWeek.actual);
        this.observedWorkWeeks()[index].estimated(assignmentWorkWeek.estimated);
      }

      return this.observedWorkWeeks()[index];
    }, this);
  }, this);
  this.visibleWorkWeeks.extend({rateLimit: 25});
}

ko.components.register("assignments-list-item", {
  viewModel: AssignmentsListItem,
  template: HandlebarsTemplates["assignments/list-item"]()
});
