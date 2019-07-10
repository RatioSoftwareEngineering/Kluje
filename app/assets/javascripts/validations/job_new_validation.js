$(document).ready(function() {
  $('#create_job')
    .bootstrapValidator({
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            "job[skill_id]" : {
                validators: {
                    notEmpty: {
                        message: "* Please select your contractor type."
                    }
                }
            },
            "job[job_category_id]" : {
                validators: {
                    notEmpty: {
                        message: "* Please select your job category."
                    }
                }
            },
            "job[availability_id]" : {
                validators: {
                    notEmpty: {
                        message: "* Please select when you want the job start."
                    }
                }
            },
            "job[budget_id]" : {
                validators: {
                    notEmpty: {
                        message: "* Please select your budget."
                    }
                }
            },
            "job[property_type]" : {
                validators: {
                    notEmpty: {
                        message: "* Please select your property type."
                    }
                }
            },
            "job[description]": {
                validators: {
                    notEmpty: {
                        message: 'Please describe the work you need done.'
                    },
                    stringLength: {
                        min: 30,
                        message: 'Your description must be at least 30 characters.'
                    }
                }
            },
            "job[contact_time]": {
                validators: {
                    notEmpty: {
                        message: 'Please enter your preferred contact time.'
                    }
                }
            },
            "job[mobile_number]": {
                validators: {
                    notEmpty: {
                        message: 'Please enter your phone number.'
                    },
		    regexp: {
			regexp: /\+?\d{6,13}/,
			message: 'Mobile number should contain only digits'
		    },
                    stringLength: {
                        min: 7,
                        message: 'Your phone number must be at least 7 digits.'
                    }
                }
            },
            "job[first_name]": {
                validators: {
                    notEmpty: {
                        message: 'Please enter your first name.'
                    },
                    regexp: {
                        regexp: /^[A-Za-z ]+$/,
                        message: 'First Name is invalid. Only characters allowed.'
                    }
                }
            },
            "job[last_name]": {
                validators: {
                    notEmpty: {
                        message: 'Please enter your last name.'
                    },
                    regexp: {
                        regexp: /^[A-Za-z ]+$/,
                        message: 'Last Name is invalid. Only characters allowed.'
                    }
                }
            },
            "job[email]": {
                validators: {
                    notEmpty: {
                        message: 'Please enter your email address.'
                    },
                    emailAddress: {
                        message: 'Please enter your valid email address.'
                    }
                }
            },
            "job[password]": {
                validators: {
                    notEmpty: {
                        message: 'Please enter your password.'
                    },
                    stringLength: {
                        min: 6,
                        message: 'Your password must be at least 6 digits.'
                    }
                }
            }
        }
    })
    .on('error.form.bv', function(e, data) {
      $('#error-div').html($("<span><strong style='font-size:16px;'>Please complete the form to continue.</strong></span>"));
      $('#error-div').show();
      $('#error-div').focus();
    });
    $('#error-div').hide();
});
