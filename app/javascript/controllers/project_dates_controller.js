import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "field"]

  start(event) {
    this.marker = event.currentTarget.dataset.marker
    if (!this.marker) return event.preventDefault()

    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.marker)
    event.currentTarget.classList.add("opacity-50")
  }

  over(event) {
    if (this.marker) event.preventDefault()
  }

  drop(event) {
    event.preventDefault()
    const { marker } = this
    const { date } = event.currentTarget.dataset
    if (!marker || !this.#inOrder(marker, date)) return

    this.fieldTarget.name = `project[${marker}]`
    this.fieldTarget.value = date
    this.formTarget.requestSubmit()
  }

  end(event) {
    event.currentTarget.classList.remove("opacity-50")
    this.marker = null
  }

  #inOrder(marker, date) {
    const { startsOn, endsOn } = this.formTarget.dataset
    return marker === "starts_on" ? !endsOn || date < endsOn : !startsOn || date > startsOn
  }
}
