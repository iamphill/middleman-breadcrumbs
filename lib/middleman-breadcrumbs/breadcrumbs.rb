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
  option :link_last, true, 'Convert the last page into a link'

  expose_to_template :breadcrumbs

  def initialize(app, options_hash = {}, &block)
    super
    @separator = options.separator
    @wrapper = options.wrapper
    @hide_home = options.hide_home
    @link_last = options.link_last
  end

  def breadcrumbs(page, separator: @separator, wrapper: @wrapper, hide_home: @hide_home, link_last: @link_last)
    hierarchy = [page]
    hierarchy.unshift hierarchy.first.parent while hierarchy.first.parent

    if hide_home
      hierarchy.shift
    end

    hierarchy.collect.with_index do |page, i|
      if convert_last_to_link?(i, hierarchy.size, link_last)
        content_tag(:li, page.data.title)
      else
        wrap link_to(page.data.title, "#{page.url}"), wrapper: wrapper
      end
    end.join(h separator)
  end

  private

  def wrap(content, wrapper: nil)
    wrapper ? content_tag(wrapper) { content } : content
  end

  def convert_last_to_link?(page_index, size, link_last)
    if link_last
      return true
    end

    (page_index + 1) == size
  end
end
