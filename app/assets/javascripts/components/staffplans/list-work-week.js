ko.components.register("staffplans-list-work-week", {
  viewModel: function(data) {
    // debugger
    this.relevant_work_weeks = data.work_weeks;
  },
  
  template: HandlebarsTemplates["staffplans/list-work-week"]()
});
