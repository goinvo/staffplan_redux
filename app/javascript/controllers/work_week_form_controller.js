import { Controller } from "@hotwired/stimulus"
import { useDebounce } from "stimulus-use"

export default class extends Controller {
  static targets = ["estimatedInput", "actualInput"]
  static debounces = ["submitForm"]

  connect() {
    useDebounce(this, { wait: 500 })
  }

  handleInput(event) {
    // This will be debounced by 500ms thanks to useDebounce
    this.submitForm()
  }

  submitForm() {
    // Submit the form element using requestSubmit to trigger Turbo
    // requestSubmit properly triggers form validation and Turbo interception
    this.element.requestSubmit()
  }
}