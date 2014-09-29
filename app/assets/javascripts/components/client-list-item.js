var ClientListItem = function(data) {
  var client = this.client = data.client;
  this.clientName = client.client_name();
  this.assignments = client.assignments;
  this.weekRange = data.weekRange;
}

_.extend(ClientListItem.prototype, {
  isNewClient: function() {
    return this.client.id == null;
  },
  addClientProject: function(client, event) {
    debugger
  }
})

ko.components.register("client-list-item", {
  viewModel: ClientListItem,
  template: HandlebarsTemplates["client-list-item"]()
});
