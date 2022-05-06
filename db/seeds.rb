20.times do
  Password.create!(site: Faker::Internet.domain_name, username: Faker::Internet.username,
                   password: Faker::Internet.password)
end
