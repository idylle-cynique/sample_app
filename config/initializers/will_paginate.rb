WillPaginate::ActionView::BootstrapLinkRenderer.class_eval do
  protected

  def previous_or_next_page(page, text, classname, aria_label = nil)
    tag :li,
        link(text, page || "#", "aria-label": aria_label),
        class: [(classname[0..3] if @options[:page_links]),
                (classname if @options[:page_links]),
                ("disabled" unless page)].join(" ")
  end
end
