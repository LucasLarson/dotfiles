module DiffHelper
  def extract_submodule_revisions(diff_result)
    diff_result[:lines].map do |line| 
      line[:text].gsub("Subproject commit ", "")
    end
  end

  def htmlize_highlight_trailing_whitespace (text)
    if text =~ /[ \t]+$/
      htmlize($`) + content_tag(:span, $&, :class => "trailing-whitespace")
    else
      htmlize(text)
    end
  end
end