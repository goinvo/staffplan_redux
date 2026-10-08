import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

const BASE_WIDTH = 600
const LEFT_GUTTER = 60
const PIXELS_PER_WEEK = 42
const MIN_WEEKS = 5
const MOBILE_WIDTH = 640
const MIN_SWIPE_DISTANCE = 50
const WEEK_COUNT = 52

export default class extends Controller {
  static targets = ["style", "previous", "next", "today"]
  static values = { start: String, currentWeek: Number }

  connect() {
    this.observer = new ResizeObserver(([entry]) => this.#layout(entry.contentRect.width))
    this.observer.observe(document.documentElement)
  }

  disconnect() {
    this.observer.disconnect()
  }

  page(event) {
    if (event.metaKey || event.ctrlKey || event.altKey || event.shiftKey || this.#isEditing(event.target)) return

    if (event.key === "ArrowLeft") this.#visit(this.previousTarget)
    if (event.key === "ArrowRight") this.#visit(this.nextTarget)
  }

  touchStart(event) {
    const { clientX, clientY } = event.changedTouches[0]
    this.touchOrigin = { x: clientX, y: clientY }
  }

  touchEnd(event) {
    if (!this.touchOrigin) return

    const { clientX, clientY } = event.changedTouches[0]
    const distance = this.touchOrigin.x - clientX
    const vertical = Math.abs(this.touchOrigin.y - clientY)
    this.touchOrigin = null

    if (Math.abs(distance) < MIN_SWIPE_DISTANCE || vertical > Math.abs(distance)) return

    this.#visit(distance > 0 ? this.nextTarget : this.previousTarget)
  }

  #layout(width) {
    const visible = this.#visibleWeeks(width)
    const hidden = [...Array(WEEK_COUNT).keys()].filter((index) => !visible.includes(index))

    this.styleTarget.textContent = hidden.length
      ? `${hidden.map((index) => `#${this.element.id} [data-timeline-week="${index}"]`).join(",")}{display:none!important}`
      : ""
    this.previousTarget.href = this.#startUrl(-visible.length)
    this.nextTarget.href = this.#startUrl(visible.length)
    this.todayTarget.hidden = visible.includes(this.currentWeekValue)
  }

  #visibleWeeks(width) {
    if (width < MOBILE_WIDTH) return [1]

    const extraWeeks = Math.max(0, Math.floor((width - BASE_WIDTH - LEFT_GUTTER) / PIXELS_PER_WEEK))
    const count = Math.min(WEEK_COUNT, Math.max(MIN_WEEKS, 1 + extraWeeks) + 1)
    return [...Array(count).keys()]
  }

  #startUrl(weeks) {
    const [year, month, day] = this.startValue.split("-").map(Number)
    const date = new Date(Date.UTC(year, month - 1, day + weeks * 7))
    const url = new URL(window.location.href)
    url.searchParams.set("start", date.toISOString().slice(0, 10))
    return url.toString()
  }

  #visit(link) {
    Turbo.visit(link.href, { action: "replace" })
  }

  #isEditing(element) {
    return ["INPUT", "TEXTAREA", "SELECT"].includes(element.tagName) || element.isContentEditable
  }
}
