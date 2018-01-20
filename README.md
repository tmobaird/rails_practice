# Rails Practice

This project is dedicated to my personal practice with Ruby on Rails.
Each example in this project should include a description and link in the readme or any associated docs.

If anyone else is viewing this repo for reference and would like to see any topics or examples covered,
feel free to create an issue about it for me to tackle, or create a PR with the given example!

# 3, 2, 1, Go!

### ActiveRecord

##### Belongs To

The `belongs_to` relationship is how you associate a given model object with another
in an ownership type of relationship. In our example we have an Automaker
model and a Car model. The Car model has a `belongs_to` relationship to the
Automaker model.