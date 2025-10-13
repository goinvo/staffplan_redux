import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["backdrop", "dialog"]

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)

    // If modal is already visible on connect (e.g., from TurboStream), set up listeners
    if (!this.element.classList.contains("hidden")) {
      this.addKeydownListener()
      this.dialogTarget.focus()
    }
  }

  disconnect() {
    this.removeKeydownListener()
  }

  open() {
    this.element.classList.remove("hidden")
    this.addKeydownListener()
    // Trap focus within modal
    this.dialogTarget.focus()
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }
    this.element.classList.add("hidden")
    this.removeKeydownListener()
  }

  closeOnBackdrop(event) {
    // Only close if clicking directly on the backdrop, not child elements
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  addKeydownListener() {
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  removeKeydownListener() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }
}
