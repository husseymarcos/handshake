import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "counter"]

  connect() {
    this.updateCounter()
  }

  updateCounter() {
    const count = this.textareaTarget.value.length
    this.counterTarget.textContent = `${count} character${count === 1 ? "" : "s"}`
  }

  async pasteFromClipboard(event) {
    event.preventDefault()
    try {
      const text = await navigator.clipboard.readText()
      this.textareaTarget.value = text
      this.updateCounter()
      this.textareaTarget.focus()
    } catch (err) {
      console.error("Failed to read clipboard:", err)
    }
  }
}
