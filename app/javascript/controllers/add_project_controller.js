import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "project"]

  open() {
    this.rowTarget.hidden = false
    this.rowTarget.querySelector("input[role=combobox]").focus()
  }

  syncClient({ target }) {
    this.#groupProjectsBy(target.value)
  }

  chosen({ target, detail: { value } }) {
    if (this.projectTarget.contains(target)) return

    this.#groupProjectsBy(value)
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

  #groupProjectsBy(client) {
    const combobox = this.projectTarget.querySelector("[data-controller=combobox]")
    if (combobox) combobox.dataset.comboboxGroupValue = client
  }

  get #projectInput() {
    return this.projectTarget.querySelector("input")
  }
}
