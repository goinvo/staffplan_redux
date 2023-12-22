import { ApplicationController, useDebounce } from 'stimulus-use'

// Connects to data-controller="work-week"
export default class extends ApplicationController {
  static targets = ["proposedInput", "actualInput", "form"]
  static debounces = [{ name: "submit", wait: 200 }]

  connect() {
    useDebounce(this)
  }

  disconnect() {
  }

  submit() {
    this.formTarget.requestSubmit()
  }
}
