pin "moduler/application"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from File.expand_path("../app/assets/javascripts/moduler/controllers", __dir__), under: "moduler/controllers"
