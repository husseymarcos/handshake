import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]

  async paste(event) {
    event.preventDefault()
    try {
      const text = await navigator.clipboard.readText()
      this.textareaTarget.value = text
      this.textareaTarget.dispatchEvent(new Event("input", { bubbles: true }))
      this.textareaTarget.focus()
    } catch (err) {
      console.error("Failed to read clipboard:", err)
    }
  }
}
