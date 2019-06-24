survey = @questions.first.survey if @questions.present?
if survey.present?
	json.survey_id survey.id
	json.survey_title survey.name
end
json.question_answers do
	json.array! @questions.each do |question|
		json.id question.id
		json.title question.question_text
		json.position question.position
		json.answer_options question.answer_options
		json.validation_rules question.validation_rules
		json.display_type question.type.sub("Rapidfire::Questions::", "")
	end
end