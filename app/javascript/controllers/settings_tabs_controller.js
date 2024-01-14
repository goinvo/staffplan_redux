import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="settings-tabs"
export default class extends Controller {
    static targets = [ "selector" ]

    handleChange(e) {
        Turbo.visit(e.target.value)
    }
}

