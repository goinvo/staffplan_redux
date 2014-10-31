var AssignmentWorkWeek = function(data) {
  this.work_week = data.work_week;
  // update on estimated/actual hour change
  this.work_week.estimated_hours.subscribe(_.bind(this.updateAttributes, this));
  this.work_week.actual_hours.subscribe(_.bind(this.updateAttributes, this));
}

_.extend(AssignmentWorkWeek.prototype, {
  isFutureWorkWeek: function() {
    return moment().isBefore(this.work_week.beginning_of_week());
  },

  updateAttributes: function(newValue) {
  }
})

ko.components.register("assignment-work-week", {
  viewModel: AssignmentWorkWeek,
  template: HandlebarsTemplates["assignment-work-week"]()
});
