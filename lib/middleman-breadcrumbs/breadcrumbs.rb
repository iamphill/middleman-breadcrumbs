require 'middleman'
require File.join(File.dirname(__FILE__), 'version')
require 'rack/utils'
require 'padrino-helpers'

class Breadcrumbs < Middleman::Extension
  include BreadcrumbsVersion
  include Padrino::Helpers

  option :separator, ' > ', 'Default separator between breadcrumb levels'
  option :wrapper, nil, 'Name of tag (as symbol) in which to wrap each breadcrumb level, or nil for no wrapping'
  option :hide_home, false, 'Hide the homepage link'
  option :convert_last, true, 'Convert the last page into a link'

  expose_to_template :breadcrumbs

  def initialize(app, options_hash = {}, &block)
    super
    @separator = options.separator
    @wrapper = options.wrapper
    @hide_home = options.hide_home
    @convert_last = options.convert_last
  end

  def breadcrumbs(page, separator: @separator, wrapper: @wrapper, hide_home: @hide_home, convert_last: @convert_last)
    hierarchy = [page]
    hierarchy.unshift hierarchy.first.parent while hierarchy.first.parent
    hierarchy.collect.with_index do |page, i|
      if show_page(i, hide_home)
        if convert_last_to_link(i, hierarchy.size, convert_last)
          content_tag(:li, page.data.title)
        else
          wrap link_to(page.data.title, "#{page.url}"), wrapper: wrapper
        end
      end
    end.join(h separator)
  end

  private

  def wrap(content, wrapper: nil)
    wrapper ? content_tag(wrapper) { content } : content
  end

  def show_page(page_index, hide_home)
    return true unless hide_home
    return true unless page_index == 0
  end

  def convert_last_to_link(page_index, size, convert_last)
    return false unless !convert_last
    return true if (page_index + 1) == size
  end
end
