# FIXME: rewrite !
class CommentsController < ApplicationController
  before_filter :find_comment, :except => [:create]
  before_filter :find_node_and_discussion
  before_filter :check_is_admin, :only=>[:index, :empty_bin]
  helper_method :bin_content
  
  # TODO: test
  def reply_to
    @reply_to   = Comment.find(params[:id])
    @discussion = @reply_to.discussion
    @node = secure(Node) { Node.find(@discussion[:node_id]) }
    if @node && @node.can_comment?
      @comment = Comment.new(:reply_to=>@reply_to[:id], :discussion_id=>@discussion[:id])
    else
      render :nothing=>true
    end
  end
  
  
  def create
    @discussion.save if @discussion.new_record? && @node.can_comment?
    
    @comment = secure!(Comment) { Comment.create(filter_attributes(params[:comment])) }
    
    respond_to do |format|
      if @comment.errors.empty?
        flash[:notice] = _('Comment was successfully created.')
        format.html { redirect_to zen_path(@node) } # TODO: add ':sharp => ...'
        format.js
        format.xml  { head :created, :location => comment_path(@node) } 
      else
        format.html { render :action => "new" }
        format.js
        format.xml  { render :xml => @comment.errors.to_xml }
      end
    end
  end
  
  # TODO: test
  def edit
    @comment    = Comment.find(params[:id])
    @discussion = @comment.discussion
    @node = secure(Node) { Node.find(@discussion[:node_id]) }
    @edit = true
    unless @node && @node.can_comment? && @comment[:user_id] == visitor.id
      render :nothing=>true
    end
  end
  

  def update
    @comment.update_attributes(params[:comment])
  
    respond_to do |format|
      format.html { redirect_to zen_path(@node) }
      format.js
      format.xml  { head :updated, :location => comment_path(@node) }
    end
  end

  # TODO: test
  def remove
    @comment    = Comment.find(params[:id])
    @discussion = @comment.discussion
    @node = secure(Node) { Node.find(@discussion[:node_id]) }
    if @node && visitor.is_admin? || @node.can_drive?
      @comment.remove
    else
      render :nothing=>true
    end
  end
  
  # TODO: test
  def publish
    @comment    = Comment.find(params[:id])
    @discussion = @comment.discussion
    @node = secure_drive(Node) { Node.find(@discussion[:node_id]) }
    if @node
      @comment.publish
    else
      render :nothing=>true
    end
  end
  ### === admin only
  
  # TODO:test
  def index
    @node = visitor.contact
    @comment_pages, @comments =
          paginate :comments, :order => 'status ASC, created_at DESC', :conditions=>"status > #{Zena::Status[:rem]}", :per_page => 20
    render :layout=>admin_layout
  end
  
  # TODO: test
  def empty_bin
    bin_content.each do |c|
      c.destroy
    end
    # reset cached bin content
    @bin_content = nil
  end
  
  private
    def find_comment
      @comment = secure!(Comment) { Comment.find(params[:id]) }
      @discussion = @comment.discussion
      @node = @discussion.node
    end
    
    def find_node_and_discussion
      @node ||= secure!(Node) { Node.find_by_zip(params[:node_id]) }
      @discussion ||= @node.discussion
    end
    
    def bin_content
      @bin_content ||= Comment.find(:all, :conditions=>['status <= ?', Zena::Status[:rem]])
    end
    
    def filter_attributes(attributes)
      attrs = attributes.dup
      attrs['author_name']   = nil unless visitor.is_anon? # only anonymous user should set 'author_name'
      attrs['discussion_id'] = @discussion[:id]
      attrs['user_id']       = visitor[:id]
      attrs
    end
end
