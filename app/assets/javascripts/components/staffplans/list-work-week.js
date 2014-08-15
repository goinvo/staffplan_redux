ko.components.register("staffplans-list-work-week", {
  viewModel: function(data) {
    this.data = data;
    this.proposedHeight = function(foo, bar, baz) {
      return "height: 0px;";
    }
    this.plannedHeight = function(foo, bar, baz) {
      var fortyHours = 40;
      /* (max height in pixels times estimate's percentage of 40 hours * 100) + 20 for the numbers on top */
      return "height: " + (80 * (this.data.work_week.estimated / fortyHours)) + "px;"
    },
    this.totalHeight = function() {
      var fortyHours = 40;
      /* (max height in pixels times estimate's percentage of 40 hours * 100) + 20 for the numbers on top */
      return "height: " + (80 * (this.data.work_week.estimated / fortyHours)) + 20 + "px;"
    }
  },
  template: HandlebarsTemplates["staffplans/list-work-week"]()
});
