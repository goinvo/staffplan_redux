ko.components.register("staffplans-list-work-week", {
  viewModel: function(data) {
    this.data = data
  },
  
  template: HandlebarsTemplates["staffplans/list-work-week"]()
});
