require "application_system_test_case"

class PasswordsTest < ApplicationSystemTestCase
  setup do
    @password = passwords(:one)
  end

  test "visiting the index" do
    visit passwords_url
    assert_selector "h1", text: "Passwords"
  end

  test "creating a Password" do
    visit passwords_url
    click_on "New Password"

    fill_in "Crypted password", with: @password.crypted_password
    fill_in "Password salt", with: @password.password_salt
    click_on "Create Password"

    assert_text "Password was successfully created"
    click_on "Back"
  end

  test "updating a Password" do
    visit passwords_url
    click_on "Edit", match: :first

    fill_in "Crypted password", with: @password.crypted_password
    fill_in "Password salt", with: @password.password_salt
    click_on "Update Password"

    assert_text "Password was successfully updated"
    click_on "Back"
  end

  test "destroying a Password" do
    visit passwords_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Password was successfully destroyed"
  end
end
