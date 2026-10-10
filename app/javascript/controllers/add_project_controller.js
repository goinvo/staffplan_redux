import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "project"]

  open() {
    this.rowTarget.hidden = false
    this.rowTarget.querySelector("input[role=combobox]").focus()
  }

  syncClient({ target }) {
    this.#projectCombobox.dataset.comboboxGroupValue = target.value
  }

  chosen({ target, detail: { value } }) {
    if (this.projectTarget.contains(target)) return

    this.#projectCombobox.dataset.comboboxGroupValue = value
    this.#projectInput.focus()
  }

  keydown(event) {
    if (event.defaultPrevented) return

    if (event.key === "Escape") {
      this.rowTarget.hidden = true
    } else if (event.key === "Enter" && !this.projectTarget.contains(event.target)) {
      event.preventDefault()
      this.#projectInput.focus()
    }
  }

  get #projectCombobox() {
    return this.projectTarget.querySelector("[data-controller=combobox]")
  }

  get #projectInput() {
    return this.projectTarget.querySelector("input[role=combobox]")
  }
}
