module EndpointClassConfigGeneratorHelper
  def build_default_json(definitions, paths)
    SwaggerJsonBuilder.new
                      .build_definitions(definitions)
                      .build_paths(paths)
                      .json
  end

  def stub_swagger_json(json)
    allow(Swgr2rb::SwaggerJsonFetcher)
      .to receive(:get_swagger_json)
      .with('')
      .and_return(json)
  end
end
