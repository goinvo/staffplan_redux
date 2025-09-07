import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["arrow", "input"]
  static values = { 
    fillForward: { type: Boolean, default: true }
  }

  connect() {
    // Ensure arrow is hidden on initial load
    this.hideArrow()
  }

  handleFocus(event) {
    if (!this.fillForwardValue) return
    
    if (this.hasArrowTarget) {
      this.arrowTarget.style.opacity = '1'
      this.arrowTarget.style.pointerEvents = 'auto'
      this.arrowTarget.style.backgroundColor = '#27B5B0'
      this.arrowTarget.style.outline = '1px solid #27B5B0'
    }
    
    // Select all text in the input
    event.target.select()
    
    // Add tiffany color border to input using inline styles
    this.inputTarget.style.borderColor = '#27B5B0'
    this.inputTarget.style.outline = '2px solid #27B5B0'
    this.inputTarget.style.outlineOffset = '-1px'
  }

  handleBlur(event) {
    // Check if the blur was caused by clicking the arrow button
    if (this.hasArrowTarget && event.relatedTarget === this.arrowTarget) {
      this.fillForward()
      this.hideArrow()
      this.resetInputStyles()
      return
    }
    
    this.hideArrow()
    this.resetInputStyles()
  }
  
  resetInputStyles() {
    // Remove tiffany border from input
    this.inputTarget.style.borderColor = ''
    this.inputTarget.style.outline = ''
    this.inputTarget.style.outlineOffset = ''
  }

  hideArrow() {
    if (this.hasArrowTarget) {
      this.arrowTarget.style.opacity = '0'
      this.arrowTarget.style.pointerEvents = 'none'
      this.arrowTarget.style.backgroundColor = 'transparent'
      this.arrowTarget.style.borderColor = 'transparent'
    }
  }

  fillForward() {
    // This will trigger a custom event that the parent component can listen to
    // to implement the fill-forward logic
    const event = new CustomEvent('fill-forward', {
      detail: { 
        value: this.inputTarget.value,
        inputId: this.inputTarget.id
      },
      bubbles: true
    })
    this.element.dispatchEvent(event)
  }

  arrowClick(event) {
    event.preventDefault()
    this.fillForward()
    this.hideArrow()
    this.resetInputStyles()
    // Return focus to the input
    this.inputTarget.focus()
  }
}