
    $('#frmSmsConfirmation').bootstrapValidator({
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            "account[mobile_number]" : {
               validators: {
                    notEmpty: {
                        message: 'The mobiler number is required'
                    },
                    regexp: {
                        regexp: /^\+\d{4,13}$/,
                        message: 'Mobile number is invalid.'
                    },
                    stringLength: {
                        min: 6,
                        message: 'The mobile number must have at least 8 characters'
                    }
                }
            }
        }
    });

    $('#frmSmsCode').bootstrapValidator({
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            "account[code]" : {
               validators: {
                    notEmpty: {
                        message: 'The confirmation code is required'
                    },
                    stringLength: {
                        min: 6,
                        message: 'The confirmation code must have at least 6 digit number'
                    }
                }
            }
        }
    });
