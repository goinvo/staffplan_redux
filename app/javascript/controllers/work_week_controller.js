import { Controller } from "@hotwired/stimulus"
import _ from "lodash"

// Connects to data-controller="work-week"
export default class extends Controller {
  static targets = ["proposedInput", "actualInput", "form"]

  connect() {
  }

  disconnect() {
  }

  submit() {
    this.formTarget.requestSubmit()
  }
}
