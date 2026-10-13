import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]

  toggle() {
    this.#show(this.panelTarget.hidden)
  }

  close() {
    this.#show(false)
  }

  closeOutside({ target }) {
    if (!this.element.contains(target)) this.close()
  }

  #show(open) {
    this.panelTarget.hidden = !open
    this.buttonTarget.setAttribute("aria-expanded", open)
  }
}
