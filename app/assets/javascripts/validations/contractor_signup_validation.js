$(document).ready(function() {
    $('#frmContractor')
        .bootstrapValidator({
            feedbackIcons: {
                valid: 'glyphicon glyphicon-ok',
                invalid: 'glyphicon glyphicon-remove',
                validating: 'glyphicon glyphicon-refresh'
            },
            fields: {
                "account[contractor_attributes][company_name]" : {
                   validators: {
                        notEmpty: {
                            message: "* Please enter the company name!"
                        }
                    }
                },
                 "account[contractor_attributes][uen_number]" : {
                    validators: {
                        notEmpty: {
                            message: "* Please enter the Business Registration Number (UEN)"
                        }
                    }
                },
                "account[password_confirmation]": {
                    validators: {
                        notEmpty: {
                            message: 'Please enter the password confirmation.'
                        },
                        identical: {
                          field: 'password',
                           message: 'The password and its confirm are not the same'
                        }
                    }
                },
                "account[mobile_number]": {
                    validators: {
                        notEmpty: {
                            message: 'The mobiler number is required'
                        },
                        regexp: {
                            regexp: /^[896][0-9]{7}$/,
                            message: 'Phone number is invalid.'
                        },
                        stringLength: {
                            min: 6,
                            message: 'The phone number must have at least 8 characters'
                        }
                    }
                },
                "account[first_name]": {
                    validators: {
                        notEmpty: {
                            message: 'Please enter the first name'
                        }
                    }
                },
                "account[last_name]": {
                    validators: {
                        notEmpty: {
                            message: 'Please enter the last name'
                        }
                    }
                },
                "account[email]": {
                    validators: {
                        notEmpty: {
                            message: 'Please enter the email address'
                        },
                        emailAddress: {
                            message: 'The email address is not a valid'
                        }
                    }
                },
                "account[password]": {
                    validators: {
                        notEmpty: {
                            message: 'Please enter the password'
                        },
                        stringLength: {
                            min: 6,
                            message: 'The password must have at least 6 characters'
                        }
                    }
                }
            }
        })
        .on('error.form.bv', function(e, data) {
          $('#error-div').html($("<span><strong style='font-size:16px;'>Please complete the from to continue.</strong></span>"));
          $('#error-div').show();
          $('#error-div').focus();
        })
        $('#error-div').hide();
});
