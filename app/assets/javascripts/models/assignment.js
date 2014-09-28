function Assignment(attributes) {
  var self = this;

  if (attributes !== null && _.isPlainObject(attributes)) {
    self.actual_total = attributes.actual_total || 0;
    self.assignment_id = attributes.assignment_id;
    self.diff = attributes.diff;
    self.estimated_total = attributes.estimated_total || 0;
    self.is_active = attributes.is_active || true;
    self.is_archived = attributes.is_archived || false;
    self.is_proposed = attributes.is_proposed || false;
    self.project_id = attributes.project_id;
    self.project_name = ko.observable(attributes.project_name);
    self.work_weeks = attributes.work_weeks || [];
  }
}
