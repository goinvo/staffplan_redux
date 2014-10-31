var AssignmentWorkWeek = function(data) {
  this.work_week = data.work_week;
  this.assignment_id = data.assignment_id();
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
        // set id?
        if(this.work_week.id() == undefined)
          this.work_week.id(response.id);
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
