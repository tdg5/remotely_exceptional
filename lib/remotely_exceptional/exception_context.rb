module RemotelyExceptional
  # Module used to identify those objects that can be used as a
  # RemotelyExceptional::ExceptionContext. An ExceptionContext is a template
  # code block that provides a template for executing code with certain kinds of
  # exception handling. Each ExceptionContext is specially
  # designed to handle specific kinds of exception situations. For example,
  # handling exceptions that utilize redo require a special exception context.
  module ExceptionContext
  end

  # Module used to namespace those objects that are provided by
  # RemotelyExceptional that can be used as a ExceptionContext.
  module ExceptionContexts
  end
end
