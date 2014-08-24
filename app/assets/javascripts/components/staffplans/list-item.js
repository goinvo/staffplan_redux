function ListItemViewModel(data) {
  this.data = data
  this.staffPlanURL = "/staffplans/" + this.data.user.id
  this.visibleWorkWeeks = ko.computed(_.bind(this.computeVisibleWorkWeeks, this))
}

_.extend(ListItemViewModel.prototype, {
  computeVisibleWorkWeeks: function() {
    return _.select(this.data.user.work_weeks, function(workWeek) {
      return _.contains(this.data.weekRange(), workWeek.beginning_of_week);
    }, this);
  }
});

ko.components.register("staffplans-list-item", {
  viewModel: ListItemViewModel,
  template: HandlebarsTemplates["staffplans/list-item"]()
});
