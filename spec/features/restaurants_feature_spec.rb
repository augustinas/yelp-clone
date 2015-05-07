require 'rails_helper'

def sign_up(email, password)
  visit '/users/sign_up'
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  fill_in 'Password confirmation', with: password
  click_button 'LET ME YALP!'
end

def sign_up_and_create(email, password, restaurant)
  sign_up(email, password)
  visit '/restaurants'
  click_link 'Add a restaurant'
  fill_in 'Name', with: 'KFC'
  click_button 'Create Restaurant'
end

feature 'restaurants' do
  context 'no restaurants have been added' do
    scenario 'should display a prompt to add a restaurant'  do
      sign_up('test@test.com', 'testpassword')
      visit '/restaurants'
      expect(page).to have_content 'No restaurants yet'
      expect(page).to have_link 'Add a restaurant'
    end
  end

  context 'restaurants have been added' do
    before do
      Restaurant.create name: 'KFC'
    end

    scenario 'display restaurants' do
      visit '/restaurants'
      expect(page).to have_content 'KFC'
      expect(page).not_to have_content 'No restaurants yet'
    end
  end

  context 'creating restaurants' do

    context 'logged in user' do
      scenario 'prompts user to fill out a form then displays the new restaurant' do
        sign_up('test@test.com', 'testpassword')
        visit '/restaurants'
        click_link 'Add a restaurant'
        fill_in 'Name', with: 'KFC'
        click_button 'Create Restaurant'
        expect(page).to have_content 'KFC'
        expect(current_path).to eq '/restaurants'
      end

      context 'an invalid restaurant' do
        it 'does not let you submit a name that is too short' do
          sign_up('test@test.com', 'testpassword')
          visit '/restaurants'
          click_link 'Add a restaurant'
          fill_in 'Name', with: 'kf'
          click_button 'Create Restaurant'
          expect(page).not_to have_css 'h2', text: 'kf'
          expect(page).to have_content 'Error'
         end
      end
    end

    context 'a logged out user' do
      scenario 'does not see add restaurant button' do
        visit '/restaurants'
        expect(page).not_to have_link 'Add a restaurant'
      end

      scenario 'cannot visit add restaurants form' do
        visit '/restaurants/new'
        expect(page).to have_content 'You need to sign in or sign up before continuing.'
      end
    end
  end

  context 'viewing restaurants' do
    let! (:kfc) { Restaurant.create name: 'KFC' }

    scenario 'let the user to view a restaurant' do
      visit '/restaurants'
      click_link 'KFC'
      expect(page).to have_content 'KFC'
      expect(current_path).to eq "/restaurants/#{kfc.id}"
    end
  end

  context 'editing restaurants' do
    scenario 'let a user edit a Restaurant' do
      sign_up_and_create('test@test.com', 'testpassword', 'KFC')
      visit '/restaurants'
      click_link 'Edit KFC'
      fill_in 'Name', with: 'Kentucky Fried Chicken'
      click_button 'Update Restaurant'
      expect(page).to have_content 'Kentucky Fried Chicken'
      expect(current_path).to eq '/restaurants'
    end

    context 'cannot edit restaurant they have not created' do
      before do
        sign_up_and_create('phantom@test.com', 'testtest', 'KFC')
        click_link 'Sign out'
      end

      scenario 'by clicking a link' do
        sign_up('test@test.com', 'testpassword')
        expect(page).not_to have_content 'Edit KFC'
      end

      scenario 'by visiting url directly' do
        sign_up('test@test.com', 'testpassword')
        visit '/restaurants/1/edit'
        expect(page).to have_content 'You need to sign in or sign up before continuing.'
      end
    end
  end

  context 'deleting restaurants' do
    before { Restaurant.create name: 'KFC' }

    scenario 'let a user delete a restaurant' do
      sign_up('test@test.com', 'testpassword')
      visit '/restaurants'
      click_link 'Delete KFC'
      expect(page).not_to have_content 'KFC'
      expect(page).to have_content 'Restaurant deleted successfully'
    end
  end
end
