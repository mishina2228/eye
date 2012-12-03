class Eye::ChildProcess
  include Celluloid

  # needs: kill_process
  include Eye::Process::Commands

  # easy config + defaults: prepare_config, c, []
  include Eye::Process::Config

  # conditional watchers: start_checkers
  include Eye::Process::Watchers

  # system methods: send_signal
  include Eye::Process::System

  # logger methods: info, ...
  include Eye::Logger::Helpers

  attr_reader :pid, :name, :config, :watchers

  def initialize(pid, config = {}, logger = nil)
    raise "Empty pid" unless pid

    @pid = pid
    @config = prepare_config(config)
    @title = Eye::SystemResources.cmd(pid)
    @name = "child_#{pid}"

    prepare_logger(logger, "#{logger.prefix} child:#{pid}")
    
    @watchers = {}

    @queue = Celluloid::Chain.new(current_actor)

    debug "start monitoring CHILD config: #{@config.inspect}"

    start_checkers!
  end

  def stop
    kill_process
  end

  def restart
    stop
  end

  def monitor
  end

  def unmonitor
  end

  def remove
    remove_watchers
    @queue.terminate
    self.terminate
  end

  # All controller methods should call throught queue
  #   queue :start
  #   queue :stop
  def queue(command, reason = "")
    info "queue: #{command} #{reason}"
    @queue.add_no_dup(command)
  end

  def status_string
    "child(#{pid}): up\n"
  end
  
end