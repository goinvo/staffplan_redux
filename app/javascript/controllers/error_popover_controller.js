import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["popover"]
  static values = { 
    errors: Array,
    autoHide: { type: Boolean, default: true },
    hideDelay: { type: Number, default: 5000 }
  }

  connect() {
    // Use a small delay to ensure DOM is ready
    setTimeout(() => {
      if (this.errorsValue && this.errorsValue.length > 0) {
        this.show()
        
        if (this.autoHideValue) {
          this.scheduleHide()
        }
      }
    }, 100)
  }

  disconnect() {
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }
  }

  show() {
    if (this.hasPopoverTarget) {
      // Force display by setting styles directly
      this.popoverTarget.style.display = 'flex'
      this.popoverTarget.classList.remove('hidden')
      this.popoverTarget.classList.add('flex')
      
      // Ensure visibility
      this.popoverTarget.style.visibility = 'visible'
      this.popoverTarget.style.opacity = '1'
    }
  }

  hide() {
    if (this.hasPopoverTarget) {
      this.popoverTarget.style.display = 'none'
      this.popoverTarget.classList.add('hidden')
      this.popoverTarget.classList.remove('flex')
    }
  }

  scheduleHide() {
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }
    
    this.hideTimeout = setTimeout(() => {
      this.hide()
    }, this.hideDelayValue)
  }

  errorsValueChanged() {
    if (this.errorsValue && this.errorsValue.length > 0) {
      this.show()
      
      if (this.autoHideValue) {
        this.scheduleHide()
      }
    } else {
      this.hide()
    }
  }
}