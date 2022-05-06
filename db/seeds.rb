20.times do
  Password.create!(url: Faker::Internet.url, username: Faker::Internet.username,
                   password: Faker::Internet.password(min_length: 10, max_length: 20, mix_case: true, special_characters: true))
end
