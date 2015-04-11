var AssignmentsListItem = function(params) {
  this.assignment = params.assignment;
  this.client = params.clientListItem.client;
  this.weekRange = params.weekRange;
  this.editing = ko.observable(false);
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
          , id: ko.observable()
          , actual_hours: ko.observable(0)
          , estimated_hours: ko.observable(0)
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
        this.observedWorkWeeks()[index].id(null)
        this.observedWorkWeeks()[index].actual_hours(0);
        this.observedWorkWeeks()[index].estimated_hours(0);
      } else {
        this.observedWorkWeeks()[index].actual_hours(assignmentWorkWeek.actual_hours || 0);
        this.observedWorkWeeks()[index].estimated_hours(assignmentWorkWeek.estimated_hours || 0);
        this.observedWorkWeeks()[index].id(assignmentWorkWeek.work_week_id);
      }

      return this.observedWorkWeeks()[index];
    }, this);
  }, this);

  this.visibleWorkWeeks.extend({rateLimit: 25});
}

_.extend(AssignmentsListItem.prototype, {
  onKeyUp: function(element, event) {
    if(event.keyCode == 13)
      this.assignment.create();
  },
  addClientProject: function(assignment, event) {
    if(assignment.id == null) {
      assignment = _.extend(assignment, {
        diff: 0,
        client_name: this.client.client_name(),
        client_id: this.client.id,
        user_id: window.location.pathname.match(/\/staffplans\/(\d*)/).pop()
      });
    }
    this.client.addAssignmentRecord(assignment);
  },
  newAssignment: function() {
    return this.assignment.id() == null;
  },
  toggleId: function(prefix) {
    return prefix + this.assignment.id();
  },
  destroyAssignment: function(assignment) {
    var destroyedAssignment = this.client.assignments.remove(this.assignment);
    _.each(destroyedAssignment, function(assignment) {
      assignment.destroy();
    })
  },
  toggleEdit: function(foo, bar, baz) {
    this.editing(!this.editing());
  },
  toggleProposed: function() {
    this.assignment.assignment_proposed(!this.assignment.assignment_proposed());
    this.onValueChanged();
  },
  toggleArchived: function() {
    this.assignment.assignment_archived(!this.assignment.assignment_archived());
    this.onValueChanged();
  },
  onValueChanged: function() {
    var assignment = ko.toJS(this.assignment),
        assignmentData = {
          id: assignment.id,
          user_id: assignment.user_id,
          proposed: assignment.assignment_proposed,
          archived: assignment.assignment_archived
        },
        url = (assignmentData.id == null ? '/assignments.json' : '/assignments/' + assignmentData.id + '.json'),
        type = (assignmentData.id == null ? "POST" : "PUT");

    $(document.body).attr('style', 'cursor: wait;');

    // update
    $.ajax({
      url: url,
      type: type,
      data: {assignment: assignmentData},
      dataType: 'json',
      complete: _.bind(function() {
        $(document.body).removeAttr('style');
      }, this),
      error: _.bind(function() {
        $('.flash-container').append(
          "<p class='flash-error flash'>\
            Unexpected error occurred. Please try again.\
            <a class='close' href='javascript:void(0)'>close</a>\
          </p>"
        )
      }, this)
    })
  }
});

ko.components.register("assignment-list-item", {
  viewModel: AssignmentsListItem,
  template: HandlebarsTemplates["assignment-list-item"]()
});
