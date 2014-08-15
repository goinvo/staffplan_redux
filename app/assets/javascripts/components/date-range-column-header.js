ko.components.register('date-range-column-header', {
  viewModel: function(data) {
    this.data = moment(data.week);
    
    this.formattedMonthAndDay = function() {
      return this.data.format("M/D")
    }
    
    this.formattedYear = function() {
      return this.data.format("YYYY")
    }
    
    this.formattedMonthName = function() {
      var output = "";
      
      if(this.weekOfMonth() == 1)
        output += this.data.format("MMM")
      
      if(this.data.week() == 1)
        output += " (" + this.data.format("YYYY") + ")";
      
      return output;
    }
    
    this.weekOfMonth = function() {
      return Math.ceil(this.data.date() / 7);
    }
  },
  template: HandlebarsTemplates["date-range-column-header"]()
})
