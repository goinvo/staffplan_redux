(function($, window, document) {
  var WorkWeek = window.WorkWeek = function(data) {
    this.data = data;
  }
  
  _.extend(WorkWeek.prototype, {
      actualHours: function() {
        return "a: " + this.data.work_week.actual;
      }
      
    , estimatedHours: function() {
        /* (max height in pixels times estimate's percentage of 40 hours * 100) + 20 for the numbers on top */
        return "e: " + this.data.work_week.estimated;
      }
      
    , totalHours: function() {
        // if(this.data.work_week.actual || 0 > 0) debugger
        var total = (this.data.work_week.estimated || 0) + (this.data.work_week.actual || 0)
        return "t: " + total;
      }
  })
  
})(jQuery, window, window.document);
