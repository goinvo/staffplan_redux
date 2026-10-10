import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

const INPUT = "input[data-kind]"
const MAX_HOURS = 168

export default class extends Controller {
  static targets = ["message"]

  connect() {
    this.pending = 0
    this.queue = Promise.resolve()
  }

  focus({ target }) {
    if (!target.matches(INPUT)) return

    this.lastValid = target.value
    target.select()
  }

  blur({ target }) {
    if (!target.matches(INPUT)) return

    this.#hideMessage()
    if (this.#dirty(target)) this.#save(target.form)
  }

  submit(event) {
    event.preventDefault()
    this.#save(event.target)
  }

  input({ target }) {
    if (!target.matches(INPUT)) return

    if (!/^\d*$/.test(target.value)) {
      target.value = this.lastValid
    } else if (Number(target.value) > MAX_HOURS) {
      target.value = this.lastValid
      this.#showMessage(target)
    } else {
      this.lastValid = target.value
      this.#hideMessage()
    }
  }

  keydown(event) {
    const input = event.target
    if (!input.matches(INPUT)) return

    switch (event.key) {
      case "Enter":
        event.preventDefault()
        if (this.#dirty(input)) this.#save(input.form)
        break
      case "Escape":
        input.value = this.lastValid = input.defaultValue
        input.select()
        this.#hideMessage()
        break
      case "Tab":
        this.#move(event, this.#readingOrder(), input, event.shiftKey ? -1 : 1)
        break
      case "ArrowRight":
        if (input.selectionEnd === input.value.length) this.#move(event, this.#readingOrder(), input, 1)
        break
      case "ArrowLeft":
        if (input.selectionStart === 0) this.#move(event, this.#readingOrder(), input, -1)
        break
      case "ArrowDown":
        event.preventDefault()
        this.#move(event, this.#column(input), input, 1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.#move(event, this.#column(input), input, -1)
        break
    }
  }

  keepFocus(event) {
    event.preventDefault()
  }

  fillForward({ currentTarget: button }) {
    const input = button.parentElement.querySelector(INPUT)
    if (input.value === "") return

    const cells = [...input.closest("tr").querySelectorAll("td[data-monday]")].filter((cell) => cell.checkVisibility())
    const body = new FormData(input.form)
    body.set("through", cells.at(-1).dataset.monday)

    input.defaultValue = input.value
    this.#send(button.dataset.url, "POST", body)
  }

  #dirty(input) {
    return input.value !== input.defaultValue
  }

  #save(form) {
    const body = new FormData(form)
    form.querySelectorAll(INPUT).forEach((input) => (input.defaultValue = input.value))
    this.#send(form.action, "PATCH", body)
  }

  #send(url, method, body) {
    const headers = { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content }

    this.pending++
    this.queue = this.queue
      .then(() => fetch(url, { method, body, headers, credentials: "same-origin", keepalive: true }))
      .catch(() => {})
      .finally(() => {
        if (--this.pending === 0 && this.element.isConnected) Turbo.visit(window.location.href, { action: "replace" })
      })
  }

  #move(event, inputs, input, offset) {
    const next = inputs[inputs.indexOf(input) + offset]
    if (!next) return

    event.preventDefault()
    next.focus()
  }

  #readingOrder() {
    return [...this.element.querySelectorAll("tbody tr")].flatMap((row) => {
      const inputs = this.#usable(row.querySelectorAll(INPUT))
      return ["plan", "actual"].flatMap((kind) => inputs.filter((input) => input.dataset.kind === kind))
    })
  }

  #column(input) {
    const week = input.closest("td").dataset.timelineWeek
    return this.#usable(this.element.querySelectorAll(`tbody td[data-timeline-week="${week}"] ${INPUT}`))
  }

  #usable(inputs) {
    return [...inputs].filter((input) => !input.disabled && input.checkVisibility())
  }

  #showMessage(input) {
    this.messageTarget.textContent = `There are only ${MAX_HOURS} hours in a week, so weekly hours can't go above ${MAX_HOURS}.`
    input.parentElement.append(this.messageTarget)
    this.messageTarget.hidden = false
  }

  #hideMessage() {
    this.messageTarget.hidden = true
    this.element.append(this.messageTarget)
  }
}
