import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="settings-tabs"
export default class extends Controller {

    close() {
        this.element.remove()
    }
}

