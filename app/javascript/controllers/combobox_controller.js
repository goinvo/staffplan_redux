import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "listbox", "option", "badge"]
  static values = { group: String }

  connect() {
    this.#refresh(false)
  }

  groupValueChanged() {
    if (this.hasInputTarget) this.#refresh(this.#expanded)
  }

  open() {
    this.#refresh(true)
  }

  close() {
    this.#setExpanded(false)
  }

  filter() {
    this.#refresh(true)
  }

  keydown(event) {
    const options = this.#visibleOptions()

    switch (event.key) {
      case "ArrowDown":
      case "ArrowUp": {
        event.preventDefault()
        if (!this.#expanded) return this.#refresh(true)

        const index = options.indexOf(this.#active) + (event.key === "ArrowDown" ? 1 : -1)
        this.#activate(options[(index + options.length) % options.length])
        break
      }
      case "Enter":
        if (this.#expanded && this.#active) {
          event.preventDefault()
          this.#choose(this.#active)
        }
        break
      case "Escape":
        if (this.#expanded) {
          event.preventDefault()
          event.stopPropagation()
          this.close()
        }
        break
    }
  }

  select(event) {
    event.preventDefault()
    this.#choose(event.currentTarget)
  }

  #choose(option) {
    this.inputTarget.value = option.dataset.value
    this.#refresh(false)
    this.dispatch("chosen", { detail: { value: option.dataset.value } })
  }

  #refresh(expand) {
    const query = this.#normalize(this.inputTarget.value)

    this.optionTargets.forEach((option) => {
      option.hidden = !this.#inGroup(option) || !this.#normalize(option.dataset.value).includes(query)
    })

    const match = this.optionTargets.find((option) => this.#inGroup(option) && this.#normalize(option.dataset.value) === query)
    const badge = query === "" ? "" : match ? match.dataset.badge || "" : "new"
    if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = badge
      this.badgeTarget.hidden = badge === ""
    }

    this.#activate(null)
    this.#setExpanded(expand && this.#visibleOptions().length > 0)
  }

  #inGroup(option) {
    return !this.groupValue || option.dataset.group === this.#normalize(this.groupValue)
  }

  #visibleOptions() {
    return this.optionTargets.filter((option) => !option.hidden)
  }

  #activate(option) {
    this.optionTargets.forEach((each) => each.setAttribute("aria-selected", each === option))
    if (option) {
      this.inputTarget.setAttribute("aria-activedescendant", option.id)
      option.scrollIntoView({ block: "nearest" })
    } else {
      this.inputTarget.removeAttribute("aria-activedescendant")
    }
  }

  #setExpanded(expanded) {
    this.listboxTarget.hidden = !expanded
    this.inputTarget.setAttribute("aria-expanded", expanded)
  }

  get #active() {
    return this.optionTargets.find((option) => option.getAttribute("aria-selected") === "true")
  }

  get #expanded() {
    return !this.listboxTarget.hidden
  }

  #normalize(value) {
    return value.trim().toLowerCase()
  }
}
