json.question_answers do
	json.array! @questions.each do |question|
		json.id question.id
		json.survey_id question.survey_id
		json.position question.position
		json.answer_options question.answer_options
		json.validation_rules question.validation_rules
		json.display_type question.type.sub("Rapidfire::Questions::", "")
	end
end
