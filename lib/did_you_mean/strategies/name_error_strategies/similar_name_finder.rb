module DidYouMean
  class SimilarNameFinder
    include BaseFinder
    attr_reader :name, :_methods, :_local_variables, :original_message

    def initialize(exception)
      @name             = exception.name
      @_methods         = exception.frame_binding.eval("methods")
      @_local_variables = exception.frame_binding.eval("local_variables")
      @original_message = exception.original_message
    end

    def words
      local_variable_names + method_names
    end

    alias target_word name

    def local_variable_names
      _local_variables.map {|word| LocalVariableName.new(word.to_s) }
    end

    def method_names
      _methods.map {|word| MethodName.new(word.to_s) }
    end

    def similar_methods
      similar_words.select{|word| word.is_a?(MethodName) }
    end

    def similar_local_variables
      similar_words.select{|word| word.is_a?(LocalVariableName) }
    end

    def empty?
      !undefined_local_variable_or_method? || super
    end

    def undefined_local_variable_or_method?
      original_message.include?("undefined local variable or method")
    end

    private

    def format(word)
      "#{word.prefix}#{word}"
    end

    class MethodName < String
      def prefix; "#"; end
    end

    class LocalVariableName < String
      def prefix; ""; end
    end
  end
end
