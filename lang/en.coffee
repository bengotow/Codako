en = {}

en.request =
	not_found: "The resource you requested does not exist."
	not_found_api: "You have reached the API, but we do not understand how to service your request."
	not_found_api_request_method: "The endpoint you requested exists, but you have an invalid HTTP method."
	not_authorized: "Not authorized"
	bad_json: "Content-type was assumed to be application/json, but the post body was not valid JSON. You should attach a content type if you intend to send FORM data."
	bad_json_in_form: "Form included a json element and it was not valid JSON."
	post_data_missing: "Post data not available"
	required_field_missing: "Required fields not included"
	required_field_malformed: "One or more of the required fields was malformed. Please check the API documentation."
	invalid_event_json: "The event JSON was not valid JSON: %"
	unexpected_error: "An unexpected error occurred."

en.stage =
	is_tutorial: 'Sorry, this stage is a tutorial and you cannot save changes.'

en.users =
	not_found_id: "Sorry, we weren't able to find an account with the ID you provided."
	not_found: "Sorry, we weren't able to find an account with the email or username you entered."
	password_incorrect: "Sorry, the password you provided was incorrect."

module.exports = en
