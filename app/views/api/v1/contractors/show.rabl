object @contractor
	attributes :company_street_no,:company_street_name,:company_unit_no,:company_building_name,:company_postal_code,:company_name_slug,:company_logo,
	:nirc_no,:uen_number,:bac_license,:hdb_license,:billing_name,:billing_address,:billing_postal_code,:billing_phone_no,:mobile_alerts,:rating,:company_description,:pub_license,:ema_license,:case_member,:scal_member,:bizsafe_member,:selected_header_image,:sms_count,:is_deactivated
child :account do
	attributes :id,:first_name,:last_name,:email,:role,:locale,:mobile_number,:deleted_at,:created_at,:updated_at,:suspended_at,:is_email_verified,:no_of_account,:uid,:provider
end
