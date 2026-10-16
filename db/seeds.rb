# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

countries_json = ActiveSupport::JSON.decode(File.read('db/seeds/countries.json'))


countries_json.each do |country|
  new_country = Country.find_or_initialize_by(name: country['name'], code: country['code'])

  if country['provinces'].present?
    new_country.states_attributes = country['provinces']
  end
  new_country.save
end
