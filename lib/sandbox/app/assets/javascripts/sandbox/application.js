function setHost(host) {
    if ((host === undefined) || (host == null)) host = $('#host_form input[name=host]').attr('value')
    else  $('#host_form input[name=host]').attr('value', host)

    var linkList = $('#links a');
    for (i=0 ; i<linkList.length ; i++) {
        linkList[i].href = linkList[i].href.replace(/^([^\/]*)\/\/[^\/]+/, '$1'+'//'+host);
        linkList[i].innerHTML = linkList[i].innerHTML.replace(/([^\/]*)\/\/[^\/]+/, '$1'+'//'+host);
    }
}

/**
 * $('[name=authenticity_token]').filter(function(index){return $(this).closest('#'+formId+'_form').length >= 1}).first()
 */
function submitForm(formId, placeHolders, values, removeBeforeSubmitElements) {
    var host = $('#host_form input[name=host]').attr('value');
    //setHost(host);
    var targetForm = $('#'+formId+'_form');
    targetForm.attr('action', targetForm.attr('action').replace(':host', host));
    for (i=0 ; i<placeHolders.length ; i++) {
        targetForm.attr('action', targetForm.attr('action').replace(new RegExp(placeHolders[i]), values[i]));
    }
    if (formId == 'generic') {
        var postParams = $('#generic_postdata').val().split('&');
        for (i=0 ; i<postParams.length ; i++) {
            var pair = postParams[i].split('=');
            targetForm.append('<input type="hidden" name="'+pair[0]+'" value="'+pair[1]+'" />');
        }
        $('#generic_postdata').remove();
    }
    for (i=0 ; i<removeBeforeSubmitElements.length ; i++) {
        removeBeforeSubmitElements[i].remove();
    }

    $('#'+formId+'_submit').click();

    window.setTimeout("document.location.href = '/sandbox?host="+host+"';", 1000);
}

function toggleMethod(formId) {
    var targetForm = $('#'+formId+'_form');
    var method = $('input[name='+formId+'_method]:checked', targetForm).val();
    if (method == 'post') {
        targetForm.attr('method', 'post');
        $('#'+formId+'_put').remove();
    } else if (method == 'put') {
        targetForm.attr('method', 'post');
        targetForm.append('<input id="'+formId+'_put" type="hidden" name="_method" value="put" />');
    } else {
        alert('where you get this method?');
    }
}

function toggleAnswerType() {
    var targetForm = $('#answer_task_form');
    var type = $('input[name=answer_task_type]:checked', targetForm).val();
    var answer_task_input_text = $('#answer_task_input_text')
    var answer_task_input_file = $('#answer_task_input_file')
    var answer_task_input_mc = $('#answer_task_input_mc')
    if (type == 'text') {
        targetForm.removeAttr('enctype');
        answer_task_input_text.attr('style', 'display: block;');
        answer_task_input_file.attr('style', 'display: none;');
        answer_task_input_mc.attr('style', 'display: none;');
    } else if (type == 'photo') {
        targetForm.attr('enctype', 'multipart/form-data');
        answer_task_input_text.attr('style', 'display: none;');
        answer_task_input_file.attr('style', 'display: block;');
        answer_task_input_mc.attr('style', 'display: none');
    } else {
        targetForm.removeAttr('enctype');
        answer_task_input_text.attr('style', 'display: none;');
        answer_task_input_file.attr('style', 'display: none;');
        answer_task_input_mc.attr('style', 'display: block');
    }
}

/**
 * utility to remove invalid parameters from answer-task-form on submit
 */
function prepareAnswerTask() {
    var targetForm = $('#answer_task_form');
    var type = $('input[name=answer_task_type]:checked', targetForm).val();
    if (type == 'text') {
        $('#answer_with_answer_file').remove();
    } else if (type == 'photo') {
        $('#answer_with_answer_text').remove();
    } else {
        $('#answer_with_answer_file').remove();
    }
}

function addMCQuestion() {
    var n = 0;
    while ($('#answer_task_input_mc_question_'+(++n)).length >= 1) ;
    n--;
    var lastQuestionDiv = $('#answer_task_input_mc_question_'+n);
    var newQuestionDiv = document.createElement('div');
    newQuestionDiv.setAttribute('id', 'answer_task_input_mc_question_'+(n + 1));
    newQuestionDiv.innerHTML = lastQuestionDiv.html()
                               .replace(/question [0-9]+/, "question "+(n + 1))
                               .replace(/mc_q_[0-9]+/, "mc_q_"+n)
                               .replace(/\[answers\]\[[0-9]+\]/, "[answers]["+n+"]");
    lastQuestionDiv[0].parentNode.appendChild(newQuestionDiv);
}

function removeMCQuestion() {
    var n = 0;
    while ($('#answer_task_input_mc_question_'+(++n)).length >= 1) ;
    n -= 1;
    if (n == 1) return;
    $('#answer_task_input_mc_question_'+n).remove();
}
