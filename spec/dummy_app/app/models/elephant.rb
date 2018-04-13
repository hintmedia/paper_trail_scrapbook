class Elephant < Animal
  PaperTrail.request.disable_model(Elephant)
end
