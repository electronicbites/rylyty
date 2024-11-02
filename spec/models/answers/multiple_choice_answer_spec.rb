require 'spec_helper'

describe MultipleChoiceAnswer do

  describe "tasks" do
    it "has a minimum score" do
      task = FactoryGirl.create(:multiple_choice_task, minimum_score: 6)
      task.reload
      task.minimum_score?.should be_true
      task.minimum_score.should == 6
    end

    it "question attribute should be inaccessible" do
      task = FactoryGirl.create(:multiple_choice_task)
      expect {
        task.question
      }.to raise_error(NoMethodError)

      expect {
        task.question = '{"foo"=>1}'
      }.to raise_error(NoMethodError)
    end
  end

  describe "answer" do

    let(:game) {FactoryGirl.create(:multiple_choice_game, costs: 23)}
    let(:user) {FactoryGirl.create(:user)}

    let(:user_task) {
      user.buy_game! game
      task = game.tasks.first
      user.reload.user_games.where(game_id: game.id).first.user_tasks.where(task_id: task.id).first
    }

    before :each do
      user_task.start
    end

    it "should be a MultipleChoiceTask" do
      task = game.tasks.first
      task.should be_an_instance_of(MultipleChoiceTask)
    end

    it "create an answer task" do
      user_task.should be_an_instance_of(MultipleChoiceAnswer)
    end

    it "should provide answers method" do
      user_task.should be_respond_to(:answers)
    end

    it "should provide score method" do
      user_task.should be_respond_to(:score)
    end

    it "should provide passed? method" do
      user_task.should be_respond_to(:passed?)
    end

    it "should prevent read-access to the original answer attribute" do
      expect {
        user_task.answer
      }.to raise_error(NoMethodError)
    end

    it "should prevent write-access to the original answer attribute" do
      expect {
        user_task.answer = "foo"
      }.to raise_error(NoMethodError)
    end

    context "with all correct answers" do
      before :each do
        user_task.answer_with({answers: {
          "0" => [1], "1" => ["0", "1"], 2 => ["2"]
        }})
      end

      it "should score all points" do
        user_task.score.should == 16
      end

      it "Multiple-Choice-Test should be considered as passed" do
        user_task.passed?.should be_true
      end

      it "should transition into completed start" do
        user_task.completed?.should be_true
      end
    end

    context "with all answers wrong" do
      before :each do
        user_task.answer_with({answers: {
          "0" => [], "1" => ["0"], 2 => ["1"]
        }})
      end

      it "won't score" do
        user_task.score.should == 0
      end

      it "don't pass" do
        # user_task.answer_with({answers: {
        #   "0" => [], "1" => ["0"], 2 => ["1"]
        # }})
        user_task.passed?.should be_false
      end

      it "does not change state" do
        user_task.started?.should be_true
      end
    end


    context "with wrong answers but scored ok" do
      before :each do
        user_task.answer_with({answers: {
          "0" => [1], "1" => ["0", "1"]
        }})
      end

      it "passes" do
        user_task.passed?.should be_true
      end

      it "5 and 1 point answer correct scores 6 points" do
        user_task.score.should == 6
      end

      it "Multiple-Choice-Test should be considered as passed" do
        user_task.passed?.should be_true
      end

      it "should transition into completed start" do
        user_task.completed?.should be_true
      end
    end


  end

end