ko.components.register('date-range-column-header', {
  viewModel: function(data) {
    this.data = ko.pureComputed(function() {
      return moment(data.week.beginning_of_week());
    }, this);
    this.data.extend({rateLimit: 25});
    
    this.formattedMonthAndDay = function() {
      return this.data().format("M/D")
    }
    
    this.formattedYear = function() {
      return this.data().format("YYYY")
    }
    
    this.formattedMonthName = function() {
      var output = "";
      
      if(this.weekOfMonth() == 1)
        output += this.data().format("MMM")
      
      if(this.data().week() == 1)
        output += " (" + this.data().format("YYYY") + ")";
      
      return output;
    }
    
    this.weekOfMonth = function() {
      return Math.ceil(this.data().date() / 7);
    }
  },
  template: HandlebarsTemplates["date-range-column-header"]()
})
