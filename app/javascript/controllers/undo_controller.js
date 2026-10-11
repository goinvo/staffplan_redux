import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["template"]
  static values = { url: String, delay: { type: Number, default: 5000 } }

  start() {
    this.cells = [...this.element.children].filter((cell) => cell.tagName === "TD")
    this.cells.forEach((cell) => (cell.hidden = true))
    this.element.append(this.templateTarget.content.cloneNode(true))
    this.element.setAttribute("data-turbo-permanent", "")
    this.timer = setTimeout(() => this.commit(), this.delayValue)
  }

  undo() {
    clearTimeout(this.timer)
    this.timer = null
    this.element.querySelector("[data-undo-row]")?.remove()
    this.cells.forEach((cell) => (cell.hidden = false))
    this.element.removeAttribute("data-turbo-permanent")
  }

  flush() {
    if (this.timer) this.commit({ refresh: false })
  }

  disconnect() {
    this.flush()
  }

  async commit({ refresh = true } = {}) {
    clearTimeout(this.timer)
    this.timer = null
    const headers = { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content }
    const response = await fetch(this.urlValue, { method: "DELETE", headers, credentials: "same-origin", keepalive: true })
    if (!refresh) return

    this.element.removeAttribute("data-turbo-permanent")
    if (response.ok) this.element.remove()
    Turbo.visit(window.location.href, { action: "replace" })
  }
}
