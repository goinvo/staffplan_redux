import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="work-week"
export default class extends Controller {
  static targets = ["proposedInput", "actualInput"]
  connect() {
    console.log("Hello, Stimulus!")
  }
}
