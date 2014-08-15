function ListItemViewModel(data) {
  this.data = data
  this.staffPlanURL = "/staffplans/" + this.data.user.id
  this.visibleWorkWeeks = ko.computed(_.bind(this.computeVisibleWorkWeeks, this))
}

_.extend(ListItemViewModel.prototype, {
  computeVisibleWorkWeeks: function() {
    return _.map(this.data.weekRange(), function(beginningOfWeek) {
      var workWeek = _.find(this.data.user.work_weeks, function(workWeek) {
        return workWeek.beginning_of_week == beginningOfWeek;
      }, this);
      
      if(_.isUndefined(workWeek)) {
        workWeek = {
            beginning_of_week: beginningOfWeek
          , actual: 0
          , estimated: 0
        }
      }
      
      return workWeek;
    }, this);
  }
});

ko.components.register("staffplans-list-item", {
  viewModel: ListItemViewModel,
  template: HandlebarsTemplates["staffplans/list-item"]()
});
