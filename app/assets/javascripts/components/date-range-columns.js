ko.components.register('date-range-columns', {
  viewModel: function(params) {
    this.data = params;
  },
  template: HandlebarsTemplates["date-range-columns"]()
})
