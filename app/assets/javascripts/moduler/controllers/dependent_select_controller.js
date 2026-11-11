import { Controller } from "@hotwired/stimulus"

// Repopulates the dependent select with the choices for the value chosen in
// the source select, e.g. the roles of the chosen organization.
//
// options value: { "<source value>": [[label, value], ...] }
export default class extends Controller {
  static targets = ["source", "dependent"]
  static values = { options: Object }

  update() {
    const choices = this.optionsValue[this.sourceTarget.value] || []
    const blank = this.dependentTarget.querySelector("option[value='']")
    const options = choices.map(([label, value]) => new Option(label, value))

    this.dependentTarget.replaceChildren(...(blank ? [blank] : []), ...options)
    this.dependentTarget.value = ""
  }
}
