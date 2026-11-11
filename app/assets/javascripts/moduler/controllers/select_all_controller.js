import { Controller } from "@hotwired/stimulus"

// A checkbox that checks or unchecks all child checkboxes, and is checked
// itself when all of them are.
export default class extends Controller {
  static targets = ["parent", "child"]

  toggleChildren() {
    this.childTargets.forEach((child) => { child.checked = this.parentTarget.checked })
  }

  toggleParent() {
    this.parentTarget.checked = this.childTargets.length > 0 && this.childTargets.every((child) => child.checked)
  }
}
