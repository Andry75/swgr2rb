Given(/^I send "([^"]*)" request to "([^"]*)"(?: with using results of ([^"]*) request to "([^"]*)" endpoint)?$/) do |request_type, endpoint_name, sub_request_type, sub_endpoint_name|
  request_type = request_type.sub(' ', '_')
  endpoint_instances["#{request_type}_#{endpoint_name}"] = eval("#{endpoint_name.split(' ').map(&:capitalize).join}.new")
  if sub_request_type && sub_endpoint_name
    sub_results = endpoint_instances["#{sub_request_type}_#{sub_endpoint_name}"].results
  else
    sub_results = {}
  end
  endpoint_instances["#{request_type}_#{endpoint_name}"].send_request(request_type, nil, sub_results)
end

Given(/^I send "([^"]*)" request to "([^"]*)" with the following properties(?: with using results of ([^"]*) request to "([^"]*)" endpoint)?:$/) do |request_type, endpoint_name, sub_request_type, sub_endpoint_name, table|
  request_type = request_type.sub(' ', '_')
  endpoint_instances["#{request_type}_#{endpoint_name}"] = eval("#{endpoint_name.split(' ').map(&:capitalize).join}.new")
  if sub_request_type && sub_endpoint_name
    sub_results = endpoint_instances["#{sub_request_type}_#{sub_endpoint_name}"].results
  else
    sub_results = {}
  end
  endpoint_instances["#{request_type}_#{endpoint_name}"].send_request(request_type,
                                                                      table.hashes.first, sub_results)
end

Given(/^I send "([^"]*)" request to "([^"]*)"(?: with the following properties)? with using results of the following requests:$/) do |request_type, endpoint_name, table|
  request_type = request_type.sub(' ', '_')
  endpoint_instances["#{request_type}_#{endpoint_name}"] = eval("#{endpoint_name.split(' ').map(&:capitalize).join}.new")
  sub_results = {}
  table.hashes.first[:sub_requests].split(/;\s*/).map do |sub_request_str|
    match_data = sub_request_str.match(/^(?<request_type>\w+) (?<endpoint_name>.+)$/)
    sub_results[match_data[:endpoint_name]] = endpoint_instances["#{match_data[:request_type]}_#{match_data[:endpoint_name]}"].results
  end
  params = table.hashes.first.reject { |k, _v| k.to_sym == :sub_requests }
  endpoint_instances["#{request_type}_#{endpoint_name}"].send_request(request_type, params, sub_results)
end

And(/^the response schema for "([^"]*)" request to "([^"]*)" endpoint should be valid$/) do |request_type, endpoint_name|
  request_type = request_type.sub(' ', '_')
  endpoint_instances["#{request_type}_#{endpoint_name}"].validate_response_schema
end

And(/^the error response for "([^"]*)" request to "([^"]*)" endpoint should be valid with ([^"]*) code$/) do |request_type, endpoint_name, error_code|
  request_type = request_type.sub(' ', '_')
  endpoint_instances["#{request_type}_#{endpoint_name}"].validate_error_response(error_code.to_i)
end

And(/^I wait (\d+) seconds/) do |seconds|
  sleep(seconds)
end

And(/^I (do|do not do) this: (.*[^:])$/) do |do_or_not, step_str|
  step step_str if do_or_not == 'do'
end

And(/^I (do|do not do) this: (.*:)$/) do |do_or_not, step_str, table|
  step step_str, table if do_or_not == 'do'
end
