var AssignmentWorkWeek = function(data) {
  this.work_week = data.work_week;
  this.assignment = data.assignment;
  this.assignment_id = this.assignment.id();
}

_.extend(AssignmentWorkWeek.prototype, {
  isFutureWorkWeek: function() {
    return moment().isBefore(this.work_week.beginning_of_week());
  },

  onValueChanged: function(newValue) {
    this.work_week.actual_hours(parseInt(this.work_week.actual_hours(), 10) || 0)
    this.work_week.estimated_hours(parseInt(this.work_week.estimated_hours(), 10) || 0)

    var workWeekData = _.merge(ko.toJS(this.work_week), {assignment_id: this.assignment_id}),
        url = (workWeekData.id == null ? '/work_weeks.json' : '/work_weeks/' + workWeekData.id + '.json'),
        type = (workWeekData.id == null ? "POST" : "PUT");

    $(document.body).attr('style', 'cursor: wait;');

    // update
    $.ajax({
      url: url,
      type: type,
      data: workWeekData,
      dataType: 'json',
      success: _.bind(function(response, status, jqxhr) {
        // add new work weeks to the assignment
        if(this.work_week.id() == undefined) {
          this.work_week.id(response.id);
          this.assignment.work_weeks.push(this.work_week);
          $(document.body).trigger('workWeekCreated', [
            _.merge(ko.toJS(this.work_week),
              { assignment_id: this.assignment_id,
                assignment_archived: this.assignment.assignment_archived(),
                assignment_proposed: this.assignment.assignment_proposed(),
                user_id: this.assignment.user_id(),
                work_week_id: this.work_week.id()
              })
          ]);
        } else {
          $(document.body).trigger('workWeekUpdated', [_.merge(ko.toJS(this.work_week), {assignment_id: this.assignment_id})]);
        }

      }, this),
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
})

ko.components.register("assignment-work-week", {
  viewModel: AssignmentWorkWeek,
  template: HandlebarsTemplates["assignment-work-week"]()
});
