# frozen_string_literal: true

class Elephant < Animal
  PaperTrail.request.disable_model(Elephant)
end
