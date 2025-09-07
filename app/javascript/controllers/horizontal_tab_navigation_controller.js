import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Find all inputs within this element
    this.refreshInputs()
  }

  refreshInputs() {
    // Get all estimated hours inputs (in the first row of inputs)
    this.estimatedInputs = Array.from(
      this.element.querySelectorAll('input[name="work_week[estimated_hours]"]')
    )
    
    // Get all actual hours inputs (in the second row of inputs)
    this.actualInputs = Array.from(
      this.element.querySelectorAll('input[name="work_week[actual_hours]"]')
    )
    
    // Combine them in the correct order: all estimated first, then all actual
    this.allInputs = [...this.estimatedInputs, ...this.actualInputs]
  }

  handleKeydown(event) {
    // Only intercept Tab key
    if (event.key !== 'Tab') return
    
    // Refresh inputs in case DOM has changed
    this.refreshInputs()
    
    const currentInput = event.target
    const currentIndex = this.allInputs.indexOf(currentInput)
    
    // If the current element is not one of our inputs, let default behavior happen
    if (currentIndex === -1) return
    
    event.preventDefault()
    
    let nextIndex
    if (event.shiftKey) {
      // Shift+Tab: go backwards
      nextIndex = currentIndex - 1
      if (nextIndex < 0) {
        // At the beginning, let default behavior take over
        return
      }
    } else {
      // Tab: go forwards
      nextIndex = currentIndex + 1
      if (nextIndex >= this.allInputs.length) {
        // At the end, let default behavior take over
        return
      }
    }
    
    // Focus the next input
    const nextInput = this.allInputs[nextIndex]
    if (nextInput) {
      nextInput.focus()
      nextInput.select() // Also select the text for easier editing
    }
  }
}