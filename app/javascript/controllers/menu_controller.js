import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu"
export default class extends Controller {
  static targets = ["button", "menu"]
  static currentlyOpen = null

  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
  }

  disconnect() {
    if (this.constructor.currentlyOpen === this) {
      this.constructor.currentlyOpen = null
    }
    this.removeClickOutsideListener()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    // Close any currently open dropdown
    if (this.constructor.currentlyOpen && this.constructor.currentlyOpen !== this) {
      this.constructor.currentlyOpen.close()
    }

    // Open this dropdown
    this.menuTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.constructor.currentlyOpen = this

    // Add click outside listener after a small delay to prevent immediate closure
    setTimeout(() => {
      this.addClickOutsideListener()
    }, 0)
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")

    if (this.constructor.currentlyOpen === this) {
      this.constructor.currentlyOpen = null
    }

    this.removeClickOutsideListener()
  }

  isOpen() {
    return !this.menuTarget.classList.contains("hidden")
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  addClickOutsideListener() {
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  removeClickOutsideListener() {
    document.removeEventListener("click", this.boundHandleClickOutside)
  }
}
