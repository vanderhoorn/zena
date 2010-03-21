module Zena
  module Use
    module Display
      module ViewMethods
        include RubyLess::SafeClass
        safe_method [:title, Node, {'actions' => String,'class' => String, 'status' => String}] => String
=begin
        def title(node, opts = {})
          if node.kind_of?(Version)
            node = node.node
          end
          title_params = {}

          title_params[:check_lang] = @params[:check_lang] if @params.include?(:check_lang)

          if @params[:link]
            value, static = parse_attributes_in_value(@params[:link], :erb => false)
            link_param = ", :link=>\"#{value}\""
          else
            link_param = ''
          end

          res = "<%= show_title(:node=>#{node}#{link_param}#{params_to_erb(title_params)}"
          if @params[:text]
            res << ", :text=>#{@params[:text].inspect}"
          elsif @params[:attr]
            res << ", :text=>#{node_attribute(@params[:attr])}"
          end

          if @params.include?(:project)
            res << ", :project=>#{@params[:project] == 'true'}"
          end
          res << ")"
          if @params[:actions]
            res << " + node_actions(:node=>#{node}#{params_to_erb(:actions=>@params[:actions], :publish_after_save=>auto_publish_param)})"
          end
          res << "%>"
          res
        end
          # TODO: test
          # display the title with necessary id and checks for 'lang'. Options :
          # * :link if true, the title is a link to the object's page
          #   default = true if obj is not the current node '@node'
          # * :project if true , the project name is added before the object title as 'project / .....'
          #   default = obj project is different from current node project
          # if no options are provided show the current object title
          def title(obj, opts={})

            unless opts.include?(:link)
              # we show the link if the object is not the current node or when it is being created by zafu ajax.
              opts[:link] = (obj[:id] != @node[:id] || params[:t_url]) ? 'true' : nil
            end

            unless opts.include?(:project)
              opts[:project] = (obj.get_project_id != @node.get_project_id && obj[:id] != @node[:id])
            end

            title = opts[:text] || obj.version.title
            if opts[:project] && project = obj.project
              title = "#{project.name} / #{title}"
            end

            title += check_lang(obj) unless opts[:check_lang] == 'false'
            title  = "<span id='v_title#{obj.zip}'>#{title}</span>"

            if (link = opts[:link]) && opts[:link] != 'false'
              if link =~ /\A(\d+)/
                zip = $1
                obj = secure(Node) { Node.find_by_zip(zip) }
                link = link[(zip.length)..-1]
                if link[0..0] == '_'
                  link = link[1..-1]
                end
              end
              if link =~ /\Ahttp/
                "<a href='#{link}'>#{title}</a>"
              else
                link_opts = {}
                if link == 'true'
                  # nothing special for the link format
                elsif link =~ /(\w+\.|)data$/
                  link_opts[:mode] = $1[0..-2] if $1 != ''
                  if obj.kind_of?(Document)
                    link_opts[:format] = obj.c_ext
                  else
                    link_opts[:format] = 'html'
                  end
                elsif link =~ /(\w+)\.(\w+)/
                  link_opts[:mode]   = $1
                  link_opts[:format] = $2
                elsif !link.blank?
                  link_opts[:mode]   = link
                end
                "<a href='#{zen_path(obj, link_opts)}'>#{title}</a>"
              end
            else
              title
            end
          end
      end
=end
      end # ViewMethods

      module ZafuMethods
        include Zena::Use::Display::Links::ZafuMethods
        
        def r_show
          return parser_error("Unknown attribute '#{@params[:attr]}'") unless type = node.klass.safe_method_type([@params[:attr]])
          klass = type[:class]
          method = "#{node}.#{type[:method]}"
          if klass.ancestors.include?(String)
            show_string(method)
          elsif klass.ancestors.include?(Time)
            show_time(method)
          else
            parser_error("Invalid type: #{type[:class]}")
          end
        end

        def show_string(method)
          display = "<%= #{method} %>"
          if @params[:live] == 'true'
            "<span id='_#{@params[:attr]}<%= #{node}.zip %>'>#{display}</span>"
          else
            display
          end
        end
      end
    end # Display
  end # Use
end # Zena