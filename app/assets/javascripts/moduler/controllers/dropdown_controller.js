import { Controller } from "@hotwired/stimulus"

// Closes a <details> dropdown on a click outside it or on Escape.
export default class extends Controller {
  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  close() {
    this.element.open = false
  }
}
