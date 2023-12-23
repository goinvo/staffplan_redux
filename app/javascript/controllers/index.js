// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "controllers/application"

import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
