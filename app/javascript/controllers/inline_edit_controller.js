import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form", "input", "error"]
  static values = { original: String }

  open() {
    this.displayTarget.hidden = true
    this.formTarget.hidden = false
    this.inputTarget.focus()
  }

  cancel() {
    this.inputTarget.value = this.originalValue
    this.errorTargets.forEach((error) => error.remove())
    this.formTarget.hidden = true
    this.displayTarget.hidden = false
  }
}
