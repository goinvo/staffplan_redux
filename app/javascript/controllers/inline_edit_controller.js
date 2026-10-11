import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["display", "form", "input", "error"]

  open() {
    this.displayTarget.hidden = true
    this.formTarget.hidden = false
    this.inputTarget.focus()
  }

  cancel() {
    if (this.hasErrorTarget) return Turbo.visit(window.location.href, { action: "replace" })

    this.formTarget.reset()
    this.formTarget.hidden = true
    this.displayTarget.hidden = false
  }
}
