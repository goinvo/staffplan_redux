import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]
  static values = { url: String }

  open() {
    if (this.element.open) return

    this.frameTarget.innerHTML = ""
    this.frameTarget.src = null
    this.frameTarget.src = this.urlValue
    this.element.showModal()
  }

  focus() {
    this.element.querySelector("[autofocus]")?.focus()
  }

  close() {
    this.element.close()
  }

  closeOnBackdrop({ target, clientX, clientY }) {
    if (target !== this.element) return

    const { left, right, top, bottom } = this.element.getBoundingClientRect()
    if (clientX < left || clientX > right || clientY < top || clientY > bottom) this.close()
  }

  submitted({ detail: { success } }) {
    if (success) this.close()
  }
}
