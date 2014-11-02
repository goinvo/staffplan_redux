var ClientListItem = function(data) {
  var self = this;
  var client = self.client = data.client;
  self.client_name = client.client_name();
  self.assignments = client.assignments;
  self.weekRange = data.weekRange;
  self.showArchived = data.showArchived;

  self.visibleAssignments = ko.computed(function() {
    return _.select(self.assignments(), function(assignment) {
      if(!this.showArchived()) {
        return !assignment.assignment_archived();
      } else
        return true;
    }, self);
  });
}

_.extend(ClientListItem.prototype, {
  isNewClient: function() {
    return this.client.id == null;
  }
})

ko.components.register("client-list-item", {
  viewModel: ClientListItem,
  template: HandlebarsTemplates["client-list-item"]()
});
