require 'optparse'

class Optparsewrapper
  def initialize()
    @subcommandParsers={}
    @options={}
  end

  def getOptFun(banner, args, is_subcmd)
    lambda do | rawOpts |
      begin
        op=OptionParser.new do |opts|
          opts.banner=banner
          opts.on("-h", "--help", "show usage string") do |v|
            puts opts
            exit
          end
          args.each do | o |
            if o[4]
              @options[o[1]]=o[4]
            end
            if o[0]
              opts.on("-#{o[2]}#{o[1].upcase}", "--#{o[1]}=#{o[1].upcase}", o[3]) do |v|
                @options[o[1]]=v
              end
            else
              opts.on("-#{o[2]}", "--#{o[1]}", o[3]) do |v|
                @options[o[1]]=v
              end
            end
          end
        end
        if is_subcmd
          op.parse! rawOpts
        else
          op.order! rawOpts
        end
      rescue OptionParser::InvalidOption => e
        puts e
        puts @g_usage
        exit 1
      end
    end
  end

  def setGlobalUsage(usage)
    @g_usage=usage
    @globalParser=getOptFun(@g_usage, [], false)
  end

  def addSubcommand(cmd, banner, argTable)
    @subcommandParsers[cmd] = getOptFun(banner, argTable, true)
  end

  def handle_cmd_line(argv)
    # set the argument variable
    cmdline_args=argv

    # all the global options
    @globalParser.call(cmdline_args)

    # shift to the subcommand name
    subcommand=cmdline_args.shift

    if subcommand.nil?
      puts "No command specified"
      puts @g_usage
      exit 1
    end

    if @subcommandParsers[subcommand].nil?
      puts "Invalid Sub-command"
      puts @g_usage
      exit 1
    end

    @subcommandParsers[subcommand].call(cmdline_args)
    yield subcommand, @options, cmdline_args
  end
end
