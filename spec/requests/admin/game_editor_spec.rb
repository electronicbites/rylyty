require 'spec_helper'

I18n.locale = 'de'

feature 'cockpit - game-editor' do
  
  let(:admin) { FactoryGirl.create(:admin_user, password: 'secret') }
  let(:game_without_reward) { FactoryGirl.create(:game, points: 0) }
  let(:game_with_reward) { FactoryGirl.create(:game, points: 10) }
  let(:game_without_restriction) { FactoryGirl.create(:game, restriction_points: 0) }
  let(:game_with_restriction) { FactoryGirl.create(:game, restriction_points: 10) }
  let(:game_without_tasks) { FactoryGirl.create(:game, tasks: []) }
  let(:mc_game_with_tasks) { FactoryGirl.create(:multiple_choice_game) }

  before(:each) do
    sign_in_as_admin admin, 'secret'
  end

  scenario 'create game', js: true do
    visit "/cockpit/game_editors/new"
    
    fill_in 'game_title', with: 'game title'
    fill_in 'game_short_description', with: 'short_description'
    fill_in 'game_description', with: 'description'
    
    expect {
      find_by_id('edit_submit').click
      page.should have_content('Game created')
    }.to change { Game.count }.by(1)
  end
  
  scenario 'create multiple-choice-task', js: true do
    visit "/cockpit/game_editors/#{game_without_tasks.id}/edit?tasks=true"

    fill_in 'task_title', with: 'task title'
    
    find("select[@id='task_type']/option[value='multiple_choice_task']").select_option
    question_0 = find("input[@id='multiple_choice_task_questions_0_question']")
    question_0.set 'question 1'
    
    check 'multiple_choice_task_questions_0_option_0_check'
    
    answer_0 =  find("input[@id='multiple_choice_task_questions_0_option_0_answer']")
    answer_0.set('answer 1 correct')

    expect {
      find_by_id('edit_submit').click
      page.should have_content(game_without_tasks.title)
    }.to change { Task.count }.by(1)
  end

  scenario 'edit multiple-choice-task I: change task-attribute', js: true do
    edit_task = mc_game_with_tasks.tasks.first
    visit "/cockpit/game_editors/#{mc_game_with_tasks.id}/edit?task_id=#{edit_task.id}&tasks=true"

    fill_in 'multiple_choice_task_title', with: "#{edit_task.title}_changed"
    
    expect {
      find_by_id('edit_submit').click
      page.should have_content(game_without_tasks.title)
    }.to change { edit_task.reload.title }.from(edit_task.title).to("#{edit_task.title}_changed")
  end

  scenario 'edit multiple-choice-task II: add question', js: true do
    edit_task = mc_game_with_tasks.tasks.first
    visit "/cockpit/game_editors/#{mc_game_with_tasks.id}/edit?tasks=true&task_id=#{edit_task.id}"

    num_questions = edit_task.questions.count
    has_no_field?("multiple_choice_task_questions_#{num_questions}_question").should be_true
    add_question_link =  find("a[@id='add_q']")
    add_question_link.click
    
    new_question = find_by_id("multiple_choice_task_questions_#{num_questions}_question")
    new_question.set('new question')
   
    expect {
      find_by_id('edit_submit').click
      page.should have_content(game_without_tasks.title)
      edit_task.reload
    }.to change { edit_task.questions.count }.by(1)
  end

  scenario 'edit multiple-choice-task III: delete question', js: true do
    edit_task = mc_game_with_tasks.tasks.first
    visit "/cockpit/game_editors/#{mc_game_with_tasks.id}/edit?tasks=true&task_id=#{edit_task.id}"

    num_questions = edit_task.questions.count
    has_field?("multiple_choice_task_questions_#{(num_questions - 1)}_question").should be_true
    expect {
      del_question_link =  find_by_id("del_q_0")
      del_question_link.click
      wait_for_ajax
    }.to change { edit_task.reload.questions.count }.by(-1)
    
    has_no_field?("multiple_choice_task_questions_#{(num_questions - 1)}_question").should be_true
  end

  scenario 'edit multiple-choice-task IV: add answer', js: true do
    edit_task = mc_game_with_tasks.tasks.first
    visit "/cockpit/game_editors/#{mc_game_with_tasks.id}/edit?tasks=true&task_id=#{edit_task.id}"

    edit_question = edit_task.questions.first
    num_answers = edit_question[:options].size
    has_no_field?("multiple_choice_task_questions_0_option_#{num_answers}_answer").should be_true
    add_answer_link =  find("a[@id='add_a_to_q_0']")
    add_answer_link.click
    
    new_answer = find_by_id("multiple_choice_task_questions_0_option_#{num_answers}_answer")
    new_answer.set('new answer')
   
    expect {
      find_by_id('edit_submit').click
      page.should have_content(game_without_tasks.title)
    }.to change { edit_task.reload.questions.first[:options].count }.by(1)
  end

  scenario 'edit multiple-choice-task V: delete answer', js: true do
    edit_task = mc_game_with_tasks.tasks.first
    visit "/cockpit/game_editors/#{mc_game_with_tasks.id}/edit?tasks=true&task_id=#{edit_task.id}"
    
    edit_question = edit_task.questions.first
    num_answers = edit_question[:options].size
    has_field?("multiple_choice_task_questions_0_option_#{(num_answers - 1)}_answer").should be_true
    expect {
      del_answer_link =  find_by_id("del_q_0_a_#{(num_answers - 1)}")
      del_answer_link.click
      wait_for_ajax
    }.to change { edit_task.reload.questions.first[:options].count }.by(-1)
    
    has_no_field?("multiple_choice_task_questions_0_option_#{(num_answers - 1)}_answer").should be_true
  end

  scenario 'edit multiple-choice-task VI: error when storing question without answer', js: true do
    edit_task = mc_game_with_tasks.tasks.first
    # remove answers from question
    questions = edit_task.questions
    edit_question = questions.first
    edit_question.delete(:options)
    edit_task.questions = questions
    edit_task.save 
    
    visit "/cockpit/game_editors/#{mc_game_with_tasks.id}/edit?tasks=true&task_id=#{edit_task.id}"
    
    find_by_id('edit_submit').click
    page.should have_content('Question can\'t be saved without at least one answer')
  end

end
