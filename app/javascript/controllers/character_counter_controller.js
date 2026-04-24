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
}
