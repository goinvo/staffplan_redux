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
    this.closeTarget.classList.replace('hidden', 'block')
    this.openTarget.classList.replace('block', 'hidden')
    document.getElementById('mobile-menu').classList.replace('hidden', 'block')
    this.openValue = true;
  }

  hide() {
    this.closeTarget.classList.replace('block', 'hidden')
    this.openTarget.classList.replace('hidden', 'block')
    document.getElementById('mobile-menu').classList.replace('block', 'hidden')
    this.openValue = false
  }

  toggle() {
    this.openValue = !this.openValue
  }
}

