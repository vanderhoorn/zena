class NodeController < ApplicationController
  layout 'popup'
  helper MainHelper
  # test to here
  def test
    if request.get?
      @node = secure(Page) { Page.find(params[:id]) }
    else
      @node = secure(Page) { Page.find(params[:id]) }
      params[:node][:tag_ids] = [] unless params[:node][:tag_ids]
      @node.update_attributes(params[:node])
    end
  end
  
  # TODO: test
  # modifications of the node itself (dates, groups, revert editions, etc)
  def drive
    if params[:version_id]
      @node = secure_drive(Node) { Node.version(params[:version_id]) }
      # store the id used to preview versions
      session[:preview_id] = params[:version_id]
    else
      @node = secure_drive(Node) { Node.find(params[:id]) }
    end
  rescue ActiveRecord::RecordNotFound
    page_not_found
  end
  
  # TODO: test
  def update
    attrs = params[:node]
    @node = secure(Node) { Node.find(params[:id]) }
    if attrs[:inherit]
      @update = 'groups'
    elsif attrs[:parent_id] || attrs[:name]
      if attrs[:name]
        @node[:name] = attrs[:name]
        attrs.delete(:name)
      end
      @update = 'parent'
    else
      @update = 'dates'
    end  
    parse_dates(attrs)
    @node.update_attributes(attrs)
    @node.save
  end

  # TODO: test
  def attribute
    method = params[:attr].to_sym
    if [:v_text, :v_summary, :name, :path].include?(method)
      if params[:id] =~ /^\d+$/
        @node = secure(Node) { Node.find(params[:id]) }
      else
        @node = secure(Node) { Node.find_by_name(params[:id]) }
        raise ActiveRecord::RecordNotFound unless @node
      end
      if method == :path
        render :inline=>@node.rootpath.join('/')
      else
        @text = @node.send(method)
        if [:v_text, :v_summary].include?(method)
          render :inline=>"<%= zazen(@text) %>"
        else
          render :inline=>@text
        end
      end
    else
      render :inline=>method
    end
  rescue ActiveRecord::RecordNotFound
    render :inline=>trans('not found')
  end
  
  
  # change to ?
  
  #if @node.type != params[:node][:type]
  #  @node = @node.change_to(eval "#{params[:node][:type]}")
  #end
end
