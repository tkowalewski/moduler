import { Controller } from "@hotwired/stimulus"

// Rows of attached and new files (Moduler::Form::AttachmentsComponent).
// Adding a row opens the file picker of its new file field; removing an
// attached file's row submits its id for removal when the form is saved.
export default class extends Controller {
  static targets = ["list", "template"]
  static values = { removeFieldName: String }

  add() {
    const row = this.templateTarget.content.firstElementChild.cloneNode(true)
    this.listTarget.append(row)
    row.querySelector("input[type=file]")?.click()
  }

  remove(event) {
    const row = event.target.closest("li")
    const attachmentId = row.dataset.attachmentId

    if (attachmentId) {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = this.removeFieldNameValue
      input.value = attachmentId
      this.element.append(input)
    }

    row.remove()
  }
}
