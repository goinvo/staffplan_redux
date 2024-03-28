import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "changeButton", "gravatarNote"];

  connect() {
  }

  change(event) {
    // called when an image is chosen. Only hide the change button once

    if(this.changeButtonTarget.classList.contains('hidden')) {
      return
    }

    this.changeButtonTarget.classList.toggle('hidden')
    this.fileInputTarget.classList.toggle('hidden')
    this.gravatarNoteTarget.classList.toggle('hidden')
  }

  click(event) {
    event.preventDefault();
    this.fileInputTarget.click();
  }
}