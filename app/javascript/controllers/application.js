//https://github.com/hotwired/stimulus-rails?tab=readme-ov-file#with-import-map

import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }