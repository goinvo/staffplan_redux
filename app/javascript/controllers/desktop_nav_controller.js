import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-nav"
export default class extends Controller {
  static targets = ['open', 'close']
  static values = { open: Boolean, default: false }

  openValueChanged() {
    if (this.openValue === true) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    document.getElementById('desktop-menu').classList.replace('hidden', 'absolute')
    this.openValue = true;
  }

  hide() {
    document.getElementById('desktop-menu').classList.replace('absolute', 'hidden')
    this.openValue = false
  }

  toggle() {
    this.openValue = !this.openValue
  }
}
