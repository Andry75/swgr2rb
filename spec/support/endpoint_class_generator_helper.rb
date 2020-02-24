require_relative 'endpoint_class_config_helper'

module EndpointClassGeneratorHelper
  include EndpointClassConfigHelper

  def code_lines_regexp(lines)
    if lines.is_a?(Array)
      /#{lines.map { |line| escape_code_line(line) }.join("\n")}/
    else
      /#{escape_code_line(lines)}/
    end
  end

  private

  def escape_code_line(line)
    "\s*#{Regexp.escape(line.lstrip)}"
  end
end
