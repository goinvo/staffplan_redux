import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = { myStaffplanUrl: String, peopleUrl: String, projectsUrl: String }

  navigate(event) {
    if (event.metaKey || event.ctrlKey || event.altKey || this.#isEditing(event.target)) return

    switch (event.key.toLowerCase()) {
      case "m": return Turbo.visit(this.myStaffplanUrlValue)
      case "e": return Turbo.visit(this.peopleUrlValue)
      case "p": return Turbo.visit(this.projectsUrlValue)
      case "n": return this.newProject()
    }
  }

  newProject() {
    this.dispatch("new-project", { prefix: "staffplan", target: window })
  }

  #isEditing(element) {
    return ["INPUT", "TEXTAREA", "SELECT"].includes(element.tagName) || element.isContentEditable
  }
}
