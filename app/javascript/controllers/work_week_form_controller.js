import { Controller } from "@hotwired/stimulus"
import { useDebounce } from "stimulus-use"

export default class extends Controller {
  static targets = ["estimatedInput", "actualInput"]
  static debounces = ["submitForm"]
  static values = { skipNextSubmit: Boolean }

  connect() {
    useDebounce(this, { wait: 500 })
    this.isTabbing = false
    
    // Track if user is tabbing
    this.element.addEventListener('keydown', this.trackTabKey.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('keydown', this.trackTabKey.bind(this))
  }

  trackTabKey(event) {
    if (event.key === 'Tab') {
      this.isTabbing = true
      // Reset after a short delay
      setTimeout(() => {
        this.isTabbing = false
      }, 100)
    }
  }

  handleInput(event) {
    // Don't submit if user is tabbing through fields
    if (this.isTabbing) {
      // Still schedule a submit for after they stop tabbing
      this.submitForm()
      return
    }
    
    // This will be debounced by 500ms thanks to useDebounce
    this.submitForm()
  }

  submitForm() {
    // Don't submit if user is actively tabbing
    if (this.isTabbing) return
    
    // Submit the form element using requestSubmit to trigger Turbo
    // requestSubmit properly triggers form validation and Turbo interception
    this.element.requestSubmit()
  }
}