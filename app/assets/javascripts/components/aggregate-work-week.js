var AggregateWorkWeek = function(params) {
  this.workWeek = params.workWeek;
}

_.extend(AggregateWorkWeek.prototype, {
  // return the correct contextual total to use when rendering
  columnTotal: function() {
    if(this.isBeforeWithActuals()) {
      // for current and past dates prefer the actual hours
      return this.workWeek.actual();
    } else {
      // for future dates always use the estimated
      return this.workWeek.estimated();
    }
  },
  // true/false, if the work_week is for a prior date with actual hours
  isBeforeWithActuals: function() {
    // have to double check that this still works with the current week
    return (moment().isAfter(this.workWeek.beginning_of_week()) && this.workWeek.actual() !== 0);
  },
  // friendly hover title text for bars
  titleText: function() {
    var title = "Proposed: " + this.workWeek.estimated_proposed();
    title +=    "\nPlanned: " + this.workWeek.estimated_planned();

    if(this.isBeforeWithActuals()) {
      title +=    "\nActual: " + this.workWeek.actual();
    }

    return title;
  },
  // sets overall height for the vertical bar
  wrapperStyle: function() {
    return "height: " + parseInt(this.columnTotal() + 20, 10) + "px;";
  },
  // returns correct style for prior/actuals, all planned, planned/proposed split
  barGraphStyle: function() {
    // prior week with actuals. gray.
    if(this.isBeforeWithActuals()) {
      return "background-color: gray; height: " + this.columnTotal() + "px;";
    } else {
      if(this.workWeek.estimated_planned() == this.workWeek.estimated()) {
        // all planned. dark green.
        return "background-color: #5e9b69; height: " + this.columnTotal() + "px;";
      } else {
        // some planned, some proposed. split. planned on bottom, proposed on top.
        var style = "background-image: linear-gradient(0deg, #5e9b69, #7eba8d 40%);";
        style +=    "height: " + this.columnTotal() + "px;";
        return style;
      }
    }

    return "background-color: " + bgColor + "; height: " + this.columnTotal() + "px;";
  }
})

ko.components.register("aggregate-work-week", {
  viewModel: AggregateWorkWeek,
  template: HandlebarsTemplates["aggregate-work-week"]()
});
