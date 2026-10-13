import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["template"]
  static values = { delay: { type: Number, default: 5000 } }

  start({ params: { url, method, body = {}, template } }) {
    this.request = { url, method, body }
    this.cells = [...this.element.children].filter((cell) => cell.tagName === "TD")
    this.cells.forEach((cell) => (cell.hidden = true))
    this.element.append(this.templateTargets.find((target) => target.dataset.name === template).content.cloneNode(true))
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
    const { url, method, body } = this.request
    const headers = { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content }
    const response = await fetch(url, {
      method: "POST",
      body: new URLSearchParams({ ...body, _method: method }),
      headers,
      credentials: "same-origin",
      redirect: "manual",
      keepalive: true,
    })
    if (!refresh) return

    this.element.removeAttribute("data-turbo-permanent")
    if (response.ok || response.type === "opaqueredirect") this.element.remove()
    Turbo.visit(window.location.href, { action: "replace" })
  }
}
