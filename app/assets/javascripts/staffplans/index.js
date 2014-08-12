function getStartHash() {
  var startParam = hashParam("start")
  
  if(startParam == null) {
    m = moment()
    // default to last week
    startParam = m.utc().startOf('day').subtract('days', m.day() - 1).subtract('weeks', 1).unix() * 1000
    window.location.hash = "start=" + startParam;
  }
  
  return startParam;
}

window.StaffPlanIndex = function() {
  var self = this
    , usersData = JSON.parse($('#users').remove().text())
    // calculate the range of beginning_of_weeks we should be show
    , inputWidth = 135
    , documentWidth = $(document.body).width()
    , count = Math.floor((documentWidth - 280) / 135)
    , startParam = getStartHash();
  
  this.weekRange = ko.observableArray(_.range(startParam, (startParam + (count * 604800000)), 604800000));
  this.users = ko.observableArray(usersData);
  
  $(window).on('hashchange', function(event) {
    alert('StaffPlanIndex.onhashchange')
  })
}
