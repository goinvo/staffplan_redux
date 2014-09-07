var AggregateWorkWeek = function(data) {
  this.data = data;
}

_.extend(AggregateWorkWeek.prototype, {
  columnTotal: function() {
    if(this.isBeforeWithActuals()) {
      // for current and past dates prefer the actual hours
      return this.data.work_week.actual();
    } else {
      // for future dates always use the estimated
      return this.data.work_week.estimated();
    }
  },
  isBeforeWithActuals: function() {
    // have to double check that this still works with the current week
    return (moment().isAfter(this.data.work_week.beginning_of_week()) && this.data.work_week.actual() !== 0);
  },
  titleText: function() {
    var title = "Proposed: " + this.data.work_week.estimated_proposed();
    title +=    "\nPlanned: " + this.data.work_week.estimated_planned();

    if(this.isBeforeWithActuals()) {
      title +=    "\nActual: " + this.data.work_week.actual();
    }

    return title;
  },
  wrapperStyle: function() {
    return "height: " + parseInt(this.columnTotal() + 20, 10) + "px;";
  },
  barGraphStyle: function() {
    // prior week with actuals. gray.
    if(this.isBeforeWithActuals()) {
      return "background-color: gray; height: " + this.columnTotal() + "px;";
    } else {
      if(this.data.work_week.estimated_planned() == this.data.work_week.estimated()) {
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
