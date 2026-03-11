import { Controller } from "@hotwired/stimulus"

// Flash message auto-dismiss controller
export default class extends Controller {
  static values = { timeout: { type: Number, default: 5000 } }

  connect() {
    setTimeout(() => {
      this.dismiss()
    }, this.timeoutValue)
  }

  dismiss() {
    this.element.style.opacity = '0'
    this.element.style.transform = 'translateX(1rem)'
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
