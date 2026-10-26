import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = [ "markup", "viewer" ]
  static values = { directUploadUrl: String, blobUrl: String, attachmentsFieldName: String }

  connect() {
    this.render()
  }

  render() {
    this.viewerTarget.innerHTML = marked.parse(this.markupTarget.value)
  }

  h1() {
    this.prefixLines("# ")
  }

  h2() {
    this.prefixLines("## ")
  }

  h3() {
    this.prefixLines("### ")
  }

  bold() {
    this.wrap("**")
  }

  italic() {
    this.wrap("*")
  }

  code() {
    this.wrap("`")
  }

  quote() {
    this.prefixLines("> ")
  }

  ul() {
    this.prefixLines("* ")
  }

  ol() {
    this.prefixLines("1. ")
  }

  fencedCode() {
    this.insert("```lang\n" + this.selectedText() + "\n```")
  }

  link() {
    this.insert(`[${this.selectedText()}](http://...)`)
  }

  image() {
    this.insert(`![${this.selectedText()}](path/to/img.jpg)`)
  }

  upload() {
    const input = document.createElement("input")
    input.type = "file"
    input.multiple = true
    input.accept = "image/*"
    input.addEventListener("change", () => Array.from(input.files).forEach((file) => this.uploadFile(file)))
    input.click()
  }

  // Inserts a tab character instead of moving focus to the next field.
  // Tab with any modifier (Shift+Tab included) keeps the default behavior.
  insertTab(event) {
    if (event.key !== "Tab") return
    if (event.shiftKey || event.metaKey || event.ctrlKey || event.altKey) return

    event.preventDefault()
    this.insert("\t")
  }

  uploadFile(file) {
    new DirectUpload(file, this.directUploadUrlValue).create((error, blob) => {
      if (error) {
        console.error("Image upload failed", error)
        return
      }

      const url = this.blobUrlValue
        .replace(":signed_id", blob.signed_id)
        .replace(":filename", encodeURIComponent(blob.filename))
      this.insert(`![${blob.filename}](${url})`)

      // The blob becomes an attachment of the record only after the form is submitted.
      const field = document.createElement("input")
      field.type = "hidden"
      field.name = this.attachmentsFieldNameValue
      field.value = blob.signed_id
      this.element.append(field)
    })
  }

  selectedText() {
    const { selectionStart, selectionEnd, value } = this.markupTarget
    return value.slice(selectionStart, selectionEnd)
  }

  insert(text) {
    const { selectionStart, selectionEnd, value } = this.markupTarget

    this.markupTarget.value = value.slice(0, selectionStart) + text + value.slice(selectionEnd)
    this.markupTarget.focus()
    this.markupTarget.selectionStart = this.markupTarget.selectionEnd = selectionStart + text.length
    this.render()
  }

  wrap(marker) {
    this.insert(marker + this.selectedText() + marker)
  }

  prefixLines(prefix) {
    this.insert(this.selectedText().split("\n").map((line) => prefix + line).join("\n"))
  }
}
