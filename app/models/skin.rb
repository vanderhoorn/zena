# A skin is a master template containing all sub templates and css to render a full site or sectioon
# of a site.
class Skin < Template
  
  def template_url_for_name(template_name, helper)
    raise Exception.new('helper should not be nil!') unless (helper || ENV["RAILS_ENV"] == "test")
    if template_name == 'any'
      template = self
      zafu_url = "/#{self[:name]}/any"
    else
      template = secure(Template) { Template.find(:first, :conditions=>["parent_id = ? AND name = ?", self[:id], template_name])}
      zafu_url = "/#{self[:name]}/#{template_name}"
    end
    tmpl_name = "#{template_name}_#{visitor.lang}"
    tmpl_dir = "/templates/compiled/#{self[:name]}"
    FileUtils::mkpath("#{RAILS_ROOT}/app/views#{tmpl_dir}")
    # render for the current lang
    res = ZafuParser.new_with_url(zafu_url, :helper=>helper).render
    File.open("#{RAILS_ROOT}/app/views#{tmpl_dir}/#{tmpl_name}.rhtml", "wb") { |f| f.syswrite(res) }
    return "#{tmpl_dir}/#{tmpl_name}"
  rescue ActiveRecord::RecordNotFound
    nil
  end
  
  def template_for_path(path)
    asset_for_path(path, Template)
  end
  
  
  def asset_for_path(path, klass=Node)
    current = self
    if path == 'any'
      return current
    else  
      path = path.split('/')
      while path != []
        template_name = path.shift
        current = secure(klass) { klass.find(:first, :conditions=>["parent_id = ? AND name = ?", current[:id], template_name])}
      end
      current
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end
end