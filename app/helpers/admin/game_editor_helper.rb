module Admin::GameEditorHelper
  
  def secs_to_duration secs
    ss = secs.modulo(60)
    mm = ((secs-ss)/60).modulo(60)
    hh = (secs-mm*60-ss)/3600
    "#{hh.to_s.rjust(2,'0')}:#{mm.to_s.rjust(2,'0')}:#{ss.to_s.rjust(2,'0')}"
  end
  
  def game_index game_editor, task_editor
    game_editor ? 'admin/game_editor/game_editor' : task_editor ? 'admin/game_editor/task_editor' : 'admin/game_editor/list'
  end

  def render_multi_line_js render_hash, locals, format
    partial = render_hash[:partial]
    
    suffix = 'erb'
    path_name = Rails.root.join('app', 'views', 'admin', 'game_editor', "_#{partial}.#{format}.#{suffix}")
    if !File.exist?(path_name)
      suffix = 'haml'
    end
    erb_in = File.open(Rails.root.join('app', 'views', 'admin', 'game_editor', "_#{partial}.#{format}.#{suffix}"), 'r') {|file|file.read}
    
    case suffix
    when 'erb'
      erb = ERB.new(erb_in)
    when 'haml'
      erb = Haml::Engine.new(erb_in)
    end
    
    locals_os = OpenStruct.new(locals.merge(helper: self, request: request))
    class << locals_os
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::FormHelper
      attr_accessor :game, :task
      #
      def render args
        partial = args[:partial].gsub(/.+?\/([^\/]+)$/, '\1')
        args.delete(:partial)
        return helper.render_multi_line_js({partial: partial}, args, 'html')
      end
      #
      def method_missing method, *args
        named_route_matcher = method.to_s.match(/^(.+?)_path$/)
        unless named_route_matcher.nil?
          journey_route = request.env['action_dispatch.routes'].named_routes[named_route_matcher[1].to_s]
          result_path = journey_route.format(args[0])
          query_params = args[0].delete_if{|k,v|journey_route.required_keys.include?(k)}.to_a.collect{|k_v|"#{k_v[0]}=#{k_v[1]}"}.join('&')
          return result_path.concat('?').concat(query_params)
        end
        if method.to_s == 't'
          return I18n.translate(args[0])
        end
        super.method_missing method, *args
      end
    end
    locals_os.game = @game
    locals_os.task = @task
    
    case suffix
    when 'erb'
      erb.result(locals_os.instance_eval { binding }).gsub(/\n/, ' ')
    when 'haml'
      erb.render(locals_os, locals).gsub(/\n/, ' ').gsub(/(?<=\()'/,'_SAVED_APOS_').gsub(/'\)/,'_SAVED_APOS_)').gsub(/(?<!\\)'/,'"').gsub(/_SAVED_APOS_/,'\'')
    end
  end

end
