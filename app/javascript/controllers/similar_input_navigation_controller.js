import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('keydown', this.handleKeydown.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('keydown', this.handleKeydown.bind(this))
  }

  handleKeydown(event) {
    if (event.key !== 'Tab') return

    const activeElement = document.activeElement
    if (!activeElement || activeElement.tagName !== 'INPUT') return

    const isEstimatedInput = activeElement.name === 'work_week[estimated_hours]'
    const isActualInput = activeElement.name === 'work_week[actual_hours]'
    
    if (!isEstimatedInput && !isActualInput) return

    event.preventDefault()

    const inputType = isEstimatedInput ? 'estimated_hours' : 'actual_hours'
    const allSimilarInputs = this.element.querySelectorAll(`input[name="work_week[${inputType}]"]`)
    
    const inputsArray = Array.from(allSimilarInputs)
    const currentIndex = inputsArray.indexOf(activeElement)
    
    if (currentIndex === -1) return

    let nextIndex
    if (event.shiftKey) {
      nextIndex = currentIndex - 1
      if (nextIndex < 0) return
    } else {
      nextIndex = currentIndex + 1
      if (nextIndex >= inputsArray.length) return
    }

    const nextInput = inputsArray[nextIndex]
    if (nextInput) {
      nextInput.focus()
      nextInput.select()
    }
  }
}