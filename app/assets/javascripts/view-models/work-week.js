(function($, window, document) {
  var WorkWeek = window.WorkWeek = function(data) {
    this.data = data;
  }
  
  _.extend(WorkWeek.prototype, {
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
    barGraphStyle: function() {
      // &.proposed {
      //   background-color: #7eba8d;
      // }
      //
      // &.planned {
      //   background-color: #5e9b69;
      // }
      var bgColor = (this.isBeforeWithActuals() ? 'gray' : "#5e9b69")
      return "background-color: " + bgColor + "; height: " + this.columnTotal() + "px;";
    }
  })
  
})(jQuery, window, window.document);
