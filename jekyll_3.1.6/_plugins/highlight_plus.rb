module Jekyll
  module Tags
    class HighlightBlock < Liquid::Block

      # The regular expression syntax checker. Start with the language specifier.
      # Follow that by zero or more space separated options that take one of three
      # forms: name, name=value, or name="<quoted list>"
      #
      # value can include letters, numbers, and any of .+'-_
      # <quoted list> is a space-separated list of numbers
      SYNTAX = %r!^([a-zA-Z0-9.+#-]+)((\s+\w+(=([a-zA-Z0-9.+'-_]+|"([0-9]+\s)*[0-9]+"))?)*)$!

      def initialize(tag_name, markup, tokens)
        super
        if markup.strip =~ SYNTAX
          @lang = Regexp.last_match(1).downcase
          @highlight_options = parse_options(Regexp.last_match(2))
        else
          raise SyntaxError, <<-eos
Syntax Error in tag 'highlight' while parsing the following markup:
  #{markup}
Valid syntax: highlight <lang> [linenos]
eos
        end
      end

      def parse_options(input)
        options = {}
        unless input.empty?
          # Split along 3 possible forms -- key="<quoted list>", key=value, or key
          input.scan(%r!(?:\w="[^"]*"|\w=[a-zA-Z0-9.+'-_]+|\w)+!) do |opt|
            key, value = opt.split("=")
            # If a quoted list, convert to array
            if value && value.include?("\"")
              value.delete!('"')
              value = value.split
            end
            options[key.to_sym] = value || true
          end
        end
        if options.key?(:linenos) && options[:linenos] == true
          options[:linenos] = "inline"
        end
        options
      end

      def add_code_tag(code)
        code_attributes = [
          "class=\"language-#{@lang.to_s.tr("+", "-")}\"",
          "data-lang=\"#{@lang}\""
        ].join(" ")
        if @highlight_options.key?(:nolabel)
          figcaption = ""
        else
          caption_text = @highlight_options.key?(:filename) ? @highlight_options[:filename] : @lang
          figcaption = "<figcaption>#{caption_text}</figcaption>"
        end
        "<figure class=\"highlight\">#{figcaption}"\
        "<pre><code #{code_attributes}>"\
        "#{code.chomp}</code></pre></figure>"
      end
    end
  end
end

Liquid::Template.register_tag("highlight", Jekyll::Tags::HighlightBlock)

# tested until Jekyll v.??
# if get Syntax error in "highlight", may have to restart server. Not my fault.
