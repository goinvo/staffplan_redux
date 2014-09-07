var AssignmentWorkWeek = function(data) {
  this.work_week = data.work_week;
}

_.extend(AssignmentWorkWeek.prototype, {
  isFutureWorkWeek: function() {
    return moment().isBefore(this.work_week.beginning_of_week());
  }
})

ko.components.register("assignment-work-week", {
  viewModel: AssignmentWorkWeek,
  template: HandlebarsTemplates["assignment-work-week"]()
});
