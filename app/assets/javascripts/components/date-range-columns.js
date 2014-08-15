ko.components.register('date-range-columns', {
  viewModel: function(data) {
    this.data = data;
  },
  template: HandlebarsTemplates["date-range-columns"]()
})
