import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { dismissAfter: { type: Number, default: 5000 } }

  connect() {
    this.timeout = setTimeout(() => this.dismiss(), this.dismissAfterValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    clearTimeout(this.timeout)
    this.element.classList.add("opacity-0", "translate-x-2")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }
}
