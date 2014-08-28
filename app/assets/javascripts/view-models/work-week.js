(function($, window, document) {
  var WorkWeek = window.WorkWeek = function(data) {
    this.data = data;
    
    this.totalHours = ko.pureComputed(function() {
      var total = (this.data.work_week.estimated() || 0) + (this.data.work_week.actual() || 0)
      return "t: " + total;
    }, this);
    
    this.actualHours = ko.pureComputed(function() {
      return "a: " + this.data.work_week.actual();
    }, this);
    
    this.estimatedHours = ko.pureComputed(function() {
      /* (max height in pixels times estimate's percentage of 40 hours * 100) + 20 for the numbers on top */
      return "e: " + this.data.work_week.estimated();
    }, this)
  }
  
})(jQuery, window, window.document);
