class ApplicationFilter
  include ActiveModel::Model
  include ActiveModel::Dirty
  include ActiveModel::Attributes

  class << self
    def modifiers
      @modifiers ||= []
    end
  end

  def initialize(scope, parameters, options = {})
    super(parameters)

    @scope = scope
    @options = options
  end

  def call
    [ filter, results ]
  end

  private

  def filter
    return self unless changed?

    tap(&:valid?)
  end

  def results
    return @scope.none.page(1) if !changed? && @options.fetch(:allow_empty, false)
    return @scope.none.page(1) if invalid?

    self.class.modifiers.each do |modifier|
      @scope = modifier.call(@scope, self) || @scope
    end

    @scope
  end
end
