include Admin::GameEditorHelper

ActiveAdmin.register GameEditor do

    config.clear_action_items! # this will prevent the 'new button' showing up
    menu false # :label => "Game Editor"
    
    member_action :index do
      @game = Game.new
      task_editor = false
      
      render 'admin/game_editor/index', layout: 'game_editor', locals: { task_editor: task_editor }
    end
    
    member_action :edit do
      unless params[:tasks] == 'true'
        # handle games ...
        if params[:id] == 'new'
          @game = Game.new
        else
          @game = Game.find params[:id]
        end
        task_editor = false
      else
        # handle tasks ...
        @game = Game.find params[:id]
        if params[:task_id].blank? || params[:task_id] == 'new'
          @task = Task.new
        else
          @task = Task.find params[:task_id]
        end
        task_editor = true
      end
      
      render 'admin/game_editor/index', layout: 'game_editor', locals: { task_editor: task_editor }
    end

    member_action :sort_tasks, :method => :post do
      game = Game.find(params[:id])
      tasks = game.tasks
      tasks.each do |task|
        task.position = params['tasks'].index(task.id.to_s) + 1
        task.save
      end
      render :nothing => true
    end

    member_action :create do
      if params[:new_category_name].nil?
        # handle create game
        set_reward_and_restriction
        set_time_limit_secs
        params[:game].delete(:access_limit)
    
        params[:game][:missions] = Mission.missions_for_ids params[:game][:mission_ids] if params[:game][:mission_ids].present?
        params[:game].delete(:mission_ids)
        params[:game][:categories] = Tag.tags_for_ids params[:game][:category_ids] if params[:game][:category_ids].present?
        params[:game].delete(:category_ids)
          
        @game = Game.new(params[:game])
        if @game.save
          redirect_to edit_cockpit_game_editor_path(id: @game.id), notice: 'Game created'
        else
          render 'admin/game_editor/index', layout: 'game_editor', locals: { task_editor: false }
        end
      else
        # utility-action to add new categories via ajax - tags are actually a model of their own
        unless params[:new_category_name].blank?
          # handle add category
          category_tag = Tag.where(value: params[:new_category_name], context: Tag::GAME_CATEGORY_TYPE).first
          @category_tag = Tag.create(value: params[:new_category_name], context: Tag::GAME_CATEGORY_TYPE) if category_tag.nil?
          render 'admin/game_editor/new_category', layout: false
        else
          render text: 'can\'t be blank', content_type: 'text/plain'
        end
      end
    end
    
    member_action :update do
      task_editor = params[:tasks] == 'true'
      unless task_editor
        # handle games ...
        set_reward_and_restriction
        set_time_limit_secs
        params[:game].delete(:access_limit)
  
        missions = Mission.missions_for_ids params[:game][:mission_ids] if params[:game][:mission_ids].present?
        params[:game].delete(:mission_ids)
        params[:game][:missions] = missions unless missions.nil?
        category_tags = Tag.tags_for_ids params[:game][:category_ids]
        params[:game].delete(:category_ids)
        params[:game][:categories] = category_tags unless category_tags.nil?
        
        @game = Game.find(params[:id])
        
        if @game.update_attributes params[:game]
          redirect_to edit_cockpit_game_editor_path(id: @game.id), notice: 'Game updated' 
        else
          render 'admin/game_editor/index', layout: 'game_editor', locals: { task_editor: false }
        end
      else
        # handle tasks ...
        @game = Game.find params[:id]
        errors = {}
        begin
          setup_questions_ary if params[:task_type] == 'multiple_choice_task'
        rescue Exception => e
          errors[:question] = e.message
        end
        if params[:task_id].blank?
          # create new task ...
          set_time_limit_secs (params[:task].nil? || params[:task][:timeout_secs].nil? ? params[:task_type].to_sym : :task), :timeout_secs
          @task = Object::const_get(params[:task_type].camelcase).new (params[params[:task_type]]||{}).merge(params[:task]||{})
          @task.game = @game
          @is_new_task = true
          if (!@task.save) || errors.present?
            errors.each{|k,v|@task.errors.add k, v}
            render 'admin/game_editor/index', layout: 'game_editor', locals: { task_editor: true }
            return
          end
        else
          # update task ...
          @task = Task.find params[:task_id]
          if params[:_action].blank?
            set_time_limit_secs @task.type.tableize.singularize.to_sym, :timeout_secs
            if (!@task.update_attributes params[@task.type.tableize.singularize.to_sym].merge(params[:task]||{})) || errors.present?
              errors.each{|k,v|@task.errors.add k, v}
              render 'admin/game_editor/index', layout: 'game_editor', locals: { task_editor: true }
              return
            end
          else
            # delete questions or answers
            case params[:_action]
            when 'del_mc_q'
              delete_mc_question
              #render partial: 'admin/game_editor/mc_answer_fields', layout: false, locals: { question: question, index: params[:q_idx].to_i  }
              result = render_multi_line_js({ partial: 'mc_question_fields' }, { game: @game, task: @task }, 'js')
              render text: result, content_type: 'text/javascript'
              return
            when 'del_mc_a'
              question = delete_mc_answer
              #render partial: 'admin/game_editor/mc_answer_fields', layout: false, locals: { question: question, index: params[:q_idx].to_i  }
              result = render_multi_line_js({ partial: 'mc_answer_fields' }, { game: @game, task: @task, question: question, index: params[:q_idx].to_i }, 'js')
              render text: result, content_type: 'text/javascript'
              return
            end
          end
        end
        redirect_to edit_cockpit_game_editor_path(id: @game.id, tasks: true, task_id: @task.id), notice: "Task #{@is_new_task ? 'created' : 'updated'}"
      end
    end
    
    member_action :destroy do
      task_editor = params[:tasks] == 'true'
      if task_editor
        @game = Game.find params[:id]
        @task = Task.find params[:task_id]
        @task.destroy
        
        redirect_to edit_cockpit_game_editor_path(id: @game.id, tasks: true), notice: 'Task deleted'
      end
    end
    
    controller do
      
      def delete_mc_question
        questions = @task.questions
        questions.delete_at params[:q_idx].to_i
        @task.questions = questions
        @task.save!
      end
      
      def delete_mc_answer
        questions = @task.questions
        question = questions[params[:q_idx].to_i]
        question[:options].delete_at params[:a_idx].to_i
        @task.questions = questions
        @task.save!
        question
      end
      
      #   "task"=>{"questions"=>{
      #     "0"=>{"question"=>"If a=1, b=2. What is a+b?"
      #       ,"option"=>{
      #         "0"=>{"answer"=>"12"}
      #        ,"1"=>{"check"=>"3", "answer"=>"3"}
      #        ,"2"=>{"answer"=>"4"}}}
      #    ,"1"=>{"question"=>"Ruby ia a", "option"=>{"0"=>{"check"=>"dynamic language", "answer"=>"dynamic language"}, "1"=>{"check"=>"cool", "answer"=>"cool"}, "2"=>{"answer"=>"none of the above"}}}, "2"=>{"question"=>"Consider the following:      I. An eight-by-eight chessboard.   II. An eight-by-eight chessboard with two opposite corners removed.  III. An eight-by-eight chessboard with all four corners removed.Which of these can be tiled by two-by-one dominoes (with no overlaps or gaps, and every domino contained within the board)?", "option"=>{"0"=>{"answer"=>"I only"}, "1"=>{"answer"=>"I and II only"}, "2"=>{"check"=>"I and III only", "answer"=>"I and III only"}}}, ":index"=>{"question"=>""}}}, "commit"=>"edit", "id"=>"4"}
      #
      # "question":"If a=1, b=2. What is a+b?"
      # "points":1
      # "options":[{"answer":"12","check":false}]
      def setup_questions_ary
        if params[:task_type].blank?
          param_task_key = :task
        else
          param_task_key = params[:task_type].to_sym
        end
        return if params[param_task_key][:questions].nil?
        # exception is thrown after loop through all questions because
        # question-setup is still needed in error-view
        invalid_format = false
        questions_ary = []
        cur_index = 0
        while ((cur_question = params[param_task_key][:questions][(cur_index).to_s]) != nil)
          cur_question_hash = { question: cur_question[:question], points: cur_question[:points] }
          
          if cur_question[:option].present?
            options_ary = []
            # "options":[{"answer":"12","check":false},{"answer":"3","check":true},{"answer":"4","check":false}]
            cur_index_2 = 0
            while ((cur_answer = cur_question[:option][(cur_index_2).to_s]) != nil)
              options_ary << { answer: cur_answer[:answer], check: !cur_answer[:check].blank? }
              cur_index_2 += 1
            end
            cur_question_hash[:options] = options_ary
          else
            invalid_format = true unless invalid_format
          end
          questions_ary << cur_question_hash
          cur_index += 1
        end
        params[param_task_key][:questions] = questions_ary
        raise 'can\'t be saved without at least one answer' if invalid_format
      end
      
      def set_time_limit_secs model_key = :game, attr_key = :time_limit
        if params[model_key][attr_key].blank? || (params[model_key][attr_key] == '00:00:00')
          params[model_key][attr_key] = nil
        else
          formatted_duration_matcher = params[model_key][attr_key].match(/^([0-9]+):([0-9]+):([0-9]+)$/)
          unless formatted_duration_matcher.nil?
            num_secs = 0
            formatted_duration_matcher.captures.reverse!.each_with_index{|e,i|num_secs+=e.to_i*60**i}
          else
            num_secs = params[model_key][attr_key].to_i
          end
          params[model_key][attr_key] = num_secs
        end
      end
      

      def set_reward_and_restriction
        set_rewards
        set_restrictions
      end

      def set_rewards
        params[:game][:points] = 0 if params[:game][:points].blank?
        params[:game][:reward_badge_id] = (params[:game][:reward_badge_id][0].blank? || params[:game][:reward_badge_id].blank?) ? nil : params[:game][:reward_badge_id][0]
      end

      def set_restrictions
        params[:game][:restriction_points] = 0 if params[:game][:restriction_points].blank?
        params[:game][:restriction_badge_id] = (params[:game][:restriction_badge_id][0].blank? || params[:game][:restriction_badge_id].blank?) ? nil : params[:game][:restriction_badge_id][0]
      end
      
    end

end
