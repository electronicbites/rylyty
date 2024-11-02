//= require active_admin/base

var gameEditor = {
	toggleCosts: function() {
		var curVal = $('#game_costs').attr('disabled');
	  	if (curVal == 'disabled') $('#game_costs').attr('disabled', false);
	  	else $('#game_costs').attr('disabled', 'disabled');
	},
  toggleReward: function() {
      var checked = $('#check_reward').attr('checked');
      if (checked == 'checked') {
          $('#game_points').attr('disabled', false);
          $('#game_reward_badge_id').attr('disabled', false);
      } else {
          $('#game_points').attr('disabled', 'disabled');
          $('#game_reward_badge_id').attr('disabled', 'disabled');
      }
  },
  toggleRestriction: function() {
      var checked = $('#check_restriction').attr('checked');
      if (checked == 'checked') {
          $('#game_restriction_points').attr('disabled', false);
          $('#game_restriction_badge_id').attr('disabled', false);
      } else {
          $('#game_restriction_points').attr('disabled', 'disabled');
          $('#game_restriction_badge_id').attr('disabled', 'disabled');
      }
  },
	addCategory: function() {
		var categoryValue = $('#new_category').attr('value');
		var form = $('#add_category_form');
		form.children().filter('input[name=new_category_name]').attr('value', categoryValue);
		form.submit();
	},
	addCategoryCallback: function(category_id, category_name) {
		var categoriesSelect = $('#tag_ids');
        var numOptions = categoriesSelect[0].options.length;
        if (numOptions >= 1) {
	       	for (var i=0 ; i<numOptions ; i++) {
	       		if (categoriesSelect[0].options[i].text >= category_name) {
			       	for (var k=(numOptions-1) ; k>=i ; k--) {
	       				categoriesSelect[0].options[k+1] = new Option(categoriesSelect[0].options[k].text, categoriesSelect[0].options[k].value, false, categoriesSelect[0].options[k].selected);
			       	}
	       			categoriesSelect[0].options[i] = new Option(category_name, new String(category_id), false, true);
	       			break;
	       		}
	       	}
        } else {
	    	categoriesSelect[0].options[0] = new Option(category_name, new String(category_id), false, true);
        }
	},
	setupTaskTypeInputs: function() {
		var taskTypeSelect = $('#task_type');
		var selectedTaskTypeOption = taskTypeSelect.find("option:selected").first();
		if (selectedTaskTypeOption.val() == 'multiple_choice_task') {
			// basic question
            $('#task_basic_question').remove();
			
			// multiple choice stuff
			$('#task_points').after($('#multiple_choice_task_inputs_template_minscore').html()
			                        .replace(/:mc_minimum_score/, 'mc_minimum_score')
                                    .replace(/:mc_questions/, 'mc_questions')
                                    .replace(/:add_q/, 'add_q'));
			gameEditor.addTaskTypeInput('q');
			gameEditor.addTaskTypeInput('a', 0);
		} else {
			// multiple choice stuff
			$('#mc_minimum_score').remove();
			$('.mc_question').filter(function(index){return $(this).closest('#multiple_choice_task_inputs_template_q').length == 0}).remove();
            $('#mc_questions').remove();
            $('#add_q').remove();
			
			// basic question
			if ($('#task_basic_question').length == 0) $('#task_points').after($('#task_basic_question_template').html().replace(/:task_basic_question/, 'task_basic_question'));
		}
	},
	addTaskTypeInput: function(sub_type, parent_id) {
		// task_type is a select before task is saved for the first time. after save this refers to a hidden input
		var taskTypeInput = $('#task_type');
		var taskTypeIsSelect = taskTypeInput.find("option").length >= 1;
		var taskType = taskTypeIsSelect ? taskTypeInput.find("option:selected").first().val() : taskTypeInput.val();
		
		if (taskType == 'multiple_choice_task') {
			var curDiv = null;
			var lastDiv = null;
			if (sub_type == 'q') {
				for (var i=0 ; true ; i++) {
					curDiv = $('#multiple_choice_task_questions_'+i+'_question');
					if (curDiv.length == 0) {
						var template = $('#multiple_choice_task_inputs_template_q');
						//var newQuestion = template.
						var newQuestionHtml = template.html()
											  .replace(/:index_\+_1/g, new String(i+1))
											  .replace(/:index/g, new String(i))
											  .replace(/:parent_id/g, new String(i));
						if (lastDiv != null) {
							lastDiv.closest('.mc_question').last().parent().append(newQuestionHtml);
						} else {
							$('#mc_questions').html(newQuestionHtml);
						}
						break;
					}
					lastDiv = curDiv;
				}
			} else if (sub_type == 'a') {
				for (var i=0 ; true ; i++) {
					curDiv = $('#multiple_choice_task_questions_'+parent_id+'_option_'+i+'_answer');
					if (curDiv.length == 0) {
						var template = $('#multiple_choice_task_inputs_template_a');
						//var newQuestion = template.
						var newAnswerHtml = template.html()
											.replace(/:parent_id/g, new String(parent_id))
											.replace(/:index/g, new String(i));
						if (lastDiv != null) {
							$('#answer_field_div_'+parent_id+'_'+(i-1)).after(newAnswerHtml);
						} else {
							$('#points_field_div_'+parent_id).after(newAnswerHtml);
						}
						break;
					}
					lastDiv = curDiv;
				}
			}
		}
	}
}
