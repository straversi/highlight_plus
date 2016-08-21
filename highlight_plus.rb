module Jekyll
  module Tags
    class HighlightBlock < Liquid::Block

      def add_code_tag(code)
        code_attributes = [
          "class=\"language-#{@lang.to_s.tr("+", "-")}\"",
          "data-lang=\"#{@lang}\""
        ].join(" ")
        "<figure class=\"highlight\"><figcaption>#{@lang}</figcaption>"\
        "<pre><code #{code_attributes}>"\
        "#{code.chomp}</code></pre></figure>"
      end
    end
  end
end

Liquid::Template.register_tag("highlight", Jekyll::Tags::HighlightBlock)
